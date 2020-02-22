//
//  TestSelfDefineCollectionView.swift
//  swiftLearn
//
//  Created by nullLuli on 2018/11/1.
//  Copyright © 2018年 nullLuli. All rights reserved.
//

import Foundation
import UIKit
import FlexPageView

class TestFlexPageViewController: BaseTestFlexPageViewController<MenuViewCellData, MenuViewCell> {
    override var cellDatas: [MenuViewCellData] {
        var titleDatas: [MenuViewCellData] = []
        for title in titles {
            titleDatas.append(MenuViewCellData(title: title))
        }
        return titleDatas
    }
    
    override func getLayout(option: FlexPageViewOption) -> MenuViewBaseLayout {
        return MenuViewLayout()
    }
}
