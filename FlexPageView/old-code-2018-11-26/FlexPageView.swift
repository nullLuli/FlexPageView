//
//  SelfDefineCollectionView.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import UIKit
import Foundation

@objc protocol SelfDefineCollectionViewDataSource {
    @objc func numberOfPage() -> Int
    @objc func titles() -> [String]
    @objc func page(at index: Int) -> LLCollectionCell
}

protocol IFlexPageView {
    func menuHadSelectIndex(_ index: Int)
    var dataSource: SelfDefineCollectionViewDataSource? {get set}
}

//TODO: 定义一个缓存策略

class LLCollectionCell: UIView {
}

class FlexPageView: UIView, UIScrollViewDelegate {
    
    //界面
    var scrollView: UIScrollView = UIScrollView()
    var menuView: MenuView2 = MenuView2()
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //UI
        addSubview(menuView)
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        menuView.flexPageView = self
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
            menuView.reloadTitles(titles)
        }
        
        currentIndex = 0
        constructPages()
        menuView.selectIndex(currentIndex)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 40)
        scrollView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: frame.width, height: frame.height - menuView.frame.maxY)
        scrollView.contentSize = CGSize(width: CGFloat(numberOfPage ?? 0) * frame.width, height: 0)
        
        layoutPageViews()
    }
    
    //滑动处理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //判断现在的滑动位置：left index， precent
        let scrollViewCurrentLeftIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))
        let precent = (scrollView.contentOffset.x - (CGFloat(scrollViewCurrentLeftIndex) * scrollView.frame.width)) / scrollView.frame.width
        
        menuView.changeUIWithPrecent(leftIndex: scrollViewCurrentLeftIndex, precent: precent)
    }
    
    var scrollFinalOffset: CGPoint = CGPoint.zero
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollFinalOffset = targetContentOffset.pointee
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //检查是不是缓存范围的page都显示
        currentIndex = Int(scrollFinalOffset.x / scrollView.frame.width)
        
        debugPrint("断页--- \(currentIndex)")
        constructPages()
        menuView.changeOffsetTo(index: currentIndex)
        menuView.selectIndex(currentIndex)
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

extension UIColor {
    //返回随机颜色
    open class var randomColor: UIColor{
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}

