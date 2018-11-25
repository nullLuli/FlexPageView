//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

protocol PageViewDataSource: class {
    func page(at index: Int) -> LLCollectionCell
}

protocol FlexPageViewDataSource: PageViewDataSource {
    func numberOfPage() -> Int
    func titles() -> [String]
}

protocol PageViewProtocol: class {
    func selectItemFromScrollPageView(select index: Int)
    func updateScrollingUIFromScrollPageView(leftIndex: Int, precent: CGFloat, direction: Direction)
}

class FlexPageView2: UIView, MenuViewProtocol, PageViewProtocol {
    var currentIndex: Int = 0
    
    var pageView: PageView = PageView()
    
    var dataSource: FlexPageViewDataSource? {
        didSet {
            pageView.dataSource = dataSource
            reloadData()
        }
    }
    
    var menuView: MenuView = {
        var option = MenuViewOption()
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.5
        let view = MenuView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 40), option: option)
        view.backgroundColor = UIColor.white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(menuView)
        addSubview(pageView)
        menuView.menuViewDelegate = self
        pageView.pageViewDelegate = self
        pageView.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        let numberOfPage = dataSource?.numberOfPage() ?? 0
        
        pageView.reloadData(numberOfPage: numberOfPage)
        
        //menuview
        if let titles = dataSource?.titles() {
            assert(titles.count == numberOfPage)
            menuView.reloadTitles(titles)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: menuView.frame.height)
        pageView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: frame.width, height: frame.height - menuView.frame.maxY)
    }
    
    func updateScrollingUIFromScrollPageView(leftIndex: Int, precent: CGFloat, direction: Direction) {
        menuView.updateScrollingUI(leftIndex: leftIndex, precent: precent, direction: direction)
    }
    
    func selectItemFromScrollPageView(select index: Int) {
        currentIndex = index

        menuView.selectItem(at: index)
    }
    
    func selectItemFromTapMenuView(select index: Int) {
        currentIndex = index
        
        pageView.selectItem(at: index)
    }
}

class PageView: UIScrollView, UIScrollViewDelegate {
    
    weak var pageViewDelegate: PageViewProtocol?
    
    weak var dataSource: PageViewDataSource?
    
    var pagesDic: [Int: LLCollectionCell] = [:]
    
    var numberOfPage: Int?
    var currentIndex: Int = 0
    let cacheRange: Int = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        //清空scrollview的子view
        for view in subviews {
            if view is LLCollectionCell {
                view.removeFromSuperview()
            }
        }
        
        constructPages()        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentSize = CGSize(width: CGFloat(numberOfPage ?? 0) * frame.width, height: 0)
        layoutPageViews()
    }
    
    //滑动处理
    var lastOffsetX: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //判断现在的滑动位置：left index， precent
        let scrollViewCurrentLeftIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
//        debugPrint("leftindex \(scrollViewCurrentLeftIndex)")
        let precent = (scrollView.contentOffset.x - (CGFloat(scrollViewCurrentLeftIndex) * scrollView.frame.width)) / scrollView.frame.width
        
        var direction: Direction
        if lastOffsetX < scrollView.contentOffset.x {
            direction = .left
        } else {
            direction = .right
        }
        
        pageViewDelegate?.updateScrollingUIFromScrollPageView(leftIndex: scrollViewCurrentLeftIndex, precent: precent, direction: direction)
        
        lastOffsetX = scrollView.contentOffset.x
    }
    
    var scrollFinalOffset: CGPoint = CGPoint.zero
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollFinalOffset = targetContentOffset.pointee
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //检查是不是缓存范围的page都显示
        currentIndex = Int(scrollFinalOffset.x / scrollView.frame.width)

        constructPages()
        pageViewDelegate?.selectItemFromScrollPageView(select: currentIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewCurrentIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        if scrollViewCurrentIndex != currentIndex {
            //滑动速度非常快的时候，会出现scrollViewWillEndDragging中预测的targetContentOffset和实际停止的contentOffset不同，这里做一下兼容
            currentIndex = scrollViewCurrentIndex
            
            constructPages()
            pageViewDelegate?.selectItemFromScrollPageView(select: currentIndex)
        }
    }
    
    // MARK: 选中处理
    func selectItem(at index: Int) {
        currentIndex = index
        
        let offsetX = CGFloat(currentIndex) * frame.width
        contentOffset = CGPoint(x: offsetX, y: contentOffset.y)
        
        constructPages()
    }

    // MARK: 根据index组织显示页
    func constructPages() {
        let beginIndex = max(currentIndex - cacheRange, 0)
        let endIndex = min(currentIndex + cacheRange, (numberOfPage ?? 1) - 1)
        
        for index in beginIndex...endIndex {
            if let pageView = getPage(at: index) {
                addSubview(pageView)
            }
        }
        
        clearPageBeyondCache(cacheBegin: beginIndex, cacheEnd: endIndex)
        
        layoutPageViews()
    }
    
    func getPage(at index: Int) -> LLCollectionCell? {
        var pageView = pagesDic[index]
        if pageView == nil {
            pageView = dataSource?.page(at: index)
            pageView?.backgroundColor = UIColor.randomColor
            if let pageView = pageView {
                pagesDic[index] = pageView
            }
        }
        
        return pageView
    }
    
    func clearPageBeyondCache(cacheBegin bIndex: Int, cacheEnd eIndex: Int) {
        for (index, pageView) in pagesDic {
            if index < bIndex || index > eIndex {
                pagesDic[index] = nil
                pageView.removeFromSuperview()
            }
        }
        
        // TODO: 需要取消网络请求
    }
    

    func layoutPageViews() {
        //调整page在scrollview中的位置
        for (index, pageView) in pagesDic {
            pageView.frame = CGRect(x: CGFloat(index) * frame.width, y: 0, width: frame.width, height: frame.height)
        }
    }    
}

enum Direction {
    case left
    case right
}
