//
//  EWPageViewController.swift
//  EWPageController
//
//  Created by Ethan.Wang on 2019/6/21.
//  Copyright © 2019 王利权. All rights reserved.
//

import UIKit

public enum EWViewPageTitleBarScrollStyle {
    case scroll
    case fixed
}

public enum EWViewPageTitleBarOption {
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
    var whenScrollPercent: ((_ percent: CGFloat)->())?
    
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
        self.whenScrollPercent?(scrollView.contentOffset.x)
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
    func options(`for` viewpage: EWPageScrollView) -> [EWViewPageTitleBarOption]?
    func pages(`for` viewPage: EWPageScrollView) -> [EWPage]
    
    func didScrollToPage(index: Int)
    /// 滚动百分比。percent<0向左滚动，percent>0向右滚动
    func didScroll(percent: CGFloat)
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
}

class EWPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.setNeedsLayout()
    }

}
