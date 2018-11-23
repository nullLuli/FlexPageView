//
//  MenuView.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import UIKit

struct MenuViewOption {
    static let NormalScale: CGFloat = 1

    var titleFont: CGFloat = 15
    var allowSelectedEnlarge: Bool = false
    var selectedScale: CGFloat = 1
    var selectedColor: UIColor = UIColor.blue
    var titleColor: UIColor = UIColor.black
    var showUnderline: Bool = true
    var underlineWidth: CGFloat = 10
    var underlineHeight: CGFloat = 2
}

protocol MenuViewLayoutProtocol: class {
    func collectionView(_ collectionView: UICollectionView, titleForItemAtIndexPath indexPath: IndexPath) -> String
}

protocol MenuViewProtocol {
    func menuView(_ menuView: MenuView, didSelectItemAt indexPath: IndexPath)
    func menuView(_ menuView: MenuView, didDeselectItemAt indexPath: IndexPath)
}

class MenuViewLayout: UICollectionViewLayout {
    fileprivate var titleMargin: CGFloat = 30
    
    weak var delegate: MenuViewLayoutProtocol?
    
    var option: MenuViewOption
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    var contentWidth: CGFloat = 0
    
    init(option: MenuViewOption = MenuViewOption()) {
        self.option = option
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        cache = [UICollectionViewLayoutAttributes]()
        contentWidth = 0
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let title = delegate?.collectionView(collectionView, titleForItemAtIndexPath: indexPath)
            let titleWidth = ((title ?? "") as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: option.titleFont)], context: nil).width
            let labelWidth = titleWidth + titleMargin
            let frame = CGRect(x: contentWidth, y: 0, width: labelWidth, height: collectionView.frame.height)
            contentWidth += labelWidth
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: 0)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

class MenuView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, MenuViewLayoutProtocol {
    
    fileprivate var titles: [String] = []
    
    var option: MenuViewOption
    
    var menuViewDelegate: MenuViewProtocol?
    
    var underlineView: UIView = {
        let view = UIView()
        return view
    }()
    
    var underlineY: CGFloat {
        return bounds.height - option.underlineHeight - 5
    }
    
    init(frame: CGRect, option: MenuViewOption = MenuViewOption()) {
        self.option = option
        
        let layout = MenuViewLayout(option: option)
        layout.option = option

        super.init(frame: frame, collectionViewLayout: layout)
        
        layout.delegate = self
        
        addSubview(underlineView)
        underlineView.backgroundColor = UIColor.yellow
        underlineView.frame.size = CGSize(width: option.underlineWidth, height: option.underlineHeight)
        
        registCell(self)
        
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registCell(_ collectionView: UICollectionView) {
        collectionView.register(MenuViewCell.self, forCellWithReuseIdentifier: MenuViewCell.identifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineView.frame.origin.y = bounds.size.height - underlineView.frame.height - 5
    }
    
    func reloadTitles(_ titles: [String]) {
        self.titles = titles
        self.reloadData()
    }
    
    // MARK: 根据滑动比例更新UI
    func updateScrollingUI(leftIndex: Int, precent: CGFloat, direction: Direction) {
        let numberOfItem = numberOfItems(inSection: 0)
        guard leftIndex < numberOfItem, leftIndex >= -1 else { return }
        if leftIndex > -1 {
            let indexPath = IndexPath(item: leftIndex, section: 0)
            let leftView = cellForItem(at: indexPath)
            (leftView as? MenuViewCell)?.updateScrollingUI(with: precent)
        }
        
        let rightIndex = leftIndex + 1
        if rightIndex < numberOfItem {
            let indexPath = IndexPath(item: rightIndex, section: 0)
            let rightView = cellForItem(at: indexPath)
            (rightView as? MenuViewCell)?.updateScrollingUI(with: 1 - precent)
        }
        
        //underlineview
        updateScrollingUnderlineView(leftIndex: leftIndex, precent: precent, direction: direction)
    }
    
    private func updateScrollingUnderlineView(leftIndex: Int, precent: CGFloat, direction: Direction) {
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
    func updateSelectUI(_ index: Int, select: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = cellForItem(at: indexPath) as? MenuViewCell {
            cell.updateSelectUI(with: select)
        }

        if select {
            updateSelectUnderlineView(to: index)
        }
    }
    
    private func updateSelectUnderlineView(to index: Int) {
        let numberOfItem = numberOfItems(inSection: 0)
        guard index < numberOfItem else { return }
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = cellForItem(at: indexPath) {
            let x = ceil(cell.center.x - option.underlineWidth / 2)
            underlineView.frame = CGRect(x: x, y: underlineY, width: option.underlineWidth, height: option.underlineHeight)
        }
    }
    
    // MARK: UICollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuViewCell.identifier, for: indexPath)
        (cell as? MenuViewCell)?.setData(text: titles[indexPath.item], textSize: option.titleFont, option: option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MenuViewCell)?.updateSelectUI(with: cell.isSelected)  //考虑这样一种情况：menuview将选中的title滑动到屏幕外，然后选中一个title，这时原title会取不到cell，而无法将UI更新为未选中状态
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuViewDelegate?.menuView(self, didSelectItemAt: indexPath)
        
        updateSelectUI(indexPath.item, select: true)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        menuViewDelegate?.menuView(self, didDeselectItemAt: indexPath)
        
        updateSelectUI(indexPath.item, select: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, titleForItemAtIndexPath indexPath: IndexPath) -> String {
        return titles[indexPath.item]
    }
}

class MenuViewCell: UICollectionViewCell {
    var option: MenuViewOption = MenuViewOption()
    
    var titleLable: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(text: String, textSize: CGFloat, option: MenuViewOption) {
        self.option = option
        titleLable.text = text
        if titleLable.font.pointSize != textSize {
            titleLable.font = UIFont.systemFont(ofSize: textSize)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLable.sizeToFit()
        titleLable.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // MARK: 更新滑动UI
    func updateScrollingUI(with precent: CGFloat) {
        if option.allowSelectedEnlarge {
            let scale = 1 + ((1 - precent) * (option.selectedScale - MenuViewOption.NormalScale))
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        }
        
        titleLable.textColor = updateColor(option.selectedColor, toColor: option.titleColor, percent: precent)
    }
    
    private func updateColor(_ fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromR: CGFloat = 0
        var fromG: CGFloat = 0
        var fromB: CGFloat = 0
        var fromA: CGFloat = 0
        fromColor.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        var toR: CGFloat = 0
        var toG: CGFloat = 0
        var toB: CGFloat = 0
        var toA: CGFloat = 0
        toColor.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        let currentR: CGFloat = fromR + percent * (toR - fromR)
        let currentG: CGFloat = fromG + percent * (toG - fromG)
        let currentB: CGFloat = fromB + percent * (toB - fromB)
        let currentA: CGFloat = fromA + percent * (toA - fromA)
        return UIColor(red: currentR, green: currentG, blue: currentB, alpha: currentA)
    }
    
    // MARK: 更新选中状态UI
    func updateSelectUI(with selected: Bool) {
        if selected {
            titleLable.textColor = option.selectedColor
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: option.selectedScale, y: option.selectedScale)
        } else {
            titleLable.textColor = option.titleColor
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: MenuViewOption.NormalScale, y: MenuViewOption.NormalScale)
        }
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
