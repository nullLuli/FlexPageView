//
//  IMenuViewCell.swift
//  FlexPageView
//
//  Created by nullLuli on 2020/2/21.
//  Copyright © 2020 nullLuli. All rights reserved.
//

import Foundation

/*
    You can customize the style of the FlexMenuView cell by implementing the IMenuViewCell protocol
 */
public protocol IMenuViewCell {
    /// return the horizontal position of the underline center in the cell. Generally cell.width / 2
    var underlineCenterX: CGFloat {get}
    
    /// Update the UI during page turning
    /// - Parameter precent: Page turning progress. Between 0 and 1
    /// The farther the page turning pointer is, the greater the value.
    func updateScrollingUI(with precent: CGFloat)
    
    /// Update UI after page turning
    func updateSelectUI()
    
    /// Update data source
    func setData(data: IMenuViewCellData, option: FlexPageViewOption)
}

/*
    You can customize the data type used by IMenuViewCell by implementing IMenuViewCellData
 */
public protocol IMenuViewCellData {
    /// FlexMenuView is used to correct the UI. Except for implementing it, you should not use it or assign values to it.
    var isSelected: Bool { get set }
    
    /// Cell type required for this data type
    var CellClass: UICollectionViewCell.Type { get }
}

