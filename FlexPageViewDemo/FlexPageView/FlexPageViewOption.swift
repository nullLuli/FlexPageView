//
//  FlexPageViewOption.swift
//  FlexPageView
//
//  Created by PXCM-0101-01-0045 on 2020/2/22.
//  Copyright © 2020 nullLuli. All rights reserved.
//

public struct FlexPageViewOption {
    public static let NormalScale: CGFloat = 1
    
    public var titleFont: CGFloat = 15
    public var titleMargin: CGFloat = 30
    public var allowSelectedEnlarge: Bool = false
    public var selectedScale: CGFloat = 1.2
    public var selectedColor: UIColor = UIColor.blue
    public var titleColor: UIColor = UIColor.black
    public var showUnderline: Bool = true
    public var underlineWidth: CGFloat = 10
    public var underlineHeight: CGFloat = 2
    public var underlineColor: UIColor = UIColor.blue
    public var menuBackgroundColor: UIColor = UIColor.white

    public var parallaxPrecent: CGFloat = 0 //Parallax animation when sliding pages
    
    public var defaultSelectIndex: Int = 0
    public var menuViewHeight: CGFloat = 40
    public var cacheRange: Int = 2   //cache
    public var preloadRange: Int = 0 //preload
    
    public var showExtraView = true
    public var extraImage: UIImage?
    public var extraImageSize: CGSize = CGSize.zero
    public var extraMaskImage: UIImage?
    public var extraMaskImageSize: CGSize = CGSize.zero
    
    public init() {}
    
    public var isValid: Bool {
        //The cache must be larger than the preload
        guard cacheRange >= preloadRange else { return false }
        return true
    }
}
