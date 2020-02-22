//
//  UIColor+Trans.swift
//  FlexPageView
//
//  Created by PXCM-0101-01-0045 on 2020/2/21.
//  Copyright © 2020 nullLuli. All rights reserved.
//

extension UIColor {
    public class func transition(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
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
}
