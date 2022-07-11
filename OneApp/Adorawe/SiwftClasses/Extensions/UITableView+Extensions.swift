//
//  UITableView+Extensions.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/4.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

extension UITableView{
    ///TableView group 圆角背景
    @objc func roundedGroup(willDisplay cell: UITableViewCell,
                      forRowAt indexPath: IndexPath,
                      radius:CGFloat = 6,
                      backgroundColor:UIColor = .white,
                      horizontolPadding:CGFloat = 11) {
        cell.backgroundColor = .clear
        let normalLayer = CAShapeLayer()
        let selectLayer = CAShapeLayer()
        let bounds = cell.bounds.insetBy(dx:horizontolPadding, dy:0)
        let rowNum = self.numberOfRows(inSection: indexPath.section)
        var bezierPath:UIBezierPath
        if rowNum == 1 {
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii:CGSize(width: radius, height: radius))
        }else{
            if indexPath.row == 0 {
                bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii:CGSize(width: radius, height: radius))
            }else if indexPath.row == rowNum - 1{
                bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [UIRectCorner.bottomLeft,UIRectCorner.bottomRight], cornerRadii:CGSize(width: radius, height: radius))
            }else{
                bezierPath = UIBezierPath(rect: bounds)
            }
        }
        
        normalLayer.path = bezierPath.cgPath
        selectLayer.path = bezierPath.cgPath
        
        let normalBgView = UIView(frame: bounds)
        normalLayer.fillColor = backgroundColor.cgColor
        normalBgView.layer.insertSublayer(normalLayer, at: 0)
        normalBgView.backgroundColor = .clear
        cell.backgroundView = normalBgView
        
        let selectedBgView = UIView(frame: bounds)
        selectLayer.fillColor = backgroundColor.cgColor
        selectedBgView.layer.insertSublayer(selectLayer, at: 0)
        selectedBgView.backgroundColor = .clear
        cell.selectedBackgroundView = selectedBgView
    }
}
