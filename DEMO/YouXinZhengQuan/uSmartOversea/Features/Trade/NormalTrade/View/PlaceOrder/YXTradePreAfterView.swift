//
//  YXTradePreAfterView.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2021/7/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
//
//class YXTradePreAfterView: UIView, YXTradeHeaderSubViewProtocol {
//
//    enum AllowType: Int, EnumTextProtocol {
//        case allow
//        case notAllow
//
//        var text: String {
//            switch self {
//            case .allow:
//                return YXLanguageUtility.kLang(key: "mine_yes")
//            case .notAllow:
//                return YXLanguageUtility.kLang(key: "mine_no")
//            }
//        }
//        
//        var tradePeriod: TradePeriod {
//            switch self {
//            case .allow:
//                return .preAfter
//            case .notAllow:
//                return .normal
//            }
//        }
//    }
//    
//    var tradeModel: TradeModel? {
//        didSet {
//            if let tradeModel = tradeModel, tradeModel.symbol.count > 0 {
////                self.checkTradeStatusInfo()
//            } else {
////                self.isHidden = true
//            }
//        }
//    }
//
//    lazy var titleLabel: UILabel = {
//        let label = UILabel(with: QMUITheme().textColorLevel3(),
//                            font: UIFont.systemFont(ofSize: 12),
//                            text: YXLanguageUtility.kLang(key: "hold_fill_rth"))
//        return label
//    }()
//    
//    private var segmentView: YXTradeSegmentView<AllowType>!
//    convenience init(_ selectType: AllowType = .notAllow, selectedBlock:((AllowType) -> Void)?) {
//        self.init()
//        
//        segmentView = YXTradeSegmentView(typeArr: [.notAllow, .allow], selected: selectType, selectedBlock: selectedBlock)
//        
//        addSubview(titleLabel)
//        addSubview(segmentView)
//        
//        titleLabel.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(16)
//        }
//        
//        segmentView.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-16)
//            make.width.equalTo(88)
//            make.height.equalTo(20)
//            make.centerY.equalToSuperview()
//        }
//        
//        contentHeight = 32
//    }
//    
//    func updateType(_ typeArr: [AllowType]? = [.notAllow, .allow], selected: AllowType? = nil) {
//        segmentView.updateType(typeArr, selected: selected)
//    }
//}

class YXTradePreAfterView: UIView, YXTradeHeaderSubViewProtocol {

    enum AllowType: Int, EnumTextProtocol {
        case allow
        case notAllow

        var text: String {
            switch self {
            case .allow:
                return YXLanguageUtility.kLang(key: "hold_allow")
            case .notAllow:
                return YXLanguageUtility.kLang(key: "hold_not_allow")
            }
        }
        
        var tradePeriod: TradePeriod {
            switch self {
            case .allow:
                return .preAfter
            case .notAllow:
                return .normal
            }
        }
    }
    
    var tradeModel: TradeModel? {
        didSet {
            if let tradeModel = tradeModel, tradeModel.symbol.count > 0 {
            } else {
            }
        }
    }

//    lazy var titleLabel: UILabel = {
//        let label = UILabel(with: QMUITheme().textColorLevel3(),
//                            font: UIFont.systemFont(ofSize: 14),
//                            text: YXLanguageUtility.kLang(key: "hold_fill_rth"))
//        label.numberOfLines = 0
//        return label
//    }()
//
    lazy var infoButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "smart_type_info"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setAttributedTitle(NSAttributedString(string: YXLanguageUtility.kLang(key: "hold_fill_rth"),
                                                     attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                  .foregroundColor: QMUITheme().textColorLevel3()]),
                                  for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.spacingBetweenImageAndTitle = 4
        button.imagePosition = .right
        
