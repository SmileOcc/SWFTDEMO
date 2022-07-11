//
//  YXStockDetailFinancialCell.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/4/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import YXKit



//折线视图
class YXStockDetailFinancialChartView: UIView {
    
    enum YXFinancialUnitType {
        case tenThousand
        case hundredMillion
        case none
        case million
        case billion
    }
    
    var type: YXStockDetailFinancialType = .profit

    var clickItemBlock: ((_ selectIndex: Int) -> ())?
    
    var isYear = true
    
    var unitTpe: YXFinancialUnitType = .tenThousand
    
    var currentList: [YXFinancialDetailData]?
    
    let topPadding: CGFloat = 45

    let chartPadding: CGFloat = 66

    let chartHeight: CGFloat = 147
    
    let chartView = UIView.init()
    
    lazy var longPressView: YXFinancialLongPressView = {
        var width: CGFloat = 130
        if YXUserManager.isENMode() {
            if self.type == .profit {
                width = 200
            } else {
                width = 165
            }
        }
        let view = YXFinancialLongPressView.init(frame: CGRect.init(x: 0, y: 34, width: width, height: 90), type: self.type)
        view.isHidden = true
        return view
    }()
    
    var margin: CGFloat = 0

    lazy var unitLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") +  ": --"
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()

    lazy var popoverButton: YXStockFinancialPopoverButton = {

        let button = YXStockFinancialPopoverButton()
        button.clickItemBlock = {
            [weak self, weak weakButton = button] selectIndex in
            guard let `self` = self else { return }
            self.clickItemBlock?(selectIndex)

            if let text = weakButton?.titleLabel?.text {

                self.longPressView.currentTitle = text
            }

        }
        return button
    }()
    
