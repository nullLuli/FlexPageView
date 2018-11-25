//
//  TestSelfDefineCollectionView.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class TestFlexPageViewController: UIViewController, SelfDefineCollectionViewDataSource, FlexPageViewDataSource {
    var pageView: FlexPageView2?
    static let titles: [String] = ["hhhhh", "22", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var option = FlexPageViewOption()
        option.titleMargin = 70
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.8
        option.underlineColor = UIColor.red
        let pageView = FlexPageView2(option: option)
        pageView.dataSource = self
        view.addSubview(pageView)
        pageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 20)
        self.pageView = pageView
    }
    
    func numberOfPage() -> Int {
        return TestFlexPageViewController.titles.count
    }
    
    func titles() -> [String] {
        return TestFlexPageViewController.titles
    }
    
    func page(at index: Int) -> LLCollectionCell {
        return LLCollectionCell()
    }    
}
