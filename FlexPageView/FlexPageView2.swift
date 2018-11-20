//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class FlexPageView2: UIView, UIScrollViewDelegate {
    
    //界面
    var scrollView: UIScrollView = UIScrollView()
    var menuView: MenuView = {
        var option = MenuViewOption()
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.5
        let view = MenuView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 40), option: option)
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var pagesDic: [Int: LLCollectionCell] = [:]
    
    //数据
    weak var dataSource: SelfDefineCollectionViewDataSource? {
        didSet {
            //加载数据
            reloadData()
        }
    }
    
    var numberOfPage: Int?
    var currentIndex: Int = 0
    let cacheRange: Int = 1
    var titles: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //UI
        addSubview(menuView)
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        menuView.dataSource = menuView
        menuView.delegate = menuView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        numberOfPage = dataSource?.numberOfPage()
        scrollView.contentSize = CGSize(width: CGFloat(numberOfPage ?? 0) * frame.width, height: 0)
        
        //清空scrollview的子view
        for view in scrollView.subviews {
            if view is LLCollectionCell {
                view.removeFromSuperview()
            }
        }
        
        //menuview
        if let titles = dataSource?.titles() {
            assert(titles.count == numberOfPage)
            self.titles = titles
            menuView.reloadTitles(titles)
        }
        
        currentIndex = 0
        constructPages()
        let indexPath = IndexPath(item: currentIndex, section: 0)
        menuView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: menuView.frame.height)
        scrollView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: frame.width, height: frame.height - menuView.frame.maxY)
        scrollView.contentSize = CGSize(width: CGFloat(numberOfPage ?? 0) * frame.width, height: 0)
        
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
        
        menuView.changeUIWithPrecent(leftIndex: scrollViewCurrentLeftIndex, precent: precent, direction: direction)
        
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
        let indexPath = IndexPath(item: currentIndex, section: 0)
        menuView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewCurrentIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        if scrollViewCurrentIndex != currentIndex {
            //滑动速度非常快的时候，会出现scrollViewWillEndDragging中预测的targetContentOffset和实际停止的contentOffset不同，这里做一下兼容
            currentIndex = scrollViewCurrentIndex
            
            constructPages()
            let indexPath = IndexPath(item: currentIndex, section: 0)
            menuView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func constructPages() {
        let beginIndex = max(currentIndex - cacheRange, 0)
        let endIndex = min(currentIndex + cacheRange, (numberOfPage ?? 1) - 1)
        
        for index in beginIndex...endIndex {
            if let pageView = getPage(at: index) {
                scrollView.addSubview(pageView)
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
    
    // MARK: 选中处理
    func menuHadSelectIndex(_ index: Int) {
        currentIndex = index
        
        constructPages()
    }
    
    
    func layoutPageViews() {
        //调整page在scrollview中的位置
        for (index, pageView) in pagesDic {
            pageView.frame = CGRect(x: CGFloat(index) * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        }
    }    
}

enum Direction {
    case left
    case right
}
