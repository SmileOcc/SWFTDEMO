//
//  YXStockAnalyzeShareHoldingView.swift
//  uSmartOversea
//
//  Created by 裴艳东 on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXStockAnalyzeShareHoldingView: UIView {

    @objc var model: YXStockAnalyzeBrokerListModel? {
        didSet {

            if model?.blist == nil || (model?.blist.isEmpty ?? false) {
                noDataView.isHidden = false
                containerView.snp.updateConstraints { (make) in
                    make.height.equalTo(CGFloat(5) * itemHeight + CGFloat(15))
                }
                return
            } else {
                noDataView.isHidden = true
            }

            if let latestTime = model?.latestTime {
                let timeString = YXDateHelper.commonDateStringWithNumber(UInt64(latestTime))
                timeLabel.text = String(format: YXLanguageUtility.kLang(key: "broker_buy_sell_history_update_tip"), timeString)
            }

            var brokerCount: Int32 = 0
            var brokerRatio: Int = 0
            if let count = model?.brokerCount {
                brokerCount = count
            }
            if let ratio = model?.totalHoldRatio {
                brokerRatio = ratio
            }

            let ratioString = String(format: "%.02f%%", Double(brokerRatio) * 100.0 / 10000.0)
            totalLabel.text =  String(format: YXLanguageUtility.kLang(key: "broker_total_count"), String(brokerCount), ratioString)
            if let list = model?.blist {
                var maxValue: Int64 = 0
                for (index, view) in buyViewArray.enumerated() {
                    if index < list.count {
                        let info = list[index]
                        if index == 0 {
                            maxValue = info.holdRatio
                        }
                        var name = ""
                        if let tempName = self.brokerDic[info.brokerCode] as? String {
                            name = tempName
                        }
                        view.drawProgress(name: name, maxValue: maxValue, currentValue: info.holdRatio, base: 10000)
                    } else {
                        view.drawProgress(name: "", maxValue: 0, currentValue: 0, base: 10000)
                    }
                }

                containerView.snp.updateConstraints { (make) in
                    make.height.equalTo(CGFloat(list.count > 5 ? 5 : list.count) * itemHeight + CGFloat(15))
                }

                namesArray.removeAll()
                for info in list {
                    var name = ""
                    if let tempName = self.brokerDic[info.brokerCode] as? String {
                        name = tempName
                    }
                    let detailModel = YXStockAnalyzeBrokerStockInfo()
                    detailModel.name = name
                    detailModel.code = info.brokerCode
                    namesArray.append(detailModel)
                }
            }


        }
    }

    @objc func stockClickAction(_ sender: YXStockAnalyzeProportionView) {
        if sender.tag - 1000 < self.namesArray.count {
            self.clickBlock?(["index" : sender.tag - 1000,
                              "brokerInfo" : self.namesArray])
        }
    }

    @objc var clickBlock: ((_ params: [String: Any]) -> Void)?
    var itemHeight: CGFloat = 46.0
    var brokerDic: [String : Any] = [:]
    var namesArray: [YXStockAnalyzeBrokerStockInfo] = []
    var buyViewArray: [YXStockAnalyzeProportionView] = []
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initUI() {

        addSubview(totalLabel)
        totalLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(22)
            make.right.equalToSuperview().offset(-16)
        }

        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in

            make.left.equalTo(totalLabel)
            make.right.equalTo(totalLabel)
            make.top.equalTo(totalLabel.snp.bottom).offset(8)
            make.height.equalTo(14)
        }


        let width = (YXConstant.screenWidth - 32)
        let height: CGFloat = 46.0

        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(5.0 * itemHeight + 15)
            make.bottom.equalToSuperview()
        }
        for i in 0..<5 {

            let buyview = YXStockAnalyzeProportionView(frame: CGRect.zero, alignment: .left, maxWidth: width, isBuy: true)
            buyview.isPercent = true
            buyview.tag = 1000 + i
            addSubview(buyview)
            buyview.snp.makeConstraints { (make) in
                make.width.equalTo(width)
                make.height.equalTo(height)
                make.top.equalTo(timeLabel.snp.bottom).offset(CGFloat(i) * itemHeight + 15)
                make.left.equalTo(totalLabel)
            }

            buyview.addTarget(self, action: #selector(stockClickAction(_:)), for: .touchUpInside)


            buyViewArray.append(buyview)
        }

        addSubview(noDataView)
        noDataView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(containerView)
            make.top.equalToSuperview()
        }
    }

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.text = ""
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = String(format: YXLanguageUtility.kLang(key: "broker_total_count"), "--", "--")
        return label
    }()

    lazy var noDataView: YXStockEmptyDataView = {
        let view = YXStockEmptyDataView()
        view.isHidden = true
        //view.setCenterYOffset(-20)
        return view
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

}


