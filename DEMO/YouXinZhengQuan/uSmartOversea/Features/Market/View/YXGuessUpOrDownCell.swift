//
//  YXGuessUpOrDownCell.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXGuessUpOrDownCell: UICollectionViewCell {
    @objc var tapStockInfoAction: ((_ index: Int) -> Void)?
    @objc var tapUpAction: ((_ market: String, _ code: String, _ isSelected: Bool) -> Void)?
    @objc var tapDownAction: ((_ market: String, _ code: String, _ isSelected: Bool) -> Void)?
    @objc var tapRefreshButtonAction: (() -> Void)?
    
    @objc var tapDownUpAction: ((_ market: String, _ code: String, _ isSelected: Bool, _ isUp: Bool) -> Void)?

    var array: [YXGuessUpOrDownView] = []
    
    @objc var datas: [YXGuessUpAndDownStockInfo] = [] {
        didSet {
            emptyTipLabel.isHidden = datas.count != 0
//            containerView.isHidden = !emptyTipLabel.isHidden
            
            if array.count == 0 || oldValue.count != datas.count {
                array.forEach { (view) in
                    view.removeFromSuperview()
                }
                array.removeAll()
                
                for (index, item) in datas.enumerated() {
                    let view = YXGuessUpOrDownView()
                    view.tag = index
                    setData(view: view, data: item)
                    array.append(view)
                    contentView.addSubview(view)
                }
                
                if array.count < 2 {
                    array.first?.snp.makeConstraints({ (make) in
                        make.top.left.equalToSuperview()
                        make.height.equalTo(154)
                        make.width.equalTo((self.width - 16.0)/2.0)
                    })
                }else {
                    array.snp.distributeSudokuViews(fixedLineSpacing: 16, fixedInteritemSpacing: 16, warpCount: 2, edgeInset: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
                }
                
            }else {
                for (index, view) in array.enumerated() {
                    setData(view: view, data: datas[index])
                }
            }
        }
    }
    
    func setData(view: YXGuessUpOrDownView, data: YXGuessUpAndDownStockInfo) {
        
        let base = pow(10.0, Double(data.quote?.priceBase?.value ?? 0))
        
        view.nameLabel.text = data.quote?.name ?? "--"
//        view.symbolLabel.text = "(\(data.quote?.symbol ?? "--").\(data.quote?.market?.uppercased() ?? "--"))"
        
//        if let high = data.quote?.high?.value, high > 0 {
//            view.max.valueLabel.text = String(format: "%.2lf", Double(high) / base)
//        }else {
//            view.max.valueLabel.text = "--"
//        }
//
//        if let low = data.quote?.low?.value, low > 0 {
//            view.min.valueLabel.text = String(format: "%.2lf", Double(low) / base)
//        }else {
//            view.min.valueLabel.text = "--"
//        }
        
        if let price = data.quote?.latestPrice?.value, let priceBase = data.quote?.priceBase?.value {
            view.priceLabel.text = String(format: "%.\(priceBase)f", Double(price)/base)
        } else {
            view.priceLabel.text = "--";
        }
        
        if let level = data.quote?.level?.value, level == 0 {
            view.delayLabel.isHidden = false
        }else {
            view.delayLabel.isHidden = true
        }
        
        var op = ""
        if let roc = data.quote?.pctchng?.value, roc > 0 {
            op = "+"
            view.priceLabel.textColor = QMUITheme().stockRedColor()
            view.rocLabel.textColor = QMUITheme().stockRedColor()
        } else if let change = data.quote?.netchng?.value, change < 0 {
            view.priceLabel.textColor = QMUITheme().stockGreenColor()
            view.rocLabel.textColor = QMUITheme().stockGreenColor()
        } else {
            view.priceLabel.textColor = QMUITheme().stockGrayColor()
            view.rocLabel.textColor = QMUITheme().stockGrayColor()
        }
        
        if let roc = data.quote?.pctchng?.value {
            view.rocLabel.text = String(format: "%@%.2f%%", op, Double(roc)/100.0)
        }
        
        if let upCount = data.upCount, let downCount = data.downCount {
            view.ratioView.upCount.setTitle(upCount, for: .normal)
            view.ratioView.downCount.setTitle(downCount, for: .normal)
            
            if let up = Double(upCount), let down = Double(downCount) {
                let total = up + down
                if total > 0 {
                    let upRatio = up / total
                    let downRatio = down / total
                    view.ratioView.upRatioLabel.text = String(format: "%.2lf%%", upRatio*100.0)
                    view.ratioView.downRatioLabel.text = String(format: "%.2lf%%", downRatio*100.0)
                    
                    let w = YXConstant.screenWidth/2.0 - 24.0;
                    view.ratioView.upGradientLayer.frame = CGRect.init(x: 0, y: 0, width: w * CGFloat(upRatio), height: 4)
                    view.ratioView.downGradientLayer.frame = CGRect.init(x: view.ratioView.upGradientLayer.frame.width-5, y: 0, width: w * CGFloat(downRatio)+7, height: 4)
                }
            }
        }else {
            view.ratioView.upCount.setTitle("--", for: .normal)
            view.ratioView.downCount.setTitle("--", for: .normal)
        }
        
        view.guessButton.guessDownButton.setTitle(YXLanguageUtility.kLang(key: "warrants_sell"), for: .normal)
        view.guessButton.guessUpButton.setTitle(YXLanguageUtility.kLang(key: "warrants_buy"), for: .normal)
        
        if let guessChange = data.guessChange {
            if guessChange == "0" {
                view.guessButton.guessDownButton.setTitle(YXLanguageUtility.kLang(key: "picked_fall"), for: .normal)
                view.guessButton.guessDownButton.setImage(nil, for: .normal)
            }else {
                view.guessButton.guessUpButton.setTitle(YXLanguageUtility.kLang(key: "picked_rise"), for: .normal)
                view.guessButton.guessUpButton.setImage(nil, for: .normal)
            }
        }
        
        view.tapStockInfoAction = self.tapStockInfoAction
        
        view.tapUpAction = { [weak self]index in
            guard let `self` = self else { return }
            
            self.tapUpAction?(data.quote?.market ?? "", data.stockCode ?? "", data.guessChange != nil)
            //            self.tapDownUpAction?(data.quote?.market ?? "", data.stockCode ?? "", data.guessChange != nil, true)

        }
        
        view.tapDownAction = { [weak self]index in
            guard let `self` = self else { return }
            self.tapDownAction?(data.quote?.market ?? "", data.stockCode ?? "", data.guessChange != nil)
            //            self.tapDownUpAction?(data.quote?.market ?? "", data.stockCode ?? "", data.guessChange != nil, false)

        }
    }
    
    lazy var emptyTipLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "common_no_data")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "riseOrFall_hot_picks")
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    lazy var changeButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "change_refresh"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapRefreshButtonAction?()
        })
        return button
    }()
    
    lazy var hLine: UIView = {
        let line = UIView.line()
        return line
    }()
    
    lazy var vLine: UIView = {
        let line = UIView.line()
        return line
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(changeButton)
//        
//        titleLabel.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(15)
//            make.left.equalToSuperview().offset(14)
//        }
//        
//        changeButton.snp.makeConstraints { (make) in
//            make.centerY.equalTo(titleLabel)
//            make.right.equalToSuperview().offset(-16)
//        }
        
        addSubview(emptyTipLabel)
        emptyTipLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXGuessUpOrDownView: UIView {
    var tapStockInfoAction: ((_ index: Int) -> Void)?
    var tapUpAction: ((_ index: Int) -> Void)?
    var tapDownAction: ((_ index: Int) -> Void)?
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hexString: "#191919")?.withAlphaComponent(0.4)
        label.text = "--"
        
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.text = "--"
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var max: YXTitleValueItemView = {
        let item = creatTitleValueView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_high")
        return item
    }()
    
    lazy var min: YXTitleValueItemView = {
        let item = creatTitleValueView()
        item.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_low")
        return item
    }()
    
    func creatTitleValueView() -> YXTitleValueItemView {
        let item = YXTitleValueItemView()
        item.titleLabel.font = .systemFont(ofSize: 10)
        item.titleLabel.textColor = QMUITheme().textColorLevel3()
        item.valueLabel.font = .systemFont(ofSize: 10)
        item.valueLabel.textColor = QMUITheme().textColorLevel2()
        item.titleLabel.snp.remakeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        item.valueLabel.snp.remakeConstraints { (make) in
            make.left.equalTo(item.titleLabel.snp.right).offset(3)
            make.right.equalToSuperview()
        }
        return item
    }
    
    lazy var ratioView: YXGuessRatioView1 = {
        let view = YXGuessRatioView1()
        return view
    }()
    
    lazy var guessButton: YXGuessButtonView1 = {
        let view = YXGuessButtonView1()
        _ = view.guessUpButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapUpAction?(self.tag)
        })
        _ = view.guessDownButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapDownAction?(self.tag)
        })
        return view
    }()
    
    lazy var delayLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.backgroundColor = QMUITheme().separatorLineColor()
        label.isHidden = true
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let greyBorderView = UIView()
        greyBorderView.layer.borderWidth = 1
        greyBorderView.layer.cornerRadius = 4
        greyBorderView.layer.masksToBounds = true
        greyBorderView.layer.borderColor = QMUITheme().pointColor().cgColor
        
        addSubview(greyBorderView)
        addSubview(nameLabel)
