//
//  MenuView.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import UIKit

protocol MenuViewLayoutProtocol: class {
    func collectionView(_ collectionView: UICollectionView, dataForItemAtIndexPath indexPath: IndexPath) -> Any
}

protocol MenuViewProtocol: class {
    func selectItemFromTapMenuView(select index: Int)
}

protocol MenuViewUISource: class {
    func register() -> [String: UICollectionViewCell.Type]
}

protocol IMenuViewCell {
    func updateScrollingUI(with precent: CGFloat)
    func updateSelectUI()
    func setData(data: IMenuViewCellData, option: FlexPageViewOption)
}

protocol IMenuViewCellData {
    var CellClass: UICollectionViewCell.Type { get }
}

class MenuViewBaseLayout: UICollectionViewLayout {
    weak var delegate: MenuViewLayoutProtocol?
}

class FlexMenuView<CellData: IMenuViewCellData>: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, MenuViewLayoutProtocol {
    
    fileprivate var datas: [CellData] = []
    
    var option: FlexPageViewOption
    
    weak var menuViewDelegate: MenuViewProtocol?
    weak var menuViewUISource: MenuViewUISource? {
        didSet {
            if let uiSource = menuViewUISource {
                registCell(cellInfo: (uiSource.register()))
            }
        }
    }
    
    var underlineView: UIView = UIView()
    
    var underlineY: CGFloat {
        return bounds.height - option.underlineHeight - 5
    }
    
