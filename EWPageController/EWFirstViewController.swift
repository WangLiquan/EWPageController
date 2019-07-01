//
//  FirstViewController.swift
//  EWPageController
//
//  Created by Ethan.Wang on 2019/6/27.
//  Copyright © 2019 王利权. All rights reserved.
//

import UIKit

class EWFirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        drawMyView()
    }
    private func drawMyView() {
        self.view.backgroundColor = UIColor.gray
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 200, width: EWScreenInfo.Width, height: 200))
        titleLabel.text = "第一页"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 40)
        self.view.addSubview(titleLabel)
    }
}
