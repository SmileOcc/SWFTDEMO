//
//  YXOrderFinishView.swift
//  YouXinZhengQuan
//
//  Created by Apple on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import NSObject_Rx

enum YXOrderDetailFee {
    case unDefine
    case stampDuty          //印花税
    case tradingFee         //交易费
    case tradingTariff      //交易系统使用费
    case SFCTransactionLevy //证监会交易征费
    case FRCTransactionLevy //财汇局交易征费
    case CCASSFee           //中央结算费
    case GST                //消费税
    case clearingFee        //交收费
    case SECFee             //证监会规费
    case TAF                 //美国期权交易活动费
    case FTAF                 //美股交易活动费
    case optionClearingFee   //期权清算费
    case optionRegulatoryFee  //期权监管费
    case exchangeFee          //交易所费用
    case optionExerciseFee    //期权行权费
    case SIFee                //结算指示费
    case commission            //佣金
    case platformFee            //平台使用
    case SGclearingFee       //清算费
}

class YXOrderFinishView: UIView {

    var clickExpand: (() -> Void)?
    var feeHeight: CGFloat = 200
    
    var exchangeType: YXExchangeType?
    var symbolType = ""
    var oddTradeType = 0
    var entrustSide: YXEntrustType? //买卖方向
    
    var finishStateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
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
    
    var finishLeftLabels: [QMUILabel] = []
    var finishRightLabels: [QMUILabel] = []
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "down_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel1()))
        return imageView
    }()
    
    lazy var feeView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().blockColor()
