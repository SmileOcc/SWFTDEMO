//
//  SquareGuessUpOrDownView.swift
//  uSmartOversea
//
//  Created by usmart on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXGuessButtonView: UIView {
    
    lazy var guessUpButton: QMUIButton = {
        let button = QMUIButton()
        button.setBackgroundImage(UIImage(named: "guess_up_bg"), for: .normal)
//        button.setImage(UIImage(named: "up_icon"), for: .normal)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 4
        button.setTitle(YXLanguageUtility.kLang(key: "guessUp"), for: .normal)
        button.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6"), for: .normal)
        button.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6").withAlphaComponent(0.6), for: .selected)
        button.titleLabel?.font = .mediumFont14()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.setTitle(YXLanguageUtility.kLang(key: "picked_Up"), for: .selected)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 8.0 * YXConstant.screenWidth/375.0)

//        button.setImage(UIImage(), for: .selected)

        return button
    }()
    
    lazy var guessDownButton: QMUIButton = {
        let button = QMUIButton()
        button.setBackgroundImage(UIImage(named: "guess_down_bg"), for: .normal)
//        button.setImage(UIImage(named: "down_icon"), for: .normal)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 4
        button.setTitle(YXLanguageUtility.kLang(key: "guessDown"), for: .normal)
        button.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6"), for: .normal)
        button.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6").withAlphaComponent(0.6), for: .selected)
        button.titleLabel?.font = .mediumFont14()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.setTitle(YXLanguageUtility.kLang(key: "picked_Down"), for: .selected)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 8.0 * YXConstant.screenWidth/375.0, bottom: 0, right: 0)

