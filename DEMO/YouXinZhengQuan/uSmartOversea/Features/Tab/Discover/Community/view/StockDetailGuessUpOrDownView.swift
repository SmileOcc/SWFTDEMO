//
//  StockDetailGuessUpOrDownView.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class GuessRatioView: UIView {

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

    lazy var upRatioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "--"
        return label
    }()

    lazy var downRatioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = "--"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(upRatioLabel)
        addSubview(downRatioLabel)
        addSubview(upDownRatioView)

        upDownRatioView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(4)
        }

        upRatioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(upDownRatioView.snp.bottom).offset(4)
        }

        downRatioLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalTo(upRatioLabel)
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RateContainView:  UIView {
    
    lazy var upBtn:RateButton = {
        let upBtn = RateButton.init()
        upBtn.type = .left
        upBtn.setImage(UIImage.init(named: "guessUp"), for: .normal)
        upBtn.setImage(UIImage.init(named: "guessUp_select"), for: .selected)
        upBtn.backgroundColor = QMUITheme().stockRedColor()
        upBtn.setTitle(YXLanguageUtility.kLang(key: "guessUp"), for: .normal)
        upBtn.setTitle(YXLanguageUtility.kLang(key: "picked_Up"), for: .selected)
        upBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        upBtn.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6"), for: .normal)
        upBtn.setTitleColor(UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#FFFFFF")!, andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!.withAlphaComponent(0.4)), for: .selected)
        return upBtn
    }()
    
    lazy var downBtn:RateButton = {
        let downBtn = RateButton.init()
        downBtn.type = .right
        downBtn.setImage(UIImage.init(named: "guessDown"), for: .normal)
        downBtn.setImage(UIImage.init(named: "guessDown_select"), for: .selected)
        downBtn.backgroundColor = QMUITheme().stockGreenColor()
        downBtn.setTitle(YXLanguageUtility.kLang(key: "guessDown"), for: .normal)
        downBtn.setTitle(YXLanguageUtility.kLang(key: "picked_Down"), for: .selected)
        downBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        downBtn.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6"), for: .normal)
        downBtn.setTitleColor(UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#FFFFFF")!, andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!.withAlphaComponent(0.4)), for: .selected)
        return downBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        addSubview(upBtn)
        addSubview(downBtn)
        
        let width = YXConstant.screenWidth - 32 - 2
        upBtn.snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.equalTo(width * 0.5 + 10)
            $0.height.equalTo(32)
        }
        
        downBtn.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(width * 0.5)
        }
    }
}

class RateButton: UIButton {
    
    enum RateType {
        case none
        case left
        case right
    }
    
    var type:RateType = .none
    
    var margin:CGFloat = 12
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        switch type {
        case .none:
            break
        case .left:
            drawLeft(rect)
            break
        case .right:
            drawRight(rect)
            break
        }
    }
    
    func drawLeft(_ rect: CGRect)  {
        
        var path = UIBezierPath.init()
        path.lineWidth = 1
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        path = UIBezierPath(arcCenter: CGPoint(x: 16, y: 16), radius: 16, startAngle: 0.5*CGFloat(Double.pi), endAngle: 1.5*CGFloat(Double.pi), clockwise: true)
        path.addLine(to: CGPoint(x: self.mj_w, y: 0))
        path.addLine(to: CGPoint(x: self.mj_w - margin, y: self.mj_h))
        path.close()
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = path.cgPath
        maskLayer.frame = rect
        self.layer.mask = maskLayer
        
    }
    
    func drawRight(_ rect: CGRect)  {
        
        var path = UIBezierPath.init()
        path.lineWidth = 1
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        path = UIBezierPath(arcCenter: CGPoint(x: self.mj_w - 16, y: 16), radius: 16, startAngle: 1.5*CGFloat(Double.pi), endAngle: 0.5*CGFloat(Double.pi), clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: self.mj_h))
        path.addLine(to: CGPoint(x: margin, y: 0))
        path.close()
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = path.cgPath
        maskLayer.frame = rect
        self.layer.mask = maskLayer
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        switch type {
        case .left:
            self.imageView?.frame = CGRect.init(x: 8, y: (self.frame.size.height - 18) * 0.5, width: 18, height: 18)
            self.titleLabel?.frame = CGRect.init(x: (self.imageView?.frame.maxX ?? 0) + 8 , y: (self.frame.size.height - 14) * 0.5, width: self.mj_w - 42, height: 14)
            self.titleLabel?.textAlignment = .left
            break
        case .right:
            self.imageView?.frame = CGRect.init(x: self.mj_w - 26, y: (self.frame.size.height - 18) * 0.5, width: 18, height: 18)
            self.titleLabel?.frame = CGRect.init(x: 8 , y: (self.frame.size.height - 14) * 0.5, width: self.mj_w - 42, height: 14)
            self.titleLabel?.textAlignment = .right
            break
        case .none:
            break
        }
    }
}

