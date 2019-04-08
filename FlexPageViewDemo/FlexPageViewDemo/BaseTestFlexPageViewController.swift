//
//  BaseTestFlexPageViewController.swift
//  FlexPageView
//
//  Created by nullLuli on 2019/3/12.
//  Copyright © 2019 nullLuli. All rights reserved.
//

import Foundation
import UIKit
import FlexPageView

class BaseTestFlexPageViewController<CellData: IMenuViewCellData, Cell: UICollectionViewCell>: UIViewController, FlexPageViewDataSource, FlexPageViewUISource, FlexPageViewDelegate {
    var pageView: FlexPageView<CellData>?
    
    var layout: MenuViewBaseLayout {
        return MenuViewBaseLayout()
    }
    
    var cellDatas: [CellData] {
        return []
    }
    
    let titles: [String] = ["标题", "长长的标题", "短", "长长长长的标题", "无法证明", "一场朋友", "大约离别时", "倾城", "太傻", "美静", "孤独不苦", "喜欢"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge.right
        var option = FlexPageViewOption()
        option.titleMargin = 70
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.3
        option.preloadRange = 1
        option.underlineColor = UIColor(rgb: 0x4285F4)
        option.selectedColor = UIColor(rgb: 0x262626)
        option.titleColor = UIColor(rgb: 0x999CA0)
        option.extraImageName = "ic_nav_menu"
        option.extraImageSize = CGSize(width: 50, height: 40)
        option.extraMaskImageName = "Rectangle"
        option.extraMaskImageSize = CGSize(width: 50, height: 40)

        let pageView = FlexPageView<CellData>(option: option, layout: layout)
        pageView.delegate = self
        pageView.dataSource = self
        pageView.uiSource = self
        view.addSubview(pageView)
        pageView.frame = view.bounds
        self.pageView = pageView
    }
    
    // MARK: FlexPageView
    func numberOfPage() -> Int {
        return titles.count
    }
    
    func titleDatas() -> [IMenuViewCellData] {
        return cellDatas
    }
    
    func page(at index: Int) -> UIView {
        let control = ContentController()
        control.title = titles[index]
        addChildViewController(control)
        control.didMove(toParentViewController: self)
        return control.view
    }
    
    func pageID(at index: Int) -> String {
        return String(index)
    }
    
    func register() -> [String : UICollectionViewCell.Type] {
        return [Cell.identifier : Cell.self]
    }
    
    func extraViewAction() {
        let label = UILabel()
        label.text = "extraViewAction"
        view.addSubview(label)
        label.sizeToFit()
        label.center = view.center
        label.backgroundColor = UIColor.black
        label.textColor = UIColor.white
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            label.removeFromSuperview()
        }
    }
    
    func didRemovePage(_ page: UIView, at index: Int) {
        for control in childViewControllers {
            if control.view == page {
                control.removeFromParentViewController()
            }
        }
    }
    
    func pageWillAppear(_ page: UIView, at index: Int) {
        debugPrint("pageWillAppear \(index)")
    }
    
    func pageWillDisappear(_ page: UIView, at index: Int) {
        debugPrint("pageWillDisappear \(index)")
    }
    
}

extension UIColor {
    //返回随机颜色
    open class var randomColor: UIColor{
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
