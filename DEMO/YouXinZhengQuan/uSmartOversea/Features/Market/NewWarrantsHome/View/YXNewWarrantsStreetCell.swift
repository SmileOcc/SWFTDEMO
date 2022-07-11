//
//  YXNewWarrantsStreetCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXNewWarrantsStreetCell: UICollectionViewCell {
    
    let w: Double = Double(YXConstant.screenWidth * 151.0/375.0)
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var redView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1
        view.backgroundColor = QMUITheme().stockRedColor()
        return view
    }()
    
    lazy var greenView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1
        view.backgroundColor = QMUITheme().stockGreenColor()
        return view
    }()
    
    lazy var colorContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    lazy var bullVaueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = "--"
        return label
    }()
    
    lazy var bearVaueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = "--"
        return label
    }()
    
    lazy var bullLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = YXLanguageUtility.kLang(key: "warrants_bull")
        return label
    }()
    
    lazy var bearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = YXLanguageUtility.kLang(key: "warrants_bear")
        return label
    }()
    
    var data: YXWarrantsStreetTopItem? {
        didSet {
            if let model = data {
                titleLabel.text = model.asset?.name
                bullVaueLabel.text = String(format: "%.2lf%%", model.bullRatio/100.0)
                bearVaueLabel.text = String(format: "%.2lf%%", model.bearRatio/100.0)

                var bullW = w * model.bullRatio/10000.0
                var bearW = w - bullW

                var minValue = min(bullW, bearW)

                if minValue < 10.0 {
                    minValue = 10.0
                    if bullW < bearW {
                        bullW = minValue
                    }else {
                        bearW = minValue
                    }
                }

                greenView.snp.remakeConstraints { (make) in
                    make.right.top.bottom.equalToSuperview()
                    make.width.equalTo(bearW-1)
                }

                redView.snp.remakeConstraints { (make) in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalTo(w-bearW)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        backgroundColor = .red//QMUITheme().foregroundColor()
        let line = UIView.line()

        colorContainerView.addSubview(redView)
        colorContainerView.addSubview(greenView)
        
        redView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        greenView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(redView.snp.right)
        }

        contentView.addSubview(titleLabel)
        contentView.addSubview(colorContainerView)
        contentView.addSubview(bullLabel)
        contentView.addSubview(bullVaueLabel)
        contentView.addSubview(bearLabel)
        contentView.addSubview(bearVaueLabel)
        contentView.addSubview(line)

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        colorContainerView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth * 151.0/375.0)
        }

        bullLabel.snp.makeConstraints { (make) in
            make.left.equalTo(colorContainerView)
            make.bottom.equalTo(colorContainerView.snp.top).offset(-4)
        }

        bullVaueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(colorContainerView)
            make.top.equalTo(colorContainerView.snp.bottom).offset(4)
        }

        bearLabel.snp.makeConstraints { (make) in
            make.right.equalTo(colorContainerView)
            make.bottom.equalTo(colorContainerView.snp.top).offset(-4)
        }

        bearVaueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(colorContainerView)
            make.top.equalTo(colorContainerView.snp.bottom).offset(4)
        }

        line.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
