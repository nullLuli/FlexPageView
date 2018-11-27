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
    var cacheRange: Int = 1
}

protocol FlexPageViewDataSource: PageContentViewDataSource {
    func numberOfPage() -> Int
    func titleDatas() -> [IMenuViewCellData]
}

protocol FlexPageViewUISource: MenuViewUISource {
}

class FlexPageView2<CellData: IMenuViewCellData>: UIView, MenuViewProtocol, PageContentViewProtocol {
    var menuView: MenuView<CellData>
    var contentView: PageContentView
    
    weak var dataSource: FlexPageViewDataSource? {
        didSet {
            contentView.dataSource = dataSource
            reloadData()
        }
    }
    weak var uiSource: FlexPageViewUISource?
    
    init(option: FlexPageViewOption = FlexPageViewOption(), uiSource: FlexPageViewUISource? = nil, layout: MenuViewBaseLayout? = nil) {
        menuView = MenuView(frame: CGRect(x: 0, y: 0, width: 0, height: option.menuViewHeight), option: option, uiSource: uiSource, layout: layout)
        contentView = PageContentView(option: option)
        
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
        if let titles = dataSource?.titleDatas() as? [CellData] {
            assert(titles.count == numberOfPage)
            menuView.reloadTitles(titles)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: menuView.frame.height)
        contentView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: frame.width, height: frame.height - menuView.frame.maxY)
    }
    
    func updateScrollingUIFromPageContentView(leftIndex: Int, precent: CGFloat, direction: Direction) {
        menuView.updateScrollingUI(leftIndex: leftIndex, precent: precent, direction: direction)
    }
    
    func selectItemFromPageContentView(select index: Int) {
        menuView.selectItem(at: index)
    }
    
    func selectItemFromTapMenuView(select index: Int) {
        contentView.selectItem(at: index)
    }
}
