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
    
    var underlineView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    func changeUIWithPrecent(leftIndex: Int, precent: CGFloat, direction: Direction) {        
        let numberOfItem = numberOfItems(inSection: 0)
        guard leftIndex < numberOfItem, leftIndex >= -1 else { return }
        if leftIndex > -1 {
            let indexPath = IndexPath(item: leftIndex, section: 0)
            let leftView = cellForItem(at: indexPath)
            (leftView as? MenuViewCell)?.updateUI(with: precent)
        }
        
        let rightIndex = leftIndex + 1
        if rightIndex < numberOfItem {
            let indexPath = IndexPath(item: rightIndex, section: 0)
            let rightView = cellForItem(at: indexPath)
            (rightView as? MenuViewCell)?.updateUI(with: 1 - precent)
        }
        
        //underlineview
        updateUnderlineView(leftIndex: leftIndex, precent: precent, direction: direction)
    }
    
    func updateUnderlineView(leftIndex: Int, precent: CGFloat, direction: Direction) {
        let numberOfItem = numberOfItems(inSection: 0)
        let rightIndex = leftIndex + 1
        if leftIndex > -1, rightIndex < numberOfItem {
            let indexPath = IndexPath(item: leftIndex, section: 0)
            let rightIndexPath = IndexPath(item: rightIndex, section: 0)
            
            if let leftView = cellForItem(at: indexPath), let rightView = cellForItem(at: rightIndexPath) {
                let leftX: CGFloat = ceil(leftView.center.x - option.underlineWidth / 2)
                let rightX: CGFloat = ceil(rightView.center.x - option.underlineWidth / 2)
                let underlineY: CGFloat = bounds.height - option.underlineHeight - 5
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
    
    func updateUI(with precent: CGFloat) {
        if option.allowSelectedEnlarge {
            let scale = 1 + ((1 - precent) * (option.selectedScale - MenuViewOption.NormalScale))
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLable.textColor = option.selectedColor
            } else {
                titleLable.textColor = option.titleColor
            }
        }
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
