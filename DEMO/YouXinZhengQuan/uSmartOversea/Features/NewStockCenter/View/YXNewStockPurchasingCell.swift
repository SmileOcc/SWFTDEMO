//
//  YXNewStockPurchasingCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit


/// 获取入场费的类型
///canIPO:公开认购入场费
///canEcm:国际配售入场费
func fetchAdmissionFeeType(with model:YXNewStockCenterPreMarketStockModel) -> (Bool,Bool) {
    var canIPO = false
    var canEcm = false
    let serverUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.serverTime)
    
    var subscribeWayArray: [String] = []
    //认购方式，多种认购用,隔开，比如0,1支持现金和融资(1-公开现金认购，2-公开融资认购，3-国际配售)
    if let subscribeWay =  model.subscribeWay {
        subscribeWayArray = subscribeWay.components(separatedBy: ",")
    }

    if subscribeWayArray.contains(String(YXNewStockSubsType.internalSubs.rawValue)) {
        
        if model.ecmStatus == YXNewStockPurcahseStatus.purchasing.rawValue || model.ecmStatus == YXNewStockPurcahseStatus.ecmReconfirm.rawValue  {
            let ecmUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.ecmEndTime)
            if ecmUnixTime > 0, ecmUnixTime > serverUnixTime {
               canEcm = true
            }
        }
        
    }

    if subscribeWayArray.contains(String(YXNewStockSubsType.financingSubs.rawValue)) && model.status == YXNewStockPurcahseStatus.purchasing.rawValue {
        let financeUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.financingEndTime)
        if let financingMultiple = model.financingMultiple, financingMultiple > 0, financeUnixTime > 0, financeUnixTime > serverUnixTime {
            canIPO = true
        }
    }

    //purchasing 状态更改不是立马生效的，同步恒生那边要10min左右, 判断要加上截止时间
    let cashUnixTime: TimeInterval = YXNewStockDateFormatter.unixTime(model.endTime)
    if cashUnixTime > 0, cashUnixTime > serverUnixTime, model.status == YXNewStockPurcahseStatus.purchasing.rawValue {
        canIPO = true
    }
    //canIPO:公开认购入场费
    //canEcm:国际配售入场费
    return (canIPO,canEcm)
}

