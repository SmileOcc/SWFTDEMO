//
//  YXTradeExpandCell.swift
//  uSmartOversea
//
//  Created by ellison on 2019/1/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import FLAnimatedImage

@objc enum YXTradeExpandItem: Int {
    case buy
    case sell
    case lastLiq // 最近平仓
    case warrant
    case price
    case modify
    case cancel
    case detail
    case smart
    case share
    case shareOrder // 分享订单需要动态图标
    case reorder

    var title: String {
        switch self {
        case .buy:
            return YXLanguageUtility.kLang(key: "hold_trade_buy")
        case .sell:
            return YXLanguageUtility.kLang(key: "hold_trade_sell")
        case .lastLiq:
            return "Last Liq"
        case .warrant:
            return YXLanguageUtility.kLang(key: "warrants_warrants")
        case .price:
            return YXLanguageUtility.kLang(key: "hold_trade_quote")
        case .modify:
            return YXLanguageUtility.kLang(key: "hold_trade_modify")
        case .cancel:
            return YXLanguageUtility.kLang(key: "hold_trade_cancel")
        case .detail:
            return YXLanguageUtility.kLang(key: "hold_trade_detail")
        case .smart:
            return YXLanguageUtility.kLang(key: "hold_trade_smart_order")
        case .share, .shareOrder:
            return YXLanguageUtility.kLang(key: "hold_trade_share")
        case .reorder:
            return YXLanguageUtility.kLang(key: "trade_smart_one_more")
        }
    }
    
    var iconName: String {
        switch self {
        case .buy:
            return "hold_buy"
        case .sell:
            return "hold_sell"
        case .lastLiq:
            return "hold_lastliq"
        case .warrant:
            return "hold_warrants"
        case .price:
            return "hold_price"
        case .modify:
            return "todayorder_modify"
        case .cancel:
            return "todayorder_cancel"
        case .detail:
            return "todayorder_detail"
        case .smart:
            return "icon_smart_hold"
        case .share:
            return "icon_share_hold"
        case .shareOrder:
            return "gif_share"
        case .reorder:
            return "icon_reorder_hold"
        }
    }
}

class YXTradeExpandCell: YXTableViewCell {

    @objc var action: ((_ type: YXTradeExpandItem) -> Void)?
    
    func creatButton(type: YXTradeExpandItem) -> YXTradeExpandShareButton {
        let button = YXTradeExpandShareButton()
        if type == .shareOrder,
           let path = Bundle.main.path(forResource: type.iconName.themeSuffix, ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            button.topImageView.animatedImage = image
        } else {
            button.topImageView.image = UIImage(named: type.iconName)
        }
        button.bottomLabel.text = type.title
        button.type = type
        button.addTarget(self, action: #selector(clickButton(_:)), for: .touchUpInside)
        return button
    }

    lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    fileprivate var buttons: [UIControl] = []

    override func initialUI() {
        super.initialUI()
        selectionStyle = .none
        backgroundColor = QMUITheme().backgroundColor()
        contentView.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc var items: [NSNumber]? {
        didSet {
            if items != oldValue, let list = items {
                buttons.forEach { (button) in
                    button.removeFromSuperview()
                }
                buttons.removeAll()
                for item in list {
                    let type = YXTradeExpandItem.init(rawValue: item.intValue) ?? .buy
                    
                    let btn = creatButton(type: type)
                    
                    buttons.append(btn)
                   // contentView.addSubview(btn)
                    scrollView.addSubview(btn)
                }

                let cellWidth = self.width
                
                if buttons.count > 0 {
                    if (buttons.count == 1) {
                        let button = self.buttons[0];
                        button.snp.makeConstraints { (make) in
                            make.height.top.centerX.equalToSuperview()
                            make.width.equalTo(100)
                        }
                    } else if buttons.count > 4 {//滑动一屏展示4.5个
                        let w = cellWidth / 4.5
                        for (index,subBtn) in buttons.enumerated() {
                            subBtn.snp.makeConstraints { make in
                                make.width.equalTo(w)
                                make.height.top.equalToSuperview()
                                make.left.equalTo( w * CGFloat(index))
                            }
                        }
                        scrollView.contentSize = CGSize.init(width: w * CGFloat(buttons.count), height: 0)
                        scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
                    }else {
                        
                        let w = cellWidth / CGFloat(buttons.count)
                        for (index,subBtn) in buttons.enumerated() {
                            subBtn.snp.makeConstraints { make in
                                make.width.equalTo(w)
                                make.height.top.equalToSuperview()
                                make.left.equalTo( w * CGFloat(index))
                            }
                        }
 //
 //                       //scrollView上 此方法 布局有不准确
//                        buttons.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
//                        buttons.snp.makeConstraints { (make) in
//                            make.height.top.equalToSuperview()
//                        }
                    }
                }
            }
        }
    }


    @objc func clickButton(_ sender: YXTradeExpandShareButton) {
        self.action?(sender.type)
    }

    @objc func resetScrollViewContentOffset() {
        scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
    }
    
}


class YXTradeExpandShareButton: UIControl {

    var type: YXTradeExpandItem = .buy

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(topImageView)
        addSubview(bottomLabel)

        topImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
        }

        bottomLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
            make.top.equalTo(topImageView.snp.bottom).offset(2)
            make.bottom.lessThanOrEqualToSuperview().offset(-2)
        }
    }

    lazy var topImageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        if YXUserManager.isENMode() {
            label.numberOfLines = 2
        } else {
            label.numberOfLines = 1
        }
        label.textColor = QMUITheme().textColorLevel2()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6

        return label
    }()

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if type == .shareOrder,
           let path = Bundle.main.path(forResource: type.iconName.themeSuffix, ofType: "gif"),
           let data = try? Data.init(contentsOf: URL(fileURLWithPath: path)) {
            let image = FLAnimatedImage(animatedGIFData: data)
            self.topImageView.animatedImage = image
        } else {
            self.topImageView.image = UIImage(named: type.iconName)
        }
    }

}




