//
//  YXETFBriefReturnInfoView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXETFBriefReturnInfoView: UIView {

    var updateHeightBlock: ((_ height: CGFloat) -> Void)?

    var model: YXETFBriefModel? {
        didSet {
            if let returnsInfo = model?.returnsInfo {
                for item in returnsInfo {
                    if item.uniqueSecuCode == self.market + self.symbol {
                        handleReturnsRatio(item.rrinSingleWeek, singleWeekSubView.secondLabel)

                        handleReturnsRatio(item.rrinSingleMonth, singleMonthSubView.secondLabel)

                        handleReturnsRatio(item.rrinThreeMonth, threeMonthSubView.secondLabel)

                        handleReturnsRatio(item.rrinSixMonth, sixMonthSubView.secondLabel)

                        handleReturnsRatio(item.rrinSingleYear, singleYearSubView.secondLabel)

                        handleReturnsRatio(item.rrSinceThisYear, sinceThisYearSubView.secondLabel)

                    } else {
                        handleReturnsRatio(item.rrinSingleWeek, singleWeekSubView.thirdLabel)

                        handleReturnsRatio(item.rrinSingleMonth, singleMonthSubView.thirdLabel)

                        handleReturnsRatio(item.rrinThreeMonth, threeMonthSubView.thirdLabel)

                        handleReturnsRatio(item.rrinSixMonth, sixMonthSubView.thirdLabel)

                        handleReturnsRatio(item.rrinSingleYear, singleYearSubView.thirdLabel)

                        handleReturnsRatio(item.rrSinceThisYear, sinceThisYearSubView.thirdLabel)
                    }
                }
            }

        }
    }

    func handleReturnsRatio(_ ratioStr: String, _ label: UILabel) {

        if ratioStr.count > 0, let ratio = Double(ratioStr) {
            label.text = String(format: "%@%.2f%%", ratio > 0 ? "+" : "", ratio)
            label.textColor = YXToolUtility.stockChangeColor(ratio)
        } else {
            label.text = "--"
            label.textColor = YXToolUtility.stockChangeColor(0)
        }
    }

    var market: String = ""
    var name: String = ""
    var symbol: String = ""
    init(frame: CGRect, market: String, symbol: String, name: String) {
        super.init(frame: frame)
        self.market = market
        self.name = name
        self.symbol = symbol
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

        let subviewArr = [titlesSubView,
                          singleWeekSubView,
                          singleMonthSubView,
                          threeMonthSubView,
                          sixMonthSubView,
                          singleYearSubView,
                          sinceThisYearSubView]

        for (index, view) in subviewArr.enumerated() {
            self.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(44)
                make.top.equalTo(titleLabel.snp.bottom).offset(24 + 44 * index)
            }
        }

        for i in 0...subviewArr.count {
            
            let lineView = UIView()
            lineView.backgroundColor = QMUITheme().pointColor()
            addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.top.equalTo(titleLabel.snp.bottom).offset(24 + 44 * i)
                make.height.equalTo(1)
            }
        }

        let averageWidth = (YXConstant.screenWidth - 32.0) / 3.0
        for i in 0...3 {
            let lineView = UIView()
            lineView.backgroundColor = QMUITheme().pointColor()
            addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16.0 + CGFloat(i) * averageWidth)
                make.width.equalTo(1)
                make.top.equalTo(titlesSubView.snp.top)
                make.bottom.equalTo(sinceThisYearSubView.snp.bottom)
            }
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "brief_return_profit")
        return label
    }()

    lazy var titlesSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: true)
        view.backgroundColor = QMUITheme().blockColor()
        view.firstLabel.text = YXLanguageUtility.kLang(key: "brief_profit_range")
        view.secondLabel.text = self.name
        view.thirdLabel.text = YXLanguageUtility.kLang(key: "common_hkHSI")

        view.firstLabel.backgroundColor = QMUITheme().blockColor()
        view.secondLabel.backgroundColor = QMUITheme().blockColor()
        view.thirdLabel.backgroundColor = QMUITheme().blockColor()
        return view
    }()

    lazy var singleWeekSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: false)
        view.firstLabel.text = "7" + YXLanguageUtility.kLang(key: "common_day_unit")
        return view
    }()

    lazy var singleMonthSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: false)
        view.firstLabel.text = "30" + YXLanguageUtility.kLang(key: "common_day_unit")
        return view
    }()

    lazy var threeMonthSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: false)
        view.firstLabel.text = "90" + YXLanguageUtility.kLang(key: "common_day_unit")
        return view
    }()

    lazy var sixMonthSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: false)
        view.firstLabel.text = "180" + YXLanguageUtility.kLang(key: "common_day_unit")
        return view
    }()

    lazy var singleYearSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: false)
        view.firstLabel.text = "1" + YXLanguageUtility.kLang(key: "common_year")

        return view
    }()

    lazy var sinceThisYearSubView: YXETFBriefReturnInfoSubView = {
        let view = YXETFBriefReturnInfoSubView(frame: .zero, isTitle: false)
        view.firstLabel.text = YXLanguageUtility.kLang(key: "hold_within_this_year")
        return view
    }()

}


class YXETFBriefReturnInfoSubView: UIStackView {

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
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.alignment = .fill

        addArrangedSubview(firstLabel)
        addArrangedSubview(secondLabel)
        addArrangedSubview(thirdLabel)
    }

    lazy var firstLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        //label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)

        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()


    lazy var secondLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var thirdLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
}