    lazy var lineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = QMUITheme().pointColor()
        return view
    }()
    
    lazy var dateLabels: [QMUILabel] = {
        var labels: [QMUILabel] = []
        for x in 0..<4 {
            let lab = QMUILabel()
            lab.text = "--"
            lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            lab.textColor = QMUITheme().textColorLevel3()
            lab.textAlignment = .center
            labels.append(lab)
        }
        return labels
    }()
    
    lazy var blackLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.lineWidth = 0.0
        layer.fillColor = QMUITheme().themeTintColor().cgColor
        layer.strokeColor = QMUITheme().themeTintColor().cgColor
        return layer
    }()
    
    lazy var greenLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.lineWidth = 0.0
        layer.fillColor = financialGreenColor.cgColor
        layer.strokeColor = financialGreenColor.cgColor
        return layer
    }()
    
    lazy var redLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.lineWidth = 1.0
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = financialRedColor.cgColor
        return layer
    }()

    lazy var blackCircleLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.fillColor = QMUITheme().themeTintColor().cgColor
        layer.strokeColor = QMUITheme().themeTintColor().cgColor
        return layer
    }()

    lazy var greenCircleLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.fillColor = financialGreenColor.cgColor
        layer.strokeColor = financialGreenColor.cgColor
        return layer
    }()

    lazy var redCircleLayer: CAShapeLayer = {
        let layer: CAShapeLayer = CAShapeLayer()
        layer.fillColor = financialRedColor.cgColor
        layer.strokeColor = financialRedColor.cgColor
        return layer
    }()
    
    lazy var highestValueLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var halfValueLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var lowestValueLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "--"
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var highestRatioLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "100%"
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var halfRatioLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "50%"
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var lowestRatioLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = "0%"
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    var incomeData: YXFinancialData? {
        
        didSet {

            for i in 0..<self.dateLabels.count {
                self.dateLabels[i].text = ""
            }
            self.currentList = self.incomeData?.list
            //value
            refreshIncomeUI(with: true)
        }
        
    }
    var balanceData: YXFinancialData? {
        
        didSet {

            for i in 0..<self.dateLabels.count {
                self.dateLabels[i].text = ""
            }
            self.currentList = self.balanceData?.list
            //value
            refreshIncomeUI(with: false)
        }
        
    }
    var cashFlow: YXFinancialData? {
        
        didSet {

            for i in 0..<self.dateLabels.count {
                self.dateLabels[i].text = ""
            }
            self.currentList = self.cashFlow?.list
            refreshCashUI()
        }
    }
    
    convenience init(frame: CGRect, type: YXStockDetailFinancialType) {
        self.init(frame: frame)
        self.type = type
        initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        addSubview(unitLabel)
        addSubview(popoverButton)
        addSubview(lineView)
        self.layer.addSublayer(blackLayer)
        self.layer.addSublayer(greenLayer)
        self.layer.addSublayer(redLayer)
        self.layer.addSublayer(blackCircleLayer)
        self.layer.addSublayer(greenCircleLayer)
        self.layer.addSublayer(redCircleLayer)
        addSubview(highestValueLabel)
        addSubview(halfValueLabel)
        addSubview(lowestValueLabel)
        addSubview(highestRatioLabel)
        addSubview(halfRatioLabel)
        addSubview(lowestRatioLabel)
        
        addSubview(chartView)
        
        unitLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(14)
        }

        popoverButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(unitLabel)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.chartPadding)
            make.right.equalToSuperview().offset(-self.chartPadding)
            make.height.equalTo(1)
            make.top.equalToSuperview().offset(191)
        }
        
        let padding_x: CGFloat = self.chartPadding
        let itemWidth: CGFloat = 28
        let dateWidth: CGFloat = (YXConstant.screenWidth - 2 * padding_x) / 4.0
        for x in 0..<dateLabels.count {
            let dateLabel = dateLabels[x]
            addSubview(dateLabel)
            dateLabel.snp.makeConstraints { (make) in
                make.top.equalTo(lineView.snp.bottom).offset(6)
                make.leading.equalToSuperview().offset(padding_x + dateWidth * CGFloat(x))
                make.width.equalTo(dateWidth)
            }
        }
        
        highestValueLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(self.topPadding)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(12)
        }
        
        halfValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.top).offset(self.topPadding + self.chartHeight / 2.0)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(12)
        }
        
        lowestValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.top).offset(self.topPadding + self.chartHeight)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(12)
        }
        
        highestRatioLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(self.topPadding)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(12)
        }
        
        halfRatioLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.top).offset(self.topPadding + self.chartHeight / 2.0)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(12)
        }
        
        lowestRatioLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.top).offset(self.topPadding + self.chartHeight)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(12)
        }
        
        chartView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(self.chartPadding)
            make.trailing.equalToSuperview().offset(-self.chartPadding)
            make.top.equalToSuperview().offset(self.topPadding)
            make.height.equalTo(self.chartHeight)
        }
        
        self.addSubview(pressBlockView)
        
        self.addSubview(longPressView)
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.longPressGestureRecognizerAction(_:)))
        chartView.addGestureRecognizer(longPress)

    }
    
    
    // 营收和总资产
    func refreshIncomeUI(with income: Bool) {
        
        guard var list = self.currentList else { return }
        list.reverse()
        
        //柱状图 & 折线
        let padding_x: CGFloat = self.chartPadding
        let itemWidth: CGFloat = 12 + 12 + 4
        let margin: CGFloat = (YXConstant.screenWidth - 2 * padding_x - 4 * itemWidth) / 4.0

        let blackPath = UIBezierPath()
        let greenPath = UIBezierPath()
        let redPath = UIBezierPath()
        let redCirclePath = UIBezierPath()
        
        var minFirstValue: Float64 = 0
        var maxFirstValue: Float64 = 0
        var minSecondValue: Float64 = 0
        var maxSecondValue: Float64 = 0
        if income {
            minFirstValue = list.first?.operatingIncome ?? 0.00
            maxFirstValue = list.first?.operatingIncome ?? 0.00
            minSecondValue = list.first?.netIncome ?? 0.00
            maxSecondValue = list.first?.netIncome ?? 0.00
        } else{
            minFirstValue = list.first?.totalAssets ?? 0.00
            maxFirstValue = list.first?.totalAssets ?? 0.00
            minSecondValue = list.first?.totalLiabilities ?? 0.00
            maxSecondValue = list.first?.totalLiabilities ?? 0.00
        }
        
        
        var maxRato: Float64 = 0.0
        var minRato: Float64 = 0.0
        
        if abs(maxFirstValue) > 0 {
            maxRato = maxSecondValue / maxFirstValue
        }
        if abs(minFirstValue) > 0 {
            minRato = minSecondValue / minFirstValue
        }
        
        maxRato = max(maxRato, minRato)
        minRato = min(maxRato, minRato)
        
        var maxValue: Float64 = 0.00
        var minValue: Float64 = 0.00
        var midValue: Float64 = 0.00
        
        for i in 0..<list.count {
            var firstValue: Float64 = 0.0
            var secondValue: Float64 = 0.0
            
            if let operaIncome = income ? list[i].operatingIncome : list[i].totalAssets {
                firstValue = operaIncome
            }
            
            if let operaIncome = income ? list[i].netIncome : list[i].totalLiabilities {
                secondValue = operaIncome
            }
            if firstValue < minFirstValue {
                minFirstValue = firstValue
            }
            if secondValue < minSecondValue {
                minSecondValue = secondValue
            }
            if firstValue > maxFirstValue {
                maxFirstValue = firstValue
            }
            if secondValue > maxSecondValue {
                maxSecondValue = secondValue
            }
            var rato: Float64 = 0.0
            if abs(firstValue) > 0 {
                rato = secondValue / firstValue
            }

            if let rate = income ? list[i].retainedProfitsRate : list[i].totalLiabilitiesRate, rate > 0 {
                rato = rate / 100
            }            
            if rato > maxRato {
                maxRato = rato
            }
            if rato < minRato {
                minRato = rato
            }
        }
        
        maxValue = max(maxFirstValue, maxSecondValue)
        minValue = min(minFirstValue, minSecondValue)
        
        var zeroY: CGFloat = self.topPadding + self.chartHeight

        let chartMaxY: CGFloat = self.topPadding + self.chartHeight
        
        if maxValue >= 0 && minValue >= 0 {
            minValue = 0
            midValue = maxValue * 0.5
            zeroY = self.topPadding + self.chartHeight
        } else if maxValue >= 0 && minValue < 0 {
            midValue = (minValue - maxValue) * 0.5 + maxValue
            // 中间刻度
            zeroY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(0), distance: self.chartHeight, zeroY: zeroY)
            
        } else if maxValue < 0 && minValue < 0 {
            maxValue = 0
            midValue = minValue * 0.5
            zeroY = topPadding
        }
        
        if maxRato > 0 && minRato > 0 {
            minRato = 0.0
        }
        
        self.unitTpe = self.calUntiType(with: maxValue, minValue: minValue)
        
        // 在最大值和最小值相等的时候.不画图
        if maxValue == minValue {
            return
        }
        
        for x in 0..<list.count {
            let incomeDetailModel = list[x]
            
            var operaIncomePointY: CGFloat = 0
            var netIncomePointY: CGFloat = 0
            
            var operaIncomeHeight: CGFloat = 0
            var netIncomeHeight: CGFloat = 0
            
            let finalOperatingIncome = income ? incomeDetailModel.operatingIncome : incomeDetailModel.totalAssets
            let finalNetIncome = income ? incomeDetailModel.netIncome : incomeDetailModel.totalLiabilities
            
            if maxValue == 0 {
                // 矩形
                operaIncomePointY = topPadding
                netIncomePointY = topPadding
                operaIncomeHeight = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(finalOperatingIncome ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY - operaIncomePointY)
                netIncomeHeight = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(finalNetIncome ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY - netIncomePointY)
            } else if maxValue >= 0 && minValue < 0 {
                
                let operatingIncome = finalOperatingIncome ?? 0.00
                let netIncome = finalNetIncome ?? 0.00
                if operatingIncome > 0 {
                    operaIncomePointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(0), price: CGFloat(operatingIncome), distance: zeroY - topPadding, zeroY: zeroY)
                    operaIncomeHeight = zeroY - operaIncomePointY
                } else {
                    operaIncomeHeight = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(0), minPrice: CGFloat(minValue), price: CGFloat(operatingIncome), distance: chartMaxY - zeroY, zeroY: chartMaxY - zeroY)
                    operaIncomePointY = zeroY
                }
                
                if netIncome > 0 {
                    netIncomePointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(0), price: CGFloat(netIncome), distance: zeroY - topPadding, zeroY: zeroY)
                    netIncomeHeight = zeroY - netIncomePointY
                } else {
                    netIncomeHeight = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(0), minPrice: CGFloat(minValue), price: CGFloat(netIncome), distance: chartMaxY - zeroY, zeroY: chartMaxY - zeroY)
                    netIncomePointY = zeroY
                }
                
            } else {
                // 矩形
                operaIncomePointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(finalOperatingIncome ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY)
                netIncomePointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(finalNetIncome ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY)
                operaIncomeHeight = chartMaxY - operaIncomePointY
                netIncomeHeight = chartMaxY - netIncomePointY
            }
            
            
            // 折线
            var incomeRatioPointY = 0.0
            if let operatingIncome = finalOperatingIncome, abs(operatingIncome) > 0, let netIncome = finalNetIncome {
                incomeRatioPointY = Double(YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxRato), minPrice: CGFloat(minRato), price: CGFloat(netIncome / operatingIncome), distance: chartMaxY - topPadding, zeroY: chartMaxY))
            } else {
                incomeRatioPointY = Double(YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxRato), minPrice: CGFloat(minRato), price: CGFloat(0), distance: chartMaxY - topPadding, zeroY: chartMaxY))
            }

            let xCoor = padding_x + (margin + itemWidth) * CGFloat(x) + margin / 2.0
            let operaIncomePath = UIBezierPath(roundedRect: CGRect(x: xCoor, y: operaIncomePointY, width: 12.0, height: abs(operaIncomeHeight)), cornerRadius: 2)
            let netIncomePath = UIBezierPath(roundedRect: CGRect(x: xCoor + 4.0 + 12.0, y: netIncomePointY, width: 12.0, height: abs(netIncomeHeight)), cornerRadius: 2)
            
            if x == 0 {
                redPath.move(to: CGPoint(x: xCoor + itemWidth / 2.0, y: CGFloat(incomeRatioPointY)))
            } else {
                redPath.addLine(to: CGPoint(x: xCoor + itemWidth / 2.0, y: CGFloat(incomeRatioPointY)))
            }

            redCirclePath.append(UIBezierPath(roundedRect: CGRect(x: xCoor + itemWidth / 2.0 - 2, y: CGFloat(incomeRatioPointY) - 2.0, width: 4, height: 4), cornerRadius: 2))
            
            blackPath.append(operaIncomePath)
            greenPath.append(netIncomePath)
            
            //日期
            if self.isYear {
                if let year = incomeDetailModel.fiscalYear {
                    self.dateLabels[x].text = "\(year)"
                }
            } else {
                if let year = incomeDetailModel.calendarYear, let quarter = incomeDetailModel.calendarQuarter {
                    self.dateLabels[x].text = "\(year)" + "Q" + "\(quarter)"
                }
            }
        }
        self.blackLayer.path = blackPath.cgPath
        self.greenLayer.path = greenPath.cgPath
        self.redLayer.path = redPath.cgPath;

        self.redCircleLayer.path = redCirclePath.cgPath;
        
        let unit: Float64 = self.getUntiPrice()
        //刻度
        self.highestValueLabel.text = String(format: "%.2f", (maxValue / unit))
        self.lowestValueLabel.text = String(format: "%.2f", (minValue / unit))
        self.halfValueLabel.text = String(format: "%.2f", (midValue / unit))
        
        let midRato = (maxRato + minRato) * 0.5
        // 百分比
        self.highestRatioLabel.text = String(format: "%.2f%@", (maxRato * 100), "%")
        self.halfRatioLabel.text = String(format: "%.2f%@", (midRato * 100), "%")
        self.lowestRatioLabel.text = String(format: "%.2f%@", (minRato * 100), "%")
        
        // 隐藏右边的百分比
        if maxRato == minRato {
            self.highestRatioLabel.isHidden = true
        }
        if midRato == minRato {
            self.halfRatioLabel.isHidden = true
        }
    }
    
    // 现金流
    func refreshCashUI() {
        
        guard var list = self.currentList else { return }
        list.reverse()
        
        //柱状图 & 折线
        let padding_x: CGFloat = self.chartPadding
        let margin: CGFloat = (YXConstant.screenWidth -  2 * padding_x) / 4.0
        let chartMaxY: CGFloat = self.topPadding + self.chartHeight
        let blackPath = UIBezierPath()
        let greenPath = UIBezierPath()
        let redPath = UIBezierPath()

        let blackCirclePath = UIBezierPath()
        let greenCirclePath = UIBezierPath()
        let redCirclePath = UIBezierPath()
        
        var minFirstValue: Float64 = list.first?.cashFromOperations ?? 0.00
        var maxFirstValue: Float64 = list.first?.cashFromOperations ?? 0.00
        var minSecondValue: Float64 = list.first?.cashFromInvesting ?? 0.00
        var maxSecondValue: Float64 = list.first?.cashFromInvesting ?? 0.00
        var minCashFromFinancing: Float64 = list.first?.cashFromFinancing ?? 0.00
        var maxCashFromFinancing: Float64 = list.first?.cashFromFinancing ?? 0.00
        
        var maxValue: Float64 = 0.00
        var minValue: Float64 = 0.00
        var midValue: Float64 = 0.00
        
        for i in 0..<list.count {
            if let operaIncome = list[i].cashFromOperations, operaIncome <= minFirstValue {
                minFirstValue = operaIncome
            }
            if let operaIncome = list[i].cashFromOperations, operaIncome >= maxFirstValue {
                maxFirstValue = operaIncome
            }
            
            if let netIncome = list[i].cashFromInvesting, netIncome <= minSecondValue {
                minSecondValue = netIncome
            }
            if let netIncome = list[i].cashFromInvesting, netIncome >= maxSecondValue {
                maxSecondValue = netIncome
            }
            
            if let cashFromFinancing = list[i].cashFromFinancing, cashFromFinancing <= minCashFromFinancing {
                minCashFromFinancing = cashFromFinancing
            }
            if let cashFromFinancing = list[i].cashFromFinancing, cashFromFinancing >= maxCashFromFinancing {
                maxCashFromFinancing = cashFromFinancing
            }
        }
        
        maxValue = max(maxFirstValue, maxSecondValue, maxCashFromFinancing)
        minValue = min(minFirstValue, minSecondValue, minCashFromFinancing)
        
        if maxValue > 0 && minValue >= 0 {
            minValue = 0
            midValue = maxValue * 0.5
        } else if maxValue > 0 && minValue < 0 {
            midValue = 0
            
            // 中间刻度
            let midY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(midValue), distance: chartMaxY - topPadding, zeroY: chartMaxY)
            if (midY > chartMaxY - 30) || midY < (topPadding + 30) {
                self.halfValueLabel.isHidden = true
            } else {
                self.halfValueLabel.isHidden = false
                self.halfValueLabel.snp.updateConstraints { (make) in
                    make.centerY.equalTo(self.snp.top).offset(centerY)
                }
            }
            
        } else {
            midValue = minValue * 0.5
        }
        
        self.unitTpe = self.calUntiType(with: maxValue, minValue: minValue)
        
        // 在最大值和最小值相等的时候.不画图
        if maxValue == minValue {
            return
        }
        
        for x in 0..<list.count {
            
            let incomeDetailModel = list[x]
            let operaIncomePointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(incomeDetailModel.cashFromOperations ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY)
            let netIncomePointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(incomeDetailModel.cashFromInvesting ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY)
            let cashFromFinancingPointY = YXKLineUtility.getYCoordinate(withMaxPrice: CGFloat(maxValue), minPrice: CGFloat(minValue), price: CGFloat(incomeDetailModel.cashFromFinancing ?? 0.00), distance: chartMaxY - topPadding, zeroY: chartMaxY)

            let xcoor: CGFloat = padding_x + margin * CGFloat(x) + margin / 2.0
            if x == 0 {
                redPath.move(to: CGPoint(x: xcoor, y: CGFloat(cashFromFinancingPointY)))
                blackPath.move(to: CGPoint(x: xcoor, y: operaIncomePointY))
                greenPath.move(to: CGPoint(x: xcoor, y: netIncomePointY))
            } else {
                redPath.addLine(to: CGPoint(x: xcoor, y: CGFloat(cashFromFinancingPointY)))
                blackPath.addLine(to: CGPoint(x: xcoor, y: operaIncomePointY))
                greenPath.addLine(to: CGPoint(x: xcoor, y: netIncomePointY))
            }

            redCirclePath.append(UIBezierPath(roundedRect: CGRect(x: xcoor - 2, y: CGFloat(cashFromFinancingPointY) - 2.0, width: 4, height: 4), cornerRadius: 2))
            blackCirclePath.append(UIBezierPath(roundedRect: CGRect(x: xcoor - 2, y: operaIncomePointY - 2, width: 4, height: 4), cornerRadius: 2))
            greenCirclePath.append(UIBezierPath(roundedRect: CGRect(x: xcoor - 2, y: netIncomePointY - 2, width: 4, height: 4), cornerRadius: 2))
            // 日期
            if self.isYear {
                if let year = incomeDetailModel.fiscalYear {
                    self.dateLabels[x].text = "\(year)"
                }
            } else {
                if let year = incomeDetailModel.calendarYear, let quarter = incomeDetailModel.calendarQuarter {
                    self.dateLabels[x].text = "\(year)" + "Q" + "\(quarter)"
                }
            }
        }
        
        self.blackLayer.fillColor = UIColor.clear.cgColor
        self.blackLayer.lineWidth = 1.0
        self.blackLayer.strokeColor = QMUITheme().themeTintColor().cgColor
        self.greenLayer.fillColor = UIColor.clear.cgColor
        self.greenLayer.lineWidth = 1.0
        self.greenLayer.strokeColor = financialGreenColor.cgColor

        self.blackLayer.path = blackPath.cgPath
        self.greenLayer.path = greenPath.cgPath
        self.redLayer.path = redPath.cgPath;

        self.blackCircleLayer.path = blackCirclePath.cgPath
        self.greenCircleLayer.path = greenCirclePath.cgPath
        self.redCircleLayer.path = redCirclePath.cgPath;
        
        self.highestRatioLabel.isHidden = true
        self.halfRatioLabel.isHidden = true
        self.lowestRatioLabel.isHidden = true

        let unit: Float64 = self.getUntiPrice()
        //刻度
        self.highestValueLabel.text = String(format: "%.2f", (maxValue / unit))
        self.halfValueLabel.text = String(format: "%.2f", (midValue / unit))
        self.lowestValueLabel.text = String(format: "%.2f", (minValue / unit))
        
    }
    

    func calUntiType(with maxValue: Float64, minValue: Float64) -> YXFinancialUnitType {
        var type: YXFinancialUnitType = .none
        
        var maxValue = maxValue
        var minValue = minValue
        if let model = self.currentList?.first, model.isHS {
            maxValue = maxValue / 1000000
            minValue = minValue / 1000000
        }
        
        if YXUserManager.isENMode() {
            if abs(maxValue) >= 1000 || abs(minValue) >= 1000 {
                type = .billion
            } else if abs(maxValue) >= 1 || abs(minValue) >= 1 {
                type = .million
            }
        } else {
            if abs(maxValue) >= 100 || abs(minValue) >= 100 {
                type = .hundredMillion
            } else if (0.01 <= abs(maxValue) && abs(maxValue) <= 100) || (0.01 <= abs(minValue) && abs(minValue) <= 100) {
                type = .tenThousand
            } else if (0 < abs(maxValue) && abs(maxValue) < 0.01) || (0 < abs(minValue) && abs(minValue) < 0.01) {
                type = .none
            }
        }
        return type
    }
    
    func getUntiPrice() -> Float64 {
        var unit: Float64 = 1
        if let model = self.currentList?.first, model.isHS {
            switch self.unitTpe {
            case .none:
                unit = 1
            case .tenThousand:
                unit = 10000
            case .hundredMillion:
                unit = 100000000
            case .billion:
                unit = 1000000
            case .million:
                unit = 1000000000
            }
        } else {
            switch self.unitTpe {
            case .none:
                unit = 0.000001
            case .tenThousand:
                unit = 0.01
            case .hundredMillion:
                unit = 100
            case .billion:
                unit = 1000
            case .million:
                unit = 1
            }
        }
        return unit
    }
    
    @objc func longPressGestureRecognizerAction(_ gesture: UILongPressGestureRecognizer) {
        
        guard var list = self.currentList, list.count > 0 else { return }
        list.reverse()
        
        let point = gesture.location(in: self)
        let margin = (YXConstant.screenWidth - 2 * chartPadding) / 4.0
        let doubleIndex = (point.x - self.chartPadding) / margin
        var index = NSInteger.init(doubleIndex)
        
        if index > list.count - 1 {
            index = list.count - 1
        }
//        padding_x + (margin + itemWidth) * CGFloat(x) + margin / 2.0
        let xCoor = self.chartPadding + (margin) * CGFloat(index) + margin / 2.0
        if gesture.state == .changed || gesture.state == .began {
            
            if self.longPressView.mj_w > (self.mj_w * 0.5) {
                self.longPressView.mj_x = self.lineView.mj_x
            } else {
                if index < 2 {
                    self.longPressView.mj_x = chartPadding + 2 * margin
                } else {
                    self.longPressView.mj_x = self.lineView.mj_x
                }
            }            
            let model = list[index]
            self.longPressView.isYear = self.isYear
            self.longPressView.model = model
            self.longPressView.isHidden = false
            pressBlockView.mj_x = xCoor - self.pressBlockView.mj_w * 0.5
            pressBlockView.isHidden = false
        } else if gesture.state == .ended {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.longPressView.isHidden = true
                self.pressBlockView.isHidden = true
            }
        }
    }
    
    lazy var pressBlockView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: self.topPadding, width: 32, height: chartHeight))
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.04)
        view.isHidden = true
        return view
    }()
    
}
