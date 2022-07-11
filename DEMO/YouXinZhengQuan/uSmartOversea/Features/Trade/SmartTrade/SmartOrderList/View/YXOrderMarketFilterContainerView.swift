//
//  YXOrderFilterView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/4/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objc public enum YXMarketFilterType: Int {
    case all
    case us
    case hk
    case sg
}

extension YXMarketFilterType: CaseIterable {
    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "all_markets")
        case .us:
            return YXLanguageUtility.kLang(key: "us_market")
        case .hk:
            return YXLanguageUtility.kLang(key: "hk_market")
        case .sg:
            return YXLanguageUtility.kLang(key: "sg_market")
        }
    }

    var iconName: String {
        switch self {
        case .all:
            return "filter_market_type_all"
        case .us:
            return "filter_market_type_us"
        case .hk:
            return "filter_market_type_hk"
        case .sg:
            return "filter_market_type_sg"
        }
    }

    var filterRequestValue: String {
        switch self {
        case .all:
            return ""
        case .us:
            return "US"
        case .hk:
            return "HK"
        case .sg:
            return "SG"
        }
    }
}

class YXOrderMarketFilterContainerView: UIView {

    var currentOrderMarket: YXMarketFilterType = .all

    @objc var selectOrderMarketBlock:((YXMarketFilterType) -> Void)?

    @objc var didShowBlock:(() -> Void)?

    lazy var marketFilterButton: YXOrderMarketFilterButton = {
        let button = YXOrderMarketFilterButton()
        button.market = self.currentOrderMarket
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak button] (btn) in
            guard let `self` = self else { return }

            if self.orderMarketFilterView.isHidden {
                button?.isSelected = true
                self.orderMarketFilterView.show(selectedMarketType: self.currentOrderMarket)
                self.didShowBlock?()
            } else {
                button?.isSelected = false
                self.orderMarketFilterView.hidden()
            }
        })
        return button
    }()

    lazy var orderMarketFilterView: YXOrderMarketFilterView = {
        let filterView = YXOrderMarketFilterView.init(frame: CGRect.zero, marketType: self.currentOrderMarket)
        filterView.isHidden = true
        filterView.selectMarketBlock = { [weak self, weak filterView] market in
            guard let `self` = self else { return }

            self.currentOrderMarket = market
            self.marketFilterButton.market = market

            self.layoutIfNeeded()
            filterView?.hidden()

            self.selectOrderMarketBlock?(market)
        }

        filterView.didHideBlock = { [weak self] _ in
            self?.marketFilterButton.isSelected = false
        }
        return filterView
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superView = self.superview {
            superView.insertSubview(self.orderMarketFilterView, belowSubview: self)
            self.orderMarketFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(marketFilterButton.snp.bottom)
            }
        }
    }

    @objc init(frame: CGRect, defaultMarketFilterType: YXMarketFilterType = .all) {
        super.init(frame: frame)

        self.currentOrderMarket = defaultMarketFilterType

        self.backgroundColor = QMUITheme().foregroundColor()

        addSubview(marketFilterButton)
        marketFilterButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let lineView = UIView.line()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXOrderMarketFilterButton: QMUIButton {

    var market: YXMarketFilterType = .all {
        didSet {
            setImage(UIImage(named: market.iconName), for: .normal)
            setTitle(market.title, for: .normal)
        }
    }

    lazy var arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "grey_arrow_down")
        return view
    }()

    override func didInitialize() {
        super.didInitialize()

        spacingBetweenImageAndTitle = 8
        contentHorizontalAlignment = .left
        titleLabel?.font = .systemFont(ofSize: 16)
        setTitleColor(QMUITheme().textColorLevel1(), for: .normal)

        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }

        market = .all
    }

    override var isSelected: Bool {
        didSet {
            arrowImageView.image = isSelected ? UIImage(named: "grey_arrow_up") : UIImage(named: "grey_arrow_down")
        }
    }
}