        button.qmui_tapBlock = { _ in
            let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "hold_fill_rth"), message: nil)
            alertView.addCustomView(YXPreAfterAlertView())
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
                
            }))
            alertView.showInWindow()
        }
        
        return button
    }()
    
    private var segmentView: YXTradeSegmentView<AllowType>!
    convenience init(_ selectType: AllowType = .notAllow, selectedBlock:((AllowType) -> Void)?) {
        self.init()
        
        segmentView = YXTradeSegmentView(typeArr: [.allow, .notAllow], selected: selectType, selectedBlock: selectedBlock)
        segmentView.itemSize = CGSize(width: 105, height: 28)
        segmentView.useNewStyle()
        
        addSubview(segmentView)
//        addSubview(titleLabel)
        addSubview(infoButton)
        

        segmentView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(210)
            make.top.equalTo(16)
            make.height.equalTo(28)
        }
        
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(16)
//            make.left.equalTo(16)
//            make.height.equalTo(44)
//            make.right.lessThanOrEqualTo(segmentView.snp.left).offset(-60)
//        }
        
        infoButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(segmentView)
            make.right.lessThanOrEqualTo(segmentView.snp.left).offset(-20)
        }
        
        contentHeight = 44
    }
    
    func updateType(_ typeArr: [AllowType]? = [.allow, .notAllow], selected: AllowType? = nil) {
        segmentView.updateType(typeArr, selected: selected)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


class YXSmartTradePreAfterView: UIView, YXTradeHeaderSubViewProtocol {
    
    var tradeModel: TradeModel? {
        didSet {
            if let tradeModel = tradeModel, tradeModel.symbol.count > 0 {
            } else {
            }
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel(with: QMUITheme().textColorLevel3(),
                            font: UIFont.systemFont(ofSize: 12),
                            text: YXLanguageUtility.kLang(key: "hold_fill_rth"))
        return label
    }()
    
    lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "smart_type_info"), for: .normal)
        button.contentHorizontalAlignment = .left
        
        button.qmui_tapBlock = { _ in
            let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "hold_fill_rth"), message: nil)
            alertView.addCustomView(YXPreAfterAlertView())
