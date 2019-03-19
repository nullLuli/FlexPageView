<p align="center">
    <img src="https://github.com/nullLuli/FlexPageView/blob/master/1552911813695.gif" width="30%" height="30%" alt="Screenshot Preview" />
</p>


## Features

* 仿UITableView，翻页操作同业务分离，使用代理的方式获取数据和UI
* 支持定制标签栏UI
* 支持翻页的视差效果
* 支持预加载、缓存

## Installation

* <a href="https://guides.cocoapods.org/using/using-cocoapods.html" target="_blank">CocoaPods</a>:

```ruby
pod 'FlexPageView'
```
## Usage

```swift
//1. 生成一个FlexPageView，并添加到view层级中
var option = FlexPageViewOption()
option.selectedColor = UIColor.red //option中定制UI
let layout = MenuViewLayout() //可以是自己的自定义的layout
let pageView = FlexPageView(option: option, layout: layout)
pageView.frame = view.bounds
view.addSubview(pageView)

//2. 设置FlexPageView的代理
pageView.delegate = self //FlexPageViewDelegate
pageView.dataSource = self //FlexPageViewDataSource
pageView.uiSource = self //FlexPageViewUISource

//3. 实现代理方法
//FlexPageViewDelegate
func didRemovePage(_ page: UIView, at index: Int) {}
func pageWillAppear(_ page: UIView, at index: Int) {}
func pageWillDisappear(_ page: UIView, at index: Int) {}
func extraViewAction() {}

//FlexPageViewDataSource
func numberOfPage() -> Int {return 0}
func titleDatas() -> [IMenuViewCellData] {return []}
func page(at index: Int) -> UIView {return UIView()}
func pageID(at index: Int) -> Int {return index}

//FlexPageViewUISource
func register() -> [String: UICollectionViewCell.Type] {return ["MenuViewCellData": MenuViewCellData.self]}
```
## Design & Author
[iOS切换标签组件 FlexPageView](https://www.jianshu.com/p/d1044a1939d1)