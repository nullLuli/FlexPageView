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
    var pageView: FlexPageView?
    
    var layout: MenuViewBaseLayout {
        return MenuViewBaseLayout()
    }
    
    var cellDatas: [CellData] {
        return []
    }
    
    let titles: [String] = ["关注", "推荐", "热榜", "一个长的标签", "短", "汽车", "5G", "科技", "生活"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge.right
        setupFlexPageView()
    }
    
    private func setupFlexPageView() {
        var option = FlexPageViewOption()
        option.titleMargin = 30
        option.allowSelectedEnlarge = true
        option.selectedScale = 1.3
        option.preloadRange = 1
        option.underlineColor = UIColor(rgb: 0x4285F4)
        option.selectedColor = UIColor(rgb: 0x262626)
        option.titleColor = UIColor(rgb: 0x999CA0)
        option.extraImage = UIImage(named: "ic_nav_menu")
        option.extraImageSize = CGSize(width: 50, height: 40)
        option.extraMaskImage = UIImage(named: "Rectangle")
        option.extraMaskImageSize = CGSize(width: 50, height: 40)

        if let pageView = FlexPageView(option: option, layout: getLayout(option: option)) {
            pageView.delegate = self
            pageView.dataSource = self
            pageView.uiSource = self
            self.pageView = pageView
            view.addSubview(pageView)
        }
    }
    
    func getLayout(option: FlexPageViewOption) -> MenuViewBaseLayout {
        return MenuViewBaseLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        pageView?.frame = view.bounds
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
        addChild(control)
        control.didMove(toParent: self)
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
    
    func selectItemFromTapMenuView(select index: Int) {
    }

    func didRemovePage(_ page: UIView, at index: Int) {
        for control in children {
            if control.view == page {
                control.removeFromParent()
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
