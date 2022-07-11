//
//  YXOptionalListCell.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXOptionalListCell: QMUITableViewCell, HasDisposeBag {
    
    var prePrice: Int64? // 记录前一个价格，与当前价格比较以展示刷新涨跌动画
    var quoteIdenitifiy: String? //记录股票防止cell重用动画展示一个价格

    lazy var quote = BehaviorRelay<YXV2Quote?>(value: nil)
    
    lazy var quoteAccessView: YXOptionalAccessView = {
        YXOptionalAccessView()
    }()
    
    lazy var simpleLineView: YXSimpleTimeLine = {
        YXSimpleTimeLine(frame: CGRect(x: 0, y: 0, width: 60, height: 24), market: YXMarketType.HK.rawValue, minute: 3)
    }()
    
    lazy var longPress: UILongPressGestureRecognizer = {
        let ges = UILongPressGestureRecognizer(target: self, action: #selector(longPressEvent(sender:)))
        return ges
    }()
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        return YXStockBaseinfoView()
    }()
    
    @objc func longPressEvent(sender: UIGestureRecognizer) {
        if sender.state == .began {
            longPressHandler?(sender)
        }
    }
    
    var longPressHandler:((UIGestureRecognizer)->())?
    
    
    lazy var animationView: YXGradientLayerView = {
        let view = YXGradientLayerView()
        view.direction = .horizontal
        return view
    }()
    
    func animationStockUp() {
        animationView.colors = [QMUITheme().stockRedColor().withAlphaComponent(0), QMUITheme().stockRedColor().withAlphaComponent(0.1)]
        startAnimation()
    }
    
    func animationStockDown() {
        animationView.colors = [QMUITheme().stockGreenColor().withAlphaComponent(0), QMUITheme().stockGreenColor().withAlphaComponent(0.1)]
        startAnimation()
    }
    
    func startAnimation() {
        UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction) {
            self.animationView.alpha = 1.0
        } completion: { (finish) in
            UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction) {
                self.animationView.alpha = 0
            } completion: { (finish) in
                
            }
        }
    }
    
    override func didInitialize(with style: UITableViewCell.CellStyle) {
        super.didInitialize(with: style)
        
        contentView.backgroundColor = QMUITheme().foregroundColor()
        backgroundColor = .clear
        selectionStyle = .none
    
        contentView.addSubview(animationView)
        contentView.addGestureRecognizer(longPress)
        
        contentView.addSubview(quoteAccessView)
        contentView.addSubview(simpleLineView)
        
        contentView.addSubview(stockInfoView)
        
        animationView.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }
        
        quoteAccessView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(112)
            make.top.bottom.equalToSuperview()
        }
        
        simpleLineView.snp.makeConstraints { (make) in
            make.right.equalTo(quoteAccessView.snp.left).offset(-29)
            make.width.equalTo(50)
            make.height.equalTo(31)
            make.centerY.equalToSuperview()
        }
    
        stockInfoView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.lessThanOrEqualTo(simpleLineView.snp.left).offset(-20)
        }
    }

}