//        button.setImage(UIImage(), for: .selected)

        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(guessUpButton)
        addSubview(guessDownButton)
        
        guessUpButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(28)
            make.right.equalTo(self.snp.centerX).offset(5)
        }
        
        guessDownButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(-5)
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
        var selectedupBgImage: UIImage?
        var selecteddownBgImage: UIImage?
        
        var upIconImage: UIImage?
        var downIconImage: UIImage?

        
        if YXUserManager.curColor(judgeIsLogin: true) == .gRaiseRFall {
            upBgImage = UIImage(named: "guess_up_bg")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            downBgImage = UIImage(named: "guess_down_bg")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selectedupBgImage = UIImage(named: "guess_up_bg_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selecteddownBgImage = UIImage(named: "guess_down_bg_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            upIconImage = UIImage(named: "up_icon")
            downIconImage = UIImage(named: "down_icon")
        }else {
            upBgImage = UIImage(named: "guess_up_bg_red")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            downBgImage = UIImage(named: "guess_down_bg_green")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selectedupBgImage = UIImage(named: "guess_up_bg_red_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selecteddownBgImage = UIImage(named: "guess_down_bg_green_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            upIconImage = UIImage(named: "down_icon")
            downIconImage = UIImage(named: "up_icon")
        }
        
        self.guessUpButton.setBackgroundImage(upBgImage, for: .normal)
        self.guessDownButton.setBackgroundImage(downBgImage, for: .normal)
        self.guessUpButton.setBackgroundImage(selectedupBgImage, for: .selected)
        self.guessDownButton.setBackgroundImage(selecteddownBgImage, for: .selected)
        
//        self.guessUpButton.setImage(upIconImage, for: .normal)
//        self.guessDownButton.setImage(downIconImage, for: .normal)
        
//        self.guessUpButton.setTitleColor(QMUITheme().stockRedColor(), for: .normal)
//        self.guessDownButton.setTitleColor(QMUITheme().stockGreenColor(), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SquareGuessUpOrDownViewCell:UICollectionViewCell {
    
    var tapUpAction: (() -> Void)?
    
    var tapDownAction: (() -> Void)?
    
    var tapDownUpAction: ((_ market: String, _ code: String, _ isSelected: Bool, _ isUp: Bool) -> Void)?

    var model: YXGuessUpAndDownListStockInfo? {
        didSet {
            if let model = self.model{
                //每次刷的时候根据设置颜色，切皮肤的时候及时重制颜色
                guessButton.guessUpButton.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6"), for: .normal)
                guessButton.guessDownButton.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6").withAlphaComponent(0.6), for: .selected)
                
                
                
                iconLabel.market = model.market

                if let symbol = model.secuCode ,let market = model.market {
                    symbolLabel.text = symbol + "." + market
                } else {
                    symbolLabel.text =  "__"
                }

                if let name = model.stockName {
                    nameLabel.text = name
                } else {
                    nameLabel.text = "__"
                }

                let priceBase = model.priceBase?.intValue ?? 0

                var color = QMUITheme().stockGrayColor()
                if let change = model.netchng?.intValue {
                    color = YXToolUtility.stockColor(withData: Double(change), compareData: 0)
                    let value = YXToolUtility.stockPriceData(Double(change), deciPoint: Int(priceBase), priceBase: Int(priceBase)) ?? "0.000"
                    changeLabel.text = (change > 0 ? "+" : "") + value
                } else {
                    changeLabel.text = "0.000"
                }

                if let roc = model.pctchng?.intValue {

                    let value = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2) ?? "0.00"
                    rocLabel.text =  value
                } else {
                    rocLabel.text = "0.00%"
                }

                if let now = model.latestPrice?.intValue {
                    nowLabel.text = YXToolUtility.stockPriceData(Double(now), deciPoint: Int(priceBase), priceBase: Int(priceBase)) ?? "--"
                } else {
                    nowLabel.text = "--"
                }


                changeLabel.textColor = color
                rocLabel.textColor = color
                nowLabel.textColor = QMUITheme().textColorLevel1()
                setButtonBgColor()

                if let upCount = model.upCount?.doubleValue, let downCount = model.downCount?.doubleValue {

                    let total = upCount + downCount
                    if total > 0 {
                        let upRatio = upCount / total
                        let downRatio = downCount / total
                        upRatioLabel.text = String(format: "%.2lf%%", upRatio*100.0)
                        downRatioLabel.text = String(format: "%.2lf%%", downRatio*100.0)

//                        upRatioLabel.textColor = QMUITheme().stockRedColor()
//                        downRatioLabel.textColor = QMUITheme().stockGreenColor()

                        let w: CGFloat = 236
                        upGradientLayer.frame = CGRect.init(x: 0, y: 0, width: w * CGFloat(upRatio), height: 4)
                        downGradientLayer.frame = CGRect.init(x: upGradientLayer.frame.width, y: 0, width: w * CGFloat(downRatio), height: 4)
                    } else {
                        let upRatio = 0.5
                        let downRatio = 0.5
                        upRatioLabel.text = String(format: "%.2lf%%", upRatio*100.0)
                        downRatioLabel.text = String(format: "%.2lf%%", downRatio*100.0)

//                        upRatioLabel.textColor = QMUITheme().stockRedColor()
//                        downRatioLabel.textColor = QMUITheme().stockGreenColor()

                        let w: CGFloat = 236
                        upGradientLayer.frame = CGRect.init(x: 0, y: 0, width: w * CGFloat(upRatio), height: 4)
                        downGradientLayer.frame = CGRect.init(x: upGradientLayer.frame.width, y: 0, width: w * CGFloat(downRatio), height: 4)
                    }

                }

                if let guessChange = model.guessChange?.intValue {
                    if guessChange == 0 {
                        guessButton.guessDownButton.isSelected = true
                        guessButton.guessUpButton.isSelected = false
                    } else {
                        guessButton.guessDownButton.isSelected = false
                        guessButton.guessUpButton.isSelected = true
                    }
                } else {
                    guessButton.guessDownButton.isSelected = false
                    guessButton.guessUpButton.isSelected = false
                }
                
            }
        }
    }
    
    func setButtonBgColor() {
        
        var upBgImage: UIImage?
        var downBgImage: UIImage?
        var selectedupBgImage: UIImage?
        var selecteddownBgImage: UIImage?
        
        var upIconImage: UIImage?
        var downIconImage: UIImage?

        
        if YXUserManager.curColor(judgeIsLogin: true) == .gRaiseRFall {
            upBgImage = UIImage(named: "guess_up_bg")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            downBgImage = UIImage(named: "guess_down_bg")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selectedupBgImage = UIImage(named: "guess_up_bg_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selecteddownBgImage = UIImage(named: "guess_down_bg_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            upIconImage = UIImage(named: "up_icon")
            downIconImage = UIImage(named: "down_icon")
        }else {
            upBgImage = UIImage(named: "guess_up_bg_red")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            downBgImage = UIImage(named: "guess_down_bg_green")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selectedupBgImage = UIImage(named: "guess_up_bg_red_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            selecteddownBgImage = UIImage(named: "guess_down_bg_green_selected")?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20), resizingMode: .stretch)
            
            upIconImage = UIImage(named: "down_icon")
            downIconImage = UIImage(named: "up_icon")
        }
        
        guessButton.guessUpButton.setBackgroundImage(upBgImage, for: .normal)
        guessButton.guessDownButton.setBackgroundImage(downBgImage, for: .normal)
        guessButton.guessUpButton.setBackgroundImage(selectedupBgImage, for: .selected)
        guessButton.guessDownButton.setBackgroundImage(selecteddownBgImage, for: .selected)
        
//        self.guessUpButton.setImage(upIconImage, for: .normal)
//        self.guessDownButton.setImage(downIconImage, for: .normal)
        
//        self.guessUpButton.setTitleColor(QMUITheme().stockRedColor(), for: .normal)
//        self.guessDownButton.setTitleColor(QMUITheme().stockGreenColor(), for: .normal)
    }

    
    lazy var glLayer: CAGradientLayer = {
        let glLayer = CAGradientLayer()
        glLayer.startPoint = CGPoint(x: 0.5, y: 0)
        glLayer.endPoint = CGPoint(x: 0.5, y: 1)
        glLayer.locations = [0, 1.0]
        return glLayer
    }()
    
    @objc lazy var iconLabel: YXMarketIconLabel = {
        return YXMarketIconLabel()
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .mediumFont16()
        return label
    }()
    
    lazy var nowLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .mediumFont16()
        label.textAlignment = .right
        return label
    }()
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .mediumFont14()
        label.textAlignment = .right
        label.text = "0.00%"
        return label
    }()

    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .mediumFont14()
        label.textAlignment = .right
        label.text = "0.000"
        return label
    }()
        
    lazy var upRatioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
