//
//  MenuView.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import UIKit

public protocol MenuViewDelegate: class {
    func selectItemFromTapMenuView(select index: Int)
}

/// return the cell type and corresponding identifier that FlexMenuView needs to registered
public protocol MenuViewUISource: class {
    func register() -> [String: UICollectionViewCell.Type]
}

class FlexMenuView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, MenuViewLayoutDataSource {
    
    fileprivate var datas: [IMenuViewCellData] = []
    
    internal var option: FlexPageViewOption
    
    internal weak var menuViewDelegate: MenuViewDelegate?
    internal weak var menuViewUISource: MenuViewUISource? {
        didSet {
            if let uiSource = menuViewUISource {
                registCell(cellInfo: (uiSource.register()))
            }
        }
    }
    
    private var underlineView: UIView = UIView()
    
    private var underlineY: CGFloat {
        return bounds.height - option.underlineHeight - 5
    }
    
    /// FlexMenuView inherits from UICollectionView and uses subclasses of MenuViewBaseLayout to layout cells
    internal init(frame: CGRect, option: FlexPageViewOption = FlexPageViewOption(), layout: MenuViewBaseLayout? = nil) {
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
        
        layoutR.dataSource = self
        
        if option.showUnderline {
            addSubview(underlineView)
            underlineView.backgroundColor = option.underlineColor
            underlineView.layer.cornerRadius = 0.5
            underlineView.layer.masksToBounds = true
            underlineView.frame.size = CGSize(width: option.underlineWidth, height: option.underlineHeight)
        }
        
        self.dataSource = self
        self.delegate = self
        backgroundColor = option.menuBackgroundColor
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registCell(cellInfo: [String: AnyClass]) {
        for (identifier, cell) in cellInfo {
            register(cell, forCellWithReuseIdentifier: identifier)
        }
    }
    
    internal func reloadTitles(_ datas: [IMenuViewCellData], index: Int? = nil) {
        self.datas = datas
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
            self.layoutIfNeeded()
        }) { (_) in
            let selectedDatas = self.datas.filter({ (item) -> Bool in
                return item.isSelected
            })
            if selectedDatas.isEmpty {
                let selectIndex: Int = index ?? self.option.defaultSelectIndex
                self.selectItem(at: selectIndex)
            }
        }
    }
    
    // MARK: Update UI when scrolling
    public func updateScrollingUI(leftIndex: Int, precent: CGFloat, direction: FlexPageDirection) {
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
            
            if let leftView = cellForItem(at: indexPath) as? IMenuViewCell & UIView, let rightView = cellForItem(at: rightIndexPath) as? IMenuViewCell & UIView {
                let leftCenterX = leftView.convert(CGPoint(x: leftView.underlineCenterX, y: 0), to: self).x
                let rightCenterX = rightView.convert(CGPoint(x: rightView.underlineCenterX, y: 0), to: self).x
                let leftX: CGFloat = ceil(leftCenterX - option.underlineWidth / 2)
                let rightX: CGFloat = ceil(rightCenterX - option.underlineWidth / 2)
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
    
    // MARK: Update UI when selected
    internal func selectItem(at index: Int) {
        _selectItem(at: index)
    }
    
    private func updateSelectUnderlineView(to index: Int) {
        let numberOfItem = numberOfItems(inSection: 0)
        guard index < numberOfItem else { return }
        let indexPath = IndexPath(item: index, section: 0)
        if let selectedView = cellForItem(at: indexPath) as? IMenuViewCell & UIView {
            let centerX = selectedView.convert(CGPoint(x: selectedView.underlineCenterX, y: 0), to: self).x
            let x = centerX - (option.underlineWidth / 2)
            underlineView.frame = CGRect(x: x, y: underlineY, width: option.underlineWidth, height: option.underlineHeight)
        }
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
         When the cell is out of the screen, the cell cannot be obtained through the cellForItem and the UI state of the cell cannot be updated. So adjust the selected state of cell in willDisplay
         */
        if let cell = cell as? IMenuViewCell {
            cell.updateSelectUI()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dataForItemAtIndexPath indexPath: IndexPath) -> IMenuViewCellData {
        return datas[indexPath.item]
    }
    
    // MARK: Selected processe
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuViewDelegate?.selectItemFromTapMenuView(select: indexPath.item)
        
        _selectItem(at: indexPath.item)
    }
    
    private func _selectItem(at index: Int) {
        guard index < datas.count else { return }
        
        datas.enumerated().forEach { (offset, element) in
            if element.isSelected {
                let indexPath = IndexPath(item: offset, section: 0)
                let cell = cellForItem(at: indexPath)
                cell?.isSelected = false
                (cell as? IMenuViewCell)?.updateSelectUI()
                selectData(index: offset, to: false)
            }
        }
        let indexPath = IndexPath(item: index, section: 0)
        scrollItemToHorizonCenter(indexPath) {
            self.updateSelectUnderlineView(to: index)
            
            let cell = self.cellForItem(at: indexPath)
            cell?.isSelected = true
            (cell as? IMenuViewCell)?.updateSelectUI()
            self.selectData(index: indexPath.item, to: true)
        }
    }
        
    private func selectData(index: Int, to selected: Bool) {
        var data = datas[index]
        data.isSelected = selected
        datas[index] = data
    }
    
    private func scrollItemToHorizonCenter(_ indexPath: IndexPath, complete: (() -> Void)? = nil ) {
        UIView.animate(withDuration: 0.25, animations: {
            let selectCellLayout = self.collectionViewLayout.layoutAttributesForItem(at: indexPath)
            let offset = min(max(self.contentSize.width - self.frame.width, 0), max((selectCellLayout?.frame.midX ?? 0) - self.frame.width / 2, 0))
            self.setContentOffset(CGPoint(x: offset, y: self.contentOffset.y), animated: false)
        }) { (_) in
            complete?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineView.frame.origin.y = underlineY
    }
}

