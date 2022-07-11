//
//  YXETFBriefElementChangeView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//
import UIKit
import YXKit
import RxSwift
import RxCocoa

class YXETFBriefElementChangeView: UIView {

    var updateHeightBlock: ((_ height: CGFloat) -> Void)?

    var pushToDetailBlock: (() -> Void)?

    var model: YXETFBriefModel? {
        didSet {

            if let elementChangeInfo = model?.elementChangeInfo {
                elementSubviews.forEach { (view) in
                    view.isHidden = true
                }
                for (index, item) in elementChangeInfo.enumerated() {
                    if index >= elementSubviews.count {
                        break
                    }
                    let subview = elementSubviews[index]
                    subview.isHidden = false

                    if index == elementChangeInfo.count - 1 {
                        subview.lineView.isHidden = true
                    } else {
                        subview.lineView.isHidden = false
                    }

                    if let str = item.dateChanged {
                        subview.firstLabel.text = String(str.prefix(10))
                    }

                    if let str = item.secuCodeElement {
                        subview.secondLabel.text = str
                    }

                    var isInterger = false
                    if YXUserManager.isENMode() {
                        isInterger = abs(item.holderChanged) < 1000
                    } else {
                        isInterger = abs(item.holderChanged) < 10000
                    }
                    var string = ""

                    if (isInterger) {
                        string = String(item.holderChanged) + YXLanguageUtility.kLang(key: "stock_unit_en")
                    } else {
                        string = YXToolUtility.stockData(Double(item.holderChanged), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
                    }

                    if item.holderChanged > 0 {
                        subview.thirdLabel.text = "+" + string
                    } else {
                        subview.thirdLabel.text = string
                    }

                }
            }
        }
    }

    var elementSubviews: [YXETFBriefElementSubView] = []

    var market: String = ""
    init(frame: CGRect, market: String) {
        super.init(frame: frame)
        self.market = market
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.top.equalToSuperview()
//            make.height.equalTo(4)
//        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        addSubview(detailButton)
        detailButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }

        addSubview(subTitlesView)
        addSubview(firstView)
        addSubview(secondView)
        addSubview(thirdView)

        elementSubviews = [firstView, secondView, thirdView]

        let arr = [subTitlesView, firstView, secondView, thirdView]
        for (index, view) in arr.enumerated() {
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(44)
                make.left.right.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(12 + 44 * index)
            }
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "brief_element_change")
        return label
    }()

    lazy var detailButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.contentHorizontalAlignment = .right
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.pushToDetailBlock?()
        }).disposed(by: rx.disposeBag)
        return button
    }()


    lazy var subTitlesView: YXETFBriefElementSubView = {
        let view = YXETFBriefElementSubView(frame: .zero, isTitle: true)
        view.firstLabel.text = YXLanguageUtility.kLang(key: "brife_change_date")
        view.secondLabel.text = YXLanguageUtility.kLang(key: "brife_change_code")
        view.thirdLabel.text = YXLanguageUtility.kLang(key: "brife_hold_amount")
        return view
    }()

    lazy var firstView: YXETFBriefElementSubView = {
        let view = YXETFBriefElementSubView(frame: .zero, isTitle: false)
        view.isHidden = true
        return view
    }()

    lazy var secondView: YXETFBriefElementSubView = {
        let view = YXETFBriefElementSubView(frame: .zero, isTitle: false)
        view.isHidden = true
        return view
    }()

    lazy var thirdView: YXETFBriefElementSubView = {
        let view = YXETFBriefElementSubView(frame: .zero, isTitle: false)
        view.isHidden = true
        return view
    }()
}


class YXETFBriefElementSubView: UIView {

    var isTitle = false
    init(frame: CGRect, isTitle: Bool) {
        super.init(frame: frame)
        self.isTitle = isTitle
        initUI()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(firstLabel)
        addSubview(secondLabel)
        addSubview(thirdLabel)

        var maxWidth: CGFloat = 100
        var secondLeftMargin: CGFloat = 134
        if (YXConstant.screenWidth == 320) {
            maxWidth = 85.0
            secondLeftMargin = 124.0
        }
        firstLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(maxWidth)
        }

        thirdLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(maxWidth)
        }

        secondLabel.snp.makeConstraints { (make) in

            make.left.equalToSuperview().offset(secondLeftMargin)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(maxWidth)
        }

//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(8)
//            make.right.equalToSuperview().offset(-8)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
    }

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return view
    }()

    lazy var firstLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        if self.isTitle {
            label.numberOfLines = 2
            label.textColor = QMUITheme().textColorLevel3()
        } else {
            label.textColor = QMUITheme().textColorLevel1()
        }
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left

        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()


    lazy var secondLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        if self.isTitle {
            label.numberOfLines = 2
            label.textColor = QMUITheme().textColorLevel3()
        } else {
            label.textColor = QMUITheme().textColorLevel1()
        }
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()

    lazy var thirdLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        if self.isTitle {
            label.numberOfLines = 2
            label.textColor = QMUITheme().textColorLevel3()
        } else {
            label.textColor = QMUITheme().textColorLevel1()
        }
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()
}
