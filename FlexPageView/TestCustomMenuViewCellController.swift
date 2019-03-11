//
//  TestCustomMenuViewCellController.swift
//  FlexPageView
//
//  Created by nullLuli on 2019/3/11.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class TestCustomMenuViewCellController: UIViewController, FlexPageViewDataSource, FlexPageViewUISource, FlexPageViewDelegate {
    var pageView: FlexPageView<MenuViewCellData2>?
    static let titles: [String] = ["hhhhh", "22", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge.right
        var option = FlexPageViewOption()
        option.titleMargin = 70
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.8
        option.underlineColor = UIColor.red
        let pageView = FlexPageView<MenuViewCellData2>(option: option, layout: MenuViewLayout2(option: option))
        pageView.delegate = self
        pageView.dataSource = self
        pageView.uiSource = self
        view.addSubview(pageView)
        pageView.frame = view.bounds
        self.pageView = pageView
    }
    
    // MARK: FlexPageView
    func numberOfPage() -> Int {
        return TestFlexPageViewController.titles.count
    }
    
    func titleDatas() -> [IMenuViewCellData] {
        var titleDatas: [MenuViewCellData2] = []
        for title in TestFlexPageViewController.titles {
            titleDatas.append(MenuViewCellData2(text: title, isHot: true))
        }
        return titleDatas
    }
    
    func page(at index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.randomColor
        return view
    }
    
    func pageID(at index: Int) -> Int {
        return index
    }
    
    func register() -> [String : UICollectionViewCell.Type] {
        return ["MenuViewCell2": MenuViewCell2.self]
    }
    
    func extraViewAction() {
        //
    }
    
    func didRemovePage(_ page: UIView, at index: Int) {
        //
    }
    
    func pageWillAppear(_ page: UIView, at index: Int) {
        //
    }
    
    func pageWillDisappear(_ page: UIView, at index: Int) {
        //
    }
    
}