//        label.textColor = QMUITheme().stockRedColor()
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "--"
        return label
    }()
    
    lazy var downRatioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
//        label.textColor = QMUITheme().stockGreenColor()
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "--"
        return label
    }()
    
    lazy var upDownRatioView: UIView = {
        let view = UIView()
        view.layer.addSublayer(upGradientLayer)
        view.layer.addSublayer(downGradientLayer)
        return view
    }()
    
//    lazy var upGradientLayer: CAGradientLayer = {
//        let layer = CAGradientLayer.init()
//        layer.cornerRadius = 2
//        layer.startPoint = CGPoint(x: 0, y: 0)
//        layer.endPoint = CGPoint(x: 1, y: 0)
//        layer.colors = [UIColor.init(hexString: "#FC6666")!.cgColor, UIColor.init(hexString: "#FFB9B9")!.cgColor]
//        return layer
//    }()
//
//    lazy var downGradientLayer: CAGradientLayer = {
//        let layer = CAGradientLayer.init()
//        layer.cornerRadius = 2
//        layer.startPoint = CGPoint(x: 0, y: 0)
//        layer.endPoint = CGPoint(x: 1, y: 0)
//        layer.colors = [UIColor.init(hexString: "#9BE3C0")!.cgColor, UIColor.init(hexString: "#52DA98")!.cgColor]
//        return layer
//    }()
    
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
    
    lazy var guessButton: YXGuessButtonView = {
        let view = YXGuessButtonView()
        _ = view.guessUpButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapUpAction?()
        })
        _ = view.guessDownButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapDownAction?()
        })
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        backgroundColor = QMUITheme().foregroundColor()
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowOpacity = 1
//        layer.shadowRadius = 4
        layer.cornerRadius = 4
        layer.borderColor = QMUITheme().pointColor().cgColor
        layer.borderWidth = 1

