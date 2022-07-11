//
//  YXOptionalHotStockView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

@objcMembers class YXOptionalHotStockView: UIView {

    var cellClickBlock: ((_ inputs: [YXStockInputModel], _ selectIndex: Int) -> Void)?
    var refreshQuoteData: (() -> Void)?
    var changeHotStockBlock: (() -> Void)?

    var list: [YXOptionalHotStockDetailInfo] = [] {
        didSet {
            if list.count > 0 {
                self.tableView.reloadData()
                noDataView.isHidden = true
            } else {
                noDataView.isHidden = false
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(36)
        }


        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topView.snp.bottom)
        }

        addSubview(noDataView)
        noDataView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.bringSubviewToFront(topView)
    }

    lazy var topView: UIView = {
        let view = UIView()

        view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
        }

        view.addSubview(self.changeButton)
        self.changeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-14)
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "hot_stock_recommend")
        return label
    }()

    lazy var changeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10
        button.setImage(UIImage(named: "refresh_1"), for: .normal)
        button.addTarget(self, action: #selector(changeButtonAction), for: .touchUpInside)
        return button
    }()

    func changeButtonAction() {
        self.changeHotStockBlock?()
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YXOptionalHotStockCell.self, forCellReuseIdentifier: "YXOptionalHotStockCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")
        return tableView
    }()

    lazy var noDataView: YXStockEmptyDataView = {
        let view = YXStockEmptyDataView()
        view.isHidden = true
        view.backgroundColor = UIColor.qmui_color(withHexString: "#F7F7F7")
        return view
    }()
}

extension YXOptionalHotStockView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXOptionalHotStockCell", for: indexPath)
        if let hotCell = cell as? YXOptionalHotStockCell, indexPath.row < list.count {
            let model = list[indexPath.row]
            hotCell.model = model
            hotCell.refreshQuoteData = {
                [weak self] in
                self?.refreshQuoteData?()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        58.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var inputs: [YXStockInputModel] = []
        for info in list {
            let input = YXStockInputModel()
            input.market = info.market
            input.symbol = info.symbol
            input.name = info.name
            inputs.append(input)
        }

        if indexPath.row < list.count, inputs.count > 0 {
            self.cellClickBlock?(inputs, indexPath.row)
        }
    }
}

class YXOptionalHotStockCell: UITableViewCell {

    var refreshQuoteData: (() -> Void)?

    var model: YXOptionalHotStockDetailInfo? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let model = model {
            let sec = YXOptionalSecu()
            sec.market = model.market
            sec.symbol = model.symbol

            if YXSecuGroupManager.shareInstance().containsSecu(sec) {
                self.likeButton.isSelected = true
            } else {
                self.likeButton.isSelected = false
            }

            stocknameLabel.text = model.name

            stockDescLabel.text = model.recommend_reason

//            if model.market == kYXMarketHK {
//                marketIconView.image = UIImage(named: "hk")
//            } else if model.market == kYXMarketUS {
//                marketIconView.image = UIImage(named: "us")
//            } else if model.market == kYXMarketChinaSH {
//                marketIconView.image = UIImage(named: "sh")
//            } else if model.market == kYXMarketChinaSZ {
//                marketIconView.image = UIImage(named: "sz")
//            }

            if model.roc.count > 0, let roc = Double(model.roc) {
                stockRocLabel.text = String(format: "%@%.02f%%", (roc > 0 ? "+" : ""), roc / 100.0)
                if roc > 0 {
                    stockRocLabel.textColor = QMUITheme().stockRedColor()
                } else if roc < 0 {
                    stockRocLabel.textColor = QMUITheme().stockGreenColor()
                } else {
                    stockRocLabel.textColor = QMUITheme().stockGrayColor()
                }
            } else {
                stockRocLabel.text = "--"
                stockRocLabel.textColor = QMUITheme().stockGrayColor()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
        selectionStyle = .none
        backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")
    }

    required init?(coder: NSCoder) {
        //super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(1)
        }

//        contentView.addSubview(marketIconView)
//        marketIconView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(14)
//            make.top.equalToSuperview().offset(13)
//            make.width.equalTo(20)
//            make.height.equalTo(20)
//        }

        contentView.addSubview(likeButton)
        likeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }

        let scale = YXConstant.screenWidth / 375.0

        contentView.addSubview(stockRocLabel)
        stockRocLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(likeButton.snp.left).offset(-40 * scale)
        }

        contentView.addSubview(stocknameLabel)
        contentView.addSubview(stockDescLabel)

        stocknameLabel.snp.makeConstraints { (make) in

            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(8)
            //make.centerY.equalTo(marketIconView)
            //make.left.equalTo(marketIconView.snp.right).offset(5)
            make.right.lessThanOrEqualTo(stockRocLabel.snp.left).offset(-8)
            make.height.equalTo(22)
        }

        stockDescLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stocknameLabel.snp.bottom).offset(3)
            make.left.equalTo(stocknameLabel)
            make.right.lessThanOrEqualTo(stockRocLabel.snp.left).offset(-8)
            make.height.equalTo(17)
        }

        stockRocLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    lazy var marketIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "hk")
        return imageView
    }()

    lazy var stocknameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()

    lazy var stockDescLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()


    lazy var stockRocLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .right
        label.text = "--"
        return label
    }()


    lazy var likeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandY = 5
        button.expandX = 5
        button.setImage(UIImage(named: "icon_like_deselect"), for: .normal)
        button.setImage(UIImage(named: "new_like_select"), for: .selected)
        button.addTarget(self, action: #selector(likeButtonAction(_:)), for: .touchUpInside)
        return button
    }()


    @objc func likeButtonAction(_ sender: UIButton) {
        if let model = model {
            let secu = YXOptionalSecu()
            secu.market = model.market
            secu.symbol = model.symbol

            if !YXSecuGroupManager.shareInstance().containsSecu(secu) {

                YXToolUtility.addSelfStockToGroup(secu: secu) { (addResult) in
                    if addResult {
                        sender.isSelected = true
                        self.refreshQuoteData?()
                    } else {
                        sender.isSelected = false
                    }
                }

            } else {
                YXSecuGroupManager.shareInstance().remove(secu)
                sender.isSelected = false
                if let window = UIApplication.shared.delegate?.window, window != nil {
                    YXProgressHUD.showMessage(message: YXLanguageUtility.kLang(key: "search_remove_from_favorite"), inView: window!, buttonTitle: "", delay: 2, clickCallback: nil)
                }
                
            }
        }

    }


}

