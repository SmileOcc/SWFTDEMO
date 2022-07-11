//
//  YXETFBriefElementView.swift
//  uSmartOversea
//
//  Created by youxin on 2021/3/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa

class YXETFBriefElementView: UIView {

    var updateHeightBlock: ((_ height: CGFloat) -> Void)?

    var pushToDetailBlock: (() -> Void)?

    var pushToStockDetail:((_ input: YXStockInputModel) -> Void)?

    var maxValue: Double = 0

    var model: YXETFBriefModel? {
        didSet {

            var totalPercent: Double = 0
            if let elementInfo = model?.elementInfo {
                for (index, item) in elementInfo.enumerated() {
                    if index >= 10 {
                        break
                    }
                    if index == 0 {
                        self.maxValue = item.investmentRationElement
                    }
                    totalPercent += item.investmentRationElement
                }
            }

            let spaceStr = " "

            self.ratioLabel.text = YXLanguageUtility.kLang(key: "stock_deal_Proportion") + spaceStr + String(format: "%.02f%%", totalPercent)
            self.tableView.reloadData()
        }
    }

    var cellsArray: [YXElementTableViewCell] = []
    var market: String = ""
    init(frame: CGRect, market: String) {
        super.init(frame: frame)
        self.market = market
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.top.equalToSuperview()
//            make.height.equalTo(4)
//        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
            make.right.equalToSuperview().offset(-36)
        }

        addSubview(detailButton)
        detailButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }
        
        addSubview(ratioLabel)
        ratioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.height.equalTo(16)
            make.right.equalToSuperview().offset(-16)
        }

        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.top.equalTo(ratioLabel.snp.bottom).offset(6)
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "brief_ten_stocks")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var ratioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "stock_deal_Proportion")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var detailButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.contentHorizontalAlignment = .right
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.pushToDetailBlock?()
        }).disposed(by: rx.disposeBag)
        return button
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YXElementTableViewCell.self, forCellReuseIdentifier: "YXElementTableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        return tableView
    }()


}


extension YXETFBriefElementView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let elementInfo = self.model?.elementInfo {
            return elementInfo.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXElementTableViewCell", for: indexPath) as! YXElementTableViewCell

        if let elementInfo = self.model?.elementInfo {
            let item = elementInfo[indexPath.row]
            cell.refreshUI(indexPath: indexPath, model: item, maxValue: self.maxValue)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let elementInfo = self.model?.elementInfo {
            let item = elementInfo[indexPath.row]

            if let marketSymbol = item.uniqueSecuCodeElement, !marketSymbol.isEmpty {
                let input = YXStockInputModel()
                input.name = item.secuElement ?? ""
                input.symbol = item.secuCodeElement ?? ""
                input.market = YXToolUtility.marketFromMarketSymbol(marketSymbol)
                self.pushToStockDetail?(input)
            }
        }

    }

}