//        if YXUserManager.shared().getSkinType() == .pureWhite {
//            layer.shadowColor = UIColor.init(hexString: "#000000")?.withAlphaComponent(0.08).cgColor
//        }else {
//            layer.shadowColor = UIColor.init(hexString: "#000000")?.withAlphaComponent(0.5).cgColor
//        }
        contentView.addSubview(iconLabel)

        contentView.addSubview(nameLabel)
        contentView.addSubview(nowLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(rocLabel)
    
        contentView.addSubview(upDownRatioView)
        contentView.addSubview(upRatioLabel)
        contentView.addSubview(downRatioLabel)
        contentView.addSubview(guessButton)
        
        iconLabel.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.left.equalTo(9)
            $0.size.equalTo(CGSize.init(width: 16, height: 12))
        }
        
        
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(13)
            $0.left.equalTo(30)
        }
        
        nowLabel.snp.makeConstraints {
            $0.left.equalTo(nameLabel.snp.right).offset(4)
            $0.centerY.equalTo(nameLabel)
            $0.right.equalTo(-10)
//            $0.width.equalTo(65)
        }
        //CompressionResistance保持自己更大，优先级越高越大
        nowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        symbolLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
//            $0.left.equalTo(nameLabel)
            $0.left.equalTo(9)
        }
        
        rocLabel.snp.makeConstraints {
            $0.centerY.equalTo(symbolLabel)
            $0.right.equalToSuperview().offset(-12)
        }
        
        changeLabel.snp.makeConstraints {
            $0.centerY.equalTo(symbolLabel)
            $0.right.equalTo(rocLabel.snp.left).offset(-12)
        }
        
        //中间
        upDownRatioView.snp.makeConstraints {
            $0.height.equalTo(4)
//            $0.top.equalToSuperview().offset(73)
            $0.top.equalTo(symbolLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-12)
        }

        upRatioLabel.snp.makeConstraints {
            $0.left.equalTo(upDownRatioView)
            $0.top.equalTo(upDownRatioView.snp.bottom).offset(3)
        }

        downRatioLabel.snp.makeConstraints {
            $0.right.equalTo(upDownRatioView)
            $0.centerY.equalTo(upRatioLabel)
        }

        //尾部
        guessButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(236)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        tapUpAction = { [weak self]  in
            guard let `self` = self else { return }
            self.tapDownUpAction?(self.model?.market ?? "", self.model?.secuCode ?? "", self.model?.guessChange != nil, true)
        }

        tapDownAction = { [weak self]  in
            guard let `self` = self else { return }
            self.tapDownUpAction?(self.model?.market ?? "", self.model?.secuCode ?? "", self.model?.guessChange != nil, false)
        }
    }
}


class SquareGuessUpOrDownView: UIView,StackViewSubViewProtocol {
    
    @objc var refreshData: (()->())?
    
    
    var model: YXGuessUpAndDownListResModel?{
        
        didSet {
            guard let _ = self.model else {
                return
            }
            self.collectionView.reloadData()
        }   
    }
    
