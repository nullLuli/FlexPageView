//
//  TestCustomMenuViewCellController.swift
//  FlexPageView
//
//  Created by nullLuli on 2019/3/11.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import Foundation
import UIKit

class TestCustomMenuViewCellController: BaseTestFlexPageViewController<MenuViewCellData2, MenuViewCell2> {
    override var cellDatas: [MenuViewCellData2] {
        var titleDatas: [MenuViewCellData2] = []
        for title in titles {
            titleDatas.append(MenuViewCellData2(text: title, isHot: true))
        }
        return titleDatas
    }
    
    override var layout: MenuViewBaseLayout {
        return MenuViewLayout2()
    }
}
