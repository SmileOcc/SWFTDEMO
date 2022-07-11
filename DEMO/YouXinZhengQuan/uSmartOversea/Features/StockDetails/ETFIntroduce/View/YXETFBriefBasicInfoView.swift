//
//  YXETFBriefBasicInfoView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXETFBriefBasicInfoView: YXETFBriefBaseView {

    var updateHeightBlock: ((_ height: CGFloat) -> Void)?

    var infoSubViews: [YXETFBriefBasicInfoSubView] = []

    @objc var type3: OBJECT_SECUSecuType3 = OBJECT_SECUSecuType3.stEtf

    var model: YXETFBriefModel? {
        didSet {

            let moneyArr: [String] = YXToolUtility.moneyUnitArray()

            if (self.market == kYXMarketHK) {

                if (infoSubViews.count == 0) {
                    return
                }

                //ETF类型
                if let etfName = model?.basicInfo?.name, !etfName.isEmpty {
                    infoSubViews[0].rightLabel.text = etfName
                    infoSubViews[0].rightLabel.numberOfLines = 2
                }

                //资产净值
                if let unitNv = model?.basicInfo?.unitNv, unitNv > 0 {
                    var valueString: String = ""
                    if (unitNv < 10000) {
                        valueString = String(format: "%.2f", unitNv)
                    } else {
                        if let string = YXToolUtility.stocKNumberData(Int64(unitNv), deciPoint: 2, stockUnit: "", priceBase: 0)?.string {
                            valueString = string;
                        }
                    }

                    if let unit = model?.basicInfo?.unitNvCurr, unit > 0, unit < moneyArr.count {

                        valueString += moneyArr[unit]
                    }

                    infoSubViews[1].rightLabel.text = valueString
                }

                //发行商
                if let valueString = model?.basicInfo?.publisher, !valueString.isEmpty {
                    infoSubViews[2].rightLabel.text = valueString
                }

                //追踪指数
                if let valueString = model?.basicInfo?.targetIndex, !valueString.isEmpty {
                    infoSubViews[3].rightLabel.text = valueString
                }

                //基金规模
                if let totalAssetnv = model?.basicInfo?.totalAssetnv, totalAssetnv > 0 {
                    var valueString: String = ""
                    if (totalAssetnv < 10000) {
                        valueString = String(format: "%.2f", totalAssetnv)
                    } else {
                        if let string = YXToolUtility.stocKNumberData(Int64(totalAssetnv), deciPoint: 2, stockUnit: "", priceBase: 0)?.string {
                            valueString = string;
                        }
                    }

                    infoSubViews[4].rightLabel.text = valueString
                }

                //上市日期
                if let valueString = model?.basicInfo?.listedDate,  !valueString.isEmpty {
                    infoSubViews[5].rightLabel.text = String(valueString.prefix(10))
                }

                //费用比率
                if let ratio = model?.basicInfo?.totalFeeRatio, ratio > 0 {
                    let yearStr = YXLanguageUtility.kLang(key: "brief_per_year")

                    if YXUserManager.isENMode() {
                        infoSubViews[6].rightLabel.text = String(format: "%.02f%% %@", ratio * 100, yearStr)
                    } else {
                        infoSubViews[6].rightLabel.text = String(format: "%@%.02f%%", yearStr, ratio * 100)
                    }

                }

                //派息政策
                if let valueString = model?.basicInfo?.dividendPolicy, !valueString.isEmpty {
                    //infoSubViews[7].rightLabel.text = valueString
                    yyContent = valueString
                }
                setBriefLabel(self.isShow)

            } else {

                //ETF全称
                if let etfName = model?.basicInfo?.name, !etfName.isEmpty {
                    infoSubViews[0].rightLabel.text = etfName
                    infoSubViews[0].rightLabel.numberOfLines = 2
                }

                //管理人
                if let custodian = model?.basicInfo?.custodian, !custodian.isEmpty {
                    infoSubViews[1].rightLabel.text = custodian
                }

                //发行方
                if let publisher = model?.basicInfo?.publisher, !publisher.isEmpty {
                    infoSubViews[2].rightLabel.text = publisher
                }

                //发行时间
                if let valueString = model?.basicInfo?.issueDate, !valueString.isEmpty {
                    infoSubViews[3].rightLabel.text = String(valueString.prefix(10))
                }

                //杠杆
                if let leverage = model?.basicInfo?.leverage, leverage != 0 {
                    if leverage > 0 {
                        infoSubViews[4].rightLabel.text =  String(format: YXLanguageUtility.kLang(key: "brief_positive_lever"), leverage)
                    } else {
                        infoSubViews[4].rightLabel.text = String(format: YXLanguageUtility.kLang(key: "brief_negative_lever"), abs(leverage))
                    }
                } else {
                    infoSubViews[4].rightLabel.text = YXLanguageUtility.kLang(key: "brief_no_lever")
                }

                //分红频率
                if let rateFrequency = model?.basicInfo?.rateFrequency, !rateFrequency.isEmpty {
                    infoSubViews[5].rightLabel.text = rateFrequency
                }

                //ETF简介
                if let etfIntroduction = model?.basicInfo?.introduction, !etfIntroduction.isEmpty {
                    //infoSubViews[6].rightLabel.text = etfIntroduction
                    yyContent = etfIntroduction
                }
                setBriefLabel(self.isShow)
            }
        }
    }

    var market: String = ""
    init(frame: CGRect, market: String, type3: OBJECT_SECUSecuType3) {
        super.init(frame: frame)
        self.type3 = type3
        self.market = market
        self.yyMaxWidth = YXConstant.screenWidth - 132
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        var arr: [String] = []
        if (self.market == kYXMarketHK) {
            var typeStr = YXLanguageUtility.kLang(key: "brief_etf_type")
            if self.type3 == .stFundUsEtn {
                typeStr = YXLanguageUtility.kLang(key: "brief_etn_type")
            }

            arr = [typeStr,
                   YXLanguageUtility.kLang(key: "brief_nunitNv"),
                   YXLanguageUtility.kLang(key: "brief_publisher"),
                   YXLanguageUtility.kLang(key: "brief_targetIndex"),
                   YXLanguageUtility.kLang(key: "brief_totalAssetnv"),
                   YXLanguageUtility.kLang(key: "market_marketDate"),
                   YXLanguageUtility.kLang(key: "brief_total_feeRatio"),
                   YXLanguageUtility.kLang(key: "brief_dividend_policy")]
        } else {
            var name = YXLanguageUtility.kLang(key: "brief_etf_fullname")
            var introduce = YXLanguageUtility.kLang(key: "brief_introduction")
            if self.type3 == .stFundUsEtn {
                name = YXLanguageUtility.kLang(key: "brief_etn_fullname")
                introduce = YXLanguageUtility.kLang(key: "brief_etn_introduction")
            }

            arr = [name,
                   YXLanguageUtility.kLang(key: "brief_custodian"),
                   YXLanguageUtility.kLang(key: "brief_publisher2"),
                   YXLanguageUtility.kLang(key: "brief_issueDate"),
                   YXLanguageUtility.kLang(key: "brief_leverage"),
                   YXLanguageUtility.kLang(key: "brief_rate_frequency"),
                   introduce]
        }

        addSubview(introduceLabel)

        let height: Int = 44

        var preview: UIView = titleLabel
        for (index, title) in arr.enumerated() {
            let infoView = YXETFBriefBasicInfoSubView()
            addSubview(infoView)
            infoView.leftLabel.text = title
            infoSubViews.append(infoView)

            infoView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(preview.snp.bottom).offset(24)
            }

            if (self.market == kYXMarketUS && index == 1) {
                infoView.leftLabel.numberOfLines = 1
            }

            if index != arr.count - 1 {
                infoView.rightLabel.text = "--"
            }

            if (index == arr.count - 1) {
                introduceLabel.snp.makeConstraints { (make) in
                    make.left.right.equalTo(infoView.rightLabel)
                    make.top.equalTo(infoView.leftLabel).offset(2)
                    make.height.equalTo(40)
                    make.bottom.equalToSuperview().offset(-20)
                }
            }
            
            preview = infoView
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "brief_basic_title")
        return label
    }()

}

