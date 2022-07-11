//
//  YXStockAnylzeEstimatedView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2021/3/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

// MARK: - 估值划线的view
class YXStockAnylzeEstimatedLineView: UIView {
    
    let drawHeight: CGFloat = 117
    let paddingY: CGFloat = 4
    let paddingLeft: CGFloat = 16
    
    var maxValueLabel = UILabel.init()
    var midValueLabel = UILabel.init()
    var minValueLabel = UILabel.init()
    
    var maxTimeLabel = UILabel.init()
    var midTimeLabel = UILabel.init()
    var minTimeLabel = UILabel.init()
    
    lazy var valueLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = QMUITheme().themeTextColor().cgColor
        return layer
    }()
    
    lazy var meanLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.lineWidth = 0.5
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = QMUITheme().textColorLevel3().cgColor
        return layer
    }()

    
    @objc var currentList = [YXAnalyzeEstimateSubModel]() {
        didSet {
            self.valueLayer.path = nil;
            self.meanLayer.path = nil;
            if currentList.count > 1 {
                self.drawCashFlow()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        maxValueLabel.textColor = QMUITheme().textColorLevel3()
        maxValueLabel.font = .systemFont(ofSize: 10)
        maxValueLabel.text = "--"
        
        midValueLabel.textColor = QMUITheme().textColorLevel3()
        midValueLabel.font = .systemFont(ofSize: 10)
        midValueLabel.text = "--"
        
        minValueLabel.textColor = QMUITheme().textColorLevel3()
        minValueLabel.font = .systemFont(ofSize: 10)
        minValueLabel.text = "--"
                
        maxTimeLabel.textColor = QMUITheme().textColorLevel3()
        maxTimeLabel.font = .systemFont(ofSize: 10)
        
        midTimeLabel.textColor = QMUITheme().textColorLevel3()
        midTimeLabel.font = .systemFont(ofSize: 10)
        
        minTimeLabel.textColor = QMUITheme().textColorLevel3()
        minTimeLabel.font = .systemFont(ofSize: 10)
        
        self.addSubview(maxValueLabel)
        self.addSubview(midValueLabel)
        self.addSubview(minValueLabel)
        self.addSubview(maxTimeLabel)
        self.addSubview(minTimeLabel)
        self.addSubview(midTimeLabel)
        self.layer.addSublayer(self.valueLayer)
        self.layer.addSublayer(self.meanLayer)

        let labelHeight: CGFloat = 22
        
        minTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(paddingLeft)
            make.top.equalToSuperview().offset(paddingY + drawHeight + 1)
            make.height.equalTo(labelHeight)
        }

        midTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(minTimeLabel)
            make.height.equalTo(labelHeight)
        }

        maxTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(minTimeLabel)
            make.height.equalTo(labelHeight)
        }
        
        maxValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(minTimeLabel)
            make.top.equalTo(self.snp.top).offset(paddingY)
            make.height.equalTo(labelHeight)
        }
        
        midValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(minTimeLabel)
            make.centerY.equalTo(self.snp.top).offset(paddingY + drawHeight * 0.5)
            make.height.equalTo(labelHeight)
        }
        
        minValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(minTimeLabel)
            make.bottom.equalTo(self.snp.top).offset(paddingY + drawHeight)
            make.height.equalTo(labelHeight)
        }
        let line1 = self.getBottomLineView("-  " ,YXLanguageUtility.kLang(key: "stock_estimated_history"), QMUITheme().themeTextColor())
        let line2 = self.getBottomLineView("··  ", YXLanguageUtility.kLang(key: "stock_estimated_average"), QMUITheme().textColorLevel3())
        addSubview(line1)
        addSubview(line2)
        
        line1.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.centerX).offset(-15)
            make.top.equalToSuperview().offset(drawHeight + paddingY + 35)
        }
        line2.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(15)
            make.top.equalToSuperview().offset(drawHeight + paddingY + 35)
        }
        
        // 画网格线
        let generator = YXLayerGenerator.init()
        self.layer.addSublayer(generator.horizonLayer)
        self.layer.qmui_sendSublayer(toBack: generator.horizonLayer)

        generator.horizonLayer.strokeColor = QMUITheme().pointColor().cgColor
        generator.horizonLayer.lineWidth = 0.5
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.init(x: paddingLeft, y: paddingY + labelHeight))
        path.addLine(to: CGPoint.init(x: self.width - paddingLeft, y: paddingY + labelHeight))
        
        path.move(to: CGPoint.init(x: paddingLeft, y: paddingY + drawHeight * 0.5 + labelHeight / 2.0))
        path.addLine(to: CGPoint.init(x: self.width - paddingLeft , y: paddingY + drawHeight * 0.5 + labelHeight / 2.0))

        path.move(to: CGPoint.init(x: paddingLeft, y: paddingY + drawHeight))
        path.addLine(to: CGPoint.init(x: self.width - paddingLeft, y: paddingY + drawHeight))
        
        generator.horizonLayer.path = path.cgPath
                
    }
    
    func drawCashFlow() {
        
        let padding_x: CGFloat = paddingLeft
        let margin: CGFloat = (YXConstant.screenWidth - padding_x * 2) / CGFloat(self.currentList.count)
    
        let redPath = UIBezierPath()
        
        var maxValue: Float = 0.00
        var minValue: Float = 0.00
                
        var numbers = self.currentList.map {
            $0.value
        }
        maxValue = Float(numbers.max() ?? 0)
        minValue = Float(numbers.min() ?? 0)
        
        if maxValue == minValue {
            if minValue <= 0 {
                maxValue = 0;
            }
            if minValue > 0 {
                minValue = 0;
            }
        }

        let midValue = (maxValue - minValue) * 0.5 + minValue
                        
        self.maxValueLabel.text = YXToolUtility.stockData(Double(maxValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        self.midValueLabel.text = YXToolUtility.stockData(Double(midValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        self.minValueLabel.text = YXToolUtility.stockData(Double(minValue), deciPoint: 2, stockUnit: "", priceBase: 0)
        
        let firstTime = self.currentList.last
        let lastTime = self.currentList.first
        var minTime: YXAnalyzeEstimateSubModel?
        if self.currentList.count > 2 {
            minTime = self.currentList[(self.currentList.count / 2)]
        }
        if let firstTime = firstTime {
            self.minTimeLabel.text = YXDateHelper.commonDateString(firstTime.date, scaleType: .scale)
        } else {
            self.minTimeLabel.text = ""
        }
        if let lastTime = lastTime {
            self.maxTimeLabel.text = YXDateHelper.commonDateString(lastTime.date, scaleType: .scale)
        } else {
            self.maxTimeLabel.text = ""
        }
        if let minTime = minTime {
            self.midTimeLabel.text = YXDateHelper.commonDateString(minTime.date, scaleType: .scale)
        } else {
            self.midTimeLabel.text = ""
        }
                
        
        numbers.reverse()
        for i in 0..<numbers.count {
            let value = numbers[i]
            let pointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(value), distance: drawHeight, zeroY: drawHeight + paddingY)
            if i == 0 {
                redPath.move(to: CGPoint(x: padding_x + margin * CGFloat(i), y: CGFloat(pointY)))
            } else {
                redPath.addLine(to: CGPoint(x: padding_x + margin * CGFloat(i), y: CGFloat(pointY)))
            }
        }
        
        if let firstModel = self.currentList.first {
            let meanPath = UIBezierPath()
            let meanY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(firstModel.mean), distance: drawHeight, zeroY: drawHeight + paddingY)
            let count = 50
            let padding = (self.mj_w - paddingLeft * 2) / CGFloat(count) * 0.4
            let width = ((self.mj_w - paddingLeft * 2) - (padding * CGFloat(count))) / CGFloat(count);
            
            for i in 0..<count {
                let path = UIBezierPath.init()
                path.move(to: CGPoint.init(x: paddingLeft + CGFloat(i) * (width + padding), y: meanY))
                path.addLine(to: CGPoint.init(x: paddingLeft + CGFloat(i) * (width + padding) + width, y: meanY))
                meanPath .append(path)
            }
            self.meanLayer.path = meanPath.cgPath
        }
        self.valueLayer.path = redPath.cgPath
        
    }
    
    func getBottomLineView(_ preTitle: String, _ title: String, _ color: UIColor) -> UILabel {
//        let view = UIView.init()
        let label = UILabel.init()
        
        let attM = NSMutableAttributedString.init()
        let attributesTitle = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : color]
        let attributesSubTitle = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3()]
        let peTitle = NSAttributedString.init(string: preTitle, attributes: attributesTitle)
        let peValue = NSAttributedString.init(string: title, attributes: attributesSubTitle)
        
        attM.append(peTitle)
        attM.append(peValue)
        
        label.attributedText = attM

        
        return label
    }
}


