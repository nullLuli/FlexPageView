//
//  MenuView.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/16.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import UIKit

struct MenuViewOption {
    var titleFont: CGFloat = 15
    var allowSelectedEnlarge: Bool = false
    var selectedScale: CGFloat = 1
    
    static let NormalScale: CGFloat = 1
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
    
    init(frame: CGRect, option: MenuViewOption = MenuViewOption()) {
        self.option = option
        
        let layout = MenuViewLayout(option: option)
        layout.option = option

        super.init(frame: frame, collectionViewLayout: layout)
        
        register(MenuViewCell.self, forCellWithReuseIdentifier: MenuViewCell.identifier)
        
        layout.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadTitles(_ titles: [String]) {
        self.titles = titles
        self.reloadData()
    }
    
    func changeUIWithPrecent(leftIndex: Int, precent: CGFloat) {
        debugPrint("leftindex: \(leftIndex)")
        if option.allowSelectedEnlarge {
            let numberOfItem = numberOfItems(inSection: 0)
            guard leftIndex < numberOfItem, leftIndex >= -1 else { return }
            if leftIndex > -1 {
                let indexPath = IndexPath(item: leftIndex, section: 0)
                let leftView = cellForItem(at: indexPath)
                let leftScale = 1 + ( (1 - precent) * (option.selectedScale - MenuViewOption.NormalScale))
                leftView?.transform = CGAffineTransform.identity.scaledBy(x: leftScale, y: leftScale)
            }
            
            let rightIndex = leftIndex + 1
            if rightIndex < numberOfItem {
                let indexPath = IndexPath(item: rightIndex, section: 0)
                let rightView = cellForItem(at: indexPath)
                let rightScale = 1 + (precent * (option.selectedScale - MenuViewOption.NormalScale))
                rightView?.transform = CGAffineTransform.identity.scaledBy(x: rightScale, y: rightScale)
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
        (cell as? MenuViewCell)?.setData(text: titles[indexPath.item], textSize: option.titleFont)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, titleForItemAtIndexPath indexPath: IndexPath) -> String {
        return titles[indexPath.item]
    }
}

class MenuViewCell: UICollectionViewCell {
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
    
    func setData(text: String, textSize: CGFloat) {
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
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
