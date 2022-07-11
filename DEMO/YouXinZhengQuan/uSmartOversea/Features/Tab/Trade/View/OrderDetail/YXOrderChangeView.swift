//
//  YXOrderChangeView.swift
//  YouXinZhengQuan
//
//  Created by Apple on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXOrderChangeView: UIView {
    
    lazy var changeStateLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    lazy var changeTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        return label
    }()

    lazy var failReasonLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()
    
    var exchangeType: YXExchangeType = .hk
    var symbolType = ""
    var oddTradeType = 0
    
    var changeLeftLabels: [QMUILabel] = []
    var changeRightLabels: [QMUILabel] = []
    
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

            let changeStateAttributedString = NSMutableAttributedString(
                string: YXLanguageUtility.kLang(key: "order_detail_modify_order"),
                attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
            )

            if let modifyOrderNote = item?.modifyOrderNote, !modifyOrderNote.isEmpty {
                let modifyOrderStateColor = item?.operateStatus == YXOrderModifyState.successful.rawValue ? "#414FFF" : "#FF6933"

                let attributedString = NSAttributedString(
                    string: "\n\(modifyOrderNote)",
                    attributes: [.foregroundColor: UIColor.qmui_color(withHexString: modifyOrderStateColor)!, .font: UIFont.systemFont(ofSize: 14, weight: .medium)]
                )
                changeStateAttributedString.append(attributedString)
            }

            changeStateLabel.attributedText = changeStateAttributedString

            changeTimeLabel.text = item?.createTime
            
            changeTimeLabel.text = (item?.createTime ?? "").yx_orderTime()
            if item?.createTime?.count ?? 0 < 4 {
                changeTimeLabel.text = ""
            }
            if failReasonLabel.isHidden == false, let reason = item?.failReason {
                failReasonLabel.text = YXLanguageUtility.kLang(key: "fail_reason") + ": " + reason
            }
            
            var unit = YXLanguageUtility.kLang(key: "stock_unit")
            if exchangeType == .usop {
                unit = ""
            }
            
            changeRightLabels.enumerated().forEach({ [weak self] (offset, label) in
                guard let strongSelf = self else { return }
                guard let item = strongSelf.item else { return }
                
                switch offset {
                case 0:
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
                case 1:
                    if let entrustAmount = item.entrustQty?.value as? Int64 {
                        label.text = (countFormatter.string(from: NSNumber(value: entrustAmount)) ?? "0") + unit
                    } else if let entrustAmount = item.entrustQty?.value as? Double {
                        label.text = (countFormatter.string(from: NSNumber(value: entrustAmount)) ?? "0") + unit
                    } else if let entrustAmount = item.entrustQty?.value as? String, let value = Double(entrustAmount) {
                        label.text = (countFormatter.string(from: NSNumber(value: value)) ?? "0") + unit
                    }
                case 2:
                    if let entrustBalance = item.entrustBalance?.value as? Double {
                        label.text = numberFormatter.string(from: NSNumber(value: entrustBalance))
                    } else if let entrustBalance = item.entrustBalance?.value as? Int64 {
                        label.text = numberFormatter.string(from: NSNumber(value: Double(entrustBalance)))
                    } else if let entrustBalance = item.entrustBalance?.value as? String, let value = Double(entrustBalance) {
                        label.text = numberFormatter.string(from: NSNumber(value: value))
                    }
                    
                    if let entrustProp = item.entrustProp, entrustProp == "d" {
                        label.text = "--"
                    }
                default:
                    break
                }
                //撤单失败 orderStatus == 32 后端做了entrustPrice，entrustAmount为null的处理
                if label.text == nil || label.text == "" || item.detailStatus == 32  {
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
    
    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        return lineView
    }()
    
    var failReasonHeight: CGFloat = 0

    init(
        frame: CGRect,
        orderModel: YXOrderInfoItem,
        exchangeType: YXExchangeType,
        symbolType: String = "",
        oddTradeType: Int = 0,
        allOrderType: YXAllOrderType
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
        
        self.exchangeType = exchangeType
        self.symbolType = symbolType
        self.oddTradeType = oddTradeType
        
        addSubview(changeStateLabel)
        changeStateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(9)
            make.height.equalTo(40)
            make.right.equalTo(self.snp.centerX).offset(-9)
        }
        
        addSubview(changeTimeLabel)
        changeTimeLabel.snp.makeConstraints { (make) in
             make.right.equalToSuperview().offset(-12)
             make.centerY.equalTo(changeStateLabel)
             make.left.equalTo(self.snp.centerX).offset(9)
         }

        var topSpacing: CGFloat = 68
        if orderModel.detailStatus == 31 || orderModel.detailStatus == 22 || orderModel.detailStatus == 25 || (self.exchangeType == .usop && orderModel.detailStatus == 130)  {
            //以前的下单失败是12，改单失败是22，撤单失败是32 sg的下单失败31 改单失败22 撤单失败25
            addSubview(failReasonLabel)
            failReasonLabel.isHidden = false
            failReasonLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-12)
                make.top.equalTo(changeStateLabel.snp.bottom).offset(5)
                make.left.equalTo(17)
            }

            if let failReason = orderModel.failReason, failReason.count > 0 {
                failReasonHeight = (failReason as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 56, height: 500), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).height
                topSpacing = topSpacing + failReasonHeight
            }
        }
         
         let label1 = leftLabel()
         label1.text = YXLanguageUtility.kLang(key: "delgation_price")
         
         let label2 = leftLabel()
         label2.text = YXLanguageUtility.kLang(key: "delgation_number")
         
         let label3 = leftLabel()
         label3.text = YXLanguageUtility.kLang(key: "delgation_money")
         
         addSubview(label1)
         addSubview(label2)
         addSubview(label3)
         
         changeLeftLabels = [label1, label2, label3]
         changeLeftLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 16)
         changeLeftLabels.snp.makeConstraints { (make) in
             make.left.equalTo(12)
         }
         
         var rightLabels = [QMUILabel]()
         for _ in 0...2 {
             let label = rightLabel()
             addSubview(label)
             rightLabels.append(label)
         }
         changeRightLabels = rightLabels
         changeRightLabels.snp.distributeViewsAlong(axisType: .vertical, fixedItemLength: 22, leadSpacing: topSpacing, tailSpacing: 16)
         changeRightLabels.snp.makeConstraints { (make) in
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


extension String {
    
    func yx_orderTime() -> String {
        var dateString = self.replacingOccurrences(of: "-", with: "")
        dateString = dateString.replacingOccurrences(of: ":", with: "")
        dateString = dateString.replacingOccurrences(of: " ", with: "")
        return YXDateHelper.commonDateString(dateString, format: .DF_MDYHMS)
    }
    
    func yx_orderStatueName() -> String {
        let range = self.range(of: "(")
        
        if let range = range {
            var str = self
            str.insert("\n", at: range.lowerBound)
            return str
        }
        
        return self
    }
}
