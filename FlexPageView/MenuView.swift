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
    var defaultSelectIndex: Int = 0
}

protocol MenuViewLayoutProtocol: class {
    func collectionView(_ collectionView: UICollectionView, titleForItemAtIndexPath indexPath: IndexPath) -> String
}

protocol MenuViewProtocol: class {
    func selectItemFromTapMenuView(select index: Int)
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
    
    weak var menuViewDelegate: MenuViewProtocol?
    
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
        
        underlineView.frame.origin.y = underlineY
    }
    
    func reloadTitles(_ titles: [String]) {
        self.titles = titles
        self.reloadData()
        
        if indexPathsForSelectedItems?.first == nil {
            selectItem(at: option.defaultSelectIndex)
            /*
             reloadData 后调用 collectionView 的 selectItem 不会触发 didSelectItemAt 方法
             所以在这里更新下滑条
             */
            updateSelectUnderlineView(to: option.defaultSelectIndex)
        }
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
    func selectItem(at index: Int) {
        guard index < titles.count else { return }
        
        let indexPath = IndexPath(item: index, section: 0)
        selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func updateSelectUnderlineView(to index: Int) {
        let numberOfItem = numberOfItems(inSection: 0)
        guard index < numberOfItem else { return }
        let selectCellLayout = (collectionViewLayout as? MenuViewLayout)?.cache[index]
        let x = ceil(selectCellLayout?.frame.midX ?? 0 - option.underlineWidth / 2)
        underlineView.frame = CGRect(x: x, y: underlineY, width: option.underlineWidth, height: option.underlineHeight)
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
        /*
         1. cell在屏幕外时无法通过 cellForItem 取到cell，所以无法更新cell的UI状态
         2. reloadData调用后 collectionView 的 selectItem 不会触发 didSelectItemAt 方法 + reloadData调用后无法通过 cellForItem 取到cell
         在 willDisplay 中调整 cell 的选中状态
         */
        if let cell = cell as? MenuViewCell {
            cell.updateSelectUI(with: cell.isSelected)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, titleForItemAtIndexPath indexPath: IndexPath) -> String {
        return titles[indexPath.item]
    }

    // MARK: 选中处理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuViewDelegate?.selectItemFromTapMenuView(select: indexPath.item)
        
        if let cell = cellForItem(at: indexPath) as? MenuViewCell {
            cell.updateSelectUI(with: cell.isSelected)
        }
        updateSelectUnderlineView(to: indexPath.item)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = cellForItem(at: indexPath) as? MenuViewCell {
            cell.updateSelectUI(with: cell.isSelected)
        }
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
