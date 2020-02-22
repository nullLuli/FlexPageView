//
//  TestCustomMenuViewCellController.swift
//  FlexPageView
//
//  Created by nullLuli on 2019/3/11.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import Foundation
import UIKit
import FlexPageView

class TestCustomMenuViewCellController: BaseTestFlexPageViewController<MenuViewCustomCellData, MenuViewCustomCell> {
    override var cellDatas: [MenuViewCustomCellData] {
        var titleDatas: [MenuViewCustomCellData] = []
        titles.enumerated().forEach { (offset, element) in
            titleDatas.append(MenuViewCustomCellData(text: element, isHot: element == "热榜"))
        }
        return titleDatas
    }
    
    override func getLayout(option: FlexPageViewOption) -> MenuViewBaseLayout {
        return MenuViewCustomLayout(option: option)
    }
}
