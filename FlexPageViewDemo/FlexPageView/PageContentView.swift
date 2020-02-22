//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

public protocol PageContentViewDataSource: class {
    func page(at index: Int) -> UIView
    func pageID(at index: Int) -> String
}
public protocol PageContentViewPageChangeProtocol: class {
    func didRemovePage(_ page: UIView, at index: Int)
    func pageWillAppear(_ page: UIView, at index: Int)
    func pageWillDisappear(_ page: UIView, at index: Int)
}

internal protocol PageContentViewUserInteractionProtocol: class {
    func selectItemFromPageContentView(select index: Int)
    func updateScrollingUIFromPageContentView(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection)
}

public class PageContentView: UIScrollView, UIScrollViewDelegate {
    
    class PageView {
        var view: UIView
        var id: String
        var parallaxPrecent: CGFloat
        var reused: Bool
        
        required init(view: UIView, id: String, parallaxPrecent: CGFloat, reused: Bool = false) {
            self.view = view
            self.id = id
            self.parallaxPrecent = parallaxPrecent
            self.reused = reused
        }
    }
    
    weak var pageChangeDelegate: PageContentViewPageChangeProtocol?
    weak var userInteractionDelegate: PageContentViewUserInteractionProtocol?
    
    weak var dataSource: PageContentViewDataSource?
    
    var pagesIndexDic: [Int: PageView] = [:]
    
    var numberOfPage: Int?
    var currentIndex: Int
    
    var option: FlexPageViewOption
    
    /// There are two cache hit modes. One is to use pageDics to compare the index to determine whether to hit the cache when the data source has not changed, and the other is to use the comparison method provided by the outside world to change the data source. Decide whether to hit
    enum PageContentViewCacheType {
        case hitByIndex
        case hitByContent
    }
    
    init(option: FlexPageViewOption) {
        currentIndex = option.defaultSelectIndex
        self.option = option
        
        super.init(frame: CGRect.zero)
        
        //UI
        delegate = self
        isPagingEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(numberOfPage: Int, selectIndex: Int) {
        self.numberOfPage = numberOfPage
        contentSize = CGSize(width: CGFloat(numberOfPage) * frame.width, height: 0)
        
        selectItem(at: selectIndex, cacheType: .hitByContent)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        contentSize = CGSize(width: CGFloat(numberOfPage ?? 0) * frame.width, height: 0)
        layoutPageViews()
    }

    
    // MARK: 滑动处理
    var lastOffsetX: CGFloat = 0
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else { return }
        //判断现在的滑动位置：left index， precent
        let scrollViewCurrentLeftIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        let precent = (scrollView.contentOffset.x - (CGFloat(scrollViewCurrentLeftIndex) * scrollView.frame.width)) / scrollView.frame.width
        
        var direction: FlexPageDirection
        if lastOffsetX < scrollView.contentOffset.x {
            direction = .left
        } else {
            direction = .right
        }
        lastOffsetX = scrollView.contentOffset.x
        
        parallaxAnimate(leftIndex: scrollViewCurrentLeftIndex, precent: precent, direction: direction)
        userInteractionDelegate?.updateScrollingUIFromPageContentView(leftIndex: scrollViewCurrentLeftIndex, precent: precent, direction: direction)
    }
    
