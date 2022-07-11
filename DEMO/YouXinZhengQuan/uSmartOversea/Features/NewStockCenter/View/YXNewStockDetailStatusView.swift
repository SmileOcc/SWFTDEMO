//
//  YXNewStockDetailStatusView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import YXKit
import SnapKit


class YXNewStockDetailStatusView: UIView {
    
    @objc enum YXNewStockType: Int {
        case start = 0
        case end
        case publish
        case greyTrade
        case listing
        
        func name() -> String {
            switch self {
                case .start:
                return YXLanguageUtility.kLang(key: "newStock_detail_start_subscribe")
                case .end:
                return YXLanguageUtility.kLang(key: "newStock_detail_end_subscribe")
                case .publish:
                return YXLanguageUtility.kLang(key: "newStock_detail_announce_signing2")
                case .greyTrade:
                return YXLanguageUtility.kLang(key: "grey_mkt")
                case .listing:
                return YXLanguageUtility.kLang(key: "newStock_detail_listed")
            }
        }
    }
    
    enum StatusCircleType {
        case ring    //带圆环
        case cirlce  //实心圆
    }
    
    enum GreyTradingType {
        case noOpen
        case open
        case close
        case none
    }
    
    var circleType: StatusCircleType = .cirlce
    var columns: Int = 4 //每行展示的个数
    
    private var titleLabels: [YXStockDetailNewStockStatusTypeLabel] = []
    private var datesLabels: [YXStockDetailNewStockStatusTypeLabel] = []
    private var lineViews: [YXStockDetailNewStockStatusLineView] = []
    private var circleViews: [YXStockDetailNewStockStatusCircleView] = []
    
    var circleSelectedColor: UIColor = QMUITheme().textColorLevel1()
    var circleNormalColor: UIColor = UIColor.qmui_color(withHexString: "#DADADA") ?? .white
    