//        view.layer.cornerRadius = 4
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var failReasonTitleLabel: UILabel = {
        let label = leftLabel()
        label.isHidden = true
        label.text = YXLanguageUtility.kLang(key: "fail_reason")
        return label
    }()

    lazy var failReasonLabel: UILabel = {
        let label = rightLabel()
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    var isExpand = false
    
    var orderStatus = 0
    
    var feeRightLabels: [YXOrderDetailRowLabel] = []
    
    lazy var feeExplainView: UIView = {
        let view = UIView()
        let label = leftLabel()
        label.text = YXLanguageUtility.kLang(key: "hold_transaction_explain")
        label.textColor = QMUITheme().textColorLevel2()
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view)
            make.centerX.equalToSuperview().offset(-8)
        })
        
        let arrowView = UIImageView(image: UIImage(named: "up_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel3())?.qmui_image(with: .right))
        view.addSubview(arrowView)
        arrowView.snp.makeConstraints({ (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(label.snp.right).offset(5)
        })
        
        return view
    }()
    
    var item: YXOrderInfoItem?
    {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.positiveFormat = "###,##0.00"
            numberFormatter.locale = Locale(identifier: "zh")

            let countFormatter = NumberFormatter()
            countFormatter.numberStyle = .decimal;
            countFormatter.groupingSize = 3;
            countFormatter.groupingSeparator = ","
            countFormatter.maximumFractionDigits = 4
            
            finishStateLabel.text = item?.detailStatusName?.yx_orderStatueName()
            if let depositStockDay = item?.depositStockDay, depositStockDay.count > 0 {
                finishTimeLabel.text = (item?.createTime ?? "").yx_orderTime() + "\n" + depositStockDay
                finishTimeLabel.numberOfLines = 2
            } else {
//                finishTimeLabel.text = item?.createTime
                finishTimeLabel.text = (item?.createTime ?? "").yx_orderTime()
                if item?.createTime?.count ?? 0 < 4 {
                    finishTimeLabel.text = ""
                }
                finishTimeLabel.numberOfLines = 1
            }

            if failReasonLabel.isHidden == false, let reason = item?.failReason {
                failReasonLabel.text = reason
            }
            
            var unit = YXLanguageUtility.kLang(key: "stock_unit")
            if exchangeType == .usop {
                unit = ""
            }
            
            finishRightLabels.enumerated().forEach({ [weak self] (offset, label) in
                guard let strongSelf = self else { return }
                guard let item = strongSelf.item else { return }
                
                switch offset {
                case 0:
                    if let businessAveragePrice = item.businessAvgPrice?.value as? NSNumber {
                        label.text = priceFormatter.string(from: businessAveragePrice)
                    } else if let businessAveragePrice = item.businessAvgPrice?.value as? String, let value = Double(businessAveragePrice) {
                        label.text = priceFormatter.string(from: NSNumber(value: value))
                    }
                case 1:
                    if let businessAmount = item.businessQty?.value as? Int64 {
                        label.text = (countFormatter.string(from: NSNumber(value: businessAmount)) ?? "0") + unit
                    } else if let entrustAmount = item.businessQty?.value as? Double {
                        label.text = (countFormatter.string(from: NSNumber(value: entrustAmount)) ?? "0") + unit
                    } else if let businessAmount = item.businessQty?.value as? String, let value = Double(businessAmount) {
                        label.text = (countFormatter.string(from: NSNumber(value: value)) ?? "0") + unit
                    }
                case 2:
                    if let businessBalance = item.businessBalance?.value as? Double {
                        label.text = numberFormatter.string(from: NSNumber(value: businessBalance))
                    } else if let businessBalance = item.businessBalance?.value as? Int64 {
                        label.text = numberFormatter.string(from: NSNumber(value: businessBalance))
                    } else if let businessBalance = item.businessBalance?.value as? String, let value = Double(businessBalance)  {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case 3:
                    if let entrustFee = item.entrustFee, let value = Double(entrustFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                default:
                    break
                }
                if label.text == nil || label.text == "" || strongSelf.orderStatus == 6 || strongSelf.orderStatus == 8 {//(strongSelf.exchangeType == .usop && strongSelf.orderStatus != 60 && strongSelf.orderStatus != 70 &&  strongSelf.orderStatus != 100)
                    label.text = "--"
                }
            })
          //  let exchangeType = self.exchangeType ?? .hk
            feeRightLabels.enumerated().forEach({ [weak self] (offset, label) in
                guard let strongSelf = self else { return }
                guard let item = strongSelf.item else { return }
                let feeType = label.feeType
                switch feeType{
                case .stampDuty:
                    if let stampDutyFee = item.stampDutyFee, let value = Double(stampDutyFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .tradingFee,
                     .SECFee:
                    
                    if let transactionFee = item.transactionFee, let value = Double(transactionFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .tradingTariff,
                     .optionClearingFee:
                    if let tradingSystemUsage = item.tradingSystemUsage, let value = Double(tradingSystemUsage) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .SFCTransactionLevy,
                     .FTAF,
                     .TAF,
                     .SIFee:
                    if let transactionLevyFee = item.transactionLevyFee, let value = Double(transactionLevyFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .FRCTransactionLevy,
                     .exchangeFee:
                        if let frcTransactionLevyFee = item.frcTransactionLevyFee, let value = Double(frcTransactionLevyFee) {
                            label.text = numberFormatter.string(from: NSNumber(value: value))
                        }
                case .CCASSFee,
                     .clearingFee,
                     .SGclearingFee,
                     .optionRegulatoryFee:
                    
                    if let payFee = item.payFee, let value = Double(payFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .GST:
                    if let exciseFee = item.exciseFee, let value = Double(exciseFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .commission:
                    if let commissionFee = item.commissionFee, let value = Double(commissionFee) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                case .platformFee:
                    if let platformUseFee = item.platformUseFee, let value = Double(platformUseFee)  {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                default:
                    break
                }
                
                if label.text == nil || label.text == "" || orderStatus == 6 || orderStatus == 8  {
                    label.text = "--"
                }
            })
        }
    }
    
    fileprivate lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 4
        return formatter;
    }()
    
    func leftLabel() -> YXOrderDetailRowLabel {
        let label = YXOrderDetailRowLabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14);
        return label
    }
    
    func rightLabel() -> YXOrderDetailRowLabel {
        let label = YXOrderDetailRowLabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14);
        label.textAlignment = .right
        return label
    }
    
    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return lineView
    }()
    
    var failReasonHeight: CGFloat = 0
    
    init(
        frame: CGRect,
        exchangeType: YXExchangeType,
        symbolType: String = "",
        oddTradeType: Int = 0,
        orderModel: YXOrderInfoItem,
        allOrderType: YXAllOrderType,
        entrustSide:YXEntrustType
    ) {
        super.init(frame: frame)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(53)
            make.height.equalTo(1)
        }
        self.entrustSide = entrustSide
        self.exchangeType = exchangeType
        self.symbolType = symbolType
        self.oddTradeType = oddTradeType
        self.orderStatus = orderModel.detailStatus ?? 0
        addSubview(finishStateLabel)
        finishStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(9)
            make.height.equalTo(40)
            make.right.equalTo(self.snp.centerX).offset(-9)
        }
        
        addSubview(finishTimeLabel)
        finishTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(finishStateLabel)
            make.left.equalTo(self.snp.centerX).offset(9)
        }

        var topSpacing: CGFloat = 68
//        if let exchangeType = self.exchangeType, exchangeType != .us {
//            topSpacing = 62
//        }
        if orderModel.detailStatus == 31 || orderModel.detailStatus == 22 || orderModel.detailStatus == 25
            || ((allOrderType == .option || allOrderType == .shortSell) && orderModel.detailStatus == 24)
            || orderModel.detailStatus == 32 {
            //下单失败是12，改单失败是22，撤单失败是32
            //以前的下单失败是12，改单失败是22，撤单失败是32 撤单提交30 sg的下单失败31 改单失败22 撤单失败25 撤单提交24

            addSubview(failReasonTitleLabel)
            failReasonTitleLabel.isHidden = false
            failReasonTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(topSpacing)
                make.left.equalTo(12)
                make.width.equalTo(100)
            }

            addSubview(failReasonLabel)
            failReasonLabel.isHidden = false
            failReasonLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-12)
                make.top.equalTo(topSpacing)
                make.left.equalTo(failReasonTitleLabel.snp.right).offset(8)
            }
            if let failReason = orderModel.failReason {
                let failReasonLabelWidth: CGFloat = YXConstant.screenWidth - 56 - 108

                failReasonHeight = (failReason as NSString).boundingRect(
                    with: CGSize(width: failReasonLabelWidth, height: 500),
                    options: [.usesFontLeading, .usesLineFragmentOrigin],
                    attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)],
                    context: nil
                ).height

                topSpacing = topSpacing + failReasonHeight + 10
            }
        }
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(126)
            make.top.equalTo(topSpacing)
        }
        
        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "hold_transaction_cost_price")
        
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "hold_transaction_num")
        
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "hold_transaction_money")
        
        let label4 = leftLabel()
        label4.text = YXLanguageUtility.kLang(key: "hold_transaction_total_fee")
        
        containerView.addSubview(label1)
        containerView.addSubview(label2)
        containerView.addSubview(label3)
        containerView.addSubview(label4)
        
        finishLeftLabels = [label1, label2, label3, label4]
        finishLeftLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, tailSpacing: 8)
        
        finishLeftLabels.snp.makeConstraints { (make) in
            make.left.equalTo(12)
        }
        
        var rightLabels = [QMUILabel]()
        for _ in 0..<4 {
            let label = rightLabel()
            containerView.addSubview(label)
            rightLabels.append(label)
        }
        
        finishRightLabels = rightLabels
        
        finishRightLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, tailSpacing: 8)
        finishRightLabels.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
        }
        
        rightLabels[3].snp.remakeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalTo(finishLeftLabels[3])
        }
        
        addSubview(arrowView)
        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(rightLabels[3])
        }
        
        let arrowBgView = UIView()
        addSubview(arrowBgView)
        arrowBgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(80)
            make.bottom.equalTo(finishRightLabels[3])
            make.height.equalTo(30)
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            if (rightLabels[3].text != "--" && rightLabels[3].text != "0.00") {
                if (strongSelf.isExpand) {
                    strongSelf.arrowView.image = UIImage(named: "down_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel1())
                    strongSelf.feeView.isHidden = true
                    strongSelf.isExpand = false
                } else {
                    strongSelf.arrowView.image = UIImage(named: "up_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel1())
                    strongSelf.feeView.isHidden = false
                    strongSelf.isExpand = true
                }
            }
            strongSelf.clickExpand?()
        }).disposed(by: rx.disposeBag)
        arrowBgView.addGestureRecognizer(tap)
        
        setupFeeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFeeView() {
        feeView.isHidden = true
        addSubview(feeView)
        
        if let exchangeType = self.exchangeType, exchangeType != .us {
            if exchangeType == .hk {
                feeHeight = 272 + 36
            } else {
                feeHeight = 272
            }
        }else {
            if  entrustSide == .buy {
                feeHeight = 200  - 24
            }else {
                feeHeight = 200 + 36
            }
        }
        
        feeView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(feeHeight)
        }
        
        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "hold_stampduty") //印花税
        label1.feeType = .stampDuty
        
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "hold_pay_fee") //交收费
        label2.feeType = .clearingFee
    
        
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "hold_transaction_fee") //交易费
        label3.feeType = .tradingFee
        
        let label4 = leftLabel()
        label4.text = YXLanguageUtility.kLang(key: "hold_trading_system_useage")  //交易系统使用费
        label4.feeType = .tradingTariff
        
        let label5 = leftLabel()
        label5.text = YXLanguageUtility.kLang(key: "hold_transaction_levy_fee") //证监会交易征费
        label5.feeType = .SFCTransactionLevy
        
        let label6 = leftLabel()
        label6.text = YXLanguageUtility.kLang(key: "hold_frc_transaction_levy_fee") //财汇局交易征费
        label6.feeType = .FRCTransactionLevy
        
        let label7 = leftLabel()
        label7.text = YXLanguageUtility.kLang(key: "hold_commission_fee")
        label7.feeType = .commission
        
        let label8 = leftLabel()
        label8.text = YXLanguageUtility.kLang(key: "hold_platform_useage")
        label8.feeType = .platformFee
        
        let label9 = leftLabel()
        label9.text = YXLanguageUtility.kLang(key: "hold_CCASS_fee")
        label9.feeType = .CCASSFee
        
        let label10 = leftLabel()
        label10.text = YXLanguageUtility.kLang(key: "hold_GST")
        label10.feeType = .GST
        
        

        
        let exchangeType = self.exchangeType ?? .hk
        if exchangeType == .hk {
            feeView.addSubview(label1)
            feeView.addSubview(label5)
            feeView.addSubview(label6)
            feeView.addSubview(label9)
        } else if exchangeType == .us {
            label1.text = YXLanguageUtility.kLang(key: "hold_pay_fee")
            label1.feeType = .clearingFee
            feeView.addSubview(label1)
            
            if self.entrustSide == .sell {
                label3.text = YXLanguageUtility.kLang(key: "hold_transaction_fee_us")
                label3.feeType = .SECFee
                label4.text = YXLanguageUtility.kLang(key: "hold_transaction_levy_fee_us")
                label4.feeType = .FTAF
            }
        } else if exchangeType == .sg{
            feeView.addSubview(label2)
            feeView.addSubview(label9)
            label9.text = YXLanguageUtility.kLang(key: "hold_SI_fee")
            label2.text = YXLanguageUtility.kLang(key: "hold_transaction_fee")
            label3.text = YXLanguageUtility.kLang(key: "hold_clearing_fee")
            label2.feeType = .tradingFee
            label3.feeType = .SGclearingFee
            label9.feeType = .SIFee
        } else if exchangeType == .usop {
            feeView.addSubview(label1)
            label1.feeType = .optionClearingFee
            feeView.addSubview(label2)
            label2.feeType = .optionRegulatoryFee
            label3.feeType = .exchangeFee
            feeView.addSubview(label5)
            
            if self.entrustSide == .sell {
                label4.text = YXLanguageUtility.kLang(key: "hold_transaction_fee_us")
                label4.feeType = .SECFee
                label5.text = YXLanguageUtility.kLang(key: "hold_transaction_levy_fee_us")
                label5.feeType = .FTAF
            }
            label1.text = YXLanguageUtility.kLang(key: "option_clearing_fee")
            label2.text = YXLanguageUtility.kLang(key: "options_regulatory_fee")
            label3.text = YXLanguageUtility.kLang(key: "exchange_fee")
        } else {
            feeView.addSubview(label1)
            feeView.addSubview(label6)
            
            label1.text = YXLanguageUtility.kLang(key: "china_fee_handling")
            label2.text = YXLanguageUtility.kLang(key: "china_fee_management")
            label3.text = YXLanguageUtility.kLang(key: "china_fee_transfer")
            label4.text = YXLanguageUtility.kLang(key: "china_fee_scrip")
            label6.text = YXLanguageUtility.kLang(key: "china_fee_stamp")
        }
        
        feeView.addSubview(label3)
        feeView.addSubview(label4)
        feeView.addSubview(label10)
        feeView.addSubview(label7)
        feeView.addSubview(label8)

        var labels = [YXOrderDetailRowLabel]()
        if exchangeType == .hk {
            labels = [label1, label3, label4, label5, label6,label9,label10]
        } else if exchangeType == .us {
            if self.entrustSide == .sell {
                labels = [label1,label3,label4,label10]
            }else {
                labels = [label1,label10]
            }
        } else if exchangeType == .usop {
            if self.entrustSide == .sell {
                labels = [label1, label2,label3, label4, label5,label10]
            }else {
                labels = [label1, label2,label3,label10]
            }
        } else if exchangeType == .sg{
            labels = [label2,label3,label9,label10]
        } else {
            labels = [label1, label3, label4, label6,label10]
        }
        labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 14, tailSpacing: 108)
        labels.snp.makeConstraints { (make) in
            make.left.equalTo(12)
        }
        
        var leftLabels = labels

        var lineTopPadding: CGFloat = 0
        if self.exchangeType == .usop {
            labels = [label7, label8];
        }else {
            labels = [label7, label8];
        }
        if let exchangeType = self.exchangeType, exchangeType != .us {
            if exchangeType == .hk {
                labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 185 + 36, tailSpacing: 33)
                lineTopPadding = 170 + 36
            } else {
                lineTopPadding = 170
                labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 185, tailSpacing: 33)
            }
        } else {
            var padding : CGFloat = 36.0
            if entrustSide == .buy {
                padding = -24
            }
            labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 113 + padding, tailSpacing: 33)
            lineTopPadding = 103 + padding
        }
        
        labels.snp.makeConstraints { (make) in
            make.left.equalTo(12)
        }
        
        leftLabels += labels
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        feeView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(0.5)
            make.top.equalToSuperview().offset(lineTopPadding)
        }
        
        var rightLabels = [YXOrderDetailRowLabel]();
        var rightLabelsInView = [YXOrderDetailRowLabel]();
        for (_,subLab) in leftLabels.enumerated() {
            let label = rightLabel()
            label.feeType = subLab.feeType
            rightLabels.append(label)
            feeView.addSubview(label)
            rightLabelsInView.append(label)
        }
        feeRightLabels = rightLabels;

        labels = (rightLabelsInView as NSArray).subarray(with: NSRange(location: 0, length: rightLabelsInView.count - 2)) as! [YXOrderDetailRowLabel]
        labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 14, tailSpacing: 108)
        labels.snp.makeConstraints { (make) in
            make.right.equalTo(feeView).offset(-12)
        }
        
        labels = (rightLabelsInView as NSArray).subarray(with: NSRange(location: rightLabelsInView.count - 2, length: 2)) as! [YXOrderDetailRowLabel]

        if exchangeType != .us {
            if exchangeType == .hk {
                labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 185 + 36, tailSpacing: 33)
            } else {
                labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 185, tailSpacing: 33)
            }
        } else {
            var padding:CGFloat = 36.0
            if entrustSide == .buy {
                padding = -24
            }
            labels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: 113 + padding, tailSpacing: 33)
        }
        
        labels.snp.makeConstraints { (make) in
            make.right.equalTo(feeView).offset(-12)
        }
        
        feeView.addSubview(feeExplainView)
        feeExplainView.snp.makeConstraints { (make) in
            make.width.equalTo(250)
            make.height.equalTo(22)
            make.centerX.equalTo(feeView)
            make.bottom.equalTo(feeView).offset(-10)
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

class YXOrderDetailRowLabel: QMUILabel {
    var feeType : YXOrderDetailFee = .unDefine
}