    var scrollFinalOffset: CGPoint = CGPoint.zero
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollFinalOffset = targetContentOffset.pointee
    }
    
    // 在scrollViewDidEndDragging中使用constructPages、pageWillAppear会因为controller的init和网络数据解析影响界面流畅度
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let scrollViewCurrentIndex = getScrollViewCurrentIndex(scrollView)
            scrollViewDidEndScroll(scrollView, scrollViewCurrentIndex: scrollViewCurrentIndex)
            resetParallaxAnimate()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetParallaxAnimate()
        let scrollViewCurrentIndex = getScrollViewCurrentIndex(scrollView)
        if scrollViewCurrentIndex != currentIndex {
            //滑动速度非常快的时候，会出现scrollViewWillEndDragging中预测的targetContentOffset和实际停止的contentOffset不同，这里做一下处理
            scrollViewDidEndScroll(scrollView, scrollViewCurrentIndex: scrollViewCurrentIndex)
        }
    }
    
    private func scrollViewDidEndScroll(_ scrollView: UIScrollView, scrollViewCurrentIndex: Int) {
        guard scrollViewCurrentIndex != currentIndex else { return }
        
        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillDisappear(view, at: currentIndex)
        }
        
        currentIndex = scrollViewCurrentIndex
        
        constructPages(cacheType: .hitByIndex)
        userInteractionDelegate?.selectItemFromPageContentView(select: currentIndex)
        
        if let currentPage = pagesIndexDic[currentIndex]?.view {
            bringSubviewToFront(currentPage) //将当前页面置于最上方，为了实现Parallax效果
        }
        
        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillAppear(view, at: currentIndex)
        }
    }
    
    private func getScrollViewCurrentIndex(_ scrollView: UIScrollView) -> Int {
        guard let numberOfPage = numberOfPage else { return option.defaultSelectIndex }
        var scrollViewCurrentIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        if scrollViewCurrentIndex < 0 {
            scrollViewCurrentIndex = 0
        }
        if scrollViewCurrentIndex >= numberOfPage {
            scrollViewCurrentIndex = numberOfPage - 1
        }
        return scrollViewCurrentIndex
    }
    
    // MARK: 选中处理
    func selectItem(at index: Int, cacheType: PageContentViewCacheType = .hitByIndex) {
        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillDisappear(view, at: currentIndex)
        }
        
        currentIndex = index
        
        let offsetX = CGFloat(currentIndex) * frame.width
        contentOffset = CGPoint(x: offsetX, y: contentOffset.y)
        
        constructPages(cacheType: cacheType)
        
        if let currentPage = pagesIndexDic[currentIndex]?.view {
            bringSubviewToFront(currentPage) //将当前页面置于最上方，为了实现Parallax效果
        }
        
        resetParallaxAnimate()

        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillAppear(view, at: currentIndex)
        }
    }
    
    // MARK: 根据index组织显示页
    private func constructPages(cacheType: PageContentViewCacheType) {
        resetReuseState()
        let cachedPageDic = pagesIndexDic
        pagesIndexDic.removeAll()
        
        //proload
        let beginIndex = max(currentIndex - option.preloadRange, 0)
        let endIndex = min(currentIndex + option.preloadRange, (numberOfPage ?? 1) - 1)
        if endIndex >= beginIndex {
            for index in beginIndex...endIndex {
                if let id = dataSource?.pageID(at: index) {
                    var pageView: PageView?
                    switch cacheType {
                    case .hitByIndex:
                        pageView = hitCacheByIndex(index: index, cachedPageDic: cachedPageDic)
                    case .hitByContent:
                        pageView = hitCacheByContent(id: id, cachedPageViews: Array(cachedPageDic.values))
                    }
                    
                    if let pageView = pageView {
                        pageView.reused = true
                        pagesIndexDic[index] = pageView
                    } else {
                        if let view = dataSource?.page(at: index) {
                            let pageView = PageView(view: view, id: id, parallaxPrecent: 0, reused: true)
                            pagesIndexDic[index] = pageView
                            addSubview(pageView.view)
                        }
                    }
                }
            }
        }
        //cache
        let cacheBeginIndex = max(currentIndex - option.cacheRange, 0)
        let cacheEndIndex = min(currentIndex + option.cacheRange, (numberOfPage ?? 1) - 1)
        if cacheEndIndex >= cacheBeginIndex {
            for index in cacheBeginIndex...cacheEndIndex {
                if let _ = pagesIndexDic[index] {
                    continue
                }
                var pageView: PageView?
                switch cacheType {
                case .hitByIndex:
                    pageView = hitCacheByIndex(index: index, cachedPageDic: cachedPageDic)
                case .hitByContent:
                    if let id = dataSource?.pageID(at: index) {
                        pageView = hitCacheByContent(id: id, cachedPageViews: Array(cachedPageDic.values))
                    }
                }
                
                if let pageView = pageView {
                    pageView.reused = true
                    pagesIndexDic[index] = pageView
                }
            }
        }
        
        clearUnusePage(cachedPageDic: cachedPageDic)
        
        layoutPageViews()
    }
    
    private func hitCacheByIndex(index: Int, cachedPageDic: [Int: PageView]) -> PageView? {
        return cachedPageDic[index]
    }
    
    private func hitCacheByContent(id: String, cachedPageViews: [PageView]) -> PageView? {
        return cachedPageViews.first { (pageView) -> Bool in
            return pageView.id == id && !pageView.reused
        }
    }
    
    private func resetReuseState() {
        for item in pagesIndexDic.values {
            item.reused = false
        }
    }
    
    private func clearUnusePage(cachedPageDic: [Int: PageView]) {
        for (index, pageView) in cachedPageDic {
            if !pageView.reused {
                pageView.view.removeFromSuperview()
                pageChangeDelegate?.didRemovePage(pageView.view, at: index)
            }
        }
    }
    
    
    func layoutPageViews() {
        //调整page在scrollview中的位置
        for (index, pageView) in pagesIndexDic {
            pageView.view.frame = CGRect(x: (CGFloat(index) + pageView.parallaxPrecent) * frame.width, y: 0, width: frame.width, height: frame.height)
        }
    }
    
    //MARK: 滑动动效
    private func parallaxAnimate(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection) {
        switch direction {
        case .left:
            //右边的view有视差效果 parallax: -0.5 - 0 precent: 0 - 1
            let rightIndex = leftIndex + 1
            pagesIndexDic[rightIndex]?.parallaxPrecent = (precent - 1) * option.parallaxPrecent
        case .right:
            //左边的view有视差效果 parallax: 0.5 - 0 precent: 1 - 0
            pagesIndexDic[leftIndex]?.parallaxPrecent =  precent * option.parallaxPrecent
        }
    }
    
    private func resetParallaxAnimate() {
        for item in pagesIndexDic.values {
            item.parallaxPrecent = 0
        }
    }
    
    var currentPage: UIView? {
        return pagesIndexDic[currentIndex]?.view
    }
}

enum FlexPageDirection {
    case left
    case right
}
