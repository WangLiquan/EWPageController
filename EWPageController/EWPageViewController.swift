//
//  EWPageViewController.swift
//  EWPageController
//
//  Created by Ethan.Wang on 2019/6/21.
//  Copyright © 2019 王利权. All rights reserved.
//

import UIKit
/// 界面信息宏定义
struct EWScreenInfo {
    static let Frame = UIScreen.main.bounds
    static let Height = Frame.height
    static let Width = Frame.width
    static let navigationHeight:CGFloat = navBarHeight()
    
    static func isIphoneX() -> Bool {
        return UIScreen.main.bounds.equalTo(CGRect(x: 0, y: 0, width: 375, height: 812))
    }
    static private func navBarHeight() -> CGFloat {
        return isIphoneX() ? 88 : 64
    }
}
/// 上方滚动Bar参数
public enum EWViewPageIndicatorBarOption {
    /// bar高度
    case height(CGFloat)
    /// bar背景色
    case backgroundColor(UIColor)
    /// bar左侧padding
    case barPaddingleft(CGFloat)
    /// bar右侧padding
    case barPaddingRight(CGFloat)
    /// bar上方padding
    case barPaddingTop(CGFloat)
    /// bar标题normal字体
    case barItemTitleFont(UIFont)
    /// bar标题选中字体
    case barItemTitleSelectedFont(UIFont)
    /// bar标题颜色
    case barItemTitleColor(UIColor)
    /// bar标题选中颜色
    case barItemTitleSelectedColor(UIColor)
    /// 选中滑块颜色
    case indicatorColor(UIColor)
    /// 选中滑块高度
    case indicatorHeight(CGFloat)
    /// 选中滑块距离bar底部高度
    case indicatorBottom(CGFloat)
    /// bar下分割线颜色
    case bottomlineColor(UIColor)
    /// bar下分割线高度
    case bottomlineHeight(CGFloat)
    /// bar下分割线左padding
    case bottomlinePaddingLeft(CGFloat)
    /// bar下分割线右padding
    case bottomlinePaddingRight(CGFloat)
}
/// 为滚动bar上的scrollview添加delegate，获取bar的滚动状态
fileprivate class EWPageScrollViewDelegate: NSObject, UIScrollViewDelegate {
    weak var scrollView: UIScrollView?
    /// scrollView当前展示左侧x位置
    var startLeft: CGFloat = 0.0
    /// scrollView当前展示右侧x位置
    var startRight: CGFloat = 0.0
    /// 当scrollView滚动到最左侧
    var whenScrollToLeftEdge: (()->())?
    /// 当scrollView滚动到最右侧
    var whenScrollToRightEdge: (()->())?
    /// 当scrollView滚动某一page
    var whenScrollToPageIndex: ((_ index: Int)->())?
    
    /// scrollView开始滚动，UIScrollViewDelegate中的方法
    fileprivate func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        /// 记录scrollView初始位置
        startLeft = scrollView.contentOffset.x
        startRight = scrollView.contentOffset.x + scrollView.frame.size.width
    }
    /// scrollView滚动减速, UIScrollViewDelegate中的方法
    fileprivate func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        /// 获取滚动结束时右侧边的x
        let lastEdge = scrollView.contentOffset.x + scrollView.frame.size.width
        
        if (lastEdge == scrollView.contentSize.width && lastEdge == startRight) {
            /// 如果滚动结束时lastEdge等于scrollView.contentSize.width且 lastEdge等于startRight。相当于scrollView已经滚动到了最右边，并且这次操作并有没有滚动
            self.whenScrollToRightEdge?()
        } else if (scrollView.contentOffset.x == 0 && startLeft == 0) {
            /// 如果滚动结束时scrollView.contentOffset.x == 0且 startLeft == 0。相当于scrollView已经滚动到了最左边，并且这次操作并有没有滚动
            self.whenScrollToLeftEdge?()
        } else {
            /// 正常滚动中根据 scrollView.contentOffset.x来获取选取页的index
            self.whenScrollToPageIndex?(Int(scrollView.contentOffset.x/scrollView.frame.size.width))
        }
    }
}
/// 外部继承delegate方法
protocol EWViewPageDelegate: class {
    func titles(for viewpage: EWPageScrollView) -> [String]
    func options(for viewpage: EWPageScrollView) -> [EWViewPageIndicatorBarOption]?
    func pages(for viewPage: EWPageScrollView) -> [EWPage]
    
