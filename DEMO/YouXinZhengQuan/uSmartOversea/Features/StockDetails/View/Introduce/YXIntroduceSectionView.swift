//
//  YXIntroduceSectionView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXIntroduceSectionBottomView: UIView {

    var type: YXStockDetailIntroduceType = .divien {
        didSet {
            if self.type == .divien {
                firstLabel.text = YXLanguageUtility.kLang(key: "stock_detail_dividend_ex_date")
                secondLabel.text = YXLanguageUtility.kLang(key: "stock_detail_dividend_payable")
                thirdLabel.text = YXLanguageUtility.kLang(key: "stock_detail_dividend_dividend")
            } else if self.type == .buyback {
                firstLabel.text = YXLanguageUtility.kLang(key: "stock_detail_dividend_date")
                secondLabel.text = YXLanguageUtility.kLang(key: "stock_detail_dividend_qty")
                thirdLabel.text = YXLanguageUtility.kLang(key: "stock_detail_dividend_buyback_amount")
            } else if self.type == .splitshare {
                firstLabel.text = YXLanguageUtility.kLang(key: "stock_detail_stock_snc_ann")
                secondLabel.text = YXLanguageUtility.kLang(key: "stock_detail_stock_snc_date")
                thirdLabel.text = YXLanguageUtility.kLang(key: "stock_detail_stock_snc_detail")
            }
        }
    }
    
    let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: "")
    let secondLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: "")
    let thirdLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: "")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var market = YXMarketType.HK.rawValue {
        didSet {
            if market == YXMarketType.US.rawValue || market == YXMarketType.SG.rawValue  {
                firstLabel.isHidden = true
                secondLabel.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(16)
                    make.centerY.equalToSuperview()
                }
            }
        }
    }
    
    func initUI() {
        addSubview(firstLabel)
        addSubview(secondLabel)
        addSubview(thirdLabel)
        
        firstLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        secondLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(uniHorLength(-145))
            make.centerY.equalToSuperview()
        }
        
        thirdLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}

class YXIntroduceSectionView: UIView {

    var pushToDetailBlock:((_ type: YXStockDetailIntroduceType) -> Void)?

    var market = YXMarketType.HK.rawValue {
        didSet {
            if market == YXMarketType.HK.rawValue {
                detailButton.isHidden = false
            } else {
                detailButton.isHidden = true
            }
        }
    }

    var type: YXStockDetailIntroduceType = .divien {
        didSet {
            if self.type == .divien || self.type == .buyback || self.type == .splitshare {
                self.addSubview(self.bottomView)
                self.bottomView.snp.makeConstraints({ (make) in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.height.equalTo(36)
                })

                if market == YXMarketType.US.rawValue, self.type == .splitshare {
                    self.bottomView.market = market
                }
            }

            if (type == .compose || type == .industry || type == .conception) {
                self.detailButton.isHidden = true
            }
        }
    }
    
    let titleLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 20, weight: .medium), text: "--")
    let rightLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14, weight: .medium), text: "")
    
    lazy var bottomView: YXIntroduceSectionBottomView = {
        let view = YXIntroduceSectionBottomView.init()
        view.type = self.type
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {

        backgroundColor = QMUITheme().foregroundColor()
//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().lightLineColor().withAlphaComponent(0.5)
//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.top.right.equalToSuperview()
//            make.height.equalTo(4)
//        }

        addSubview(rightLabel)
        addSubview(titleLabel)
        addSubview(detailButton)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.3
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(40)
            //make.trailing.lessThanOrEqualTo(rightLabel.snp.leading).offset(-10)
        }

        detailButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }
        
    }

    lazy var detailButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.contentHorizontalAlignment = .right
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }

            self.pushToDetailBlock?(self.type)

        }).disposed(by: rx.disposeBag)
        return button
    }()
}