// MARK: - 估值选择类型的view
class YXStockAnylzeEstimatedTypeView: UIView {
    
    var selectBtn = UIButton.init()
    
    var selectCallBack: ((_ tag: NSInteger) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        let arr = ["PE", "PB", "PS"]
        let stackView = UIStackView.init()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal

        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        for i in 0..<arr.count {
            let title = arr[i]
            let btn = UIButton.init(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            btn.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
            btn.setBackgroundImage(UIImage.init(color: QMUITheme().foregroundColor()), for: .selected)
            btn.setBackgroundImage(UIImage.init(color: QMUITheme().textColorLevel1().withAlphaComponent(0.05)), for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.addTarget(self, action: #selector(self.btnClick(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(btn)
            if i == 0 {
                self.selectBtn = btn
                btn.isSelected = true
            }
            btn.tag = i
            
            if i > 0 {
                let lineView = UIView.init()
                lineView.backgroundColor = QMUITheme().separatorLineColor()
                addSubview(lineView)
                lineView.snp.makeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(1)
                    make.left.equalTo(btn)
                }
            }
        }
        
        
        
        self.layer.borderWidth = 1
        self.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        
    }
    
    @objc func btnClick(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            self.selectBtn.isSelected = false
            self.selectBtn = sender

            selectCallBack?(sender.tag)
        }
    }
}


// MARK: - 估值整体的view
class YXStockAnylzeEstimatedView: YXStockAnalyzeBaseView {
    