    lazy var headerCell: YXSquareSectionCell = {
        let view = YXSquareSectionCell.init()
        view.clickCallBack = { [weak self] in
            let context = YXWebViewModel(dictionary: [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.newGuessUpOrDownMoreUrl()
            ])
            YXSquareManager.getTopService()?.push(YXModulePaths.webView.url, context: context)
        }
        view.titleLabel.text = YXLanguageUtility.kLang(key: "rise_or_fall")
        view.subTitleLabel.text = ""
        view.hLineView.isHidden = true
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    private lazy var layout: QMUICollectionViewPagingLayout = {
        let layout = QMUICollectionViewPagingLayout(style: .default)!
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 24, right: 0)
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SquareGuessUpOrDownViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(SquareGuessUpOrDownViewCell.self))
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let containView = UIView.init()
        containView.backgroundColor = QMUITheme().foregroundColor()
        addSubview(containView)
        containView.addSubview(headerCell)
        containView.addSubview(collectionView)
        
        
        containView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(12)
            $0.left.right.bottom.equalToSuperview()
        }
        
        headerCell.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints{
            $0.top.equalTo(headerCell.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(164)
        }
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiSkinChange))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                self?.collectionView.reloadData()
            })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SquareGuessUpOrDownView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model?.list.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let guessIndexCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(SquareGuessUpOrDownViewCell.self),
            for: indexPath
        ) as! SquareGuessUpOrDownViewCell
        guessIndexCell.model = model?.list[indexPath.row]
        
        guessIndexCell.tapDownUpAction = { [weak self] market, sybmol, isSelected, isUp in
            guard let `self` = self else { return }
            guard let _ = YXSquareManager.getTopService() else { return }
            if YXUserManager.isLogin() {

                var h5Str = ""
                var value = ""
                if isUp {
                    h5Str = "1"
                    value = "1"
                } else {
                    h5Str = "-1"
                    value = "0"
                }
                
                var type = ""
                if market == kYXMarketHK {
                    type =  "warrant"
                } else if market == kYXMarketUS {
                    type = "option"
                } else if market == kYXMarketSG {
                    type = "0"
                }
                
                let context = YXWebViewModel(dictionary: [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.guessUpOrDownUrl(market: market, symbol: sybmol, type: type, upOrDown: h5Str)
                ])
                YXSquareManager.getTopService()?.push(YXModulePaths.webView.url, context: context)
                

                // 请求接口
                if !isSelected {
                    let requestModel = YXGuessUpAndDownUserGuessReqModel.init()

                    if market == kYXMarketHK {
                        requestModel.market = kYXMarketHK
                    } else if market == kYXMarketUS {
                        requestModel.market = kYXMarketUS
                    } else if market == kYXMarketSG {
                        requestModel.market = kYXMarketSG
                    }
                    requestModel.guessChange = value
                    requestModel.code = sybmol

                    let hud = YXProgressHUD.showLoading("")
                    let request = YXRequest.init(request: requestModel)
                    request.startWithBlock(success: { response in
                        hud.hide(animated: true)
                        guard response.code == .success else {
                            if let msg = response.msg, msg.count > 0 {
                                YXProgressHUD.showError(msg)
                            }
                            return
                        }
                        self.refreshData?()
                    }, failure: { request in
                        hud.hide(animated: true)
                        hud.showError(YXLanguageUtility.kLang(key: "network_failed"))
                    })

                }

            } else {
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
                YXSquareManager.getTopService()?.push(YXModulePaths.defaultLogin.url, context: context)
            }
        }
        return guessIndexCell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let model =  model?.list[indexPath.row] {
            goToStockDetail(market: model.market, symbol: model.secuCode)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 260, height: 139)
    }
    
    func goToStockDetail(market: String?, symbol: String?) {
        if let mkt = market, let code = symbol {
            let input = YXStockInputModel()
            input.market = mkt
            input.symbol = code
            input.name = ""
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let navigator = root.navigator
                navigator.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex": 0], animated: true)
            }
        }
    }
}


