//
//  YXHKTradeExpandCell.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import NSObject_Rx

enum YXTradeHoldType {
    case hold       //持仓
    case order      //下单
    case condition  //条件单
}

class YXHKTradeExpandCell: QMUITableViewCell, HasDisposeBag {
    
    var isFinal: Bool = false
    var isOdd: Bool = false
    var isUS: Bool = false
    var isCN: Bool = false
    var greyFlag: Bool = false //是否暗盘
    
    var tradeType: YXTradeHoldType = .hold {
        didSet {
            refreshUI()
        }
    }
    //行情
    lazy var quoteButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_quote"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_quote"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    //买入
    lazy var buyButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_buy"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_buy"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    //卖出
    lazy var sellButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_sell"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_sell"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    //【订单明细】
    lazy var orderButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_detail"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_order_detail"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    //【修改】
    lazy var changeButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_edit"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_change"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    //【取消订单】
    lazy var recallButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_recall"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_order_recall"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    //终止
    lazy var stopButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "order_stop"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "hold_stop"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.imagePosition = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        return button
    }()
    
    fileprivate var buttons: [QMUIButton] = []

    override func didInitialize(with style: UITableViewCell.CellStyle) {
        super.didInitialize(with: style)
        
        selectionStyle = .none
        backgroundColor = QMUITheme().backgroundColor()
    }
    
    func refreshUI() {
        buttons.forEach { (button) in
            button.removeFromSuperview()
        }
        
        switch tradeType {
        case .hold:
            contentView.addSubview(quoteButton)
            contentView.addSubview(buyButton)
            contentView.addSubview(sellButton)
            buttons = [quoteButton, buyButton, sellButton]
        case .order:
            if isFinal {
                contentView.addSubview(orderButton)
                buttons = [orderButton]
            } else {
                if isOdd {
                    contentView.addSubview(orderButton)
                    contentView.addSubview(recallButton)
                    buttons = [orderButton, recallButton]
                } else {
                    contentView.addSubview(orderButton)
                    contentView.addSubview(recallButton)
                    if isUS || isCN {
                        buttons = [orderButton, recallButton]
                    } else {
                        if self.greyFlag {
                            buttons = [orderButton, recallButton]
                        } else {
                            contentView.addSubview(changeButton)
                            buttons = [orderButton, changeButton, recallButton]
                        }
                        
                    }
                }
            }

        case .condition:
            if self.greyFlag || self.isCN {
                contentView.addSubview(recallButton)
                buttons = [recallButton]
            } else {
                contentView.addSubview(changeButton)
                contentView.addSubview(recallButton)
                buttons = [changeButton, recallButton]
            }
            
            break
        }

        if (buttons.count == 1) {
            let button = self.buttons[0];
            button.snp.remakeConstraints { (make) in
                make.height.top.centerX.equalTo(self)
                make.width.equalTo(100)
            }
        } else {
            buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
            buttons.snp.makeConstraints { (make) in
                make.height.top.equalTo(self)
            }
        }
    }
}
