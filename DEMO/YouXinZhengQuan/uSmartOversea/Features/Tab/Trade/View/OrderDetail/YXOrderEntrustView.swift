//
//  YXOrderEntrustView.swift
//  YouXinZhengQuan
//
//  Created by Apple on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderEntrustView: UIView {
    
    lazy var entrustStateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
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
    
    var entrustLeftLabels: [QMUILabel] = []
    var entrustRightLabels: [QMUILabel] = []
    
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

            entrustStateLabel.text = item?.detailStatusName?.yx_orderStatueName()
            entrustTimeLabel.text = (item?.createTime ?? "").yx_orderTime()
            if item?.createTime?.count ?? 0 < 4 {
                entrustTimeLabel.text = ""
            }
            if failReasonLabel.isHidden == false, let reason = item?.failReason {
                failReasonLabel.text = reason
            }
            
            var unit = YXLanguageUtility.kLang(key: "stock_unit")
            if exchangeType == .usop {
                unit = ""
            }

            let startOffSet = self.symbolType == "2" ? 1 : 0

            entrustRightLabels.enumerated().forEach({ [weak self] (offset, label) in
                guard let strongSelf = self else { return }
                guard let item = strongSelf.item else { return }

                if strongSelf.symbolType == "2" {
                    if offset == 0 {
                        if oddTradeType == 1 {
                            label.text = YXLanguageUtility.kLang(key: "trading_type_shares")
                        } else {
                            label.text = YXLanguageUtility.kLang(key: "trading_type_amount")
                        }
                        return
                    }
                }
                
                switch offset {
                case startOffSet:
                    if self?.sessionType == 3 && self?.orderType == 1 { // 是暗盘并且orderType==1时写死为条件单
                        label.text = YXLanguageUtility.kLang(key: "condition_order")
                    }else {
                       label.text = item.entrustPropName
                    }
                case (startOffSet + 1):
                    label.text = item.currency
                case (startOffSet + 2):
                    if let entrustPrice = item.entrustPrice?.value as? NSNumber {
                        label.text = priceFormatter.string(from: entrustPrice)
                    } else if let entrustPrice = item.entrustPrice?.value as? String {
                        label.text = priceFormatter.string(from: NSNumber(value: entrustPrice.doubleValue))
                    }
                    
                    if let entrustProp = item.entrustProp {
                        //以前旧版的委托属性('0'-美股限价单,'d'-竞价单,'e' -增强限价单,'g'-竞价限价单,'h'-港股限价单,'j'-特殊限价单 “w”市价)
                        //sg新版的委托属性,LMT:限价单,ELMT:增强限价单,MKT:市价单,AM:竞价市价单,AL:竞价限价单
                        if entrustProp == "AM" || entrustProp == "AL" {
                            label.text = "--"
                        } else if entrustProp == "MKT" {
                            label.text = YXLanguageUtility.kLang(key: "trade_market_price")
                        }
                    }
                case (startOffSet + 3):
                    if let entrustAmount = item.entrustQty?.value as? Int64 {
                        label.text = (countFormatter.string(from: NSNumber(value: entrustAmount)) ?? "0") + unit
                    } else if let entrustAmount = item.entrustQty?.value as? Double {
                        label.text = (countFormatter.string(from: NSNumber(value: entrustAmount)) ?? "0") + unit
                    } else if let entrustAmount = item.entrustQty?.value as? String, let value = Double(entrustAmount) {
                        label.text = (countFormatter.string(from: NSNumber(value: value)) ?? "0") + unit
                    }
                case (startOffSet + 4):
                    if let entrustProp = item.entrustProp, entrustProp != "MKT" {
                        if let entrustBalance = item.entrustBalance?.value as? Double {
                            label.text = numberFormatter.string(from: NSNumber(value: entrustBalance))
                        } else if let entrustBalance = item.entrustBalance?.value as? Int64 {
                            label.text = numberFormatter.string(from: NSNumber(value: entrustBalance))
                        } else if let entrustBalance = item.entrustBalance?.value as? String, let value = Double(entrustBalance) {
                            label.text = numberFormatter.string(from: NSNumber(value: value))
                        }
                        
                        if entrustProp == "AM" {
                            label.text = "--"
                        }
                    }

                default:
                    break
                }
                if label.text == nil || label.text == ""  {
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

    func leftLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14);
        return label
    }
    
    func rightLabel() -> QMUILabel {
        let label = QMUILabel()
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
    
    var exchangeType: YXExchangeType = .hk
    var sessionType: UInt = 0
    var orderType = 0
    var symbolType = ""
    var oddTradeType = 0

    var failReasonHeight: CGFloat = 0
    
    init(
        frame: CGRect,
        exchangeType: YXExchangeType,
        sessionType: UInt,
        orderModel: YXOrderInfoItem,
        orderType: Int = 0,
        symbolType: String = "",
        oddTradeType: Int = 0,
        allOrderType: YXAllOrderType
    ) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        self.exchangeType = exchangeType
        self.sessionType = sessionType
        self.orderType = orderType
        self.symbolType = symbolType
        self.oddTradeType = oddTradeType
        
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(53)
            make.height.equalTo(1)
        }
        
        addSubview(entrustStateLabel)
        entrustStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)            
            make.top.equalTo(9)
            make.height.equalTo(40)
        }
        
        addSubview(entrustTimeLabel)
        entrustTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(entrustStateLabel)
            make.left.equalTo(self.snp.centerX).offset(9)
        }

        var topSpacing: CGFloat = 68
        if orderModel.detailStatus == 31 || orderModel.detailStatus == 22 || orderModel.detailStatus == 25 || orderModel.detailStatus == -1 ||
            ((allOrderType == .option || allOrderType == .shortSell) && orderModel.detailStatus == 24)
            || orderModel.detailStatus == 32 {
            //下单失败是12，改单失败是22，撤单失败是32 // 日内融订单失败是 -1
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

        let label = leftLabel()
        label.text = YXLanguageUtility.kLang(key: "trading_type")

        let label1 = leftLabel()
        label1.text = YXLanguageUtility.kLang(key: "trading_order_type")
        
        let label2 = leftLabel()
        label2.text = YXLanguageUtility.kLang(key: "hold_dollar_type")
        
        let label3 = leftLabel()
        label3.text = YXLanguageUtility.kLang(key: "delgation_price")
        
        let label4 = leftLabel()
        label4.text = YXLanguageUtility.kLang(key: "delgation_number")

        addSubview(label1)
        addSubview(label2)
        addSubview(label3)
        addSubview(label4)
        
        entrustLeftLabels = [label1, label2, label3, label4]

        if symbolType == "2" {
            addSubview(label)
            entrustLeftLabels.insert(label, at: 0)
        }
        
        if orderModel.entrustProp != "w" {
            let label5 = leftLabel()
            label5.text = YXLanguageUtility.kLang(key: "delgation_money")
            addSubview(label5)
            
            entrustLeftLabels.append(label5)
        }
        
        let leftLabelCount = entrustLeftLabels.count

        if self.exchangeType == .us {
            let label6 = leftLabel()
            label6.text = YXLanguageUtility.kLang(key: "hold_fill_rth")
            addSubview(label6)
            entrustLeftLabels.append(label6)

            if sessionType == 12 {
                let label = leftLabel()
                label.numberOfLines = 0;
                label.text = YXLanguageUtility.kLang(key: "detail_pre_after")
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.3
                label.font = .systemFont(ofSize: 12)
                addSubview(label)
                
                label.snp.makeConstraints { (make) in
                    make.left.equalTo(12)
                    make.right.equalToSuperview().offset(-12)
                    make.top.equalTo(label6.snp.bottom).offset(8)
                    make.height.equalTo(40)
                }
                
                entrustLeftLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 8 + 40)
            } else {
                entrustLeftLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 8)
            }
            
            entrustLeftLabels.snp.makeConstraints { (make) in
                make.left.equalTo(12)
            }
            
        } else {
            entrustLeftLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 8)
            entrustLeftLabels.snp.makeConstraints { (make) in
                make.left.equalTo(12)
            }
        }
        
        var rightLabels = [QMUILabel]()
        for _ in 0..<leftLabelCount {
            let label = rightLabel()
            addSubview(label)
            rightLabels.append(label)
        }
        
        if self.exchangeType == .us {
            let label = rightLabel()
            addSubview(label)
            rightLabels.append(label)
            
            label.text = YXLanguageUtility.kLang(key: "hold_not_allow")
            if sessionType == 12 {
                label.text = YXLanguageUtility.kLang(key: "hold_allow")
            }
        }
        
        entrustRightLabels = rightLabels
        if sessionType == 12 {
            entrustRightLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 8 + 40)
        } else {
            entrustRightLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 8)
        }
        entrustRightLabels.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
