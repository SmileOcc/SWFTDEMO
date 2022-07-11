//
//  YXStockDetailCompanyIndustryCell.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailCompanyIndustryCell: UITableViewCell {

    var industryClickBlock:((_ title: String, _ market: String, _ code: String) -> Void)?

    @objc var expandBlock:(() -> Void)?

    @objc var market: String = kYXMarketHK

    @objc enum CompanyIndustryType: Int {
        case industry = 0  //所属行业
        case conception     //所属概念
    }
    var cacheViews: [YXStockDetailCompanyIndustrySubView] = []
    var type: CompanyIndustryType = .industry


    var model: YXStockIntroduceModel? {
        didSet {
            if self.type == .industry {
                for view in cacheViews {
                    view.removeFromSuperview()
                }
                cacheViews.removeAll()

                let subView = YXStockDetailCompanyIndustrySubView(frame: .zero, type: self.type)
                self.contentView.addSubview(subView)
                let height: CGFloat = 26
                let width = (YXConstant.screenWidth - 32.0) 
                subView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.height.equalTo(height)
                    make.width.equalTo(width)
                    make.left.equalToSuperview().offset(16)
                }

                subView.market = self.market
                subView.industryClickBlock = {
                    [weak self] (title, market, code) in
                    guard let `self` = self else { return }
                    self.industryClickBlock?(title, market, code)
                }

                cacheViews.append(subView)

                subView.profile = model?.profile
            }
        }
    }

    var HSModel: YXHSStockIntroduceModel? {
        didSet {
            if self.type == .industry {
                for view in cacheViews {
                    view.removeFromSuperview()
                }
                cacheViews.removeAll()

                let subView = YXStockDetailCompanyIndustrySubView(frame: .zero, type: self.type)
                self.contentView.addSubview(subView)
                let height: CGFloat = 26
                //let width = (YXConstant.screenWidth - 32.0 - 24.0) / 2.0
                let width = YXConstant.screenWidth - 32.0
                subView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.height.equalTo(height)
                    make.width.equalTo(width)
                    make.left.equalToSuperview().offset(16)
                }

                subView.market = self.market
                subView.industryClickBlock = {
                    [weak self] (title, market, code) in
                    guard let `self` = self else { return }
                    self.industryClickBlock?(title, market, code)
                }

                cacheViews.append(subView)

                subView.hsProfile = HSModel?.profile
            } else if self.type == .conception {
                if let conception = HSModel?.conception {
                    self.conceptions = conception
                }
            }
        }
    }

    var config: YXStockIntroduceConfigModel = YXStockIntroduceConfigModel()

    var conceptions: [YXHSConception] = [] {
        didSet {
            if self.type == .conception {
                for view in cacheViews {
                    view.removeFromSuperview()
                }
                cacheViews.removeAll()

                let width = (YXConstant.screenWidth - 36.0 - 24.0) / 2.0

                let isExpand = config.isConceptionExpand
                for (index, item) in conceptions.enumerated() {

                    if !isExpand, index >= 6 {
                        break
                    }

                    let subView = YXStockDetailCompanyIndustrySubView(frame: .zero, type: self.type)
                    let height: CGFloat = 26
                    self.contentView.addSubview(subView)
                    subView.snp.makeConstraints { (make) in
                        make.top.equalToSuperview().offset(CGFloat(index / 2) * height)
                        make.height.equalTo(height)
                        make.width.equalTo(width)
                        make.left.equalToSuperview().offset(18.0 + (width + 24.0) * CGFloat(index % 2))
                    }
                    subView.market = self.market
                    subView.industryClickBlock = {
                        [weak self] (title, market, code) in
                        guard let `self` = self else { return }
                        self.industryClickBlock?(title, market, code)
                    }

                    cacheViews.append(subView)

                    subView.conception = item
                }

                if conceptions.count > 6, self.foldButton.superview == nil {
                    self.contentView.addSubview(self.foldButton)
                    self.foldButton.snp.makeConstraints { (make) in
                        make.height.equalTo(20)
                        make.left.right.equalToSuperview()
                        make.bottom.equalToSuperview().offset(-10)
                    }
                }

            }
        }
    }

    @objc init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, type: CompanyIndustryType) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.type = type
        self.backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        //super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    lazy var foldButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        let downImage = UIImage(named: "down_arrow12")
        button.setImage(downImage, for: .normal)
        let upImage = downImage?.qmui_image(with: .down)
        button.setImage(upImage, for: .selected)
        button.addTarget(self, action: #selector(foldButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func foldButtonAction() {

        config.isConceptionExpand = !config.isConceptionExpand
        self.foldButton.isSelected = config.isConceptionExpand

        self.expandBlock?()
    }

}

