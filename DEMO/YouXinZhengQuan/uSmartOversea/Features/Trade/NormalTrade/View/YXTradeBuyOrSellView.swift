//
//  YXBuyOrSellView.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2021/7/9.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXTradeBuyOrSellButton: UIButton {
    
    @objc var isLeft = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc var isFull = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc var padding: CGFloat = 10
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
                        
        let height = rect.size.height
        let width = rect.size.width
        
        var path = UIBezierPath.init()
        path.lineWidth = 1
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        if isFull {
            path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize.init(width: 2, height: 2))
        } else {
            if isLeft {
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width-1, y: 0))
                path.addLine(to: CGPoint(x: width - padding, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.close()
            } else {
                path.move(to: CGPoint(x: padding, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 1, y: height))
                path.addLine(to: CGPoint(x: padding, y: 0))
            }
            self.layer.cornerRadius = 2
            self.layer.masksToBounds = true
        }
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = path.cgPath
        maskLayer.frame = rect
        self.layer.mask = maskLayer
    }

}


enum TradeDirectionButtonType {
    case buy   //买
    case sell  //卖
    case onlyBuy // 只有买
    case onlySell //只有卖
}

extension TradeDirectionButtonType {
    var direction: TradeDirection {
        switch self {
        case .buy,
             .onlyBuy:
            return .buy
        case .sell,
             .onlySell:
            return .sell
        }
    }
}

class YXTradeDirectionView: UIView, YXTradeHeaderSubViewProtocol {
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "trade_direction")
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        return titleLabel
    }()

    lazy var buyOrSellView: YXTradeBuyOrSellView = {
        return YXTradeBuyOrSellView()
    }()
    
    var selectTypeCallBack:((TradeDirectionButtonType) -> ())? {
        didSet {
            buyOrSellView.selectTypeCallBack = selectTypeCallBack
        }
    }
    
    var selectType: TradeDirectionButtonType = .buy {
        didSet {
            buyOrSellView.selectType = selectType
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(titleLabel)
        addSubview(buyOrSellView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.height.equalTo(28)
            make.left.equalTo(16)
        }
        
        buyOrSellView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.height.equalTo(28)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(210)
        }
        
        contentHeight = 44
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TradeModel {
    var directionButtonType: TradeDirectionButtonType {
        let isOnly = tradeStatus == .change || tradeStatus == .limit
        
        switch direction {
        case .buy:
            return isOnly ? .onlyBuy : .buy
        case .sell:
            return isOnly ? .onlySell : .sell
        }
    }
}

class YXTradeBuyOrSellView: UIView {
    
    let leftBtn = YXTradeBuyOrSellButton.init()
    let rightBtn = YXTradeBuyOrSellButton.init()
    
    
    var selectTypeCallBack:((TradeDirectionButtonType) -> () )?
    
    var selectType: TradeDirectionButtonType = .buy {
        
        didSet {
            if selectType == .buy {
                trackViewClickEvent(name: "Direction-Buy_Tab")
            } else {
                trackViewClickEvent(name: "Direction-Sell_Tab")
            }
            self.refreshUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        self.refreshUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
                        
        leftBtn.isLeft = true
        rightBtn.isLeft = false
        
        
        leftBtn.tag = 1000
        rightBtn.tag = 1001
        
        
        leftBtn.addTarget(self, action: #selector(self.btnDidClick(_:)), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(self.btnDidClick(_:)), for: .touchUpInside)
        
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        leftBtn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        leftBtn.setTitleColor(UIColor.white, for: .selected)
        
        rightBtn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        rightBtn.setTitleColor(UIColor.white, for: .selected)
        
        leftBtn.setTitle(YXLanguageUtility.kLang(key: "trade_buy"), for: .normal)
        rightBtn.setTitle(YXLanguageUtility.kLang(key: "trade_sell"), for: .normal)
        
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        leftBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(110)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(110)
        }
    }
    
    @objc func btnDidClick(_ sender: UIButton) {
        guard !sender.isSelected else {
            return
        }
        if sender.tag == 1000 {
            selectType = .buy
        } else {
            selectType = .sell
        }
        
        selectTypeCallBack?(selectType)
    }
    
    func refreshUI() {
        
        var leftW: CGFloat = 110
        var rightW: CGFloat = 110
        if selectType == .buy {
            self.leftBtn.layer.backgroundColor = QMUITheme().buy().cgColor
            self.rightBtn.layer.backgroundColor = QMUITheme().blockColor().cgColor
            self.leftBtn.isSelected = true
            self.rightBtn.isSelected = false

            self.leftBtn.isFull = false
            self.rightBtn.isFull = false
        } else if selectType == .sell {
            self.leftBtn.layer.backgroundColor = QMUITheme().blockColor().cgColor
            self.rightBtn.layer.backgroundColor = QMUITheme().sell().cgColor
            self.leftBtn.isSelected = false
            self.rightBtn.isSelected = true
            
            self.leftBtn.isFull = false
            self.rightBtn.isFull = false
        } else if selectType == .onlyBuy {
            self.leftBtn.layer.backgroundColor = QMUITheme().buy().withAlphaComponent(0.4).cgColor
            self.leftBtn.isSelected = true
            leftW = 210
            rightW = 0
            
            self.leftBtn.isFull = true
            self.rightBtn.isFull = false
        } else if selectType == .onlySell {
            self.rightBtn.layer.backgroundColor = QMUITheme().sell().withAlphaComponent(0.4).cgColor
            self.rightBtn.isSelected = true
            leftW = 0
            rightW = 210
            
            self.leftBtn.isFull = false
            self.rightBtn.isFull = true
        }
        
        self.leftBtn.snp.updateConstraints { make in
            make.width.equalTo(leftW)
        }
        self.rightBtn.snp.updateConstraints { make in
            make.width.equalTo(rightW)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refreshUI()
    }
}


class YXSmartDirectionView: UIView, YXTradeHeaderSubViewProtocol {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(with: QMUITheme().textColorLevel3(),
                            font: UIFont.systemFont(ofSize: 12),
                            text: YXLanguageUtility.kLang(key: "trade_direction"))
        return label
    }()
    
    private var segmentView: YXTradeSegmentView<TradeDirection>!
    convenience init(typeArr: [TradeDirection] = [.buy, .sell], selectType: TradeDirection = .buy, selectedBlock:((TradeDirection) -> Void)?) {
        self.init()
        
        segmentView = YXTradeSegmentView(typeArr: typeArr, selected: selectType, selectedBlock: selectedBlock)
        segmentView.itemSize = CGSize(width: 65, height: 24)
        
        addSubview(segmentView)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(segmentView)
            make.left.equalToSuperview().offset(16)
        }
        
        segmentView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(130)
            make.height.equalTo(24)
            make.top.equalTo(8)
        }
        
        contentHeight = 40
    }
    
    var triggerType: TradeDirection {
        segmentView.selectedType
    }
    
    func updateType(_ selected: TradeDirection? = nil) {
        segmentView.updateType(selected: selected)
    }
}
