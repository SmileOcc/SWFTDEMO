//
//  YXStreetScaleView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStreetScaleView: UIView {
    
    var defaultWidth: Double {
        Double(frame.width - 24)
    }
    
    @objc var model: YXCbbcDetailResponseModel? {
        didSet {
            if let model = model {
                let totalRatio = model.bullRatio + model.bearRatio
                if (totalRatio == 0) {
                    bullPercent = 0.5
                } else {
                    bullPercent = Double(model.bullRatio)/Double(totalRatio)
                }
                //bearPercent = Double(model.putRatio)/Double(totalRatio)
                bearPercent = 1.0 - bullPercent

                let dateStr = YXDateHelper.commonDateStringWithNumber(UInt64(model.date))
                let text = String(format: "%@：%@", YXLanguageUtility.kLang(key: "cbbc_last_updated"), dateStr)
                dateLabel.text = text
            } else {
                bullPercent = 0
                bearPercent = 0
            }
        }
    }
    
    @objc var bullPercent: Double = 0 {
        didSet {
            bullPercentLabel.text = String(format: "%.1f%%", bullPercent * 100)
            
            var width = defaultWidth * bullPercent
            if width < 10 {
                width = 10
            } else if width > defaultWidth - 10 {
                width = defaultWidth - 10
            }
            bullView.snp.updateConstraints { (make) in
                make.width.equalTo(width-1)
            }
        }
    }
    
    @objc var bearPercent: Double = 0 {
        didSet {
            bearPercentLabel.text = String(format: "%.1f%%", bearPercent * 100)
            
            var width = defaultWidth * bearPercent
            if width < 10 {
                width = 10
            } else if width > defaultWidth - 10 {
                width = defaultWidth - 10
            }
            bearView.snp.updateConstraints { (make) in
                make.width.equalTo(width-1)
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = YXLanguageUtility.kLang(key: "cbbc_outstanding_ratio")//"街货比例及分布"
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    lazy var bullLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "warrants_bull")
        return label
    }()
    
    lazy var bearLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "warrants_bear")
        return label
    }()
    
    lazy var bearPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var bullPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var bearView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = QMUITheme().stockGreenColor()
        return view
    }()
    
    lazy var bullView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = QMUITheme().stockRedColor()
        return view
    }()
    
//    lazy var smallBearView: UIView = {
//        let view = UIView()
//        view.backgroundColor = QMUITheme().stockGreenColor()
//        return view
//    }()
//
//    lazy var smallBullView: UIView = {
//        let view = UIView()
//        view.backgroundColor = QMUITheme().stockRedColor()
//        return view
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().blockColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(bullView)
        addSubview(bearView)
        addSubview(bullPercentLabel)
        addSubview(bearPercentLabel)
//        addSubview(smallBullView)
//        addSubview(smallBearView)
        addSubview(bullLabel)
        addSubview(bearLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(16)
            make.right.equalTo(-12)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        bullView.snp.makeConstraints { (make) in
            make.left.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.height.equalTo(16)
            make.width.equalTo(0)
        }
        
        bearView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-12)
            make.top.height.equalTo(bullView)
            make.width.equalTo(0)
        }
        
        bullPercentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bullView).offset(4)
            make.centerY.equalTo(bullView)
        }
        
        bearPercentLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(bearView)
            make.right.equalTo(bearView).offset(-4)
        }
        
        bullLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bullView)
            make.top.equalTo(bullView.snp.bottom).offset(4)
        }
        
//        smallBullView.snp.makeConstraints { (make) in
//            make.right.equalTo(bullLabel.snp.left).offset(-4)
//            make.size.equalTo(CGSize(width: 12, height: 12))
//            make.centerY.equalTo(bullLabel)
//        }
//
//        smallBearView.snp.makeConstraints { (make) in
//            make.left.equalTo(self.snp.centerX).offset(12)
//            make.size.equalTo(CGSize(width: 12, height: 12))
//            make.centerY.equalTo(bullLabel)
//        }
        
        bearLabel.snp.makeConstraints { (make) in
            make.right.equalTo(bearView)
            make.top.equalTo(bullLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
