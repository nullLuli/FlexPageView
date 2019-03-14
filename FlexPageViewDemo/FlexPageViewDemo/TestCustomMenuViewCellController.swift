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
        for title in titles {
            titleDatas.append(MenuViewCustomCellData(text: title, isHot: true))
        }
        return titleDatas
    }
    
    override var layout: MenuViewBaseLayout {
        return MenuViewCustomLayout()
    }
}
