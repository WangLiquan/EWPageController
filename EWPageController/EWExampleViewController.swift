//
//  EWExampleViewController.swift
//  EWPageController
//
//  Created by Ethan.Wang on 2019/6/27.
//  Copyright © 2019 王利权. All rights reserved.
//

import UIKit

class EWExampleViewController: EWPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Example"
    }
    /// 子控制器数量由下两个方法控制
    /// 子控制器title
    override func titles(for viewpage: EWPageScrollView) -> [String] {
        return ["第一页","第二页","第三页","第四页"]
    }
    /// 子控制器
    override func pages(for viewPage: EWPageScrollView) -> [EWPage] {
        return [EWSubViewController(text: "第一页"),EWSubViewController(text: "第二页"),EWSubViewController(text: "第三页"),EWSubViewController(text: "第四页")]
    }
    /// 子控制器UI设置
    override func options(for viewpage: EWPageScrollView) -> [EWViewPageIndicatorBarOption]? {
        let pageOptions: [EWViewPageIndicatorBarOption] = [
            .height(52),
            .backgroundColor(UIColor.white),
            .barPaddingleft(0),
            .barPaddingRight(0),
            .barItemTitleFont(UIFont.systemFont(ofSize: 15)),
            .barItemTitleSelectedFont(UIFont.boldSystemFont(ofSize: 15)),
            .barItemTitleColor(UIColor.lightGray),
            .barItemTitleSelectedColor(UIColor.black),
            .indicatorColor(UIColor.red),
            .indicatorHeight(2),
            .indicatorBottom(5),
            .bottomlineColor(UIColor.brown),
            .bottomlineHeight(0)
        ]
        return pageOptions
    }
    /// 当前显示子控制器index
    override func didScrollToPage(index: Int) {
        print(index)
    }
    /// 滚动至最左边控制器后仍左滑
    override func didScrollToLeftEdge() {
        print("left")
    }
    /// 滚动至最右边控制器后仍右滑
    override func didScrollToRightEdge() {
        print("right")
    }
}
