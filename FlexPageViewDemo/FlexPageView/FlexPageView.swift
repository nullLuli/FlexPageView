//
//  FlexPageView2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/25.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

public protocol FlexPageViewDataSource: PageContentViewDataSource {
    func numberOfPage() -> Int
    func titleDatas() -> [IMenuViewCellData]
}

public protocol FlexPageViewDelegate: PageContentViewPageChangeProtocol, MenuViewDelegate {
    func extraViewAction()
}

public protocol FlexPageViewUISource: MenuViewUISource {
}

public class FlexPageView: UIView, MenuViewDelegate, PageContentViewUserInteractionProtocol {
    private var menuView: FlexMenuView
    private var extraView: UIButton = UIButton()
    private var extralMaskView: UIImageView = UIImageView()
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
    
    /// Some methods in the delegate will be called during reloading, such as didRemovePage. Loading will be triggered when the dataSource is set. If the delegate has no value at this time, you may miss some delegate methods.
    public weak var delegate: FlexPageViewDelegate? {
        didSet {
            contentView.pageChangeDelegate = delegate
        }
    }
    
    public required init?(option: FlexPageViewOption = FlexPageViewOption(), layout: MenuViewBaseLayout? = nil) {
        guard option.isValid else { return nil }
        
        menuView = FlexMenuView(frame: CGRect(x: 0, y: 0, width: 0, height: option.menuViewHeight), option: option, layout: layout)
        contentView = PageContentView(option: option)
        self.option = option
        
        super.init(frame: CGRect.zero)
        
        addSubview(menuView)
        addSubview(contentView)
        
        if option.showExtraView {
            addSubview(extralMaskView)
            addSubview(extraView)
        }
        
        menuView.menuViewDelegate = self
        contentView.userInteractionDelegate = self
        contentView.dataSource = dataSource
        extralMaskView.image = option.extraMaskImage
        extraView.setImage(option.extraImage, for: .normal)
        extraView.addTarget(self, action: #selector(self.extraViewAction), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData(_ selectIndex: Int = -1) {
        let numberOfPage = dataSource?.numberOfPage() ?? 0
        
        var index: Int = currentIndex
        if selectIndex >= 0, selectIndex < numberOfPage {
            index = selectIndex
        }
        
        contentView.reloadData(numberOfPage: numberOfPage, selectIndex: index)
        //menuview
        if let titles = dataSource?.titleDatas() {
            assert(titles.count == numberOfPage)
            menuView.reloadTitles(titles, index: index)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if option.showExtraView {
            extralMaskView.frame.size = option.extraMaskImageSize
            extralMaskView.frame.origin.x = bounds.width - extralMaskView.frame.width
            extralMaskView.frame.origin.y = (menuView.frame.height - extralMaskView.frame.height) / 2
            
            extraView.frame.size = option.extraImageSize
            extraView.frame.origin.x = bounds.width - extraView.frame.width
            extraView.frame.origin.y = (menuView.frame.height - extraView.frame.height) / 2
        }
        
        menuView.frame = CGRect(x: 0, y: 0, width: frame.size.width - extraView.frame.width, height: menuView.frame.height)
        contentView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: frame.width, height: frame.height - menuView.frame.maxY)
        contentView.contentOffset = CGPoint(x: CGFloat(contentView.currentIndex) * frame.width, y: contentView.contentOffset.y)
    }
    
    internal func updateScrollingUIFromPageContentView(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection) {
        menuView.updateScrollingUI(leftIndex: leftIndex, precent: precent, direction: direction)
    }
    
    internal func selectItemFromPageContentView(select index: Int) {
        menuView.selectItem(at: index)
    }
    
    @objc public func selectItemFromTapMenuView(select index: Int) {
        delegate?.selectItemFromTapMenuView(select: index)
        contentView.selectItem(at: index)
    }
    
    @objc public func extraViewAction() {
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
