//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

protocol ContentViewDataSource: class {
    func page(at index: Int) -> LLCollectionCell
}
protocol ContentViewProtocol: class {
    func selectItemFromScrollPageView(select index: Int)
    func updateScrollingUIFromScrollPageView(leftIndex: Int, precent: CGFloat, direction: Direction)
}

class ContentView: UIScrollView, UIScrollViewDelegate {
    
    weak var contentViewDelegate: ContentViewProtocol?
    
    weak var dataSource: ContentViewDataSource?
    
    var pagesDic: [Int: LLCollectionCell] = [:]
    
    var numberOfPage: Int?
    var currentIndex: Int
    
    var option: FlexPageViewOption
    
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
    
    // MARK: 滑动处理
    var lastOffsetX: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //判断现在的滑动位置：left index， precent
        let scrollViewCurrentLeftIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        let precent = (scrollView.contentOffset.x - (CGFloat(scrollViewCurrentLeftIndex) * scrollView.frame.width)) / scrollView.frame.width
        
        var direction: Direction
        if lastOffsetX < scrollView.contentOffset.x {
            direction = .left
        } else {
            direction = .right
        }
        lastOffsetX = scrollView.contentOffset.x

        contentViewDelegate?.updateScrollingUIFromScrollPageView(leftIndex: scrollViewCurrentLeftIndex, precent: precent, direction: direction)
    }
    
    var scrollFinalOffset: CGPoint = CGPoint.zero
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollFinalOffset = targetContentOffset.pointee
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //检查是不是缓存范围的page都显示
        currentIndex = Int(scrollFinalOffset.x / scrollView.frame.width)

        constructPages()
        contentViewDelegate?.selectItemFromScrollPageView(select: currentIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewCurrentIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        if scrollViewCurrentIndex != currentIndex {
            //滑动速度非常快的时候，会出现scrollViewWillEndDragging中预测的targetContentOffset和实际停止的contentOffset不同，这里做一下处理
            currentIndex = scrollViewCurrentIndex
            
            constructPages()
            contentViewDelegate?.selectItemFromScrollPageView(select: currentIndex)
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
    private func constructPages() {
        let beginIndex = max(currentIndex - option.cacheRange, 0)
        let endIndex = min(currentIndex + option.cacheRange, (numberOfPage ?? 1) - 1)
        
        for index in beginIndex...endIndex {
            if let pageView = getPage(at: index) {
                addSubview(pageView)
            }
        }
        
        clearPageBeyondCache(cacheBegin: beginIndex, cacheEnd: endIndex)
        
        layoutPageViews()
    }
    
    private func getPage(at index: Int) -> LLCollectionCell? {
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
    
    private func clearPageBeyondCache(cacheBegin bIndex: Int, cacheEnd eIndex: Int) {
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
