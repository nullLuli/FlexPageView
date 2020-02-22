//
//  MenuViewCell2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/26.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit
import FlexPageView

struct MenuViewCustomCellData: IMenuViewCellData {
    var isSelected: Bool = false
    
    var text: String
    var isHot: Bool
    
    var CellClass: UICollectionViewCell.Type {
        return MenuViewCustomCell.self
    }
    
    var identifier: String {
        return MenuViewCustomCell.identifier
    }
}

let HotImageViewWidth: CGFloat = 32
let HotImageMargin: CGFloat = 3

class MenuViewCustomLayout: MenuViewBaseLayout {
    var option: FlexPageViewOption
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    var contentMaxX: CGFloat = 0
    
    init(option: FlexPageViewOption) {
        self.option = option
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        cache = [UICollectionViewLayoutAttributes]()
        contentMaxX = 0
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let data = dataSource?.collectionView(collectionView, dataForItemAtIndexPath: indexPath) as? MenuViewCustomCellData
            let title = data?.text
            let isHot = data?.isHot ?? false
            let titleWidth = ((title ?? "") as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: option.titleFont)], context: nil).width
            let labelWidth = titleWidth + option.titleMargin
            var contentWidth = labelWidth
            if isHot {
                contentWidth += (HotImageViewWidth + HotImageMargin)
            }
            let frame = CGRect(x: contentMaxX, y: 0, width: ceil(contentWidth), height: collectionView.frame.height)
            contentMaxX += contentWidth

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentMaxX, height: 0)
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

class MenuViewCustomCell: UICollectionViewCell, IMenuViewCell {
    var underlineCenterX: CGFloat {
        return titleLable.center.x
    }
    
    var option: FlexPageViewOption = FlexPageViewOption()
    
    var titleLable: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()
    
    var hotImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "hot")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLable)
        addSubview(hotImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLable.sizeToFit()
        if hotImageView.isHidden {
            titleLable.center = CGPoint(x: bounds.midX, y: bounds.midY)
        } else {
            titleLable.frame.origin.x = option.titleMargin / 2
            titleLable.center.y = bounds.midY
            hotImageView.frame = CGRect(x: titleLable.frame.maxX + HotImageMargin, y: 0, width: HotImageViewWidth, height: HotImageViewWidth)
        }
    }
    
    // MARK: 更新数据
    func setData(data: IMenuViewCellData, option: FlexPageViewOption) {
        guard let data = data as? MenuViewCustomCellData else {
            assertionFailure()
            return
        }
        self.option = option
        titleLable.text = data.text
        titleLable.sizeToFit()
        if titleLable.font.pointSize != option.titleFont {
            titleLable.font = UIFont.systemFont(ofSize: option.titleFont)
        }
        hotImageView.isHidden = !data.isHot
        setNeedsLayout()
    }
    
    // MARK: 更新滑动UI
    func updateScrollingUI(with precent: CGFloat) {
        if option.allowSelectedEnlarge {
            let scale = 1 + ((1 - precent) * (option.selectedScale - FlexPageViewOption.NormalScale))
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        }
        
        titleLable.textColor = UIColor.transition(fromColor: option.selectedColor, toColor: option.titleColor, percent: precent)
    }
    
    // MARK: 更新选中状态UI
    func updateSelectUI() {
        if isSelected {
            titleLable.textColor = option.selectedColor
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: option.selectedScale, y: option.selectedScale)
        } else {
            titleLable.textColor = option.titleColor
            titleLable.transform = CGAffineTransform.identity.scaledBy(x: FlexPageViewOption.NormalScale, y: FlexPageViewOption.NormalScale)
        }
    }
}