//        addSubview(symbolLabel)
        addSubview(delayLabel)
        addSubview(priceLabel)
        addSubview(rocLabel)
        addSubview(ratioView)
        addSubview(guessButton)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
//        symbolLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(nameLabel.snp.right).offset(3)
//            make.centerY.equalTo(nameLabel)
//        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(12)
            make.centerY.equalTo(priceLabel)
            make.right.lessThanOrEqualToSuperview()
        }
        
        ratioView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(priceLabel.snp.bottom).offset(20)
        }
        
        guessButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(26)
            make.top.equalTo(ratioView.snp.bottom).offset(10)
        }
        
        delayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(2)
            make.centerY.equalTo(nameLabel)
            make.right.lessThanOrEqualToSuperview()
        }
        
        greyBorderView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer.init(actionBlock: { [weak self] _ in
            guard let `self` = self else { return }
            self.tapStockInfoAction?(self.tag)
        })
        
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXGuessRatioView1: UIView {
    
    lazy var upDownRatioView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.layer.addSublayer(upGradientLayer)
        view.layer.addSublayer(downGradientLayer)
        return view
    }()
    
    lazy var upGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer.init()
        layer.backgroundColor = QMUITheme().stockRedColor().cgColor
        return layer
    }()
    
    lazy var downGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer.init()
        layer.backgroundColor = QMUITheme().stockGreenColor().cgColor
        return layer
    }()
    
    lazy var upCount: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.spacingBetweenImageAndTitle = 3
        btn.imagePosition = .left
        btn.setImage(UIImage(named: "arrow_up_oversea"), for: .normal)
        return btn
    }()
    
    lazy var downCount: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        btn.spacingBetweenImageAndTitle = 3
        btn.imagePosition = .left
        btn.setImage(UIImage(named: "arrow_down_oversea"), for: .normal)
        return btn
    }()
    
    lazy var upRatioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = "--"
        return label
    }()
    
    lazy var downRatioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = "--"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(upCount)
        addSubview(downCount)
        addSubview(upRatioLabel)
        addSubview(downRatioLabel)
        addSubview(upDownRatioView)
        
        upCount.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
        }
        
        downCount.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
        }
        
        upDownRatioView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(4)
            make.top.equalTo(upCount.snp.bottom).offset(5)
        }
        
        upRatioLabel.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(upDownRatioView.snp.bottom).offset(2)
        }
        
        downRatioLabel.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.top.equalTo(upRatioLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXGuessButtonView1: UIView {
    
    lazy var guessUpButton: QMUIButton = {
        let button = QMUIButton()
        button.layer.cornerRadius = 4
        button.backgroundColor = QMUITheme().stockRedColor()
        button.setTitle(YXLanguageUtility.kLang(key: "warrants_buy"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6

        return button
    }()
    
    lazy var guessDownButton: QMUIButton = {
        let button = QMUIButton()
        button.layer.cornerRadius = 4
        button.backgroundColor = QMUITheme().stockGreenColor()
        button.setTitle(YXLanguageUtility.kLang(key: "warrants_sell"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(guessUpButton)
        addSubview(guessDownButton)
        
        guessUpButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(26)
            make.right.equalTo(self.snp.centerX).offset(-8)
        }
        
        guessDownButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(8)
        }
        
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateColor))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] noti in
                
                guard let `self` = self else { return }
                
                self.setButtonBgColor()
            })
        
        setButtonBgColor()
    }
    
    func setButtonBgColor() {
        
        var upBgImage: UIImage?
        var downBgImage: UIImage?
        
        if YXUserManager.curColor(judgeIsLogin: true) == .gRaiseRFall {
            upBgImage = UIImage(named: "guess_up_bg")
            downBgImage = UIImage(named: "guess_down_bg")
        }else {
            upBgImage = UIImage(named: "guess_up_bg_red")
            downBgImage = UIImage(named: "guess_down_bg_green")
        }
        
        self.guessUpButton.setBackgroundImage(upBgImage, for: .normal)
        self.guessDownButton.setBackgroundImage(downBgImage, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
