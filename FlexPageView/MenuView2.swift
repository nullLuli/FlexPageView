//
//  MenuView2.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import Foundation
import UIKit

protocol IMenuView {
    func reloadTitles(_ titles: [String])
    func toIndex(_ index: Int)
    func move(preIndex: Int, nextIndex: Int, precent: CGFloat)
}

protocol MenuViewItemProtocol {
    func select()
    func unselect()
}//希望在UIview的基础上加条protocol，该怎么办呢

class MenuView2: UIView {
    weak var flexPageView: FlexPageView?
    
    var scrollView: UIScrollView = UIScrollView()
    var views: [UIButton] = []
    var titles: [String] = []
    
    //状态相关
    var selectedIndex: Int?
    
    //固定值
    let titleWidth: CGFloat = 80
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        var i: Int = 0
        for view in views {
            view.frame = CGRect(x: CGFloat(i) * titleWidth, y: 0, width: titleWidth, height: scrollView.frame.height)
            i += 1
        }
    }
    
    func reloadTitles(_ titles: [String]) {
        self.titles = titles
        scrollView.contentSize = CGSize(width: CGFloat(titles.count) * scrollView.frame.width, height: 0)
        
        for view in scrollView.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        views = []
        
        var i: Int = 0
        
        for title in titles {
            /*
             优化的最终形态：
             每个title对应的view外包出去
             view对应的位置做成layout，给一个默认的layout，也可以允许自定义layout
             */
            //需要计算titleview的宽度，这里先随便给一个
            let view = UIButton()
            view.setTitle(title, for: .normal)
            view.setTitle(title, for: .selected)
            view.setTitleColor(UIColor.red, for: .selected)
            view.setTitleColor(UIColor.gray, for: .normal)
            scrollView.addSubview(view)
            views.append(view)
            
            i += 1
        }
    }
    
    /*
     scrollview的状态：scrollview的偏移，UI变化
     */
    func changeOffsetTo(index: Int) {
        if let preIndex = selectedIndex, preIndex < views.count {
            if preIndex == index { return }
            let view = views[preIndex]
            view.isSelected = false
        }
        
        if index < views.count {
            let view = views[index]
            view.isSelected = true
            selectedIndex = index
            
            var offsetX = view.frame.midX - (scrollView.frame.width / 2) //滚到scrollview中间
            offsetX = max(offsetX, 0)
            if scrollView.contentSize.width > scrollView.frame.width {
                offsetX = min(offsetX, scrollView.contentSize.width - scrollView.frame.width)
            }
            scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
        }
    }
    
    func changeUIWithPrecent(leftIndex: Int, precent: CGFloat) {
        guard leftIndex < views.count, leftIndex >= -1 else { return }
        if leftIndex > -1 {
            let leftView = views[leftIndex]
            let leftScale = 1 + ( (1 - precent) * 0.5)
            leftView.transform = CGAffineTransform.identity.scaledBy(x: leftScale, y: leftScale)
        }
        
        let rightIndex = leftIndex + 1
        if rightIndex < views.count {
            let rightView = views[rightIndex]
            let rightScale = 1 + (precent * 0.5)
            rightView.transform = CGAffineTransform.identity.scaledBy(x: rightScale, y: rightScale)
        }
    }
}
