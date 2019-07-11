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
    override func titles(for viewpage: EWPageScrollView) -> [String] {
        return ["第一页","第二页"]
    }
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
    override func pages(for viewPage: EWPageScrollView) -> [EWPage] {
        return [EWFirstViewController(), EWSecondViewController()]
    }
    override func didScrollToPage(index: Int) {
        print(index)
    }
    override func didScrollToLeftEdge() {
        print("left")
    }
    override func didScrollToRightEdge() {
        print("right")
    }
}
