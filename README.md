## Description

- 类似UISegmentController的UI结构，有一个菜单栏，菜单栏下面是内容页

- 菜单栏的点击会同步到下面的内容页，以便内容页翻页

- 内容页支持滑动翻页，也会同步到上方的菜单栏中，让菜单栏更新选中标签

- 菜单栏可以横向滑动，支持超过一屏菜单

- 内容页不用跟着菜单栏一次全部加载出来，以避免无用的内容页加载

- 内容页的加载支持缓存，以减少同样的内容的网络请求

- 内容页的加载支持预加载，减少翻页后用户等待内容加载的时间

- 菜单栏的UI可以定制

## Installation

* <a href="https://guides.cocoapods.org/using/using-cocoapods.html" target="_blank">CocoaPods</a>:

```ruby
pod 'FlexPageView'
```
## Design & Usage

#### FlexMenuView - 菜单栏

##### 自定义UI

FlexMenuView是UICollectionView的子类，以便提供定制化菜单栏UI的需求。

<p align="left">
    <img src="https://github.com/nullLuli/FlexPageView/blob/master/%E9%80%9A%E8%BF%87data%E8%8E%B7%E5%8F%96cell.png" width="50%" height="50%" alt="通过data获取cell" />
</p>

通过实现IMenuViewCell和IMenuViewCellData协议，在FlexPageViewUISource的register方法中注册cell，来实现定制菜单的UI。

```swift
class Controller: UIViewController, FlexPageViewUISource {
	func register() -> [String : UICollectionViewCell.Type] {
    return [CustomCell.identifier : CustomCell.self]
	}
}
```

通过实现MenuViewBaseLayout的子类，来为了FlexMenuView提供自定义的布局

```swift
let option = FlexPageViewOption()
let layout = CustomLayout(option: option) //不一定需要option，看你的布局需求
FlexPageView(option: option, layout: layout)
```

##### 为FlexMenuView提供数据

```swift
class Controller: UIViewController, FlexPageViewDataSource {
  func titleDatas() -> [IMenuViewCellData] {
    return YourDatas
	}
}
```

#### PageContentView - 内容区域

##### 加载内容页

FlexPageView会像UITableView那样，页面滚动到哪里，就使用page:方法获取哪个页面，对应UITableView的cellForRowAt indexPath

```swift
class Controller: UIViewController, FlexPageViewDataSource {
  func page(at index: Int) -> UIView {
    let controller = YourController()
    addChild(controller)
    controller.didMove(toParent: self)
    return controller.view
	}
}
```

需要注意的是，FlexPageView只接受UIView，如果你的内容页有它的controller，需要在page:方法中将controller add到上一级controller上，并且调用controller.didMove方法，以保证你能收到UIViewController中的viewWillAppear系列方法

同样的，你需要在didRemovePage方法中调用相应controller的removeFromParent方法

```swift
class Controller: UIViewController, FlexPageViewDataSource {
	func didRemovePage(_ page: UIView, at index: Int) {
     for control in children {
         if control.view == page {
             control.removeFromParent()
         }
     }
  }
}
```



##### 设置缓存与预加载

可以使用FlexPageViewOption设置缓存范围，设置缓存范围x后，当前页的前x页和后x页就不会被释放

```swift
var option = FlexPageViewOption()
option.cacheRange = 1 //当前页的前一页和后一页会被缓存
```

设置预加载范围

```
var option = FlexPageViewOption()
option.preloadRange = 1
```

缓存范围必须比预加载范围大，生成FlexPageView的时候会检查，如果缓存值小于预加载值，FlexPageView会初始化失败

##### 命中缓存

FlexPageView.reloadData时，会根据FlexPageViewDataSource提供的页面ID命中缓存

```swift
class Controller: UIViewController, FlexPageViewDataSource {
  func pageID(at index: Int) -> String {
    return IdOfPageAtIndex
	}
}
```

## Author
[iOS切换标签组件 FlexPageView](https://www.jianshu.com/p/d1044a1939d1)