class YXETFBriefBasicInfoSubView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(leftLabel)
        addSubview(rightLabel)

        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(90)
            //make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leftLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(leftLabel)
        }
    }


    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
}


class YXETFBriefInvestView: YXETFBriefBaseView {

    var updateHeightBlock: ((_ height: CGFloat) -> Void)?

    var model: YXETFBriefModel? {
        didSet {
            yyContent = model?.basicInfo?.investTarget ?? "--";
            setBriefLabel(self.isShow)
        }
    }

    var market: String = ""
    init(frame: CGRect, market: String) {
        super.init(frame: frame)
        self.market = market
        self.yyFolderRowCount = 2
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

        addSubview(introduceLabel)
        introduceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "brief_invest_title")
        return label
    }()

}


class YXETFBriefBaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var introduceLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textVerticalAlignment = .top
        return label
    }()

    var yyContent: String = "--"
    var isShow = false
    var yyMaxWidth: CGFloat = YXConstant.screenWidth - 28.0
    var yyFolderRowCount: UInt = 2

    lazy var showMoreBtn: QMUIButton = {
        let button = QMUIButton.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 20))

        
        button.setTitle(YXLanguageUtility.kLang(key: "share_info_more"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.addTarget(self, action: #selector(self.moreClick(_:)), for: .touchUpInside)
        return button
    }()

    @objc func moreClick(_ sender: UIButton) {
        self.isShow = !self.isShow
        self.setBriefLabel(self.isShow)
    }

    func setBriefLabel(_ isShow: Bool) {

        let str: String = yyContent

        var height: CGFloat = 20
        let maxWidth: CGFloat = yyMaxWidth
        if str.count > 0 {
            let att = YXToolUtility.attributedString(withText: str, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), lineSpacing: 5)
            if let att = att {
                var layout = YYTextLayout.init(containerSize: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), text: att)

                if let rowCount = layout?.rowCount, rowCount > self.yyFolderRowCount {
                    if isShow {
                        self.introduceLabel.numberOfLines = 0
                        self.introduceLabel.truncationToken = nil
                        //收起
                        let showAtt = NSMutableAttributedString.init(string: "  " + YXLanguageUtility.kLang(key: "stock_detail_pack_up"))
                        showAtt.yy_font = UIFont.systemFont(ofSize: 14)
                        showAtt.yy_color = QMUITheme().themeTextColor()
                        showAtt.yy_setTextHighlight(NSRange.init(location: 0, length: showAtt.length), color: QMUITheme().themeTextColor(), backgroundColor: .clear) { [weak self] (view, att, range, rect) in
                            //点击【收起】的响应
                            guard let `self` = self else { return }
                            self.moreClick(self.showMoreBtn)
                        }
                        att.append(showAtt)
                    } else {
                        self.introduceLabel.numberOfLines = self.yyFolderRowCount
                        let att = YXToolUtility.attributedString(withText: "...   ", font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), lineSpacing: 0)!
                        let attachment = NSMutableAttributedString.yy_attachmentString(withContent: self.showMoreBtn, contentMode: .center, attachmentSize: CGSize.init(width: 40, height: 20), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                        att.append(attachment)
                        self.introduceLabel.truncationToken = att
                    }

                    layout = YYTextLayout.init(containerSize: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), text: att)
                    height = layout?.textBoundingSize.height ?? 20
                    if !isShow {
                        //如果是收起状态，height > 63,则固定为63
                        if height > CGFloat(self.yyFolderRowCount * 20 + 2) {
                            height = CGFloat(self.yyFolderRowCount * 20 + 2)
                        }
                    }
                    self.introduceLabel.attributedText = att

                } else {

                    self.introduceLabel.numberOfLines = 0
                    self.introduceLabel.truncationToken = nil
                    self.introduceLabel.attributedText = att
                    height = layout?.textBoundingSize.height ?? 20
                }

            }

        }

        self.introduceLabel.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
}

