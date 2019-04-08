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

class PageContentView: UIScrollView, UIScrollViewDelegate {
    
    struct PageView {
        var view: UIView
        var id: String
        var parallaxPrecent: CGFloat
    }
    
    weak var pageChangeDelegate: PageContentViewPageChangeProtocol?
    weak var userInteractionDelegate: PageContentViewUserInteractionProtocol?
    
    weak var dataSource: PageContentViewDataSource?
    
    var pagesIndexDic: [Int: PageView] = [:]
    
    var numberOfPage: Int?
    var currentIndex: Int
    
    var option: FlexPageViewOption
    
    enum PageContentViewCacheType {
        //有两种缓存命中模式，一种是在数据源没有变化的情况下，使用pageDics进行对比index来决定是否命中缓存，另一种是在数据源有变化的情况下，使用外界提供的对比方法来决定是否命中
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
    
    func reloadData(numberOfPage: Int) {
        self.numberOfPage = numberOfPage
        contentSize = CGSize(width: CGFloat(numberOfPage) * frame.width, height: 0)
        
        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillDisappear(view, at: currentIndex)
        }
        
        constructPages(cacheType: .hitByContent)
        
        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillAppear(view, at: currentIndex)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentSize = CGSize(width: CGFloat(numberOfPage ?? 0) * frame.width, height: 0)
        layoutPageViews()
    }
    
    // MARK: 滑动处理
    var lastOffsetX: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollFinalOffset = targetContentOffset.pointee
    }
    
    // 在scrollViewDidEndDragging中使用constructPages、pageWillAppear会因为controller的init和网络数据解析影响界面流畅度
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let scrollViewCurrentIndex = getScrollViewCurrentIndex(scrollView)
            scrollViewDidEndScroll(scrollView, scrollViewCurrentIndex: scrollViewCurrentIndex)
            resetParallaxAnimate()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    func selectItem(at index: Int) {
        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillDisappear(view, at: currentIndex)
        }
        
        currentIndex = index
        
        let offsetX = CGFloat(currentIndex) * frame.width
        contentOffset = CGPoint(x: offsetX, y: contentOffset.y)
        
        constructPages(cacheType: .hitByIndex)
        
        resetParallaxAnimate()

        if let view = pagesIndexDic[currentIndex]?.view {
            pageChangeDelegate?.pageWillAppear(view, at: currentIndex)
        }
    }
    
    // MARK: 根据index组织显示页
    private func constructPages(cacheType: PageContentViewCacheType) {
        let beginIndex = max(currentIndex - option.preloadRange, 0)
        let endIndex = min(currentIndex + option.preloadRange, (numberOfPage ?? 1) - 1)
        
        let cachePages = Array(pagesIndexDic.values)
        if endIndex >= beginIndex {
            for index in beginIndex...endIndex {
                if let id = dataSource?.pageID(at: index) {
                    var pageView: PageView?
                    switch cacheType {
                    case .hitByIndex:
                        pageView = hitCacheByIndex(index: index)
                    case .hitByContent:
                        pageView = hitCacheByContent(id: id, cachedPageViews: cachePages)
                    }
                    
                    if pageView == nil {
                        if let view = dataSource?.page(at: index) {
                            pageView = PageView(view: view, id: id, parallaxPrecent: 0)
                            pagesIndexDic[index] = pageView
                        }
                    }
                    
                    if let pageView = pageView?.view {
                        addSubview(pageView)
                    }
                }
            }
        }
        
        let cacheBeginIndex = max(currentIndex - option.cacheRange, 0)
        let cacheEndIndex = min(currentIndex + option.cacheRange, (numberOfPage ?? 1) - 1)
        clearPageBeyondCache(cacheBegin: cacheBeginIndex, cacheEnd: cacheEndIndex)
        
        layoutPageViews()
    }
    
    private func hitCacheByIndex(index: Int) -> PageView? {
        return pagesIndexDic[index]
    }
    
    private func hitCacheByContent(id: String, cachedPageViews: [PageView]) -> PageView? {
        return cachedPageViews.first { (pageView) -> Bool in
            return pageView.id == id
        }
    }
    
    private func clearPageBeyondCache(cacheBegin bIndex: Int, cacheEnd eIndex: Int) {
        for (index, pageView) in pagesIndexDic {
            if index < bIndex || index > eIndex {
                pagesIndexDic[index] = nil
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
            if var page = pagesIndexDic[rightIndex] {
                page.parallaxPrecent = (precent - 1) * option.parallaxPrecent
                pagesIndexDic[rightIndex] = page
            }
        case .right:
            //左边的view有视差效果 parallax: 0.5 - 0 precent: 1 - 0
            if var page = pagesIndexDic[leftIndex] {
                page.parallaxPrecent =  precent * option.parallaxPrecent
                pagesIndexDic[leftIndex] = page
            }
        }
    }
    
    private func resetParallaxAnimate() {
        for (index, pageView) in pagesIndexDic {
            var pageView = pageView
            pageView.parallaxPrecent = 0
            pagesIndexDic[index] = pageView
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
