//
//  YXBondDetailViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/8/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXBondDetailViewController: YXHKViewController, HUDViewModelBased {
    
    typealias ViewModelType = YXBondDetailViewModel
    
    var viewModel: YXBondDetailViewModel!
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    
    let containerView = UIView()
    let headerView = UIView()
    let entrustView = UIView()
    let changeView = UIView()
    let finishView = UIView()
    
    var containsChange = false
    
    lazy var tipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "stock_detail_about")
        return imageView
    }()
    
    lazy var tipLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    //headerView
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        return label
    }()
    
    lazy var symbolLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var statusNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    var directionLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    //entrustView
    lazy var entrustStateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 16.0 / 20.0
        label.text = YXLanguageUtility.kLang(key: "delgation_trading")
        return label
    }()
    
    lazy var entrustTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    
    lazy var entrustLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1()
        view.isHidden = true
        return view
    }()
    
    var entrustLeftLabels: [QMUILabel] = []
    var entrustRightLabels: [QMUILabel] = []
  
    //finishView
    var finishStateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.minimumScaleFactor = 16.0 / 20.0
        
        return label
    }()
    
    var finishEndLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    
    var finishTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()
    // 委托面值label
    var entrustFaceLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    // 成交面值label
    var finishFaceLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    var finishLeftLabels: [QMUILabel] = []
    var finishRightLabels: [QMUILabel] = []
    
    //feeView
    lazy var feeView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.05)
        view.layer.cornerRadius = 10
        view.layer.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.05).cgColor
        view.layer.shadowColor = QMUITheme().themeTintColor().withAlphaComponent(0.1).cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 4
        
        
        
        let startX = YXConstant.screenWidth - 36 - 44
        let bezierpath = UIBezierPath()
        bezierpath.move(to: CGPoint(x: startX, y: 0))
        bezierpath.addLine(to: CGPoint(x: startX + 6.5, y: -12))
        bezierpath.addLine(to: CGPoint(x: startX + 13, y: 0))
        bezierpath.close()
    
        let layer = CAShapeLayer()
        layer.fillColor = QMUITheme().mainThemeColor().withAlphaComponent(0.05).cgColor
        layer.strokeColor = UIColor.clear.cgColor
        layer.path = bezierpath.cgPath
        
        view.layer.addSublayer(layer)
        
        return view
    }()
    
    var feeLeftLabels: [QMUILabel] = []
    var feeRightLabels: [QMUILabel] = []
    
    lazy var feeExplainView: UIView = {
        let view = UIView()
        let label = QMUILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 12);
        label.text = YXLanguageUtility.kLang(key: "hold_transaction_explain")
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().offset(-8)
        })
                
        let arrowView = UIImageView(image: UIImage(named: "up_arrow")?.qmui_image(withTintColor: QMUITheme().mainThemeColor())?.qmui_image(with: .right))
        view.addSubview(arrowView)
        arrowView.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(label.snp.right).offset(5)
        })
        
        view.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            if ges.state == .ended {
                let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.TRANSACTION_FEE_DESCRIPTION_URL()]
                self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }).disposed(by: disposeBag)
        
        return view
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "down_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel2()))
        return imageView
    }()
    
    var isExpand = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = YXLanguageUtility.kLang(key: "hold_order_detail")
        
        bindHUD()
        
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(18 + 15 + 6)
            make.right.equalTo(view).offset(-18)
            make.bottom.equalTo(view.safeArea.bottom).offset(-10)
        }
        
        view.addSubview(tipImageView)
        tipImageView.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.equalTo(tipLabel.snp.top).offset(-4)
            make.width.height.equalTo(23)
        }
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(view.safeArea.top)
            make.bottom.equalTo(tipLabel.snp.top).offset(-10)
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        viewModel.hudSubject.subscribe(onNext: { [weak self] (type) in
            guard let strongSelf = self else { return }
            
            if case .error(_, _) = type, strongSelf.viewModel.detailRelay.value == nil {
                strongSelf.showErrorEmptyView()
                strongSelf.view.insertSubview(strongSelf.emptyView ?? UIView(), belowSubview: strongSelf.networkingHUD)
            }
        }).disposed(by: disposeBag)
        
        viewModel.detailRelay.asDriver().drive(onNext: { [weak self] (detail) in
            guard let strongSelf = self else { return }
            
            if let data = detail {
        
                strongSelf.hideEmptyView()
                strongSelf.nameLabel.text = data.bondInfoVO?.bondName ?? "--"
                strongSelf.symbolLabel.text = YXLanguageUtility.kLang(key: "bond")
                strongSelf.statusNameLabel.text = data.externalStatusName ?? ""
                strongSelf.directionLabel.text = data.orderDirection
                
                var color = UIColor.qmui_color(withHexString: "#F1B92D")
                if let direct = data.direction, direct.type == 1 {
                    color = QMUITheme().mainThemeColor()
                }
                
                strongSelf.directionLabel.textColor = color
                
                strongSelf.tipLabel.text = data.bottomRemark ?? ""
                
                let numberFormatter = NumberFormatter()
                numberFormatter.positiveFormat = "###,##0.00"
                numberFormatter.locale = Locale(identifier: "zh")
                let countFormatter = NumberFormatter()
                countFormatter.positiveFormat = "###,##0"
                countFormatter.locale = Locale(identifier: "zh")
                
                if let createTime = data.createTime {
                    strongSelf.entrustTimeLabel.text = YXDateHelper.dateSting(from: TimeInterval(createTime))
                } else {
                    strongSelf.entrustTimeLabel.text = "--"
                }
                
                let moneyUnit = data.bondInfoVO?.currency?.name ?? YXLanguageUtility.kLang(key: "common_us_dollar")
                
                if let faceValue = data.bondInfoVO?.minFaceValue {
                    let format = countFormatter.string(from: NSNumber(value: faceValue)) ?? "0"
                    strongSelf.entrustFaceLabel.text = "\(YXLanguageUtility.kLang(key: "bond_min_startup"))\(format)\(moneyUnit)/\(YXLanguageUtility.kLang(key: "copies"))"
                } else {
                    strongSelf.entrustFaceLabel.text = "\(YXLanguageUtility.kLang(key: "bond_min_startup"))--\(moneyUnit)/\(YXLanguageUtility.kLang(key: "copies"))"
                }
                
                strongSelf.entrustRightLabels.enumerated().forEach({ (offset, label) in
                    switch offset {
                    case 0:
                        label.text = moneyUnit
                    case 1:
                        if let entrustPrice = data.bondOrderEntrustVO?.entrustPrice {
                            label.text = String(format:"%.4f", Double(entrustPrice) ?? 0.0)
                        }
                    case 2:
                        if let copies = data.bondOrderEntrustVO?.copies, let volumn = Int64(copies) {
                            label.text = (countFormatter.string(from: NSNumber(value: volumn)) ?? "0")  + YXLanguageUtility.kLang(key: "copies")
                        }
                    case 3:
                        if let entrustAmount = data.bondOrderEntrustVO?.entrustMarketValue, let amount = Double(entrustAmount) {
                            label.text = (numberFormatter.string(from: NSNumber(value: amount)) ?? "0")
                        }
                    case 4:
                        let interestTitleLabel = self?.entrustLeftLabels[offset]
                        if (data.direction?.type == 1) {
                            interestTitleLabel?.text = YXLanguageUtility.kLang(key: "pay_interes")
                        }else {
                            interestTitleLabel?.text = YXLanguageUtility.kLang(key: "bond_interest")
                        }
                        if let entrustAmount = data.bondOrderEntrustVO?.entrustInterest, let amount = Double(entrustAmount) {
                            label.text = (numberFormatter.string(from: NSNumber(value: amount)) ?? "0")
                        }
                    default:
                        break
                    }
                    if label.text == nil || label.text == ""  {
                        label.text = "--"
                    }
                })
                
                if let status = data.externalStatus, status >= 5, status <= 11 { // 终态
                    
                    strongSelf.finishStateLabel.text = data.externalStatusFinalName ?? ""
                    
                    var strings: [String]?
                    if data.externalStatusFinalName?.contains("(") ?? false {
                        strings = data.externalStatusFinalName?.components(separatedBy: "(")
                        guard strings?.count ?? 0 > 1 else {
                            return
                        }
                        if let string = strings?.first {
                            self?.finishStateLabel.text = string
                        }
                        if let string = strings?[1] {
                            self?.finishEndLabel.text = "(" + string
                        }
                    }else if data.externalStatusFinalName?.contains("（") ?? false {
                        strings = data.externalStatusFinalName?.components(separatedBy: "（")
                        guard strings?.count ?? 0 > 1 else {
                            return
                        }
                        if let string = strings?.first {
                            self?.finishStateLabel.text = string
                        }
                        if let string = strings?[1] {
                            self?.finishEndLabel.text = "（" + string
                        }
                    }
                    
                    strongSelf.entrustLineView.isHidden = false
                    strongSelf.setupFinishView(failedRemark: data.failedRemark)
                    if let createTime = data.finishedTime {
                        strongSelf.finishTimeLabel.text = YXDateHelper.dateSting(from: TimeInterval(createTime))
                    } else {
                        strongSelf.finishTimeLabel.text = "--"
                    }
                    
                    if let faceValue = data.bondInfoVO?.minFaceValue {
                        let format = countFormatter.string(from: NSNumber(value: faceValue)) ?? "0"
                        strongSelf.finishFaceLabel.text = "\(YXLanguageUtility.kLang(key: "bond_min_startup"))\(format)\(moneyUnit)/\(YXLanguageUtility.kLang(key: "copies"))"
                    } else {
                        strongSelf.finishFaceLabel.text = "\(YXLanguageUtility.kLang(key: "bond_min_startup"))--\(moneyUnit)/\(YXLanguageUtility.kLang(key: "copies"))"
                    }
                    
                    strongSelf.finishRightLabels.enumerated().forEach({ [weak self](offset, label) in
                        switch offset {
                        case 0:
                            if let clinchPrice = data.bondOrderClinchVO?.clinchPrice, let value = Double(clinchPrice) {
                                label.text = String(format:"%.4f", value)
                            }
                        case 1:
                            if let copies = data.bondOrderClinchVO?.copies, let value = Int64(copies) {
                                label.text = (countFormatter.string(from: NSNumber(value: value)) ?? "0") + YXLanguageUtility.kLang(key: "copies")
                            }
                        case 2:
                            if let clinchAmount = data.bondOrderClinchVO?.clinchAmount, let value = Double(clinchAmount) {
                                label.text = numberFormatter.string(from: NSNumber(value: value))
                            }
                        case 3:
                            let interestTitleLabel = self?.finishLeftLabels[offset]
                            if (data.direction?.type == 1) {
                                interestTitleLabel?.text = YXLanguageUtility.kLang(key: "pay_interes")
                            }else {
                                interestTitleLabel?.text = YXLanguageUtility.kLang(key: "bond_interest")
                            }
                            if let clinchInterest = data.bondOrderClinchVO?.clinchInterest, let value = Double(clinchInterest) {
                                label.text = numberFormatter.string(from: NSNumber(value: value))
                            }
                        case 4:
                            if let clinchCharge = data.bondOrderClinchVO?.clinchCharge, let value = Double(clinchCharge) {
                                label.text = numberFormatter.string(from: NSNumber(value: value))
                            }
                        default:
                            break
                        }
                        if label.text == nil || label.text == "" {
                            label.text = "--"
                        }
                    })
                    
                    strongSelf.feeRightLabels.enumerated().forEach({ [weak self](offset, label) in
                        if data.direction?.type == 1 { // 买入
                            self?.feeLeftLabels[2].isHidden = true
                            self?.feeRightLabels[2].isHidden = true
                            self?.feeView.snp.updateConstraints { (make) in
                                make.height.equalTo(100)
                            }
                        }else { // 卖出
                            self?.feeLeftLabels[2].isHidden = false
                            self?.feeRightLabels[2].isHidden = false
                            self?.feeView.snp.updateConstraints { (make) in
                                make.height.equalTo(120)
                            }
                        }
                        switch offset {
                        case 0:
                            if let commission = data.commission, let value = Double(commission) {
                                label.text = numberFormatter.string(from: NSNumber(value: value))
                            }
                        case 1:
                            if let platformFee = data.platformFee, let value = Double(platformFee) {
                                label.text = numberFormatter.string(from: NSNumber(value: value))
                            }
                        case 2:
                            if let finraFee = data.finraFee, let value = Double(finraFee) {
                                label.text = numberFormatter.string(from: NSNumber(value: value))
                            }
                        default:
                            break
                        }
                        
                        if label.text == nil || label.text == "" {
                            label.text = "--"
                        }
                    })
                }
            }
        }).disposed(by: disposeBag)
        
        setupHeaderView()
        setupEntrustView()
        
        viewModel.requestDetail()
    }
    
    override func emptyRefreshButtonAction() {
        viewModel.requestDetail()
    }
    
    func leftLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        return label
    }
    
    func rightLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }
    
    func setupHeaderView() {
        containerView.addSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.width.top.equalTo(self.containerView);
            make.height.equalTo(90);
        }
        
        headerView.addSubview(statusNameLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(symbolLabel)
        headerView.addSubview(directionLabel)
        
        statusNameLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.top.equalTo(self.headerView).offset(14)
        }
        statusNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.top.equalTo(self.headerView).offset(14)
            make.right.lessThanOrEqualTo(statusNameLabel.snp.left).offset(-10)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.right.lessThanOrEqualTo(directionLabel.snp.left).offset(-10)
        }
        
        directionLabel.snp.makeConstraints { make in
            make.right.equalTo(headerView).offset(-18)
            make.top.equalTo(symbolLabel)
        }
        directionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        headerView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
    }
    
    func setupEntrustView() {
        containerView.addSubview(entrustView)
        
        entrustView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.width.equalTo(containerView)
            make.height.equalTo(242)
            make.bottom.equalTo(containerView)
        }
        
        setupEntrustLabels()
    }
    
    func setupEntrustLabels() {
        
        entrustView.addSubview(entrustStateLabel)
        entrustView.addSubview(entrustTimeLabel)
        entrustStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.equalTo(20)
            make.right.lessThanOrEqualTo(entrustTimeLabel.snp.left)
        }
        
        entrustTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(entrustView).offset(-18)
            make.centerY.equalTo(entrustStateLabel)
        }
        entrustTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        // 币种
        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "hold_dollar_type")
        // 价格
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "delgation_price")
        // 份数
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "entrust_part_num")
        // 金额
        let label4 = leftLabel()
        label4.text = YXLanguageUtility.kLang(key: "delgation_money")
        // 利息
        let label5 = leftLabel()
        label5.text = YXLanguageUtility.kLang(key: "pay_interes")
        
        entrustView.addSubview(label1)
        entrustView.addSubview(label2)
        entrustView.addSubview(label3)
        entrustView.addSubview(label4)
        entrustView.addSubview(label5)
        
        entrustLeftLabels = [label1, label2, label3, label4, label5]
        
        var rightLabels = [QMUILabel]()
        for _ in 0..<entrustLeftLabels.count {
            let label = rightLabel()
            entrustView.addSubview(label)
            rightLabels.append(label)
        }
        entrustRightLabels = rightLabels
        
        var topMargin: CGFloat = 57
        let labelHeight: CGFloat = 30
        
        for index in 0..<entrustLeftLabels.count {
            let leftLabel = entrustLeftLabels[index]
            let rightLabel = entrustRightLabels[index]
            
            leftLabel.snp.makeConstraints { (make) in
                make.left.equalTo(18)
                make.height.equalTo(labelHeight)
                make.top.equalTo(topMargin)
            }
            
            rightLabel.snp.makeConstraints { (make) in
                make.right.equalTo(entrustView).offset(-18)
                make.height.equalTo(labelHeight)
                make.top.equalTo(topMargin)
            }
            
            topMargin += labelHeight
            if index == 2 {
                entrustView.addSubview(entrustFaceLabel)
                entrustFaceLabel.snp.makeConstraints { (make) in
                    make.right.equalTo(entrustView).offset(-18)
                    make.top.equalTo(topMargin - 3)
                }
                topMargin += 18
            }
        }
     
        entrustView.addSubview(entrustLineView)
        entrustLineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
    }
    
    
    func setupFinishView(failedRemark: String?) {
  
        entrustView.snp.remakeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.width.equalTo(containerView)
            make.height.equalTo(242)
        }
        
        containerView.addSubview(finishView)
        
        setupFinishLabels()
        
        var height = 260
        
        if let failReason = failedRemark, failReason.count > 0 {
            setupFailLabels(failReason: failReason)
            setupFinishDetailLabels(isHaveReasonLabel: true)
            height = 290
        }else {
            setupFinishDetailLabels(isHaveReasonLabel: false)
        }
        
        setupFeeView()
        
        finishView.snp.makeConstraints { (make) in
            make.top.equalTo(entrustView.snp.bottom)
            make.left.width.equalTo(containerView)
            make.height.equalTo(height)
            make.bottom.lessThanOrEqualTo(containerView)
        }
    }
    
    func setupFinishLabels() {
        
        finishView.addSubview(finishStateLabel)
        finishView.addSubview(finishTimeLabel)
        finishView.addSubview(finishEndLabel)
        
        finishStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.equalTo(20)
            make.right.lessThanOrEqualTo(finishTimeLabel.snp.left)
        }
        
        finishTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(finishView).offset(-18)
            make.centerY.equalTo(finishStateLabel)
        }
        finishTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        finishEndLabel.snp.makeConstraints { (make) in
            make.left.equalTo(finishStateLabel)
            make.top.equalTo(finishStateLabel.snp.bottom).offset(2)
        }
    }
    
    func setupFailLabels(failReason: String) {
        let reasonTitleLabel = leftLabel()
        reasonTitleLabel.text = YXLanguageUtility.kLang(key: "fail_reason")
        
        let reasonValueLabel = rightLabel()
        reasonValueLabel.text = failReason
        reasonValueLabel.adjustsFontSizeToFitWidth = true
        reasonValueLabel.minimumScaleFactor = 0.3
        finishView.addSubview(reasonTitleLabel)
        finishView.addSubview(reasonValueLabel)
        
        let topMargin: CGFloat = 77
        let labelHeight: CGFloat = 30
        
        reasonTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.height.equalTo(labelHeight)
            make.top.equalTo(topMargin)
        }
        
        reasonValueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(finishView).offset(-18)
            make.height.equalTo(labelHeight)
            make.top.equalTo(topMargin)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth - 100)
        }
    }
    
    func setupFinishDetailLabels(isHaveReasonLabel: Bool) {
        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "hold_transaction_cost_price")
        
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "volume_unit")
        
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "hold_transaction_money")
        
        let label4 = leftLabel()
        label4.text = YXLanguageUtility.kLang(key: "pay_interes")
        
        let label5 = leftLabel()
        label5.text = YXLanguageUtility.kLang(key: "hold_transaction_total_fee")
        
        finishView.addSubview(label1)
        finishView.addSubview(label2)
        finishView.addSubview(label3)
        finishView.addSubview(label4)
        finishView.addSubview(label5)
        
        finishLeftLabels = [label1, label2, label3, label4, label5]
        
        var rightLabels = [QMUILabel]()
        for _ in 0..<finishLeftLabels.count {
            let label = rightLabel()
            finishView.addSubview(label)
            rightLabels.append(label)
        }
        finishRightLabels = rightLabels
        
        var topMargin: CGFloat = isHaveReasonLabel ? 107 : 77
        let labelHeight: CGFloat = 30
        
        for index in 0..<finishLeftLabels.count {
            let leftLabel = finishLeftLabels[index]
            let rightLabel = finishRightLabels[index]
            
            leftLabel.snp.makeConstraints { (make) in
                make.left.equalTo(18)
                make.height.equalTo(labelHeight)
                make.top.equalTo(topMargin)
            }
            
            rightLabel.snp.makeConstraints { (make) in
                make.right.equalTo(finishView).offset(-18)
                make.height.equalTo(labelHeight)
                make.top.equalTo(topMargin)
            }
            
            topMargin += labelHeight
            if index == 1 {
                finishView.addSubview(finishFaceLabel)
                finishFaceLabel.snp.makeConstraints { (make) in
                    make.right.equalTo(finishView).offset(-18)
                    make.top.equalTo(topMargin - 3)
                }
                topMargin += 18
            }
        }
        
        rightLabels[4].snp.remakeConstraints { (make) in
            make.right.equalTo(finishView).offset(-40)
            make.centerY.equalTo(finishLeftLabels[4])
        }
        
        finishView.addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(finishView).offset(-18)
            make.centerY.equalTo(rightLabels[4])
        }
        
        let arrowBgView = UIView()
        finishView.addSubview(arrowBgView)
        arrowBgView.snp.makeConstraints { (make) in
            make.right.equalTo(finishView).offset(-12)
            make.width.equalTo(60)
            make.bottom.equalTo(finishRightLabels[4])
            make.height.equalTo(30)
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            
            if (strongSelf.isExpand) {
                strongSelf.arrowView.image = UIImage(named: "down_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel2())
                strongSelf.feeView.isHidden = true
                strongSelf.isExpand = false
            } else {
                strongSelf.arrowView.image = UIImage(named: "up_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel2())
                strongSelf.feeView.isHidden = false
                strongSelf.isExpand = true
            }
            
        }).disposed(by: disposeBag)
        arrowBgView.addGestureRecognizer(tap)
    }
    
    func setupFeeView() {
        feeView.isHidden = true
        containerView.addSubview(feeView)
        
        feeView.snp.makeConstraints { (make) in
            make.top.equalTo(finishView.snp.bottom).offset(10)
            make.left.equalTo(18)
            make.right.equalTo(finishView).offset(-18)
            make.height.equalTo(100)
            make.bottom.equalToSuperview()
        }
        
        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "hold_commission_fee")
        label1.textColor = QMUITheme().textColorLevel1()
        
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "hold_platform_useage")
        label2.textColor = QMUITheme().textColorLevel1()
        
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "hold_transaction_levy_fee_us")
        label3.textColor = QMUITheme().textColorLevel1()
    
        feeView.addSubview(label1)
        feeView.addSubview(label2)
        feeView.addSubview(label3)
        
        let labels = [label1, label2, label3]
        feeLeftLabels = labels

        var rightLabels = [QMUILabel]()
        var pre: QMUILabel!
        for (index, leftLabel) in labels.enumerated() {
            let label = rightLabel()
            rightLabels.append(label)
            feeView.addSubview(label)
            
            leftLabel.snp.makeConstraints { (make) in
                make.left.equalTo(14)
                if index == 0 {
                    make.top.equalTo(15)
                }else {
                    make.top.equalTo(pre.snp.bottom).offset(10)
                }
            }
            
            label.snp.makeConstraints { (make) in
                make.right.equalTo(feeView).offset(-14)
                make.centerY.equalTo(leftLabel)
            }
            
            pre = leftLabel
        }
        feeRightLabels = rightLabels
        
        feeView.addSubview(feeExplainView)
        feeExplainView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalTo(feeView).offset(-7)
        }
    }
}

