//
//  YXStockDetailWarrantCbbcSignalView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailWarrantCbbcSignalView: UIView, YXStockDetailSubHeaderViewProtocol {


    @objc var model: YXBullBearPbSignalItem? {
        didSet {
            refreshUI()
        }
    }

    func refreshUI() {
        if let model = model {

            let dateModel = YXDateToolUtility.dateTime(withTime: model.signal?.latestTime ?? "")
            dateLabel.text = "(\(dateModel.hour):\(dateModel.minute):\(dateModel.second))"
            signalLabel.text = model.signal?.indicatorsName ?? "--"
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
        self.backgroundColor = QMUITheme().foregroundColor()

        addSubview(nameLabel)
        addSubview(signalLabel)
        addSubview(dateLabel)

        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(11)
            make.height.equalTo(14)
        }

        signalLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            //make.top.equalToSuperview().offset(11)
            make.left.greaterThanOrEqualTo(nameLabel.snp.right).offset(15)
            //make.height.equalTo(17)
            make.centerY.equalTo(nameLabel)
        }

        dateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().separatorLineColor()
//        addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(8)
//            make.right.equalToSuperview().offset(-8)
//            make.top.equalToSuperview()
//            make.height.equalTo(1.0)
//        }
    }


    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .left
        return label
    }()

    lazy var signalLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.text = "--"
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = YXLanguageUtility.kLang(key: "bullbear_short_signal")
        return label
    }()
}

