//
//  UIViewController+Avalable.swift
//  Adorawe
//
//  Created by fan wang on 2021/9/16.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation


extension UIViewController{
    
   @objc func setUpNavigationBg(color:UIColor){
        navigationController?.navigationBar.setBackgroundImage(UIImage.yy_image(with: color), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if #available(iOS 15, *) {
            let app = UINavigationBarAppearance.init()
            app.configureWithOpaqueBackground()  // 重置背景和阴影颜色
//            app.titleTextAttributes = [
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
//                NSAttributedString.Key.foregroundColor: UIColor.white
//            ]
            app.backgroundColor = color  // 设置导航栏背景色
            app.shadowImage = UIImage.yy_image(with: color)  // 设置导航栏下边界分割线透明
            navigationController?.navigationBar.scrollEdgeAppearance = app  // 带scroll滑动的页面
            navigationController?.navigationBar.standardAppearance = app // 常规页面
        }
    }
}