//            alertView.messageLabel.font = .systemFont(ofSize: 14)
//            alertView.messageLabel.textAlignment = .left
            alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { (action) in
                
            }))
            alertView.showInWindow()
        }
        
        return button
    }()
    
    private var segmentView: YXTradeSegmentView<YXTradePreAfterView.AllowType>!
    convenience init(_ selectType: YXTradePreAfterView.AllowType = .notAllow, selectedBlock:((YXTradePreAfterView.AllowType) -> Void)?) {
        self.init()
        
        segmentView = YXTradeSegmentView(typeArr: [.allow, .notAllow], selected: selectType, selectedBlock: selectedBlock)
        segmentView.itemSize = CGSize(width: 65, height: 24)
        
        addSubview(titleLabel)
        addSubview(segmentView)
        addSubview(infoButton)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(segmentView)
            make.left.equalToSuperview().offset(16)
        }
        
        segmentView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(130)
            make.height.equalTo(24)
            make.bottom.equalToSuperview()
        }
        
        infoButton.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(36)
        }
        
        contentHeight = 36
    }
    
    func updateType(_ typeArr: [YXTradePreAfterView.AllowType]? = [.allow, .notAllow], selected: YXTradePreAfterView.AllowType? = nil) {
        segmentView.updateType(typeArr, selected: selected)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension YXTradePreAfterView {
    //检查能否盘前盘后交易
    func checkTradeStatusInfo() {

        guard let tradeModel = tradeModel, tradeModel.symbol.count > 0 else { return }
        YXTradeRequestTool.queryOrderTradeStatus(tradeModel.symbol, completion: {
            [weak self] info in
            guard let `self` = self else { return }
            if info.cantTradeReasonNo != 0 {
                self.isHidden = true
            } else {
                self.isHidden = false
            }
        })
    }
}


class YXPreAfterAlertView: UIView {
    override init(frame: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: 255, height: 310)
        super.init(frame: rect)
        
        let label1 = UILabel()
        label1.numberOfLines = 0
        label1.textColor = QMUITheme().textColorLevel1()
        label1.font = .systemFont(ofSize: 14)
        label1.text = YXLanguageUtility.kLang(key: "preafter_allow_tip")
        addSubview(label1)
        
        let imageView1 = UIImageView(image: UIImage(named: "preafter_allow"))
        addSubview(imageView1)
        
        let label2 = UILabel()
        label2.numberOfLines = 0
        label2.textColor = QMUITheme().textColorLevel1()
        label2.font = .systemFont(ofSize: 14)
        label2.text = YXLanguageUtility.kLang(key: "preafter_notallow_tip")
        addSubview(label2)
        
        let imageView2 = UIImageView(image: UIImage(named: "preafter_notallow"))
        addSubview(imageView2)
        
        label1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview()
        }
        
        imageView1.snp.makeConstraints { make in
            make.top.equalTo(label1.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
        }
        
        label2.snp.makeConstraints { make in
            make.top.equalTo(imageView1.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
        }
        
        imageView2.snp.makeConstraints { make in
            make.top.equalTo(label2.snp.bottom).offset(30)
            make.left.right.equalToSuperview()
        }
        
        let subLabel1 = UILabel()
        subLabel1.text = YXLanguageUtility.kLang(key: "pre_market")
        subLabel1.textColor = QMUITheme().buy()
        subLabel1.font = .boldSystemFont(ofSize: 10)
        subLabel1.adjustsFontSizeToFitWidth = true
        subLabel1.minimumScaleFactor = 0.3
        subLabel1.textAlignment = .center
        addSubview(subLabel1)
        
        let subLabel2 = UILabel()
        subLabel2.text = YXLanguageUtility.kLang(key: "regular_hour")
        subLabel2.textColor = QMUITheme().buy()
        subLabel2.font = .systemFont(ofSize: 10)
        subLabel2.adjustsFontSizeToFitWidth = true
        subLabel2.minimumScaleFactor = 0.3
        subLabel2.textAlignment = .center
        addSubview(subLabel2)
        
        let subLabel3 = UILabel()
        subLabel3.text = YXLanguageUtility.kLang(key: "after_hours")
        subLabel3.textColor = QMUITheme().buy()
        subLabel3.font = .systemFont(ofSize: 10)
        subLabel3.adjustsFontSizeToFitWidth = true
        subLabel3.minimumScaleFactor = 0.3
        subLabel3.textAlignment = .center
        addSubview(subLabel3)
        
        let subLabel4 = UILabel()
        subLabel4.text = YXLanguageUtility.kLang(key: "pre_market")
        subLabel4.textColor = QMUITheme().textColorLevel3()
        subLabel4.font = .systemFont(ofSize: 10)
        subLabel4.adjustsFontSizeToFitWidth = true
        subLabel4.minimumScaleFactor = 0.3
        subLabel4.textAlignment = .center
        addSubview(subLabel4)
        
        let subLabel5 = UILabel()
        subLabel5.text = YXLanguageUtility.kLang(key: "regular_hour")
        subLabel5.textColor = QMUITheme().buy()
        subLabel5.font = .systemFont(ofSize: 10)
        subLabel5.adjustsFontSizeToFitWidth = true
        subLabel5.minimumScaleFactor = 0.3
        subLabel5.textAlignment = .center
        addSubview(subLabel5)
        
        let subLabel6 = UILabel()
        subLabel6.text = YXLanguageUtility.kLang(key: "after_hours")
        subLabel6.textColor = QMUITheme().textColorLevel3()
        subLabel6.font = .systemFont(ofSize: 10)
        subLabel6.adjustsFontSizeToFitWidth = true
        subLabel6.minimumScaleFactor = 0.3
        subLabel6.textAlignment = .center
        addSubview(subLabel6)
        
        subLabel1.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.bottom.equalTo(imageView1.snp.top)
            make.centerX.equalTo(36)
            make.width.equalTo(70)
        }
        
        subLabel2.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.bottom.equalTo(imageView1.snp.top)
            make.centerX.equalTo(128)
            make.width.equalTo(104)
        }
        
        subLabel3.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.bottom.equalTo(imageView1.snp.top)
            make.centerX.equalTo(222)
            make.width.equalTo(70)
        }
        
        subLabel4.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.bottom.equalTo(imageView2.snp.top)
            make.centerX.equalTo(36)
            make.width.equalTo(70)
        }
        
        subLabel5.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.bottom.equalTo(imageView2.snp.top)
            make.centerX.equalTo(128)
            make.width.equalTo(104)
        }
        
        subLabel6.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.bottom.equalTo(imageView2.snp.top)
            make.centerX.equalTo(222)
            make.width.equalTo(70)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
