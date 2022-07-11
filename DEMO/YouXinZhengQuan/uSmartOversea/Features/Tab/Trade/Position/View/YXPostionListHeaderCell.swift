//
//  YXPostionListHeaderCell.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXPostionListHeaderCell: UITableViewCell {

    @objc var sortTypes: [NSNumber] = [] {
        didSet {
            stockListHeaderView.resetButtons(withArr: sortTypes)
        }
    }

    @objc lazy var lineView: UIView = {
        let view = UIView.line()
        view.isHidden = true
        return view
    }()

    @objc lazy var stockListHeaderView: YXHoldStockListHeaderView = {
        let view = YXHoldStockListHeaderView.init(frame: CGRect(x: 0, y: 11, width: YXConstant.screenWidth, height: 35), sortTypes: sortTypes)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()

        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(QMUIHelper.pixelOne)
        }

        contentView.addSubview(stockListHeaderView)
        stockListHeaderView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
