//
//  YXStockDetailBrokerRatioCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailBrokerRatioCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }

    required init?(coder: NSCoder) {
        //super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        let scale = YXConstant.screenWidth / 375.0
        contentView.addSubview(buyView)
        buyView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13 * scale)
            make.right.equalToSuperview().offset(-30 * scale)
            make.top.bottom.equalToSuperview()
        }
    }

    @objc lazy var buyView: YXStockAnalyzeProportionView = {
        let scale = YXConstant.screenWidth / 375.0
        let width = (YXConstant.screenWidth - 13 * scale - 30 * scale)
        let view = YXStockAnalyzeProportionView(frame: CGRect.zero, alignment: .left, maxWidth: width, isBuy: true)
        view.isPercent = true
        view.isUserInteractionEnabled = false
        return view
    }()

}

