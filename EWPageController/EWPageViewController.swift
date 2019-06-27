//
//  EWPageViewController.swift
//  EWPageController
//
//  Created by Ethan.Wang on 2019/6/21.
//  Copyright © 2019 王利权. All rights reserved.
//

import UIKit

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

public enum EWViewPageTitleBarScrollStyle {
    case scroll
    case fixed
}

public enum EWViewPageIndicatorBarOption {
    case height(CGFloat)
    case backgroundColor(UIColor)
    case scrollStyle(EWViewPageTitleBarScrollStyle)
    case barPaddingleft(CGFloat)
    case barPaddingRight(CGFloat)
    case barPaddingTop(CGFloat)
    case barItemTitleFont(UIFont)
    case barItemTitleSelectedFont(UIFont)
    case barItemTitleColor(UIColor)
    case barItemTitleSelectedColor(UIColor)
    case barItemWidth(CGFloat)
    case indicatorColor(UIColor)
    case indicatorHeight(CGFloat)
    case indicatorBottom(CGFloat)
    case bottomlineColor(UIColor)
    case bottomlineHeight(CGFloat)
    case bottomlinePaddingLeft(CGFloat)
    case bottomlinePaddingRight(CGFloat)
}

fileprivate class EWPageScrollViewDelegate: NSObject, UIScrollViewDelegate {
    weak var scrollView: UIScrollView?
    var startLeft: CGFloat = 0.0
    var startRight: CGFloat = 0.0
    var whenScrollToLeftEdge: (()->())?
    var whenScrollToRightEdge: (()->())?
    var whenScrollToPageIndex: ((_ index: Int)->())?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else {
            print("newScrollView")
            return
        }
        startLeft = scrollView.contentOffset.x
        startRight = scrollView.contentOffset.x + scrollView.frame.size.width
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        self.whenScrollToPageIndex?(Int(scrollView.contentOffset.x/scrollView.frame.size.width))
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else {
            print("newScrollView")
            return
        }
        let bottomEdge = scrollView.contentOffset.x + scrollView.frame.size.width
        if (bottomEdge >= scrollView.contentSize.width && bottomEdge == startRight) {
            self.whenScrollToLeftEdge?()
        }
        if (scrollView.contentOffset.x == 0 && startLeft == 0) {
            self.whenScrollToRightEdge?()
        }
    }
}

protocol EWViewPageDelegate: class {
    func titles(`for` viewpape: EWPageScrollView) -> [String]
    func options(`for` viewpage: EWPageScrollView) -> [EWViewPageIndicatorBarOption]?
    func pages(`for` viewPage: EWPageScrollView) -> [EWPage]
    
    func didScrollToPage(index: Int)
    func didScrollToLeftEdge()
    func didScrollToRightEdge()
}

protocol EWViewpageIndicatorBarDelegate: class {
    func didClickedIndicatorItem(index: Int)
}

typealias EWPage = UIViewController

class EWPageScrollView: UIScrollView {
    private var _pages = [EWPage]()
    var pages: [EWPage] {
        return _pages
    }
    
    func setup(with pages: [EWPage]) {
        _pages = pages
        self.contentSize = CGSize(width: CGFloat(pages.count) * (self.frame.width), height: 0)
        for (index , page) in pages.enumerated() {
            page.view.frame = CGRect(x: CGFloat(index)*self.frame.width, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    func scrollToPage(index: Int, animation: Bool = true) {
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

class EWPageIndicator: UIButton {
    
}

class EWViewPageIndicatorBarButtonItem: UIButton {
    
}

class EWViewPageIndicatorBar: UIView {
    fileprivate weak var delegate: EWViewpageIndicatorBarDelegate?
    
    private let contentView = UIScrollView()
    
    ///滑块
    private let indicatorContainer = UIView()
    private let indicator = UIView() //??
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
    /// BarItem是可以滚动的还是固定的
    private var scrollStyle = EWViewPageTitleBarScrollStyle.fixed
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
    private func parse(options: [EWViewPageIndicatorBarOption], itemCount: Int) {
        for option in options {
            switch (option) {
            case let .height(value):
                self.barHeight = value
            case let .backgroundColor(value):
                self.backgroundColor = value
            case let .scrollStyle(value):
                self.scrollStyle = value
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
            case let .barItemWidth(value):
                self.barItemWidth = value
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
        switch scrollStyle {
        case .fixed:
            self.barItemWidth = (EWScreenInfo.Width-paddingLeft-paddingRight)/CGFloat(itemCount)
        case .scroll: break
        }
    }
    func setUpUIElement(with titles: [String]) {
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
    @objc func onClickTitle(_ title: UIControl) {
        let index = Int(title.tag)
        self.delegate?.didClickedIndicatorItem(index: index)
        scrollIndicator(to: index)
    }
    public func scrollIndicator(to index: Int, animated: Bool = true) {
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
    private var _curIndex = 0
    var curIndex : Int {
        set(newValue) {
            _curIndex = newValue
        }
        get {
            return _curIndex
        }
    }
    var autoSetupUI: Bool = true
    
    private let scrollDelegate = EWPageScrollViewDelegate()
    private var indicatorBar = EWViewPageIndicatorBar()
    
    private var autoScrollIndicator = true
    var scrollEnable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _curIndex = defaultPageIndex()
        if autoSetupUI {
            self.setupUI()
        }
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
        if autoScrollIndicator {
            self.indicatorBar.scrollIndicator(to: curIndex, animated: false)
        }
    }
    func setupUI() {
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
    
    func defaultPageIndex() -> Int {
        return 0
    }
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
    func didClickedIndicatorItem(index: Int) {
        _viewPage.scrollToPage(index: index)
        self.didScrollToPage(index: index)
    }

}
