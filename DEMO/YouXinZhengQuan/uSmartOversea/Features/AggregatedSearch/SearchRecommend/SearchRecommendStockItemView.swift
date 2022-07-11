//
//  SearchRecommendStockItemView.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchRecommendStockItemView: UIView {

    var didSelectStock: ((SearchSecuModel?) -> Void)?

    private var searchSecuModel: SearchSecuModel?

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .normalFont14()
        return label
    }()

    lazy var pctChngLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .mediumFont14()
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 4
        layer.masksToBounds = true

        backgroundColor = UIColor.themeColor(
            withNormal: UIColor.qmui_color(withHexString: "#414FFF")!.withAlphaComponent(0.05),
            andDarkColor: UIColor.qmui_color(withHexString: "#6671FF")!.withAlphaComponent(0.1)
        )
        
        initSubviews()

        rx.tapGesture().subscribe(onNext: { [weak self] _ in
            self?.didSelectStock?(self?.searchSecuModel)
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        addSubview(nameLabel)
        addSubview(pctChngLabel)

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
        }

        pctChngLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(nameLabel.snp.right).offset(8)
            make.right.equalTo(-8)
        }
    }

    func bind(to model: SearchSecuModel) {
        self.searchSecuModel = model

        nameLabel.text = model.name
        pctChngLabel.text =  model.pctChngString()

        let pctChng = model.pctChng?.floatValue ?? 0
        if pctChng > 0 {
            pctChngLabel.textColor = QMUITheme().stockRedColor()
        } else if pctChng < 0 {
            pctChngLabel.textColor = QMUITheme().stockGreenColor()
        } else {
            pctChngLabel.textColor = QMUITheme().stockGrayColor()
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        let nameWidth = nameLabel.sizeThatFits(size).width
        let pctChngWidth = pctChngLabel.sizeThatFits(size).width
        size.width = nameWidth + pctChngWidth + 24
        size.height = 28
        return size
    }

}
