//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/25.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

public struct FlexPageViewOption {
    public static let NormalScale: CGFloat = 1
    
    public var titleFont: CGFloat = 15
    public var titleMargin: CGFloat = 30
    public var allowSelectedEnlarge: Bool = false
    public var selectedScale: CGFloat = 1.2
    public var selectedColor: UIColor = UIColor.blue
    public var titleColor: UIColor = UIColor.black
    public var showUnderline: Bool = true
    public var underlineWidth: CGFloat = 10
    public var underlineHeight: CGFloat = 2
    public var underlineColor: UIColor = UIColor.blue

    public var parallaxPrecent: CGFloat = 0 //滑动切换页面时的视差动效
    
    public var defaultSelectIndex: Int = 0
    public var menuViewHeight: CGFloat = 40
    public var cacheRange: Int = 2   //缓存
    public var preloadRange: Int = 0 //预加载
    //这样会有个问题，缓存一定要大于预加载，不然预加载完了会因为不在缓存范围被清除。也就是contentview没能力标明该页面是属于预加载还是缓存
    
    public var showExtraView = true
    public var extraImageName = ""
    public var extraImageSize: CGSize = CGSize.zero
    public var extraMaskImageName = ""
    public var extraMaskImageSize: CGSize = CGSize.zero
    
    public init() {}
}

public protocol FlexPageViewDataSource: PageContentViewDataSource {
    func numberOfPage() -> Int
    func titleDatas() -> [IMenuViewCellData]
}

public protocol FlexPageViewDelegate: PageContentViewPageChangeProtocol {
    func extraViewAction()
}

public protocol FlexPageViewUISource: MenuViewUISource {
}

public class FlexPageView<CellData: IMenuViewCellData>: MenuViewProtocol, PageContentViewUserInteractionProtocol {
    private var menuView: FlexMenuView<CellData>
    private var contentView: PageContentView
    
    private var option: FlexPageViewOption
    
    public weak var uiSource: FlexPageViewUISource? {
        didSet {
            menuView.menuViewUISource = uiSource
        }
    }
    
    public weak var dataSource: FlexPageViewDataSource? {
        didSet {
            contentView.dataSource = dataSource
            reloadData()
        }
    }
    
    //delegate需要在datasource赋值前赋值，因为datasource赋值后会reloaddata，reloaddata中用到了delegate
    public weak var delegate: FlexPageViewDelegate? {
        didSet {
            contentView.pageChangeDelegate = delegate
        }
    }
    
    public init(option: FlexPageViewOption = FlexPageViewOption(), layout: MenuViewBaseLayout? = nil) {
        menuView = FlexMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: option.menuViewHeight), option: option, layout: layout)
        contentView = PageContentView(option: option)
        self.option = option
        
        menuView.menuViewDelegate = self
        contentView.userInteractionDelegate = self
        contentView.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addMenuViewTo(view: UIView) {
        view.addSubview(menuView)
    }
    
    public func addContentViewTo(view: UIView) {
        view.addSubview(contentView)
    }
    
    public func setMenuViewFrame(_ frame: CGRect) {
        menuView.frame = frame
    }
    
    public func setContentViewFrame(_ frame: CGRect) {
        contentView.frame = frame
    }
    
    public func reloadData() {
        let numberOfPage = dataSource?.numberOfPage() ?? 0
        
        contentView.reloadData(numberOfPage: numberOfPage)
        
        //menuview
        if let titles = dataSource?.titleDatas() as? [CellData] {
            assert(titles.count == numberOfPage)
            menuView.reloadTitles(titles, index: currentIndex)
        }
    }
    
    internal func updateScrollingUIFromPageContentView(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection) {
        menuView.updateScrollingUI(leftIndex: leftIndex, precent: precent, direction: direction)
    }
    
    internal func selectItemFromPageContentView(select index: Int) {
        menuView.selectItem(at: index)
    }
    
    internal func selectItemFromTapMenuView(select index: Int) {
        guard currentIndex != index else { return } //menu view 是无状态的，没有current index属性，所以在这里判断是否需要阻拦
        contentView.selectItem(at: index)
    }
    
    internal func extraViewAction() {
        delegate?.extraViewAction()
    }
    
    public var currentIndex: Int {
        return contentView.currentIndex
    }
    
    public func selectPage(at index: Int) {
        menuView.selectItem(at: index)
        contentView.selectItem(at: index)
    }
    
    public var currentPage: UIView? {
        return contentView.currentPage
    }
}
