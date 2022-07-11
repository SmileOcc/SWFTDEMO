//
//  YXAlertTool.swift
//  uSmartEducation
//
//  Created by tao.sun on 2021/8/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAlertTool: NSObject {
    
    class func commonAlert(title: String, message: String,  leftTitle: String, rightTitle: String, leftBlock: (() ->Void)?, rightBlock: (() ->Void)? ) {
        let knowAction: QMUIAlertAction = QMUIAlertAction.init(title: leftTitle, style: .cancel) {  _, _ in
            if let left = leftBlock {
                left()
            }
        }
        let loginAction: QMUIAlertAction = QMUIAlertAction.init(title: rightTitle, style: .default) {  _, _ in
            if let right = rightBlock {
                right()
            }
        }
        
        let alterVC = QMUIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alterVC.alertContentCornerRadius = 6
        alterVC.sheetContentCornerRadius = 6
        if var messageAttr = alterVC.alertMessageAttributes {
            messageAttr[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 14)
            messageAttr[NSAttributedString.Key.foregroundColor] = QMUITheme().textColorLevel1()
            alterVC.alertMessageAttributes = messageAttr
        }
      
        alterVC.alertCancelButtonAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()]
        alterVC.alertButtonAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium), NSAttributedString.Key.foregroundColor : QMUITheme().mainThemeColor()]
        alterVC.addAction(knowAction)
        alterVC.addAction(loginAction)
        alterVC.showWith(animated: true)
    }
    
    class func commonOneButtonAlert(title: String, message: String,  leftTitle: String, leftBlock: (() ->Void)? ) {
        let knowAction: QMUIAlertAction = QMUIAlertAction.init(title: leftTitle, style: .default) {  _, _ in
            if let left = leftBlock {
                left()
            }
        }
        let alterVC = QMUIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if var messageAttr = alterVC.alertMessageAttributes {
            messageAttr[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 14)
            messageAttr[NSAttributedString.Key.foregroundColor] = QMUITheme().textColorLevel1()
            alterVC.alertMessageAttributes = messageAttr
        }
        
        alterVC.alertCancelButtonAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel4()]
        alterVC.alertButtonAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : QMUITheme().mainThemeColor()]
       
        alterVC.addAction(knowAction)
        alterVC.showWith(animated: true)
    }

}
