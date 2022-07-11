//
//  YXCommentDetailPopView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailPopView: UIView {
    
    @objc var popBlock:((_ type:Int) -> Void)?
    
    var popList: [Int] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc convenience init( list:[Int], isWhiteStyle:Bool, clickCallBack:((_ type:Int) -> Void)?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 75, height: 40 * list.count))
        self.popBlock = clickCallBack
        self.popList = list
//        self.layer.masksToBounds = true
//        backgroundColor = isWhiteStyle ? .white : QMUITheme().popupLayerColor()
        for (index, type) in list.enumerated() {
            
            let button = QMUIButton()
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            let titleColor:UIColor = isWhiteStyle ? QMUITheme().textColorLevel1() : QMUITheme().textColorLevel1()
            button.setTitleColor(titleColor, for: .normal)
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            button.tag = index
            button.spacingBetweenImageAndTitle = 8
            button.frame = CGRect(x: 0, y: index * 40, width: Int(frame.size.width), height: 40)
            if type == CommentButtonType.delete.rawValue {
                button.setTitle(YXLanguageUtility.kLang(key: "common_delete"), for: .normal)
            }else if type == CommentButtonType.report.rawValue {
                button.setTitle(YXLanguageUtility.kLang(key: "report_comment"), for: .normal)
             
            }else {
                button.setTitle(YXLanguageUtility.kLang(key: "share"), for: .normal)
               
            }
            
            addSubview(button)
            if index < list.count - 1 {
                let lineView = UIView.init(frame: CGRect(x: 6, y: CGFloat((index + 1) * 40), width: (CGFloat(frame.size.width - 12) ), height: CGFloat(0.5)))
                lineView.backgroundColor = QMUITheme().popSeparatorLineColor()
                addSubview(lineView)
            }
            
        }
    }
    
    @objc func buttonClick(_ sender: QMUIButton) {
        let index:Int = sender.tag
        if index < self.popList.count {
            let type: Int = self.popList[index]
            self.popBlock?(type)
        }
       
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
