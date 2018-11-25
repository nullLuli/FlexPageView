//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/25.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

struct FlexPageViewOption {
    static let NormalScale: CGFloat = 1
    
    var titleFont: CGFloat = 15
    var titleMargin: CGFloat = 30
    var allowSelectedEnlarge: Bool = false
    var selectedScale: CGFloat = 1
    var selectedColor: UIColor = UIColor.blue
    var titleColor: UIColor = UIColor.black
    var showUnderline: Bool = true
    var underlineWidth: CGFloat = 10
    var underlineHeight: CGFloat = 2
    var underlineColor: UIColor = UIColor.blue
    
    var defaultSelectIndex: Int = 0
    var menuViewHeight: CGFloat = 40
}

protocol FlexPageViewDataSource: ContentViewDataSource {
    func numberOfPage() -> Int
    func titles() -> [String]
}

class FlexPageView2: UIView, MenuViewProtocol, ContentViewProtocol {
    var currentIndex: Int
    
    var menuView: MenuView
    var contentView: ContentView
    
    var dataSource: FlexPageViewDataSource? {
        didSet {
            contentView.dataSource = dataSource
            reloadData()
        }
    }
    
    
    init(option: FlexPageViewOption = FlexPageViewOption()) {
        menuView = MenuView(frame: CGRect(x: 0, y: 0, width: 0, height: option.menuViewHeight), option: option)
        contentView = ContentView(defaultIndex: option.defaultSelectIndex)
        currentIndex = option.defaultSelectIndex
        
        super.init(frame: CGRect.zero)
        
        addSubview(menuView)
        addSubview(contentView)
        menuView.menuViewDelegate = self
        contentView.contentViewDelegate = self
        contentView.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        let numberOfPage = dataSource?.numberOfPage() ?? 0
        
        contentView.reloadData(numberOfPage: numberOfPage)
        
        //menuview
        if let titles = dataSource?.titles() {
            assert(titles.count == numberOfPage)
            menuView.reloadTitles(titles)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: menuView.frame.height)
        contentView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: frame.width, height: frame.height - menuView.frame.maxY)
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
        
        contentView.selectItem(at: index)
    }
}
