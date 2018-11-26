//
//  TestSelfDefineCollectionView.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class TestFlexPageViewController: UIViewController, SelfDefineCollectionViewDataSource, FlexPageViewDataSource, FlexPageViewUISource {
    var pageView: FlexPageView2<MenuViewCellData2>?
    static let titles: [String] = ["hhhhh", "22", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var option = FlexPageViewOption()
        option.titleMargin = 70
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.8
        option.underlineColor = UIColor.red
        let pageView = FlexPageView2<MenuViewCellData2>(option: option, uiSource: self, layout: MenuViewLayout2(option: option))
        pageView.dataSource = self
        view.addSubview(pageView)
        pageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 20)
        self.pageView = pageView
    }
    
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
    
    func page(at index: Int) -> LLCollectionCell {
        return LLCollectionCell()
    }
    
    func register() -> [String : UICollectionViewCell.Type] {
        return ["MenuViewCell2": MenuViewCell2.self]
    }
    
    func titles() -> [String] {
        //SelfDefineCollectionViewDataSource
        return TestFlexPageViewController.titles
    }

}