class YXStockAnalyzeProportionView: UIControl {

    @objc func drawProgress(name: String, maxValue: Int64, currentValue: Int64, base: Int64, pointCount: Int = 2, emptyString: String = "") {

        if maxValue == 0 {
            self.proportionLabel.text = emptyString
            self.nameLabel.text = name
            proportionView.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            marginConstraint?.update(offset: 0)
            return
        }
        self.nameLabel.text = name
        let formatString = "%.0\(pointCount)f"
        var maxString = ""
        if isPercent {
            let percent = TimeInterval(currentValue) * 100 / TimeInterval(base)
            let maxPercent = TimeInterval(maxValue) * 100 / TimeInterval(base)
            if percent < 1 {
                self.proportionLabel.text = String(format: "%.03f", percent) + "%"
            } else {
                self.proportionLabel.text = String(format: "%.02f", percent) + "%"
            }

            if maxPercent < 1 {
                maxString = String(format: "%.03f", TimeInterval(maxValue) / TimeInterval(base)) + "%"
            } else {
                maxString = String(format: "%.02f", TimeInterval(maxValue) / TimeInterval(base)) + "%"
            }

        } else {
            if currentValue > 0 {
                self.proportionLabel.text = "+" + String(format: formatString, TimeInterval(currentValue) / TimeInterval(base))
                maxString = "+" + String(format: formatString, TimeInterval(maxValue) / TimeInterval(base))
            } else {
                self.proportionLabel.text = String(format: formatString, TimeInterval(currentValue) / TimeInterval(base))
                maxString = String(format: formatString, TimeInterval(maxValue) / TimeInterval(base))
            }

        }

        let width = (maxString as NSString).boundingRect(with: CGSize(width: 500, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : self.proportionLabel.font!], context: nil).width
        let maxLength = self.maxWidth - width - 4.0
        let scale: CGFloat = CGFloat(TimeInterval(currentValue) / TimeInterval(maxValue))
        proportionView.snp.updateConstraints { (make) in
            make.width.equalTo(maxLength * scale)
        }

        if self.alignment == .right {
            marginConstraint?.update(offset: -4)
        } else {
            marginConstraint?.update(offset: 4)
        }
    }

    var isPercent: Bool = false {
        didSet {
            if isPercent {
                proportionView.backgroundColor = QMUITheme().themeTextColor()
            }
        }
    }
    var alignment: NSTextAlignment = .left
    private var maxWidth: CGFloat = 0
    private var marginConstraint: Constraint?
    init(frame: CGRect, alignment: NSTextAlignment, maxWidth: CGFloat, isBuy: Bool) {
        super.init(frame: frame)
        self.maxWidth = maxWidth
        self.alignment = alignment
        addSubview(nameLabel)
        addSubview(proportionLabel)
        addSubview(proportionView)

        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.height.equalTo(22)
            make.left.right.equalToSuperview()
        }
        nameLabel.textAlignment = alignment

        proportionView.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.top.equalTo(nameLabel.snp.bottom)
            if alignment == .right {
                make.right.equalToSuperview()
            } else {
                make.left.equalToSuperview()
            }
            make.width.equalTo(0)
        }
        
        if isBuy {
            proportionView.backgroundColor = QMUITheme().stockRedColor()
        } else {
            proportionView.backgroundColor = QMUITheme().stockGreenColor()
        }
        
        proportionLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(proportionView)
            if alignment == .right {
                marginConstraint = make.right.equalTo(proportionView.snp.left).offset(-4).constraint
            } else {
                marginConstraint = make.left.equalTo(proportionView.snp.right).offset(4).constraint
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var proportionLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    lazy var proportionView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 2.0
        return view
    }()
}
