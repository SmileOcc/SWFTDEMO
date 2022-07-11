//
//  YXPauseListAlertView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXPauseAlertTool: NSObject {
    
    
    
    @objc static func showWithList(_ list: [YXLiveDetailModel]?, _ callBack: ((_ model: YXLiveDetailModel)->())? ) {
        if let list = list, list.count > 0 {
            let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "live_want_to_continue"), message: nil, prompt: nil, style: .default, messageAlignment: .left)

            let contenView = YXPauseListAlertView.init()
            if list.count == 1 {
                contenView.frame = CGRect.init(x: 0, y: 0, width: 285, height: 40)
            } else {
                contenView.frame = CGRect.init(x: 0, y: 0, width: 285, height: list.count * 30)
            }
            contenView.list = list
            alertView.addCustomView(contenView)
                            
            let cancel = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel) { (action) in
                alertView.hideInWindow()
            }
            let confirm = YXAlertAction.init(title: YXLanguageUtility.kLang(key: "live_continue"), style: .default) { (action) in
                alertView.hideInWindow()
                if list.count == 1 {
                    callBack?(list[0])
                } else {
                    if let btn = contenView.preBtn {
                        callBack?(list[btn.tag])
                    }
                }
            }
            alertView.addAction(cancel)
            alertView.addAction(confirm)
            alertView.showInWindow()
        }
    }
    
}

class YXPauseListSingleAlertView: UIView {
    
}

class YXPauseListAlertView: UIView {
    
    var preBtn: UIButton?

    @objc var list: [YXLiveDetailModel]? {
        
        didSet {
            if let list = self.list {
                
                if list.count == 1 {
                    let titleLabel = UILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.systemFont(ofSize: 14), text: list.first?.title)
                    titleLabel.textAlignment = .center
                    addSubview(titleLabel)
                    titleLabel.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().offset(16)
                        make.right.equalToSuperview().offset(-16)
                        make.centerY.equalToSuperview()
                        make.height.equalTo(22)
                    }
                } else {
                    let stackView = UIStackView.init()
                    stackView.axis = .vertical
                    stackView.distribution = .fillEqually
                    for i in 0..<list.count {
                        let model = list[i]
                        let tempView = UIView.init()
                        let titleLabel = UILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.systemFont(ofSize: 14), text: model.title)
                        let selecBtn = UIButton.init(type: .custom, image: UIImage(named: "edit_uncheck_WhiteSkin"), target: self, action: #selector(self.selecBtnClick(_:)))!
                        selecBtn.setImage(UIImage(named: "normal_selected_WhiteSkin"), for: .selected)
                        selecBtn.tag = i
                        if i == 0 {
                            self.preBtn = selecBtn
                            self.preBtn?.isSelected = true
                        }
                        
                        tempView.addSubview(titleLabel)
                        tempView.addSubview(selecBtn)
                        
                        titleLabel.snp.makeConstraints { (make) in
                            make.left.equalToSuperview().offset(16)
                            make.right.equalToSuperview().offset(-50)
                            make.top.bottom.equalToSuperview()
                        }
                        selecBtn.snp.makeConstraints { (make) in
                            make.right.equalToSuperview().offset(-16)
                            make.centerY.equalToSuperview()
                            make.width.height.equalTo(15)
                        }
                        
                        stackView.addArrangedSubview(tempView)
                        
                        addSubview(stackView)
                        stackView.snp.makeConstraints { (make) in
                            make.edges.equalToSuperview()
                        }
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        
        
    }
    
    @objc func selecBtnClick(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        sender.isSelected = true
        self.preBtn?.isSelected = false
        self.preBtn = sender
        
    }

}