    var lineSelectedColor: UIColor = QMUITheme().textColorLevel1()
    var lineNormalColor: UIColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1)
    
    var titleLabelSelectedColor: UIColor = QMUITheme().textColorLevel1()
    var titleLabelNormalColor: UIColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
    
    var dateLabelSelectedColor: UIColor = QMUITheme().textColorLevel1().withAlphaComponent(0.7)
    var dateLabelNormalColor: UIColor = QMUITheme().textColorLevel1().withAlphaComponent(0.6)
    
    var selecteCircledWidth: CGFloat = 10
    var normalCircleWidth: CGFloat = 6
    
    //设置股票处于上市前的状态
    func setStockType(_ type: YXNewStockType, progress: CGFloat = 0.0) {
        
        for (index, view) in circleViews.enumerated() {
            if view.type.rawValue <= type.rawValue {
                view.selected = true
                if view.type == type {
                    view.snp.updateConstraints { (make) in
                        make.width.height.equalTo(self.selecteCircledWidth)
                    }
                    view.circleType = self.circleType
                    view.showRing = true
                } else {
                    view.snp.updateConstraints { (make) in
                        make.width.height.equalTo(self.normalCircleWidth)
                    }
                }
                
                let titleLabel = titleLabels[index]
                titleLabel.textColor = self.titleLabelSelectedColor
                let dateLabel = datesLabels[index]
                dateLabel.textColor = self.dateLabelSelectedColor
                
                let realIndex = index % self.columns
                let currentLine = index / self.columns
                let lineIndex = self.columns * currentLine + realIndex - 1
                if lineIndex >= 0 && lineIndex < lineViews.count {
                    let lineView = lineViews[lineIndex]
                    lineView.lineView.backgroundColor = self.lineSelectedColor
                    if lineView.type == type {
                        lineView.setProgress(progress)
                    } else {
                        lineView.setProgress(1.0)
                    }
                }
            } else {
                break
            }
        }
    }
    
    //国际配售展示文案替换
    func setOnlyInternalSubs(_ onlyInternal: Bool = true) {
        if onlyInternal {
            for label in titleLabels {
                if label.type == .publish {
                    label.text = YXLanguageUtility.kLang(key: "announce_distribution")
                    break;
                }
            }
        }
    }
    
    func setUSPulishText() {
        for label in titleLabels {
            if label.type == .publish {
                label.text = YXLanguageUtility.kLang(key: "estimated_distribution")
                break;
            }
        }
    }
    
    //配置展示类型， 行数， 每行展示个数
    func setTradeStatusArray(_ types: [YXNewStockType], columns: Int = 4) {
        self.columns = columns
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        loadData(types)
        initUI()
    }
    
    //填充日期
    func setDateArr(_ dates: [String]) {
        
        for (index, label) in datesLabels.enumerated() {
            if index < dates.count {
                label.text = dates[index]
            }
        }
    }
    
    //设置暗盘开盘前，交易中，结束不同状态的文字
    func setGreyTradingType(_ type: GreyTradingType) {
        
        var title = ""
        switch type {
            case .noOpen:
                title = YXLanguageUtility.kLang(key: "grey_mkt_trade")
            case .open:
                title = YXLanguageUtility.kLang(key: "grey_mkt_trading_session1")
            case .close:
                title = YXLanguageUtility.kLang(key: "grey_mkt_closed1")
            case .none:
                break;
        }
        
        for label in titleLabels {
            if label.type == .greyTrade {
                label.text = title
                break;
            }
        }
        
        if type == .close {
            for lineView in lineViews {
                if lineView.type == .greyTrade {
                    lineView.lineView.backgroundColor = self.lineSelectedColor
                    lineView.setProgress(0.5)
                    break;
                }
            }
        } else if type == .noOpen {
            for lineView in lineViews {
                if lineView.type == .publish {
                    lineView.lineView.backgroundColor = self.lineSelectedColor
                    lineView.setProgress(0.5)
                    break;
                }
            }
        }
       
    }
    
    //设置暗盘交易中时的日期
    func setGreyTradeDate(_ time: String) {
        for label in datesLabels {
            if label.type == .greyTrade {
                label.numberOfLines = 2
                label.text = time
                break;
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.setTradeStatusArray([.start, .end, .publish, .listing])
    }
    
    private func loadData(_ types: [YXNewStockType]) {
        
        var tempTitleLabels: [YXStockDetailNewStockStatusTypeLabel] = []
        var tempDatesLabels: [YXStockDetailNewStockStatusTypeLabel] = []
        var tempLines: [YXStockDetailNewStockStatusLineView] = []
        var tempCircles: [YXStockDetailNewStockStatusCircleView] = []
        
        for (index, type) in types.enumerated() {
            //titlelabels
            var alignment: NSTextAlignment = .left
            let realIndex = index % self.columns
            if realIndex == 0 {
                alignment = .left
            } else if realIndex == self.columns - 1 {
                alignment = .right
            } else {
                alignment = .center
            }

            let label = self.tradeTitleLabel()
            label.textAlignment = alignment
            label.text = type.name()
            label.type = type
            tempTitleLabels.append(label)
            //dateslabels
            let dateLabel = self.tradeDateLabel()
            dateLabel.textAlignment = alignment
            dateLabel.type = type
            tempDatesLabels.append(dateLabel)
            //lines
            if realIndex != self.columns - 1 {
                let lineView = YXStockDetailNewStockStatusLineView()
                lineView.backgroundColor = self.lineNormalColor
                lineView.type = type
                tempLines.append(lineView)
            }
            //circles
            let circleView = YXStockDetailNewStockStatusCircleView()
            circleView.type = type
            //circleView.circleType = self.circleType
            circleView.selectColor = self.circleSelectedColor
            circleView.normalColor = self.circleNormalColor
            tempCircles.append(circleView)
        }
        titleLabels = tempTitleLabels
        datesLabels = tempDatesLabels
        circleViews = tempCircles
        lineViews = tempLines
    }
    
    func tradeTitleLabel() -> YXStockDetailNewStockStatusTypeLabel {
        let label = YXStockDetailNewStockStatusTypeLabel()
        label.textColor = self.titleLabelNormalColor
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 14.0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }
    
    func tradeDateLabel() -> YXStockDetailNewStockStatusTypeLabel {
        let dateLabel = YXStockDetailNewStockStatusTypeLabel()
        dateLabel.text = ""
        dateLabel.numberOfLines = 2
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = self.dateLabelNormalColor
        return dateLabel
    }
    
    private func initUI() {
        let margin: CGFloat = 16.0
        let titleTopMargin: CGFloat = 8
        let dateTopMargin: CGFloat = 5
        let perLineCircleCount = self.columns
        
        var perLineHeight = 70
        if YXUserManager.isENMode() {
            perLineHeight = 84
        }

        var lastCircleView: UIView?
        var lastDateLabel: UIView?
        for (index, circleView) in circleViews.enumerated() {
            
            addSubview(circleView)
            let titleLabel = titleLabels[index]
            addSubview(titleLabel)
            let dateLabel = datesLabels[index]
            addSubview(dateLabel)
            
            let realIndex = index % perLineCircleCount
            let currentLine = index / perLineCircleCount
            circleView.snp.makeConstraints { (make) in
                if realIndex == 0 {
                    make.left.equalToSuperview().offset(margin)
                } else if realIndex == perLineCircleCount - 1 {
                    make.right.equalToSuperview().offset(-margin)
                } else {
                    let offset = (CGFloat(1) - (CGFloat(index % perLineCircleCount) / CGFloat(perLineCircleCount - 1))) *
                        (6.0 + margin) - CGFloat(index % perLineCircleCount) *  margin / CGFloat(perLineCircleCount - 1)
                    make.right
                        .equalTo(self)
                        .multipliedBy(CGFloat(index % perLineCircleCount) / CGFloat(perLineCircleCount - 1))
                        .offset(offset)
                }
                make.centerY.equalTo(self.snp.top).offset(6.0 + CGFloat(currentLine * perLineHeight))
                make.width.height.equalTo(self.normalCircleWidth)
            }
            //标题
            titleLabel.snp.makeConstraints { (make) in
                if realIndex == 0 {
                    make.left.equalTo(circleView.snp.left)
                } else if realIndex == perLineCircleCount - 1 {
                    make.right.equalTo(circleView.snp.right)
                } else {
                    make.centerX.equalTo(circleView.snp.centerX)
                }
                make.top.equalTo(circleView.snp.bottom).offset(titleTopMargin)
            }
            //日期
            dateLabel.snp.makeConstraints { (make) in
                if realIndex == 0 {
                    make.left.equalTo(circleView.snp.left)
                } else if realIndex == perLineCircleCount - 1 {
                    make.right.equalTo(circleView.snp.right)
                } else {
                    make.centerX.equalTo(circleView.snp.centerX)
                }
                if let lastView = lastDateLabel, realIndex != 0 {
                    make.top.equalTo(lastView.snp.top)
                } else {
                    make.top.equalTo(titleLabel.snp.bottom).offset(dateTopMargin)
                }
                
            }
          
            //中间横线
            let lineIndex = (perLineCircleCount - 1) * currentLine + realIndex - 1
            if realIndex > 0, lineIndex < lineViews.count, let lastView = lastCircleView {
                let lineView = lineViews[lineIndex]
                addSubview(lineView)
                lineView.snp.makeConstraints { (make) in
                    make.left.equalTo(lastView.snp.right)
                    make.right.equalTo(circleView.snp.left)
                    make.centerY.equalTo(lastView.snp.centerY)
                    make.height.equalTo(1)
                }
            }
            lastCircleView = circleView
            lastDateLabel = dateLabel
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


class YXStockDetailNewStockStatusTypeLabel: UILabel {
    
    var type: YXNewStockDetailStatusView.YXNewStockType = .start
}

class YXStockDetailNewStockStatusCircleView: UIView {
    
    var type: YXNewStockDetailStatusView.YXNewStockType = .start
    
    let circleLayer = CAShapeLayer()
    let ringLayer = CAShapeLayer()
    var normalColor: UIColor = UIColor.qmui_color(withHexString: "#ACACAC")!
    var selectColor: UIColor = QMUITheme().mainThemeColor()
    var selectedWidth: CGFloat = 10
    var normalWidth: CGFloat = 6
    var circleType: YXNewStockDetailStatusView.StatusCircleType = .cirlce
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.layer.addSublayer(circleLayer)
        self.layer.addSublayer(ringLayer)
        
        circleLayer.strokeColor = self.normalColor.cgColor
        circleLayer.fillColor = self.normalColor.cgColor
        
        ringLayer.lineWidth = 1
        ringLayer.fillColor = UIColor.clear.cgColor
    }
    
    var selected: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var showRing: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
   
    override func draw(_ rect: CGRect) {
        circleLayer.path = nil
        ringLayer.path = nil
        ringLayer.isHidden = true
        var circlePath = UIBezierPath(roundedRect: CGRect(x: self.frame.width / 2.0 - self.normalWidth / 2.0, y: self.frame.height / 2.0 - self.normalWidth / 2.0, width: self.normalWidth, height: self.normalWidth), cornerRadius: self.normalWidth / 2.0)
        
        if self.selected {
            circleLayer.strokeColor = self.selectColor.cgColor
            circleLayer.fillColor = self.selectColor.cgColor
        } else {
            circleLayer.strokeColor = self.normalColor.cgColor
            circleLayer.fillColor = self.normalColor.cgColor
        }
        
        if circleType == .cirlce, showRing {
            circlePath = UIBezierPath(roundedRect: CGRect(x: self.frame.width / 2.0 - self.selectedWidth / 2.0, y: self.frame.height / 2.0 - self.selectedWidth / 2.0, width: self.selectedWidth, height: self.selectedWidth), cornerRadius: self.selectedWidth / 2.0)
        }
        circleLayer.path = circlePath.cgPath;
        
        if circleType == .ring, showRing {
            ringLayer.isHidden = false
            ringLayer.strokeColor = self.selectColor.cgColor
            let ringPath = UIBezierPath.init(arcCenter: CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0), radius: self.selectedWidth / 2.0, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            ringLayer.path = ringPath.cgPath
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class YXStockDetailNewStockStatusLineView: UIView {
    
    var type: YXNewStockDetailStatusView.YXNewStockType = .start
    
    func setProgress(_ progress: CGFloat) {
        var realProgress = progress
        if progress > 1 {
            realProgress = 1.0
        }
        lineView.snp.remakeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(realProgress)
        }
    }
    
    lazy var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
