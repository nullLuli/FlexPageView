//
//  TestSelfDefineCollectionView.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class TestFlexPageViewController: UIViewController, SelfDefineCollectionViewDataSource {
    var pageView: FlexPageView = FlexPageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageView.dataSource = self
        view.addSubview(pageView)
        pageView.frame = CGRect(x: 0, y: 200, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
    }
    
    func numberOfPage() -> Int {
        return 12
    }
    
    func titles() -> [String] {
        return ["hhhhh", "22222", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh", "hhhhh", "22222", "hh333hhh", "hh44hhh"]
    }
    
    func page(at index: Int) -> LLCollectionCell {
        return LLCollectionCell()
    }
}
