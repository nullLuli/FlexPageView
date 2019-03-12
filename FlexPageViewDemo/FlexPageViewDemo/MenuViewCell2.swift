//
//  MenuViewCell2.swift
//  FlexPageView
//
//  Created by nullLuli on 2018/11/26.
//  Copyright © 2018 nullLuli. All rights reserved.
//

import Foundation
import UIKit

struct MenuViewCellData2: IMenuViewCellData {
    var text: String
    var isHot: Bool
    
    var CellClass: UICollectionViewCell.Type {
        return MenuViewCell2.self
    }
}

class MenuViewLayout2: MenuViewBaseLayout {
    var option: FlexPageViewOption
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    var contentWidth: CGFloat = 0
    
    init(option: FlexPageViewOption = FlexPageViewOption()) {
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
            let title = (delegate?.collectionView(collectionView, dataForItemAtIndexPath: indexPath) as? MenuViewCellData2)?.text
            let titleWidth = ((title ?? "") as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: option.titleFont)], context: nil).width
            let labelWidth = titleWidth + option.titleMargin
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

class MenuViewCell2: UICollectionViewCell, IMenuViewCell {
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
        titleLable.center = CGPoint(x: bounds.midX, y: bounds.midY)
        hotImageView.frame = CGRect(x: titleLable.frame.maxX + 3, y: 0, width: 32, height: 32)
    }
    
    // MARK: 更新数据
    func setData(data: IMenuViewCellData, option: FlexPageViewOption) {
        guard let data = data as? MenuViewCellData2 else {
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
    }
    
    // MARK: 更新滑动UI
    func updateScrollingUI(with precent: CGFloat) {
        if option.allowSelectedEnlarge {
            let scale = 1 + ((1 - precent) * (option.selectedScale - FlexPageViewOption.NormalScale))
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