class GuessUpOrDownView:UIView {
    
    var tapUpAction: ((_ isSelect: Bool) -> Void)?
    var tapDownAction: ((_ isSelect: Bool) -> Void)?
    
    //显示比例的 view
    lazy var rateContainView:RateContainView = {
        let view = RateContainView.init()
        _ = view.upBtn.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapUpAction?(self.model?.guessChange != nil)
        })
        _ = view.downBtn.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapDownAction?(self.model?.guessChange != nil)
        })
        return view
    }()
       
    lazy var ratioView: GuessRatioView = {
        let view = GuessRatioView()
        return view
    }()
    
    var model: YXStockDetailGuessUpOrDownInfo? {
        didSet {
            guard let model = model else { return }
            
            if let guessChange = model.guessChange?.intValue {
                if guessChange == 0 {
                    rateContainView.downBtn.isSelected = true
                    rateContainView.upBtn.isSelected = false
                    rateContainView.downBtn.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.3)
                } else {
                    rateContainView.downBtn.isSelected = false
                    rateContainView.upBtn.isSelected = true
                    rateContainView.upBtn.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.3)
                }
            } else {
                rateContainView.downBtn.isSelected = false
                rateContainView.upBtn.isSelected = false
            }
            
            if let upCount = model.upCount?.intValue, let downCount = model.downCount?.intValue {
                let up = Double(upCount)
                let down = Double(downCount)
                let total = up + down
                if total > 0 {
                    let upRatio = up / total
                    let downRatio = down / total
                    setupRate(CGFloat(upRatio),CGFloat(downRatio))
                } else {
                    setupRate(0.5,0.5)
                }
            }
        }
    }
    
    func setupRate(_ upRatio:CGFloat,_ downRatio:CGFloat)  {
        ratioView.upRatioLabel.text = String(format: "%.2lf%%", upRatio*100.0)
        ratioView.downRatioLabel.text = String(format: "%.2lf%%",downRatio*100.0)
        
        let w = YXConstant.screenWidth - 32.0;
        ratioView.upGradientLayer.frame = CGRect.init(x: 0, y: 0, width: w * CGFloat(upRatio), height: 4)
        ratioView.downGradientLayer.frame = CGRect.init(x: ratioView.upGradientLayer.frame.width, y: 0, width: w * CGFloat(downRatio), height: 4)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        addSubview(rateContainView)
        addSubview(ratioView)
        
        ratioView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        rateContainView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(ratioView.snp.bottom).offset(12)
        }
        
    }
}


class StockDetailGuessUpOrDownView: UIView {
    
    var tapAction: ((_ isUp:Bool, _ isSelected: Bool) -> Void)?
        
   @objc var model:YXStockDetailGuessUpOrDownInfo? {
        didSet{
            if let m = model {
                guessUpOrDownView.model = m
            }
        }
    }

    lazy var titleLabel:UILabel = {
        let label = UILabel.init()
        label.text = YXLanguageUtility.kLang(key: "rise_or_fall")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()

    private lazy var guessUpOrDownView:GuessUpOrDownView = {
        let view = GuessUpOrDownView.init()
        view.tapUpAction = { [weak self] isSelect in
            self?.tapAction!(true, isSelect)
        }
        
        view.tapDownAction = { [weak self] isSelect in
            self?.tapAction?(false,  isSelect)
        }
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        addSubview(titleLabel)
        addSubview(guessUpOrDownView)

        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
        }

        guessUpOrDownView.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
}

