//
//  EWSubViewController.swift
//  EWPageController
//
//  Created by Ethan.Wang on 2019/7/11.
//  Copyright © 2019 王利权. All rights reserved.
//

import UIKit

class EWSubViewController: UIViewController {

    private var text: String?

    init(text:String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        drawMyView()
        // Do any additional setup after loading the view.
    }
    private func drawMyView() {
        self.view.backgroundColor = UIColor.randomColor
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 200, width: EWScreenInfo.Width, height: 200))
        titleLabel.text = self.text
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 40)
        self.view.addSubview(titleLabel)
    }
}

extension UIColor {
    /// 返回随机颜色
    public class var randomColor:UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