    @objc var selectCallBack: ((_ tag: NSInteger) -> ())?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "stock_estimated_company")
        return label
    }()
    
    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.addTarget(self, action: #selector(promptButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var noDataView: YXStockEmptyDataView = {
        let view = YXStockEmptyDataView()
        view.isHidden = true
        //view.setCenterYOffset(-20)
        return view
    }()

    lazy var typeView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: ["PE", "PB", "PS"])
        view.tapAction = {
            [weak self] index in
            guard let `self` = self else { return }
            self.selectCallBack?(index)
        }

        return view
    }()
    
    let currentVlaueTitleLabel = UILabel.init(text: YXLanguageUtility.kLang(key: "stock_estimated_current"), textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))!
    let currentVlaueLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14, weight: .medium))!
    
    let meanTitleLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))!
    let meanSubTitleLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 12))!
    let meanVlaueLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14, weight: .medium))!
    
    let updateTimeLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
    
    let lineView = YXStockAnylzeEstimatedLineView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 180))
    
    
    @objc var model: YXAnalyzeEstimateModel? {
        didSet {
            if let model = model, model.list.count > 0 {
                var str = "PE"
                if self.typeView.selectIndex == 0 {
                    str = "PE"
                } else if self.typeView.selectIndex == 1 {
                    str = "PB"
                } else if self.typeView.selectIndex == 2 {
                    str = "PS"
                }
                self.currentVlaueTitleLabel.text = YXLanguageUtility.kLang(key: "stock_estimated_current") + " " + str
                let subTitle = String.init(format: YXLanguageUtility.kLang(key: "stock_estimated_sub_tip"), str)
                self.meanTitleLabel.text = YXLanguageUtility.kLang(key: "stock_estimated_average")
                self.meanSubTitleLabel.text = "("+"\(subTitle)"+")"
                if let fisrtModel = model.list.first {
                    self.currentVlaueLabel.text = String.init(format: "%.2f", fisrtModel.value)
                    self.meanVlaueLabel.text = String.init(format: "%.2f", fisrtModel.mean)
                    self.updateTimeLabel.text = YXDateHelper.commonDateString(model.updateTime, format: .DF_MDYHM, scaleType: .scale)
                    
                }
                self.lineView.currentList = model.list
                self.noDataView.isHidden = true
            } else {
                self.noDataView.isHidden = false
            }
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        
        bindModel()
        
        meanSubTitleLabel.adjustsFontSizeToFitWidth = true
        meanSubTitleLabel.minimumScaleFactor = 0.3
        meanSubTitleLabel.numberOfLines = 2
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(titleLabel)
        addSubview(promptButton)
        addSubview(typeView)
        addSubview(currentVlaueTitleLabel)
        addSubview(currentVlaueLabel)
        addSubview(meanTitleLabel)
        addSubview(meanSubTitleLabel)
        addSubview(meanVlaueLabel)
        addSubview(updateTimeLabel)
        addSubview(lineView)
        addSubview(noDataView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        promptButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.width.height.equalTo(16)
        }
        
        typeView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(30)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        currentVlaueTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(typeView.snp.bottom).offset(22)
            make.height.equalTo(16)
        }
        currentVlaueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(currentVlaueTitleLabel)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
        meanTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(currentVlaueTitleLabel.snp.bottom).offset(16)
            make.height.equalTo(16)
        }
        
        meanSubTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(meanTitleLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            //make.height.equalTo(20)
        }
        
        meanVlaueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(meanTitleLabel)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
        }
        
        updateTimeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(14)
            make.top.equalTo(meanTitleLabel.snp.bottom).offset(58)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(updateTimeLabel.snp.bottom)
            make.height.equalTo(180)
        }
        
        noDataView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.top.equalTo(self.currentVlaueTitleLabel)
        }
    }
    
    func bindModel()  {

    }
    
    @objc func promptButtonAction() {
        let alertView = YXAlertView.init(title: YXLanguageUtility.kLang(key: "stock_estimated_company"), message: nil, prompt: nil, style: .default, messageAlignment: .left)
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.clickedAutoHide = true
        
      
        let attM = NSMutableAttributedString.init()
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = 5
        
        let attributesTitle = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attributesSubTitle = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let peTitle = NSAttributedString.init(string: (YXLanguageUtility.kLang(key: "stock_estimated_pe_title") + "\n"), attributes: attributesTitle)
        let peValue = NSAttributedString.init(string: (YXLanguageUtility.kLang(key: "stock_estimated_pe_sub_title") + "\n\n"), attributes: attributesSubTitle)
        
        let pbTitle = NSAttributedString.init(string: (YXLanguageUtility.kLang(key: "stock_estimated_pb_title") + "\n"), attributes: attributesTitle)
        let pbValue = NSAttributedString.init(string: (YXLanguageUtility.kLang(key: "stock_estimated_pb_sub_title") + "\n\n"), attributes: attributesSubTitle)
        
        let psTitle = NSAttributedString.init(string: (YXLanguageUtility.kLang(key: "stock_estimated_ps_title") + "\n"), attributes: attributesTitle)
        let psValue = NSAttributedString.init(string: (YXLanguageUtility.kLang(key: "stock_estimated_ps_sub_title")), attributes: attributesSubTitle)
        
        attM.append(peTitle)
        attM.append(peValue)
        attM.append(pbTitle)
        attM.append(pbValue)
        attM.append(psTitle)
        attM.append(psValue)
        
        alertView.messageLabel.attributedText = attM
        
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default, handler: { [weak alertView](action) in
            alertView?.hide()
        }))
        alertView.showInWindow()
    }
}
