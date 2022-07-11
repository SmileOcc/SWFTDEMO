//
//  YXCurrencyExchangeAlertView.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXCurrencyExchangeAlertView: UIView {

    //获取当前的货币表示（1:新币、2:美元、3:港币）
    var currencyType:YXCurrencyType = .sg
    
    var didSelected: (YXCurrencyType)->() = { index in
        
    }
    var currencyArr: Array<YXCurrencyType> = [
        YXCurrencyType.sg,
        YXCurrencyType.hk,
        YXCurrencyType.us
    ]

    var title: String = YXLanguageUtility.kLang(key: "exchange_currency_selection")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, currencyType: YXCurrencyType, title: String) {
        self.init(frame: frame)
        self.currencyType = currencyType
        self.title = title
        initView()
    }
    
    //原来的view
    func initView() {
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.layer.backgroundColor = QMUITheme().popupLayerColor().cgColor

        //标题
        let titleLab = QMUILabel()
//        titleLab.backgroundColor = UIColor.white
        titleLab.text = title
        titleLab.textColor = QMUITheme().textColorLevel1()
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLab.textAlignment = .center
        self.addSubview(titleLab)
        
        titleLab.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(52)
        }

        var topView: UIView = titleLab
        let h: CGFloat = 52 //高度固定
        
        for (i, currency) in currencyArr.enumerated() {

            let btn = QMUIButton(type: .custom)
//            btn.backgroundColor = UIColor.white
            btn.setTitle(currency.name(), for: .normal)
            btn.setImage(UIImage(named: currency.iconName()), for: .normal)
            btn.spacingBetweenImageAndTitle = 12
            btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)

            switch currencyType {

            case .sg://新币
                if i == 0 {
                    btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
                } else {
                    btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
                }
            case .hk://港币
                if i == 1 {
                    btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
                } else {
                    btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
                }
            case .us://美元
                if i == 2 {
                    btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
                } else {
                    btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
                }
            default:
                break
            }

            btn.titleLabel?.font = .systemFont(ofSize: 16)
            btn.tag = i + 10
            btn.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
            self.addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(topView.snp.bottom)
                make.height.equalTo(h)
            }
            
            let lineView = UIView()
            lineView.backgroundColor = QMUITheme().popSeparatorLineColor()
            btn.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(QMUIHelper.pixelOne)
            }

            topView = btn
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().blockColor()
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(8)
        }

        //取消
        let cancelBtn = QMUIButton()
        cancelBtn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        cancelBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cancelBtn.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
        cancelBtn.tag = 20
//        cancelBtn.backgroundColor = UIColor.white
        addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(8)
            make.height.equalTo(h)
        }
    }
    
    @objc func btnAction(btn: UIButton) {
        let index = btn.tag-10
        
        if index == 0 {
            currencyType = .sg
        }
        else if index == 1 {
            currencyType = .hk
        }
        else if index == 2 {
            currencyType = .us
        } else {
            currencyType = .none
        }
        didSelected(currencyType)
    }
}
