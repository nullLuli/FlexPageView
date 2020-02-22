//
//  MenuViewCell.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/26.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

public struct MenuViewCellData: IMenuViewCellData {
    public var isSelected: Bool = false
    
    public var title: String
    
    public var CellClass: UICollectionViewCell.Type {
        return MenuViewCell.self
    }
        
    public init(title: String) {
        self.title = title
    }
}

public class MenuViewLayout: MenuViewBaseLayout {
    var option: FlexPageViewOption
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    var contentWidth: CGFloat = 0
    
    public init(option: FlexPageViewOption = FlexPageViewOption()) {
        self.option = option
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepare() {
        guard let collectionView = collectionView else { return }
        
        cache = [UICollectionViewLayoutAttributes]()
        contentWidth = 0
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let title = (dataSource?.collectionView(collectionView, dataForItemAtIndexPath: indexPath) as? MenuViewCellData)?.title
            let titleWidth = ((title ?? "") as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: option.titleFont)], context: nil).width
            let labelWidth = titleWidth + option.titleMargin
            let frame = CGRect(x: contentWidth, y: 0, width: labelWidth, height: collectionView.frame.height)
            contentWidth += labelWidth
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        }
    }
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: 0)
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

public class MenuViewCell: UICollectionViewCell, IMenuViewCell {
    public var underlineCenterX: CGFloat {
        return titleLable.center.x
    }
    
    var option: FlexPageViewOption = FlexPageViewOption()
    
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        titleLable.sizeToFit()
        titleLable.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // MARK: Update data
    public func setData(data: IMenuViewCellData, option: FlexPageViewOption) {
        guard let data = data as? MenuViewCellData else {
            assertionFailure()
            return
        }
        self.option = option
        titleLable.text = data.title
        if titleLable.font.pointSize != option.titleFont {
            titleLable.font = UIFont.systemFont(ofSize: option.titleFont)
        }
    }
    
    // MARK: Update UI when scrolling
    public func updateScrollingUI(with precent: CGFloat) {
        if option.allowSelectedEnlarge {
            let scale = 1 + ((1 - precent) * (option.selectedScale - FlexPageViewOption.NormalScale))
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        }
        
        titleLable.textColor = UIColor.transition(fromColor: option.selectedColor, toColor: option.titleColor, percent: precent)
    }
    
    
    // MARK: Update UI when selected
    public func updateSelectUI() {
        if isSelected {
            titleLable.textColor = option.selectedColor
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: option.selectedScale, y: option.selectedScale)
        } else {
            titleLable.textColor = option.titleColor
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: FlexPageViewOption.NormalScale, y: FlexPageViewOption.NormalScale)
        }
    }
}