class YXStockDetailCompanyIndustrySubView: UIView {

    var industryClickBlock:((_ title: String, _ market: String, _ code: String) -> Void)?

    @objc var market: String = kYXMarketHK

    var profile: YXIntroduceProfile? {
        didSet {
            if let model = profile {
                self.leftLabel.yx_setDefaultText(with: model.industryDesc)
                let industryPctchng: Double? = model.pctchng
                if let industryPctchng = industryPctchng {
                    var roc = String(format: "%.2lf%%", industryPctchng / 100)

                    if industryPctchng > 0 {
                        roc = "+\(roc)"
                        self.rightLabel.textColor = QMUITheme().stockRedColor()
                    } else if industryPctchng == 0 {
                        self.rightLabel.textColor = QMUITheme().stockGrayColor()
                    } else {
                        roc = "\(roc)"
                        self.rightLabel.textColor = QMUITheme().stockGreenColor()
                    }
                    self.rightLabel.yx_setDefaultText(with: roc)
                } else {
                    self.rightLabel.text = ""
                }
            }
        }
    }

    var hsProfile: YXHSIntroduceProfile? {
        didSet {
            if let model = hsProfile {
                self.leftLabel.yx_setDefaultText(with: model.industryName)
                let industryPctchng: Double? = model.industryPctchng
                if let industryPctchng = industryPctchng {
                    var roc = String(format: "%.2lf%%", industryPctchng / 100)

                    if industryPctchng > 0 {
                        roc = "+\(roc)"
                        self.rightLabel.textColor = QMUITheme().stockRedColor()
                    } else if industryPctchng == 0 {
                        self.rightLabel.textColor = QMUITheme().stockGrayColor()
                    } else {
                        roc = "\(roc)"
                        self.rightLabel.textColor = QMUITheme().stockGreenColor()
                    }
                    self.rightLabel.yx_setDefaultText(with: roc)
                } else {
                    self.rightLabel.text = ""
                }
            }
        }
    }

    var conception: YXHSConception? {
        didSet {
            if let desc = conception?.conceptionName, !desc.isEmpty {
                leftLabel.text = desc
            } else {
                leftLabel.text =  "--"
            }

            var roc: Double = 0
            if let pctchng = conception?.conceptionPctchng {
                roc = pctchng

                let plusString = roc > 0 ? "+" : ""
                rightLabel.text = String(format: "%@%.2f%%", plusString, roc / 100.0)
            } else {
                rightLabel.text = "--"
            }
            rightLabel.textColor = YXToolUtility.stockChangeColor(roc)
        }
    }

    var type: YXStockDetailCompanyIndustryCell.CompanyIndustryType = .industry

    @objc init(frame: CGRect, type: YXStockDetailCompanyIndustryCell.CompanyIndustryType) {
        super.init(frame: frame)
        self.type = type
        initUI()

        let tapGes = UITapGestureRecognizer.init { [weak self] (ges) in
            guard let `self` = self else { return }
            if self.type == .industry {
                if let profile = self.profile {
                    if let industryCode = profile.industryCodeYx, industryCode.count > 0 {
                        self.industryClickBlock?((profile.industryDesc ?? ""), self.market, industryCode)
                    }
                } else if let profile = self.hsProfile {
                    if let industryCode = profile.industryCodeYx, industryCode.count > 0 {
                        self.industryClickBlock?((profile.industryName ?? ""), YXMarketType.ChinaSH.rawValue, industryCode)
                    }
                }
            } else if self.type == .conception {
                if let conception = self.conception {
                    if let code = conception.conceptionCodeYx, code.count > 0 {
                        self.industryClickBlock?((conception.conceptionName ?? ""), YXMarketType.ChinaSH.rawValue, code)
                    }
                }
            }

        }

        self.addGestureRecognizer(tapGes)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(leftLabel)
        addSubview(rightLabel)

        rightLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(rightLabel.snp.left).offset(-5)
        }
    }

    lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9;
        return label
    }()

    lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        return label
    }()
}

