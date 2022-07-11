//
//  YXNewStockInternalSubsView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockInternalSubsView: UIView {

    typealias EmptyClosure = () -> Void
    typealias AmountClosure = (Double) -> Void
    typealias EnableClosure = (Bool) -> Void
    
    var saveValueClosure: EmptyClosure?
    var purchaseDeclareClosure: EmptyClosure?
    var updateTotalAmountClosure: AmountClosure?
    var purchaseEnableClosure: EnableClosure?
    var agreeDeclareClosure: ((String, String) -> Void)?
    
    //单位
    @objc var unitString = YXToolUtility.moneyUnit(2)
    //阅读申明
    @objc var hasReadDeclares: Bool = true
    var showWarn: Bool = false
    
    var incrementAmount: Double = 0.0
    var baseAmount: Double = 0.0
    var availbleAmount: Double = 0.0
    var handlingFee: Double = 0.0
    var priceMax: Double = 1.0
    var caculateStocks: Int = 0
    
    let predicte = NSPredicate(format: "SELF MATCHES %@", String(format: "^([1-9]\\d{0,%ld}|0)(\\.\\d{0,%ld})?$", 8, 2))
    
    
    //MARK: 刷新数据
    func refreshUI(model: YXNewStockECMOrderInfoModel, sourceParams: YXPurchaseDetailParams, availbleAmount: Double) {
    
        
        self.initAvailableAmountData(availbleAmount)
        
        nameLabel.text = model.stockName ?? "--"
        symbolLabel.text = String(format: "(%@)", model.stockCode ?? "")
        
        //认购股数/金额
        if let moneyType = model.moneyType {
            unitString = YXToolUtility.moneyUnit(moneyType)
        }
        moneyUnitLabel.text = unitString
        
        //原/现手续费, 原手续费和现手续费不等就按优惠展示
        updateFee(originalFee: model.ecmFeeOriginal, nowFee: model.ecmFee)
        self.handlingFee = model.ecmFee ?? 0.0
        //温馨提示
        modifyTips(tips: model.kindlyReminder)
        
        self.baseAmount = model.leastAmount ?? 0.0
        self.incrementAmount = model.incrementalAmount ?? 0.0
        self.priceMax = model.priceMax ?? 1.0
        
        warnLabel.text = self.warnString
        subsNumberView.valueLabel.text = "0" + YXLanguageUtility.kLang(key: "newStock_stock_unit")
        
        if sourceParams.isModify == 1 {
            textField.text = String(sourceParams.ecmApplyAmount)
            updateDataAndWarnMessage()
        } else if self.availbleAmount - self.handlingFee < self.baseAmount {
            
            changeWarnMessageState(isWarn: true, warnMessage: self.warnString + ", " + YXLanguageUtility.kLang(key: "newStock_ipo_ecm_cash_not_enough"))
        }
        
        if self.availbleAmount - self.handlingFee < self.baseAmount {
            self.textField.isUserInteractionEnabled = false
        }
        
        
        do {
            var linkStrings: [String] = []
            let urlStrings: [String] = [model.prospectusLink ?? "", model.ecmAppLinkDto?.link ?? ""]
            let webTitles: [String] = [YXLanguageUtility.kLang(key: "newStock_detail_stockpdf"), model.ecmAppLinkDto?.name ?? ""].filter { $0.count > 0 }
            
            var protocolString = ""
            let count = webTitles.count
            for (index, name) in webTitles.enumerated() {
                if !name.isEmpty {
                    var nameString = ""
                    if YXUserManager.isENMode() {
                        nameString = String(format: "\"%@\"", name)
                        protocolString.append(nameString)
                        if index < count - 1 {
                            protocolString.append(" and ")
                        }
                        
                    } else {
                        nameString = String(format: "《%@》", name)
                        protocolString.append(nameString)
                        if index < count - 1 {
                            protocolString.append("、")
                        }
                    }
                    linkStrings.append(nameString)
                }
            }
  
            let formatString: String = YXLanguageUtility.kLang(key: "ecm_agree_declare")
            let agreeString = String(format: formatString, protocolString)
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 8
            let attributeString = NSMutableAttributedString.init(string: agreeString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2(), NSAttributedString.Key.paragraphStyle : paragraph])
            
            for (index, string) in linkStrings.enumerated() {
                let range = (agreeString as NSString).range(of: string)
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor()], range: range)
                
                attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTextColor(), backgroundColor: UIColor.clear, tapAction: { [weak self] (view, attstring, range, rect) in
                    guard let `self` = self else { return }
                    
                    self.textField.resignFirstResponder()
                    var webTitle = ""
                    if index < webTitles.count {
                        webTitle = webTitles[index]
                    }
                    if index < urlStrings.count, urlStrings[index].count > 0 {
                        self.agreeDeclareClosure?(urlStrings[index], webTitle)
                    }
                })
            }
            
            declareLabel.attributedText = attributeString
            let height = (agreeString as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 35 - 18, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle : paragraph], context: nil).size.height
            declareLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(declareButton.snp.right).offset(3)
                make.top.equalTo(declareButton.snp.top).offset(-2)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
                make.height.equalTo(height)
            }
        }
    }
    
    func refreshEmptyView(availbleAmount: Double, sourceParams: YXPurchaseDetailParams) {
        
        self.initAvailableAmountData(availbleAmount)
        nameLabel.text = "--"
        symbolLabel.text = ""
        
        //认购股数/金额
        if sourceParams.exchangeType == YXExchangeType.us.rawValue {
            moneyUnitLabel.text = YXToolUtility.moneyUnit(1)
        } else {
            moneyUnitLabel.text = unitString
        }
        
        //原/现手续费, 原手续费和现手续费不等就按优惠展示
        updateFee(originalFee: "0.00", nowFee: 0.00)
        self.handlingFee = 0.0
        //温馨提示
        modifyTips(tips: "")
        
        self.baseAmount =  0.0
        self.incrementAmount =  0.0
        self.priceMax = 1.0
        
        warnLabel.text = self.warnString
        subsNumberView.valueLabel.text = "0" + YXLanguageUtility.kLang(key: "newStock_stock_unit")
    }
    
    //更新手续费
    func updateFee(originalFee: String?, nowFee: Double?) {
        
        bookingFeeNumLabel.isHidden = true
        bookingFeeNumImage.isHidden = true
        //原/现手续费, 原手续费和现手续费不等就按优惠展示
        if let bookFeeOriginal = originalFee, bookFeeOriginal.count > 0, let originalFee =  Double(bookFeeOriginal),
            let bookingFee = nowFee, fabs(originalFee - bookingFee) > 1e-6 {
            let string = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(originalFee), unitString)
            let mutString = NSMutableAttributedString.init(string: string)
            mutString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber.init(value: 1), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(NSAttributedString.Key.baselineOffset, value: NSNumber.init(value: 0), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel1().withAlphaComponent(0.6), range: NSRange(location: 0, length: mutString.length))
            mutString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: mutString.length))
            bookFeeOriginalLabel.attributedText = mutString
            bookingFeeNumLabel.isHidden = false
            bookingFeeNumImage.isHidden = false
        } else if let bookingFee = nowFee {
            bookFeeOriginalLabel.attributedText = NSAttributedString.init(string: String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(bookingFee), unitString), attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        } else {
            bookFeeOriginalLabel.attributedText = NSAttributedString.init(string: "--", attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        }
        
        //优惠费用
        if let bookingFee = nowFee {
           bookingFeeNumLabel.text = String(format: "%@%@     ", YXNewStockMoneyFormatter.shareInstance.formatterMoney(bookingFee), unitString)
        }
    }
    
    func modifyTips(tips: String?) {
        //温馨提示
        tipLabel.isHidden = true
        tipTextFirstLabel.isHidden = true
        if let tip = tips, tip.count > 0, let data = tip.data(using: .unicode) {
            tipLabel.isHidden = false
            tipTextFirstLabel.isHidden = false
            tipTextFirstLabel.attributedText = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType :  NSAttributedString.DocumentType.html], documentAttributes: nil)
        }
    }
    
    
    //MARK: 初始化用户可用现金
    @objc func initAvailableAmountData(_ availAmount: Double) -> Void {
        
        if let doubleAmount = Double(String(format: "%.2lf", availAmount)),
            let string = moneyFormatter.string(from: NSNumber(value: doubleAmount)) {
            self.availbleAmount = availAmount
            allowedAmountLabel.text = String(format: "%@ %@%@", YXLanguageUtility.kLang(key: "newStock_certified_funds"), string, unitString)
        } else {
            allowedAmountLabel.text = String(format: "%@ 0.00%@", YXLanguageUtility.kLang(key: "newStock_certified_funds"), unitString)
        }
    }
    
    func totalAmount() -> Double {
        var amount = 0.0
        if let text = textField.text, let inputAmount = Double(text) {
            amount = inputAmount
        }
        return amount + self.handlingFee
    }
    
    @objc lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        return formatter;
    }()
    
    //MARK: 去入金
    @objc func currencyButtonEvent() -> Void {
        if let closure = saveValueClosure {
            closure()
        }
    }
    
    //MARK: 同意按钮点击
    @objc func declareButtonEvent() -> Void {
        
        if hasReadDeclares {
            hasReadDeclares = false
            declareButton.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        } else {
            hasReadDeclares = true
            declareButton.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .normal)
        }
        
        setPurchaseButtonEnable()
    }
    
    var warnString: String {

        String(format: YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sub_amount_tip"), YXNewStockMoneyFormatter.shareInstance.formatterMoney(self.baseAmount, pointCount: 0), unitString, YXNewStockMoneyFormatter.shareInstance.formatterMoney(self.incrementAmount, pointCount: 0), unitString)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    func initializer() {
        
        do {
            addSubview(nameLabel)
            addSubview(symbolLabel)
            //股票名
            nameLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.top.equalToSuperview().offset(25)
                make.right.lessThanOrEqualToSuperview().offset(-78)
            }
            
            //股票代码
            symbolLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(nameLabel.snp.centerY)
                make.left.equalTo(nameLabel.snp.right).offset(3)
                make.height.equalTo(20)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
            }
        }
        
        let itemHeight: CGFloat = 55.0
        
        //认购金额
        do {
            addSubview(usedCashView)
            usedCashView.snp.makeConstraints { (make) in
                make.height.equalTo(itemHeight)
                make.left.right.equalToSuperview()
                make.top.equalTo(nameLabel.snp.bottom).offset(20)
            }
            
            usedCashView.addSubview(moneyUnitLabel)
            usedCashView.addSubview(textField)
            moneyUnitLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-18)
                make.centerY.equalToSuperview()
            }
            
            textField.snp.makeConstraints { (make) in
                make.right.equalTo(moneyUnitLabel.snp.left).offset(-10)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
                make.left.greaterThanOrEqualTo(usedCashView.titleLabel.snp.right).offset(6)
            }
            
            addSubview(warnLabel)
            warnLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.top.equalTo(usedCashView.snp.bottom).offset(10)
                make.right.equalToSuperview().offset(-18)
            }
        }
        
        addSubview(subsNumberView)
        subsNumberView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(warnLabel.snp.bottom).offset(10)
            make.height.equalTo(itemHeight)
        }
        
        do {
            //手续费
            addSubview(feeView)
            feeView.snp.makeConstraints { (make) in
                make.top.equalTo(subsNumberView.snp.bottom)
                make.height.equalTo(itemHeight)
                make.left.right.equalToSuperview()
            }
            
            feeView.addSubview(bookFeeOriginalLabel)
            feeView.addSubview(bookingFeeNumLabel)
            feeView.addSubview(bookingFeeNumImage)
            
            bookFeeOriginalLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(feeView.snp.centerY)
                make.right.equalTo(feeView.snp.right).offset(-18)
            }
            
            bookingFeeNumLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(feeView.snp.centerY)
                make.right.equalTo(bookFeeOriginalLabel.snp.left).offset(-5)
            }
            
            bookingFeeNumImage.snp.makeConstraints { (make) in
                make.center.equalTo(bookingFeeNumLabel.snp.center)
                make.height.equalTo(20)
                make.width.equalTo(bookingFeeNumLabel.snp.width)
            }
            feeView.bringSubviewToFront(bookingFeeNumLabel)
        }
        
        addSubview(allowedAmountLabel)
        addSubview(currencyButton)
        
        allowedAmountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(18)
            make.top.equalTo(feeView.snp.bottom).offset(10)
        }
        
        currencyButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(allowedAmountLabel.snp.centerY)
            make.left.equalTo(allowedAmountLabel.snp.right).offset(6)
            make.right.lessThanOrEqualTo(self.snp.right)
        }
        
        do {
            addSubview(declareButton)
            addSubview(declareLabel)
            addSubview(tipLabel)
            addSubview(tipTextFirstLabel)
            declareButton.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(allowedAmountLabel.snp.bottom).offset(20)
                make.height.equalTo(14)
                make.width.equalTo(14)
            }
            
            declareLabel.snp.makeConstraints { (make) in

                make.left.equalTo(declareButton.snp.right).offset(3)
                make.top.equalTo(declareButton.snp.top).offset(-2)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
                make.height.equalTo(60)
            }
            
            
            tipLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(declareLabel.snp.bottom).offset(35)
                make.right.lessThanOrEqualTo(self.snp.right).offset(-18)
            }
            
            tipTextFirstLabel.snp.makeConstraints { (make) in
                make.left.equalTo(self.snp.left).offset(18)
                make.top.equalTo(tipLabel.snp.bottom).offset(10)
                make.right.equalTo(self.snp.right).offset(-18)
                make.bottom.equalToSuperview().offset(-20)
            }
        }
    }
    
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 14.0 / 20.0
        return label
    }()
    
    @objc lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 12.0
        return label
    }()
    
    //参考认购股数
    lazy var subsNumberView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_ipo_ecm_sub_quantity")
        view.tipButton.isHidden = false
        view.delegate = self
        view.lineView.isHidden = true
        return view
    }()
    
    //手续费
    lazy var feeView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_handling_fee")
        return view
    }()
    
    
    //原费用
    @objc lazy var bookFeeOriginalLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    //现费用
    @objc lazy var bookingFeeNumLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
        
    }()
    
    lazy var bookingFeeNumImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "purchase_fee")
        return imageView
    }()
    
    //可用现金
    @objc lazy var allowedAmountLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //入金
    @objc lazy var currencyButton: UIButton = {
        let button = UIButton()
        button .setTitle(YXLanguageUtility.kLang(key: "newStock_save_cash"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(currencyButtonEvent), for: .touchUpInside)
        return button
    }()
    
    @objc lazy var declareButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .normal)
        button.addTarget(self, action: #selector(declareButtonEvent), for: .touchUpInside)
        return button
    }()
    
    lazy var declareLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = YXLanguageUtility.kLang(key: "newStock_tips") + ":"
        return label
    }()
    
    lazy var tipTextFirstLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    //认购金额
    lazy var usedCashView: YXNewStockPurcahseTitleView = {
        let view = YXNewStockPurcahseTitleView()
        view.titleLabel.text = YXLanguageUtility.kLang(key: "newStock_purchase_num")
        view.tipButton.isHidden = false
        view.delegate = self
        let tapGesture = UITapGestureRecognizer.init(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            self.textField.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        return view
    }()
    
    lazy var moneyUnitLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.keyboardType = .numbersAndPunctuation
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = QMUITheme().textColorLevel1()
        textField.textAlignment = .right
        textField.attributedPlaceholder = NSAttributedString.init(string: YXLanguageUtility.kLang(key: "newStock_ipo_ecm_subs_amount_tips"), attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        return textField
    }()
    
    lazy var warnLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension YXNewStockInternalSubsView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var checkStr = textField.text
        
        let rag = checkStr?.toRange(range)
        checkStr = checkStr?.replacingCharacters(in: rag!, with: string)
        if checkStr?.isEmpty ?? true { //checkStr?.count == 0
            return true
        }
        
        return predicte.evaluate(with:checkStr ?? "")
    }
    
    //MARK: 输入框文字变化事件处理
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        updateDataAndWarnMessage()
    }
    
    
    func updateDataAndWarnMessage() {
        var amount = 0.0
        if let text = textField.text, let inputAmount = Double(text) {
            amount = inputAmount
        }
        updateTotalAmountClosure?(amount > 0 ? amount + self.handlingFee : 0.0)
        self.caculateStocks = Int(amount / self.priceMax / YXNewStockMoneyFormatter.internalBaseRate)
        subsNumberView.valueLabel.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(self.caculateStocks) + YXLanguageUtility.kLang(key: "newStock_stock_unit")
        
        if amount > self.availbleAmount - self.handlingFee || self.availbleAmount - self.handlingFee < self.baseAmount {

            changeWarnMessageState(isWarn: true, warnMessage: self.warnString + ", " + YXLanguageUtility.kLang(key: "newStock_ipo_ecm_cash_not_enough"))
        } else if amount < self.baseAmount {
            
            changeWarnMessageState(isWarn: true)
        } else if YXNewStockMoneyFormatter.isIntergerMultiple(amount - self.baseAmount, increse: self.incrementAmount, pointCount: 0) == false {
            
            changeWarnMessageState(isWarn: true)
        } else {
            changeWarnMessageState(isWarn: false)
        }
    }
    
    func changeWarnMessageState(isWarn: Bool, warnMessage: String = "") {
        showWarn = isWarn
        if isWarn {
            usedCashView.lineView.backgroundColor = QMUITheme().tipsColor()
            setPurchaseButtonEnable()
            warnLabel.textColor = QMUITheme().tipsColor()
            warnLabel.text = warnMessage.count > 0 ? warnMessage : self.warnString
        } else {
            usedCashView.lineView.backgroundColor = QMUITheme().separatorLineColor()
            setPurchaseButtonEnable()
            warnLabel.textColor = QMUITheme().textColorLevel2()
            warnLabel.text = warnMessage.count > 0 ? warnMessage : self.warnString
        }
    }
    
    func setPurchaseButtonEnable() {
        if hasReadDeclares && !showWarn {
            purchaseEnableClosure?(true)
        } else {
            purchaseEnableClosure?(false)
        }
    }
}

extension YXNewStockInternalSubsView: YXNewStockPurcahseTitleViewDelegate {
    
    func tipButtonClick(_ titleView: YXNewStockPurcahseTitleView) {
        showEcmDescriptionAlert()
    }
    
    func showEcmDescriptionAlert() {
        
        
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "newStock_finance_declare"), message: YXLanguageUtility.kLang(key: "ipo_ecm_sub_tip2"), messageAlignment: .left)
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
        }))
        
        alertView.showInWindow()
        
    }
}
