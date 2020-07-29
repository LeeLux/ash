//
//  ViewController.swift
//  Theme
//
//  Created by Laziest on 2020/7/29.
//  Copyright © 2020 LaziestLee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let iv = UIImageView()
        view.addSubview(iv)
        iv.backgroundColor = .red
        iv.theme_image = UIImage.theme_imageNamed(name: "Icon-Small")
        iv.frame = CGRect(x: 100, y: 100, width: 100, height: 100);
        ThemeHelper.helper.theme = .ash

    }


}

