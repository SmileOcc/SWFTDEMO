//
//  YXOptionalHotStockSingleView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/7/1.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXOptionalHotStockSingleView: UIView, YXCycleScrollViewDelegate {

    @objc var tapBlock: (() -> Void)?


    var dataSource: [YXOptionalHotStockDetailInfo] = [] {
        didSet {

            if dataSource.count > 0 {
                statusNames.removeAll()

                for info in self.dataSource {
                    statusNames.append(info.name)
                }

                self.cycleScrollView.imageURLStringsGroup = statusNames
                self.cycleScrollView.titlesGroup = statusNames

                self.cycleScrollView.adjustWhenControllerViewWillAppera()
            }
        }
    }

    var quoteModel: YXV2Quote? {
        didSet {
            if let model = quoteModel {
                if model.market == kYXMarketHK {
                    marketIconView.image = UIImage(named: "hk")
                } else if model.market == kYXMarketUS {
                    marketIconView.image = UIImage(named: "us")
                } else if model.market == kYXMarketChinaSH {
                    marketIconView.image = UIImage(named: "sh")
                } else if model.market == kYXMarketChinaSZ {
                    marketIconView.image = UIImage(named: "sz")
                }

                var op = ""
                let roc = model.pctchng?.value ?? 0
                let priceBase = model.priceBase?.value ?? 0
                let lastestPrice = model.latestPrice?.value ?? 0
                if roc > 0 {
                    op = "+"
                    priceLabel.textColor = QMUITheme().stockRedColor()

                } else if roc < 0 {
                    priceLabel.textColor = QMUITheme().stockGreenColor()
                } else {
                    priceLabel.textColor = QMUITheme().stockGrayColor()
                }

                let rocString = op + String(format: "%.2f%%", Double(roc)/100.0)
                var priceString = "--"
                if lastestPrice > 0 {
                    priceString = String(format: "%.\(priceBase)f", Double(lastestPrice)/pow(10.0, Double(priceBase)))
                }

                priceLabel.text = String(format: "%@    %@", priceString, rocString)
            }
        }
    }


    var statusNames: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        self.cycleScrollView.imageURLStringsGroup = [" "]
        self.cycleScrollView.titlesGroup = [" "]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(marketIconView)
        addSubview(priceLabel)
        addSubview(cycleScrollView)


        marketIconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.equalTo(18)
            make.height.equalTo(18)
        }

        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(marketIconView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(110)
        }

        cycleScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(10)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tapGes)
    }

    lazy var control: UIControl = {
        let view = UIControl()
        view.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return view
    }()

    @objc func tapAction() {

        self.tapBlock?()
    }



    lazy var cycleScrollView: YXCycleScrollView = {

        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 35 - 156, height: 30))
        scrollView.backgroundColor = .clear
        scrollView.delegate = self;
        scrollView.titleLabelBackgroundColor = .clear
        scrollView.titleLabelTextColor = UIColor.qmui_color(withHexString: "#666666")
        scrollView.titleLabelTextFont = .systemFont(ofSize: 12)
        scrollView.titleLabelTextAlignment = .left
        scrollView.scrollDirection = .vertical
        //scrollView.onlyDisplayText = true
        //scrollView.onlyDisplayTextWithImage = true
        scrollView.showPageControl = false
        scrollView.autoScrollTimeInterval = 5
        scrollView.disableScrollGesture()
        scrollView.isUserInteractionEnabled = false
        scrollView.pageControlStyle = YXCycleScrollViewPageContolStyleNone
        scrollView.showBackView = false

        return scrollView
    }()


    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {

    }

    func customCollectionViewCellClass(for view: YXCycleScrollView!) -> AnyClass! {
        YXOptionalHotStockSingleCell.self
    }

    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: YXCycleScrollView!) {
        if let cell = cell as? YXOptionalHotStockSingleCell {
            if index < self.dataSource.count {
                cell.model = self.dataSource[index]
            }
        }
    }

    lazy var marketIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "hk")
        return imageView
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.text = "--    0.00%"
        return label
    }()
}

class YXOptionalHotStockSingleCell: YXCycleViewCell {


    @objc var model: YXOptionalHotStockDetailInfo? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let model = model {

            nameLabel.text = model.name
            descLabel.text = ": " + model.recommend_reason
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let scale = YXConstant.screenWidth / 375.0

    func initUI() {

        contentView.addSubview(nameLabel)
        contentView.addSubview(descLabel)

        descLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { (make) in
            make.right.equalTo(descLabel.snp.left)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.width.lessThanOrEqualTo(90 * scale)
        }
        descLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }



    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()


}
