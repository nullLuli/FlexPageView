//
//  MenuViewBaseLayout.swift
//  FlexPageView
//
//  Created by nullLuli on 2020/2/21.
//  Copyright © 2020 nullLuli. All rights reserved.
//

/*
    Use your custom MenuViewBaseLayout to layout FlexMenuView.
    Passed MenuViewBaseLayout instance to FlexPageView during FlexPageView initialization
 */
open class MenuViewBaseLayout: UICollectionViewLayout {
    /*
        dataSource can provide IMenuViewCellData for your custom MenuViewBaseLayout
        You can use this to calculate the size of the cell
     */
    public weak var dataSource: MenuViewLayoutDataSource?
}

public protocol MenuViewLayoutDataSource: class {
    func collectionView(_ collectionView: UICollectionView, dataForItemAtIndexPath indexPath: IndexPath) -> IMenuViewCellData
}
