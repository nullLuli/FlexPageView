//
//  TestSelfDefineCollectionView.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class TestFlexPageViewController: UIViewController, FlexPageViewDataSource, FlexPageViewUISource, FlexPageViewDelegate {
    var pageView: FlexPageView<MenuViewCellData>?
    static let titles: [String] = ["hhhhh", "22", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge.right
        var option = FlexPageViewOption()
        option.titleMargin = 70
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.8
        option.underlineColor = UIColor.red
        let pageView = FlexPageView<MenuViewCellData>(option: option, layout: MenuViewLayout(option: option))
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
        var titleDatas: [MenuViewCellData] = []
        for title in TestFlexPageViewController.titles {
            titleDatas.append(MenuViewCellData(title: title))
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
        return ["MenuViewCell": MenuViewCell.self]
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