class YXNewStockPurchasingCell: UITableViewCell {
    
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initializeViews()
        asyncRender()
    }

    func refreshUI(model: YXNewStockCenterPreMarketStockModel) {
        
        nameLabel.text = model.stockName ?? "--"

        var listExchanges: String = ""
        var symbol: String = ""
        if model.exchangeType == YXExchangeType.us.rawValue, let tempListExchanges = model.listExchanges, tempListExchanges.count > 0 {
            listExchanges = " " + tempListExchanges
        }
        if let stockCode = model.stockCode, stockCode.count > 0 {
            symbol = stockCode
        }
        if symbol.count > 0 || listExchanges.count > 0 {
            codeLabel.text = String(format: "%@%@", symbol, listExchanges)
        } else {
            codeLabel.text = ""
        }
        //状态
        var status = YXStocklabelStatus.none
        if let labelStatus = model.labelStatus, let tempStatus = YXStocklabelStatus(rawValue: labelStatus) {
            status = tempStatus
        }
        
        var tagTitleColor: UIColor = UIColor.qmui_color(withHexString: "#5B3BE8") ?? .white
        var tagImageName: String = ""
        var tagTitle: String = ""
        switch status {
            case .purchase:
                //已认购
                tagTitleColor = QMUITheme().themeTextColor()
                tagImageName = "tag_checked"
                tagTitle = YXLanguageUtility.kLang(key: "newStock_center_winState_purchased")
            case .wined:
                //已中签
                tagTitleColor = QMUITheme().tipsColor()
                tagImageName = "tag_hunting"
                tagTitle = YXLanguageUtility.kLang(key: "newStock_center_winState_success")
            case .notWined:
                //未中签
                tagTitleColor = QMUITheme().textColorLevel2()
                tagImageName = "tag_fail"
                tagTitle = YXLanguageUtility.kLang(key: "newStock_center_winState_fail")
            case .financeApplying:
                //已认购
                tagTitleColor = QMUITheme().themeTextColor()
                tagImageName = "tag_checked"
                tagTitle = model.labelStatusName ?? ""
            case .none:
                break
        }
        tagButton.setTitle(tagTitle, for: .normal)
        tagButton.setTitleColor(tagTitleColor, for: .normal)
        tagButton.setImage(UIImage(named: tagImageName), for: .normal)
        tagButton.layoutIfNeeded()
        
        let (canIPO,canEcm) = fetchAdmissionFeeType(with: model)
        
        recommendImageView.isHidden = true
        if let topStatus = model.topStatus, topStatus > 0 {
            recommendImageView.isHidden = false
        }

        var tempTitles: [String] = []
        if let titles = model.tagList?.compactMap({ $0.tagText }), titles.count > 0 {
            tempTitles = titles
        }
        ecmLabelsView.setTags(tempTitles, maxWidth: YXConstant.screenWidth - 18 * 2 - 14 * 2)
        ecmLabelsView.snp.updateConstraints { (make) in
            make.height.equalTo(ecmLabelsView.totalHeight)
        }

        
        if let endTime = model.latestEndtime, endTime.count > 0,
            let serverTime = model.serverTime, serverTime.count > 0 {
            deadLineLabel.attributedText = leftTimeString(seconds: model.remainingTime ?? 0, endTime: endTime, serverTime: serverTime)
        } else {
            deadLineLabel.text = YXLanguageUtility.kLang(key: "newStock_center_ppurchase_determined")
        }
        
        if let endTime = model.latestEndtime, endTime.count > 0 {
            dateLabel.text = endTime
        } else {
            dateLabel.text = "--"
        }
        
        var focusCount = 0
        if let count = model.focusCount, count > 0 {
            focusCount = count
        }
        var peopleCount = 0
        var unitString = YXLanguageUtility.kLang(key: "common_person_unit")
        if focusCount > 0 {
            peopleCount = focusCount
            unitString = ""
            purchaseStateLabel.text = YXLanguageUtility.kLang(key: "newStock_center_popularity")
        } else {
            purchaseStateLabel.text = ""
            peopleCountLabel.text = ""
        }
        
        if peopleCount > 0, let formatterString = moneyFormatter.string(from: NSNumber(value: peopleCount)) {
            
            let string = String(format: "%@%@", formatterString, unitString)
            let mutString = NSMutableAttributedString.init(string: string)
            mutString.addAttributes([.foregroundColor : QMUITheme().textColorLevel1()], range: NSRange(location: 0, length: string.count))
            mutString.addAttributes([.font : UIFont.systemFont(ofSize: 20, weight: .medium)], range: NSRange(location: 0, length: string.count - unitString.count))
            if unitString.count > 0 {
                mutString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], range: NSRange(location: string.count - unitString.count, length: unitString.count))
            }
            peopleCountLabel.attributedText = mutString
        }
        
        ecmAdmissionFeeLabel.text = ""
        ecmAdmissionFeeDesLabel.text = ""
        ipoAdmissionFeeLabel.text = ""
        ipoAdmissionFeeDesLabel.text = ""
        
        if model.exchangeType == YXExchangeType.us.rawValue {
            ipoAdmissionFeeDesLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_enter_funds")
            if let fee = model.ecmLeastAmount {
                ipoAdmissionFeeLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee)
            }
            
        } else if canEcm && canIPO {
            //同时支持ecm及ipo
            ecmAdmissionFeeDesLabel.text = YXLanguageUtility.kLang(key: "ecm_admission_fee")
            ipoAdmissionFeeDesLabel.text = YXLanguageUtility.kLang(key: "ipo_admission_fee")
            if let fee = model.leastAmount {
                ipoAdmissionFeeLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee)
            }
            
            if let fee = model.ecmLeastAmount {
                ecmAdmissionFeeLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee)
            }
        } else if canEcm {
            //只支持ecm
            ipoAdmissionFeeDesLabel.text = YXLanguageUtility.kLang(key: "ecm_admission_fee")
            if let fee = model.ecmLeastAmount {
                ipoAdmissionFeeLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee)
            }
        } else {
            //只支持ipo
            ipoAdmissionFeeDesLabel.text = YXLanguageUtility.kLang(key: "ipo_admission_fee")
            if let fee = model.leastAmount {
                ipoAdmissionFeeLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee)
            }
        }
        
        
        var textArray = [String]()
        if let ipoSpecialInfos = model.ipoSpecialInfos, ipoSpecialInfos.count > 0 {
            textArray = ipoSpecialInfos
        }
        tagsView.setTags(textArray, maxWidth: YXConstant.screenWidth - 36 - 28)
        tagsView.snp.updateConstraints { (make) in
            make.height.equalTo(tagsView.totalHeight)
        }
    }
    
    func leftTimeString(seconds: NSInteger, endTime: String, serverTime: String) -> NSMutableAttributedString {
        
        var value: Int = 0
        var prefixString = ""
        var suffixString = ""
        
        if seconds >= 24 * 3600 {
            if serverTime.count >= 10 {
                value = YXDateToolUtility.numberOfDaysWith(fromDate: (serverTime as NSString).substring(with: NSMakeRange(0, 10)), toDate: (endTime.count >= 10 ? (endTime as NSString).substring(with: NSMakeRange(0, 10)) : endTime))
            }
            prefixString = String(format: "%ld ", value)
            suffixString = YXLanguageUtility.kLang(key: "common_day_unit") + YXLanguageUtility.kLang(key: "newStock_center_purchase_ending")
            
        } else if seconds > 0 {
            
            if seconds >= 3600 {
                value = seconds / 3600
                suffixString = YXLanguageUtility.kLang(key: "common_hour") + YXLanguageUtility.kLang(key: "newStock_center_purchase_ending")
            } else if seconds < 3600, seconds >= 60 {
                value = seconds / 60
                suffixString = YXLanguageUtility.kLang(key: "common_minute") + YXLanguageUtility.kLang(key: "newStock_center_purchase_ending")
            } else {
                value = 1
                suffixString = YXLanguageUtility.kLang(key: "common_minute") + YXLanguageUtility.kLang(key: "newStock_center_purchase_ending")
            }
            prefixString = String(format: "%ld ", value)
            
        } else {
            suffixString = YXLanguageUtility.kLang(key: "newStock_center_purchase_ended")
        }
        let attriString: NSMutableAttributedString = NSMutableAttributedString(string: prefixString + suffixString)
        attriString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel1(), range: NSMakeRange(0, prefixString.count + suffixString.count))
        attriString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(prefixString.count, suffixString.count))
        if prefixString.count > 0 {
            attriString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .medium), range: NSMakeRange(0, prefixString.count))
        }
        return attriString
    }
    
    @objc lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()
    
    func initializeViews() {
        
        let margin: CGFloat = 18
        let innerMargin: CGFloat = 14
        contentView.addSubview(belowView)
        contentView.backgroundColor = QMUITheme().backgroundColor()
        belowView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        belowView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        backView.addSubview(nameLabel)
        backView.addSubview(codeLabel)
        backView.addSubview(tagButton)
        backView.addSubview(recommendImageView)
        backView.addSubview(deadLineLabel)
        backView.addSubview(dateLabel)
        backView.addSubview(peopleCountLabel)
        backView.addSubview(purchaseStateLabel)
        backView.addSubview(tagsView)
        backView.addSubview(ecmLabelsView)
        backView.addSubview(ipoAdmissionFeeLabel)
        backView.addSubview(ecmAdmissionFeeLabel)
        backView.addSubview(ipoAdmissionFeeDesLabel)
        backView.addSubview(ecmAdmissionFeeDesLabel)
        
        tagButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(uniHorLength(-22))
            make.top.equalToSuperview().offset(27)
        }
        tagButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        tagButton.titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(innerMargin)
            make.centerY.equalTo(tagButton.snp.centerY)
            make.right.lessThanOrEqualTo(tagButton.snp.left).offset(-46)
        }
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        codeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(3)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.right.lessThanOrEqualTo(tagButton.snp.left).offset(-3)
        }
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        ecmLabelsView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.top.equalTo(nameLabel.snp.bottom)
            make.right.equalToSuperview().offset(-innerMargin)
            make.height.equalTo(0)
        }
        
        recommendImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        deadLineLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(ecmLabelsView.snp.bottom).offset(20)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(deadLineLabel.snp.bottom).offset(5)
        }
        
        peopleCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(backView.snp.left).offset(188 * YXConstant.screenWidth / 375.0)
            make.top.equalTo(deadLineLabel.snp.top)
        }
        
        purchaseStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(peopleCountLabel.snp.left)
            make.top.equalTo(peopleCountLabel.snp.bottom).offset(5)
        }
        
        ipoAdmissionFeeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
        }
        
        ipoAdmissionFeeDesLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(ipoAdmissionFeeLabel.snp.bottom).offset(5)
            make.right.lessThanOrEqualTo(ecmAdmissionFeeDesLabel.snp.left).offset(-10)
        }
        
        ecmAdmissionFeeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(peopleCountLabel.snp.left)
            make.top.equalTo(ipoAdmissionFeeLabel.snp.top)
        }
        
        ecmAdmissionFeeDesLabel.snp.makeConstraints { (make) in
            make.left.equalTo(peopleCountLabel.snp.left)
            make.top.equalTo(ecmAdmissionFeeLabel.snp.bottom).offset(5)
        }
        
        tagsView.snp.makeConstraints { (make) in
            make.left.equalTo(backView.snp.left).offset(14)
            make.right.equalToSuperview().offset(-14)
            make.top.equalTo(ipoAdmissionFeeDesLabel.snp.bottom).offset(20)
            make.height.equalTo(0)
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.belowView.layer.shadowPath = UIBezierPath.init(rect: self.belowView.bounds.offsetBy(dx: 0, dy: 4)).cgPath
    }
    
    func asyncRender() {
        DispatchQueue.main.async {
            self.belowView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.belowView.layer.cornerRadius = 10
            self.belowView.layer.borderColor = UIColor.qmui_color(withHexString: "#F7F7F7")?.cgColor
            self.belowView.layer.borderWidth = 1
            self.belowView.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
            //self.belowView.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.belowView.layer.shadowOpacity = 1.0
            //self.belowView.layer.shadowRadius = 4
            
            self.backView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.backView.layer.cornerRadius = 10
            self.backView.layer.masksToBounds = true
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 210

        if ecmLabelsView.totalHeight > 0 {
            size.height += ecmLabelsView.totalHeight
        }

        if tagsView.totalHeight > 0 {
            size.height += (tagsView.totalHeight + 20)
        }
        return size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lazy setter and getter
    
    lazy var belowView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 16.0
        label.textAlignment = .left
        return label
    }()
    
    lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 14.0
        label.textAlignment = .left
        return label
    }()
    
    lazy fileprivate var tagButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 2.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()

    //标签列表
    lazy var ecmLabelsView: YXNewStockTagsView = {
        let view = YXNewStockTagsView()
        view.textFont = UIFont.systemFont(ofSize: 12)
        view.textColor = QMUITheme().themeTextColor()
        view.contentInset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        view.cornerRadius = 4
        view.tagBackgroundColor = UIColor.qmui_color(withHexString: "#E5EDFF")
        view.lineSpacing = 10
        view.columSpacing = 7
        return view
    }()


    lazy var deadLineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var peopleCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var purchaseStateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var ipoAdmissionFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    lazy var ipoAdmissionFeeDesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var ecmAdmissionFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    lazy var ecmAdmissionFeeDesLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var tagsView: YXNewStockTagsView = {
        let view = YXNewStockTagsView()
        view.maxShowLines = 3
        return view
    }()
    
    lazy var recommendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stock_recommend")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
}