    func didScrollToPage(index: Int)
    func didScrollToLeftEdge()
    func didScrollToRightEdge()
}
/// 点击滚动bar标题delegate方法
protocol EWViewpageIndicatorBarDelegate: class {
    func didClickedIndicatorItem(index: Int)
}

typealias EWPage = UIViewController
/// pageView的ScrollView
class EWPageScrollView: UIScrollView {
    private var _pages = [EWPage]()
    fileprivate var pages: [EWPage] {
        return _pages
    }
    
    fileprivate func setup(with pages: [EWPage]) {
        _pages = pages
        self.contentSize = CGSize(width: CGFloat(pages.count) * (self.frame.width), height: 0)
        for (index , page) in pages.enumerated() {
            page.view.frame = CGRect(x: CGFloat(index)*self.frame.width, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    /// 滚动
    fileprivate func scrollToPage(index: Int, animation: Bool = true) {
        guard index < pages.count else { return }
        if animation {
            UIView.animate(withDuration: 0.2) {
                self.contentOffset = CGPoint(x: CGFloat(index)*self.pages[index].view.frame.width, y: 0)
            }
        } else {
            self.contentOffset = CGPoint(x: CGFloat(index)*self.pages[index].view.frame.width, y: 0)
        }
    }
}
/// bar上的button类，有需要自定制功能在这拓展
class EWViewPageIndicatorBarButtonItem: UIButton {
    
}
/// 上方滚动bar
class EWViewPageIndicatorBar: UIView {
    fileprivate weak var delegate: EWViewpageIndicatorBarDelegate?
    
    private let contentView = UIScrollView()
    /// 滑块
    private let indicatorContainer = UIView() ///和barItem一样宽的透明View
    private let indicator = UIView() /// 用户可见的滚动View
    private var indicatorColor = UIColor.gray
    private var indicatorTitles = [String]()
    private var indicatorBackgroundColor = UIColor.white
    private var indicatorHeight: CGFloat = 8.0
    private var indicatorBottom: CGFloat = 0.0
    /// Bar底部线
    private let bottomline = UIView()
    private var bottomlineColor = UIColor.blue
    private var bottomlineHeight: CGFloat = 5.0
    private var bottomlinePaddingLeft: CGFloat = 0.0
    private var bottomlinePaddingRight: CGFloat = 0.0
    /// Bar本身的属性
    private var barHeight: CGFloat = 50.0
    private var paddingLeft: CGFloat = 0.0
    private var paddingRight: CGFloat = 0.0
    private var paddingTop: CGFloat = 0.0
    /// BarItem
    private var barItemTitleFont = UIFont.systemFont(ofSize: 17)
    private var barItemTitleSelectedFont = UIFont.systemFont(ofSize: 17)
    private var barItemWidth: CGFloat = 100.0
    private var barItemTitleColor = UIColor.black
    private var barItemTitleSelectedColor = UIColor.blue
    
    private var buttonItems = [EWViewPageIndicatorBarButtonItem]()
    private var curIndex = 0
    private var itemCount = 0
    
    func setUp(with options: [EWViewPageIndicatorBarOption], titles: [String]) {
        parse(options: options, itemCount: titles.count)
        setUpUIElement(with: titles)
    }
    /// 根据传来的参数配置滚动Bar
    private func parse(options: [EWViewPageIndicatorBarOption], itemCount: Int) {
        for option in options {
            switch (option) {
            case let .height(value):
                self.barHeight = value
            case let .backgroundColor(value):
                self.backgroundColor = value
            case let .barPaddingleft(value):
                self.paddingLeft = value
            case let .barPaddingRight(value):
                self.paddingRight = value
            case let .barPaddingTop(value):
                self.paddingTop = value
            case let .barItemTitleFont(value):
                self.barItemTitleFont = value
            case let .barItemTitleSelectedFont(value):
                self.barItemTitleSelectedFont = value
            case let .barItemTitleColor(value):
                self.barItemTitleColor = value
            case let .barItemTitleSelectedColor(value):
                self.barItemTitleSelectedColor = value
            case let .indicatorColor(value):
                self.indicatorColor = value
            case let .indicatorHeight(value):
                self.indicatorHeight = value
            case let .indicatorBottom(value):
                self.indicatorBottom = value
            case let .bottomlineColor(value):
                self.bottomlineColor = value
            case let .bottomlineHeight(value):
                self.bottomlineHeight = value
            case let .bottomlinePaddingLeft(value):
                self.bottomlinePaddingLeft = value
            case let .bottomlinePaddingRight(value):
                self.bottomlinePaddingRight = value
            }
        }
        self.itemCount = itemCount
        /// barItemWidth自适应
        self.barItemWidth = (EWScreenInfo.Width-paddingLeft-paddingRight)/CGFloat(itemCount)
    }
    
    private func setUpUIElement(with titles: [String]) {
        self.addSubview(contentView)
        contentView.frame = CGRect(x: paddingLeft, y: paddingTop, width: UIScreen.main.bounds.width-paddingLeft-paddingRight, height: barHeight-paddingTop)
        contentView.backgroundColor = UIColor.clear
        self.frame = CGRect(x: 0, y: EWScreenInfo.navigationHeight, width: EWScreenInfo.Width, height: barHeight)
        contentView.contentSize = CGSize(width: barItemWidth*CGFloat(titles.count), height: barHeight-paddingTop)
        
        for (index, title) in titles.enumerated() {
            let buttonItem = EWViewPageIndicatorBarButtonItem()
            buttonItem.backgroundColor = UIColor.clear
            buttonItem.titleLabel?.font = barItemTitleFont
            buttonItem.setTitle(title, for: .normal)
            buttonItem.titleLabel?.textAlignment = .center
            buttonItem.titleLabel?.sizeToFit()
            buttonItem.setTitleColor(barItemTitleColor, for: .normal)
            buttonItem.tag = index
            buttonItem.frame = CGRect(x: CGFloat(index)*barItemWidth, y: 0, width: barItemWidth, height: barHeight-paddingTop)
            buttonItem.addTarget(self, action: #selector(onClickTitle(_:)), for: .touchUpInside)
            buttonItems.append(buttonItem)
            contentView.addSubview(buttonItem)
        }
        
        bottomline.frame = CGRect(x: bottomlinePaddingLeft,
                                  y: barHeight - bottomlineHeight,
                                  width: EWScreenInfo.Width - bottomlinePaddingLeft - bottomlinePaddingRight,
                                  height: bottomlineHeight / UIScreen.main.scale * 2)
        bottomline.backgroundColor = bottomlineColor
        self.addSubview(bottomline)
        
        indicatorContainer.frame = CGRect(x: 0,
                                          y: barHeight - paddingTop - 6 - indicatorBottom,
                                          width: barItemWidth,
                                          height: indicatorHeight)
        indicatorContainer.addSubview(indicator)
        indicator.backgroundColor = indicatorColor
        contentView.addSubview(indicatorContainer)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    /// 点击bar上title
    @objc private func onClickTitle(_ title: UIControl) {
        let index = Int(title.tag)
        self.delegate?.didClickedIndicatorItem(index: index)
        scrollIndicator(to: index)
    }
    /// 外部方法，滚动至目标位置
    fileprivate func scrollIndicator(to index: Int, animated: Bool = true) {
        let range = 0..<buttonItems.count
        guard range.contains(index) else { return }
        var offsetX = CGFloat(index) * barItemWidth + barItemWidth/2
        offsetX = offsetX - contentView.frame.width/2
        offsetX = min(offsetX,contentView.contentSize.width - contentView.frame.width)
        offsetX = max(offsetX,0)
        contentView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        let originalItem = buttonItems[curIndex]
        originalItem.setTitleColor(barItemTitleColor, for: .normal)
        originalItem.titleLabel?.font = barItemTitleFont
        curIndex = index
        let currentItem = buttonItems[curIndex]
        currentItem.setTitleColor(barItemTitleSelectedColor, for: .normal)
        currentItem.titleLabel?.font = barItemTitleFont
        /// 动画滚动滑块
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.indicatorContainer.frame = CGRect(x: CGFloat(index) * self.barItemWidth,
                                                   y: self.barHeight - self.paddingTop - self.indicatorHeight,
                                                   width: self.barItemWidth,
                                                   height: self.indicatorHeight)
            if let titleLabel = currentItem.titleLabel {
                if titleLabel.frame.width != 0 {
                    self.indicator.frame = CGRect(x: titleLabel.frame.origin.x,
                                                  y: 0,
                                                  width: titleLabel.frame.width,
                                                  height: self.indicatorHeight)
                }
            }else {
                self.indicator.frame = self.indicatorContainer.frame
            }
        }
    }
    
}

class EWPageViewController: UIViewController, EWViewPageDelegate, EWViewpageIndicatorBarDelegate {

    private var _titles = [String]()
    var titles: [String] {
        return _titles
    }
    private var _viewPage: EWPageScrollView! = nil
    var viewPage : EWPageScrollView {
        return _viewPage
    }
    /// 选中index
    private var _curIndex = 0
    var curIndex : Int {
        set(newValue) {
            _curIndex = newValue
        }
        get {
            return _curIndex
        }
    }
    
    private let scrollDelegate = EWPageScrollViewDelegate()
    private var indicatorBar = EWViewPageIndicatorBar()
    /// 通过这个属性保证滚动滑块的显示
    private var autoScrollIndicator = true
    var scrollEnable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _curIndex = defaultPageIndex()
        self.setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.setNeedsLayout()
    }
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.indicatorBar.scrollIndicator(to: curIndex, animated: false)
        viewPage.scrollToPage(index: curIndex)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoScrollIndicator = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// 第一次load页面时调用方法加载滚动滑块
        if autoScrollIndicator {
            self.indicatorBar.scrollIndicator(to: curIndex, animated: false)
        }
    }
    private func setupUI() {
        _viewPage = EWPageScrollView()
        _viewPage.bounces = false
        _viewPage.isScrollEnabled = scrollEnable
        
        self._titles = self.titles(for: self._viewPage)
        if let options = self.options(for: self._viewPage) {
            self.indicatorBar.setUp(with: options, titles: titles)
        }
        self.indicatorBar.delegate = self
        self.view.addSubview(indicatorBar)
        
        let viewPageFrame = CGRect(x: 0,
                                   y: self.indicatorBar.frame.origin.y + self.indicatorBar.frame.height,
                                   width: self.view.frame.width,
                                   height: self.view.frame.height - EWScreenInfo.navigationHeight - self.indicatorBar.frame.height)
        _viewPage.frame = viewPageFrame
        _viewPage.setup(with: self.pages(for: self._viewPage))
        _viewPage.pages.forEach({ viewPage.addSubview($0.view); self.addChild($0)})
        _viewPage.scrollToPage(index: _curIndex, animation: false)
        scrollDelegate.scrollView = _viewPage
        _viewPage.delegate = scrollDelegate
        _viewPage.isPagingEnabled = true
        _viewPage.showsHorizontalScrollIndicator = false
        self.view.addSubview(_viewPage)
        
        self.scrollDelegate.whenScrollToLeftEdge = { [weak self] in
            self?.didScrollToLeftEdge()
        }
        self.scrollDelegate.whenScrollToRightEdge = { [weak self] in
            self?.didScrollToRightEdge()
        }
        self.scrollDelegate.whenScrollToPageIndex = { [weak self] index in
            self?._curIndex = index
            self?.didScrollToPage(index: index)
            self?._viewPage.scrollToPage(index: index)
            self?.indicatorBar.scrollIndicator(to: index)
        }
    }
    /// 点击上方滑动barItem
    func didClickedIndicatorItem(index: Int) {
        _viewPage.scrollToPage(index: index)
        self.didScrollToPage(index: index)
    }
    /// 默认index
    func defaultPageIndex() -> Int {
        return 0
    }
    //MARK:  外部调用方法,必须override
    func titles(for viewpape: EWPageScrollView) -> [String] {
        fatalError("请覆盖该方法")
    }
    func options(for viewpage: EWPageScrollView) -> [EWViewPageIndicatorBarOption]? {
        fatalError("请覆盖该方法")
    }
    func pages(for viewPage: EWPageScrollView) -> [EWPage] {
        fatalError("请覆盖该方法")
    }
    func didScrollToPage(index: Int) {
        fatalError("请覆盖该方法")
    }
    func didScrollToLeftEdge() {
        fatalError("请覆盖该方法")
    }
    func didScrollToRightEdge() {
        fatalError("请覆盖该方法")
    }
}