    init(frame: CGRect, option: FlexPageViewOption = FlexPageViewOption(), layout: MenuViewBaseLayout? = nil) {
        self.option = option
        
        var layoutR: MenuViewBaseLayout
        if let layout = layout {
            layoutR = layout
        } else {
            let layout = MenuViewLayout(option: option)
            layout.option = option
            layoutR = layout
        }
        
        super.init(frame: frame, collectionViewLayout: layoutR)
        
        layoutR.delegate = self
        
        if option.showUnderline {
            addSubview(underlineView)
            underlineView.backgroundColor = option.underlineColor
            underlineView.frame.size = CGSize(width: option.underlineWidth, height: option.underlineHeight)
        }
        
        self.dataSource = self
        self.delegate = self
        
        backgroundColor = UIColor.white
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registCell(cellInfo: [String: AnyClass]) {
        for (identifier, cell) in cellInfo {
            register(cell, forCellWithReuseIdentifier: identifier)
        }
    }
    
    func reloadTitles(_ datas: [CellData], index: Int? = nil) {
        self.datas = datas
        self.reloadData()
        
        if indexPathsForSelectedItems?.first == nil {
            let selectIndex: Int = index ?? option.defaultSelectIndex
            selectItem(at: selectIndex)
            if option.showUnderline {
                /*
                 reloadData 后调用 collectionView 的 selectItem 不会触发 didSelectItemAt 方法
                 所以在这里更新下滑条
                 */
                updateSelectUnderlineView(to: selectIndex)
            }
        }
    }
    
    // MARK: 根据滑动比例更新UI
    func updateScrollingUI(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection) {
        let numberOfItem = numberOfItems(inSection: 0)
        guard leftIndex < numberOfItem, leftIndex >= -1 else { return }
        if leftIndex > -1 {
            let indexPath = IndexPath(item: leftIndex, section: 0)
            let leftView = cellForItem(at: indexPath)
            (leftView as? IMenuViewCell)?.updateScrollingUI(with: precent)
        }
        
        let rightIndex = leftIndex + 1
        if rightIndex < numberOfItem {
            let indexPath = IndexPath(item: rightIndex, section: 0)
            let rightView = cellForItem(at: indexPath)
            (rightView as? IMenuViewCell)?.updateScrollingUI(with: 1 - precent)
        }
        
        if option.showUnderline {
            //underlineview
            updateScrollingUnderlineView(leftIndex: leftIndex, precent: precent, direction: direction)
        }
    }
    
    private func updateScrollingUnderlineView(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection) {
        let numberOfItem = numberOfItems(inSection: 0)
        let rightIndex = leftIndex + 1
        if leftIndex > -1, rightIndex < numberOfItem {
            let indexPath = IndexPath(item: leftIndex, section: 0)
            let rightIndexPath = IndexPath(item: rightIndex, section: 0)
            
            if let leftView = cellForItem(at: indexPath), let rightView = cellForItem(at: rightIndexPath) {
                let leftX: CGFloat = ceil(leftView.center.x - option.underlineWidth / 2)
                let rightX: CGFloat = ceil(rightView.center.x - option.underlineWidth / 2)
                if option.showUnderline {
                    let detalWidth = rightX - leftX
                    if direction == .left {
                        if precent <= 0.5 {
                            underlineView.frame = CGRect(x: leftX, y: underlineY, width: option.underlineWidth + (precent / 0.5) * detalWidth, height: option.underlineHeight)
                        } else {
                            underlineView.frame = CGRect(x: leftX + detalWidth - ((1 - precent) / 0.5) * detalWidth, y: underlineY, width: option.underlineWidth + ((1 - precent) / 0.5) * detalWidth, height: option.underlineHeight)
                        }
                        
                    } else {
                        if precent > 0.5 {
                            underlineView.frame = CGRect(x: leftX + detalWidth  - ((1 - precent) / 0.5) * detalWidth, y: underlineY, width: option.underlineWidth + ((1 - precent) / 0.5) * detalWidth, height: option.underlineHeight)
                        } else {
                            underlineView.frame = CGRect(x: leftX, y: underlineY, width: option.underlineWidth + (precent / 0.5) * detalWidth, height: option.underlineHeight)
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: 根据选中位置更新UI
    func selectItem(at index: Int) {
        guard index < datas.count else { return }
        
        let lastSelectIndexPath = indexPathsForSelectedItems?.first
        let indexPath = IndexPath(item: index, section: 0)
        selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        updateSelectUnderlineView(to: index)
        
        let cell = cellForItem(at: indexPath)
        (cell as? IMenuViewCell)?.updateSelectUI()
        if let lastSelectIndexPath = lastSelectIndexPath {
            let cell = cellForItem(at: lastSelectIndexPath)
            (cell as? IMenuViewCell)?.updateSelectUI()
        }
    }
    
    private func updateSelectUnderlineView(to index: Int) {
        let numberOfItem = numberOfItems(inSection: 0)
        guard index < numberOfItem else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let selectCellLayout = collectionViewLayout.layoutAttributesForItem(at: indexPath)
        let midX = selectCellLayout?.frame.midX ?? 0
        let x = midX - (option.underlineWidth / 2)
        underlineView.frame = CGRect(x: x, y: underlineY, width: option.underlineWidth, height: option.underlineHeight)
    }
    
    // MARK: UICollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < datas.count else { return UICollectionViewCell() }
        let data = datas[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.CellClass.identifier, for: indexPath)
        (cell as? IMenuViewCell)?.setData(data: data, option: option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*
         1. cell在屏幕外时无法通过 cellForItem 取到cell，所以无法更新cell的UI状态
         2. reloadData调用后 collectionView 的 selectItem 不会触发 didSelectItemAt 方法 + reloadData调用后无法通过 cellForItem 取到cell
         在 willDisplay 中调整 cell 的选中状态
         */
        if let cell = cell as? IMenuViewCell {
            cell.updateSelectUI()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dataForItemAtIndexPath indexPath: IndexPath) -> Any {
        return datas[indexPath.item]
    }
    
    // MARK: 用户选中处理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuViewDelegate?.selectItemFromTapMenuView(select: indexPath.item)
        
        if let cell = cellForItem(at: indexPath) as? IMenuViewCell {
            cell.updateSelectUI()
        }
        updateSelectUnderlineView(to: indexPath.item)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = cellForItem(at: indexPath) as? IMenuViewCell {
            cell.updateSelectUI()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineView.frame.origin.y = underlineY
    }
}

