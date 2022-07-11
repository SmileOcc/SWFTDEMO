//
//  YXKlineVSView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXKlineVSView: UIView {
    var isLongPressing: Bool = false
    @objc var isLandscape: Bool = false
    @objc init(frame: CGRect, isLandscape: Bool) {
        super.init(frame: frame)
        self.isLandscape = isLandscape
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var verticalDashLineLayer: CAShapeLayer = {
       let layer = CAShapeLayer()
        layer.lineDashPattern = [NSNumber(3),NSNumber(2)]
        layer.strokeColor = QMUITheme().textColorLevel3().cgColor
        return layer
    }()
    
    lazy var horzionDashLineLayer: CAShapeLayer = {
       let layer = CAShapeLayer()
        layer.lineDashPattern = [NSNumber(3),NSNumber(2)]
        layer.strokeColor = QMUITheme().textColorLevel3().cgColor
        return layer
    }()
    
    
    lazy var detailView:YXKlineVSDetailView = {
        let detailView = YXKlineVSDetailView.init(frame: CGRect.zero)
        detailView.backgroundColor = QMUITheme().foregroundColor()
//        detailView.layer.borderWidth = 0.5
        detailView.layer.borderColor = QMUITheme().textColorLevel3().cgColor
//        detailView.alpha = 0;
        detailView.isHidden = true
        detailView.layer.cornerRadius = 4;
//        detailView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        detailView.layer.shadowColor = UIColor.init(red: 136/255.0, green: 137/255.0, blue: 150/255.0, alpha: 0.25).cgColor
        detailView.layer.shadowOpacity = 1;
        detailView.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailView.layer.shadowRadius = 4;
//        detailView.clipsToBounds = true
//
//        CALayer *subLayer=[CALayer layer];
//        CGRect fixframe = _tableView.frame;
//        subLayer.frame= fixframe;
//        subLayer.cornerRadius=8;
//        subLayer.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
//        subLayer.masksToBounds=NO;
//        subLayer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
//        subLayer.shadowOffset = CGSizeMake(3,2);//shadowOffset阴影偏移,x向右偏移3，y向下偏移2，默认(0, -3),这个跟shadowRadius配合使用
//        subLayer.shadowOpacity = 0.8;//阴影透明度，默认0
//        subLayer.shadowRadius = 4;//阴影半径，默认3
//        [self.bkgView.layer insertSublayer:subLayer below:_tableView.layer];

        return detailView
    }()
    
    lazy var crossingLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05).cgColor
        layer.lineWidth = 0.5
        layer.lineCap = .square
        //layer.lineJoin = .bevel
        return layer
    }()


    lazy var firstLegendView: YXKlineVSSubTitleView = {
        let view = YXKlineVSSubTitleView(frame: .zero, isLandscape: self.isLandscape)
        view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#0C9CC5")
        view.isHidden = true
        return view
    }()

    lazy var secondLegendView: YXKlineVSSubTitleView = {
        let view = YXKlineVSSubTitleView(frame: .zero, isLandscape: self.isLandscape)
        view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#944EFF")
        view.isHidden = true
        return view
    }()

    lazy var thirdLegendView: YXKlineVSSubTitleView = {
        let view = YXKlineVSSubTitleView(frame: .zero, isLandscape: self.isLandscape)
        view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#FFC034")
        view.isHidden = true
        return view
    }()

    lazy var firstLineLayer: CAShapeLayer = {
        return createShapeLayer(color: UIColor.qmui_color(withHexString: "#0C9CC5"))
    }()

    lazy var secondLineLayer: CAShapeLayer = {
        return createShapeLayer(color: UIColor.qmui_color(withHexString: "#944EFF"))
    }()

    lazy var thirdLineLayer: CAShapeLayer = {
        return createShapeLayer(color: UIColor.qmui_color(withHexString: "#FFC034"))
    }()
    
    lazy var zeroLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05).cgColor
        layer.lineWidth = 1.0
        layer.lineCap = .square
        //layer.lineJoin = .bevel
        return layer
        
    }()

    func createShapeLayer(color: UIColor?) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color?.cgColor
        layer.isHidden = true
        layer.lineWidth = 1.0
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }

    lazy var maxRatioLabel: UILabel = {

        return createRatioLabel()
    }()

    lazy var subMaxRatioLabel: UILabel = {

        return createRatioLabel()
    }()

    lazy var subMinRatioLabel: UILabel = {

        return createRatioLabel()
    }()

    lazy var minRatioLabel: UILabel = {

        return createRatioLabel()
    }()

    func createRatioLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 10)
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }

    lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .left
        return label
    }()

    lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()
    
    lazy var timeLabel1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .left
        return label
    }()
    lazy var timeLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .left
        return label
    }()
    lazy var timeLabel3: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }()
    lazy var timeLabel4: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }()
    lazy var timeLabel5: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.45)
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .right
        return label
    }()
    
    lazy var selectTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "2021-00-00"
        label.textColor = QMUITheme().longPressTextColor()
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.backgroundColor = QMUITheme().longPressBgColor()
        label.isHidden = true
        label.layer.cornerRadius = 2.0
//        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var selectRatioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "0.00%"
        label.textColor = QMUITheme().longPressTextColor()
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.backgroundColor = QMUITheme().longPressBgColor()
        label.isHidden = true
        label.layer.cornerRadius = 2.0
//        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var timeStackView:UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

    var pointCount = 220
    var pointMargin: CGFloat = 0
    var chartRect: CGRect = .zero
    var matchDictionary: [String : CAShapeLayer] = [:]
    var allLinehighestRatio: CGFloat = 0 //最大涨幅
    var allLinelowestRatio: CGFloat = 0 //最小涨幅
    
    var zeroPoint: CGPoint? //0点坐标
    var isDrawzZeroLine: Bool = false//是否已经画过了0线
    let zerolinePath = UIBezierPath()

    
    @objc func removeItem(_ item: YXSecu) {
        let key = item.market + item.symbol
        if let layer = matchDictionary[key] {
            layer.isHidden = true
            layer.path = nil
            matchDictionary.removeValue(forKey: key)
        }
    }

    @objc func clean() {
        matchDictionary.removeAll()
        firstLineLayer.isHidden = true
        firstLineLayer.path = nil
        
        secondLineLayer.isHidden = true
        secondLineLayer.path = nil

        thirdLineLayer.isHidden = true
        thirdLineLayer.path = nil
    }

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        var leftDateMargin: CGFloat = 50
        if isLandscape {
            let topMargin: CGFloat = 60
            let bottomMargin: CGFloat = 38
            var leftMargin: CGFloat = 16

            if YXConstant.deviceScaleEqualToXStyle() {
                leftMargin = YXConstant.statusBarHeight()
            }
            let width = YXConstant.screenHeight - leftMargin * 2 - leftDateMargin
            let height = YXConstant.screenWidth - topMargin - bottomMargin - 48

            self.chartRect = CGRect(x: leftMargin + leftDateMargin, y: topMargin, width: width, height: height)
        } else {

            self.chartRect = CGRect(x: 12 + leftDateMargin, y: 42, width: YXConstant.screenWidth - 24 - leftDateMargin, height: 200)
        }

        self.layer.addSublayer(self.crossingLineLayer)
        self.layer.addSublayer(zeroLineLayer)
        self.layer.addSublayer(firstLineLayer)
        self.layer.addSublayer(secondLineLayer)
        self.layer.addSublayer(thirdLineLayer)

        addSubview(firstLegendView)
        addSubview(secondLegendView)
        addSubview(thirdLegendView)
        
        addSubview(detailView)
        
        if isLandscape {
            let width = min(YXConstant.screenWidth, YXConstant.screenHeight)
            let scale = width / 375.0;
            firstLegendView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(self.chartRect.minX - leftDateMargin)
                make.top.equalToSuperview().offset(20)
                make.height.equalTo(22)
                if width == 320 {
                    make.width.lessThanOrEqualTo(160)
                } else {
                    make.width.lessThanOrEqualTo(190 * scale)
                }
            }

            secondLegendView.snp.makeConstraints { (make) in
                make.left.equalTo(firstLegendView.snp.right).offset(40)
                make.top.equalToSuperview().offset(20)
                make.height.equalTo(22)
                if width == 320 {
                    make.width.lessThanOrEqualTo(160)
                } else {
                    make.width.lessThanOrEqualTo(190 * scale)
                }
            }

            thirdLegendView.snp.makeConstraints { (make) in
                make.left.equalTo(secondLegendView.snp.right).offset(40)
                make.top.equalToSuperview().offset(20)
                make.height.equalTo(22)
                if width == 320 {
                    make.width.lessThanOrEqualTo(160)
                } else {
                    make.width.lessThanOrEqualTo(190 * scale)
                }
            }
            
            self.detailView.snp.remakeConstraints { make in
                make.height.equalTo(220)
                make.left.equalToSuperview().offset(self.chartRect.minX + 6.0)
                make.top.equalToSuperview().offset(self.chartRect.minY + 3.0)
                make.width.equalTo(137)
            }
            
        } else {
            firstLegendView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(self.chartRect.minX)
                make.top.equalToSuperview()
                make.height.equalTo(41)
                make.width.equalTo(90)
            }

            secondLegendView.snp.makeConstraints { (make) in
                make.left.equalTo(firstLegendView.snp.right).offset(10)
                make.top.equalToSuperview()
                make.height.equalTo(41)
                make.width.equalTo(90)
            }

            thirdLegendView.snp.makeConstraints { (make) in
                make.left.equalTo(secondLegendView.snp.right).offset(10)
                make.top.equalToSuperview()
                make.height.equalTo(41)
                make.width.equalTo(90)
            }
            
            self.detailView.snp.makeConstraints { (make) in
                make.height.equalTo(150)
                make.left.equalToSuperview().offset(self.chartRect.minX + 6.0 + 100)
                make.top.equalToSuperview().offset(self.chartRect.minY + 3.0)
                make.width.equalTo(90)
            }
        }

        self.addSubview(maxRatioLabel)
        self.addSubview(subMaxRatioLabel)
        self.addSubview(subMinRatioLabel)
        self.addSubview(minRatioLabel)

        let verticalMargin = self.chartRect.height / 3.0
//        maxRatioLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.chartRect.minX + 5.0)
//            make.top.equalToSuperview().offset(self.chartRect.minY + 3.0)
//            make.height.equalTo(17)
//        }
//
//        subMaxRatioLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.chartRect.minX + 5.0)
//            make.top.equalToSuperview().offset(self.chartRect.minY + verticalMargin + 3.0)
//            make.height.equalTo(17)
//        }
//
//        subMinRatioLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.chartRect.minX + 5.0)
//            make.top.equalToSuperview().offset(self.chartRect.minY + verticalMargin * 2.0 + 3.0)
//            make.height.equalTo(17)
//        }
//
//        minRatioLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.chartRect.minX + 5.0)
//            make.top.equalToSuperview().offset(self.chartRect.maxY - 3.0 - 17.0)
//            make.height.equalTo(17)
//        }
        
        maxRatioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.chartRect.minX - leftDateMargin)
            make.top.equalToSuperview().offset(self.chartRect.minY - 10)
            make.height.equalTo(20)
        }

        subMaxRatioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.chartRect.minX - leftDateMargin)
            make.top.equalToSuperview().offset(self.chartRect.minY + verticalMargin - 10)
            make.height.equalTo(20)
        }

        subMinRatioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.chartRect.minX - leftDateMargin)
            make.top.equalToSuperview().offset(self.chartRect.minY + verticalMargin * 2.0 - 10)
            make.height.equalTo(17)
        }

        minRatioLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.chartRect.minX - leftDateMargin)
            make.top.equalToSuperview().offset(self.chartRect.maxY - 10)
            make.height.equalTo(20)
        }

//        addSubview(startTimeLabel)
//        addSubview(endTimeLabel)
        addSubview(selectTimeLabel)
        addSubview(selectRatioLabel)
        
        
        timeStackView.addArrangedSubview(timeLabel1)
        timeStackView.addArrangedSubview(timeLabel2)
        timeStackView.addArrangedSubview(timeLabel3)
        timeStackView.addArrangedSubview(timeLabel4)
        timeStackView.addArrangedSubview(timeLabel5)

        addSubview(timeStackView)
        
        
//        startTimeLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.chartRect.minX + 6.0)
//            make.top.equalToSuperview().offset(self.chartRect.maxY + 5.0)
//        }
//
//        endTimeLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(self.chartRect.maxX - 6.0 - 150.0)
//            make.top.equalToSuperview().offset(self.chartRect.maxY + 5.0)
//            make.width.equalTo(150)
//        }
        
        timeStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(self.chartRect.minX)
            make.top.equalToSuperview().offset(self.chartRect.maxY + 5.0)
            make.width.equalTo(self.chartRect.width)
            make.height.equalTo(15)
        }
        
        selectTimeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(self.chartRect.maxY + 5.0)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
        
        selectRatioLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(self.chartRect.minX)
            make.width.equalTo(50)
            make.height.equalTo(20)
        }

        drawCrossingLayer()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
        longPress.minimumPressDuration = 0.25
        longPress.delegate = self
        self.addGestureRecognizer(longPress)
    }
    
    @objc func longPressAction(sender:UILongPressGestureRecognizer) {
        self.bringSubviewToFront(self.detailView)
        let originX = self.chartRect.minX
        let endX = self.chartRect.maxX
        let endY = self.chartRect.maxY

        let dataSource = YXKlineVSTool.shared.selectList
        // x轴宽度
//        let width = max(YXConstant.screenWidth, YXConstant.screenHeight)
        var dataCount = 2
        for item in dataSource {
            if item.closePriceAfterCalculateKlineList.count > dataCount {
                dataCount = item.closePriceAfterCalculateKlineList.count
            }
        }
        
        let xAxisSpace = self.chartRect.width / CGFloat(dataCount - 1)

        switch sender.state {
        case .began,.changed:
            self.isLongPressing = true
            let touchPoint = sender .location(in: self)
            let x = min(max(self.chartRect.minX, touchPoint.x),endX)
            let y = min(max(self.chartRect.minY, touchPoint.y),endY)

           let index = min(max((NSInteger)(floor(((x - originX) / xAxisSpace))),0),dataCount-1)
            
            var data1:YXVSSearchModel?
            var line1:YXKLine?
            var data2:YXVSSearchModel?
            var line2:YXKLine?
            var data3:YXVSSearchModel?
            var line3:YXKLine?

            for (ind,item) in dataSource.enumerated() {
                if ind == 0 {
                    line1 = item.closePriceAfterCalculateKlineList[index]
                    data1 = item
                } else if ind == 1 {
                    line2 = item.closePriceAfterCalculateKlineList[index]
                    data2 = item
                } else if ind == 2 {
                    line3 = item.closePriceAfterCalculateKlineList[index]
                    data3 = item
                }
            }
            
            self.detailView.resetDeatilView(data1: data1, data2: data2, data3: data3, lineData1: line1, lineData2: line2, lineData3: line3)
            self.drawDashLine(point: CGPoint.init(x: x, y: y), index: index, drawInLeft: (index > dataCount / 2))
            
            self.selectTimeLabel.frame = CGRect.init(x: x - 40, y: self.chartRect.maxY, width: 80, height: 20)
            self.selectTimeLabel.isHidden = false
            
            if let line = line1 {
                self.selectTimeLabel.text = YXDateHelper.commonDateStringWithNumber(line.latestTime?.value ?? 0)
            } else if let line = line2 {
                self.selectTimeLabel.text = YXDateHelper.commonDateStringWithNumber(line.latestTime?.value ?? 0)
            } else if let line = line3 {
                self.selectTimeLabel.text = YXDateHelper.commonDateStringWithNumber(line.latestTime?.value ?? 0)
            }
            
                
            self.selectRatioLabel.frame = CGRect.init(x: self.chartRect.minX - 50, y: y - 10, width: 50, height: 20)
            self.selectRatioLabel.isHidden = false
            
            if let zpoint = zeroPoint {
                let zeroY = zpoint.y
                let touchY = y
                let distanceY = -(Double(touchY - zeroY))
                let distance = Double((self.allLinehighestRatio - self.allLinelowestRatio) / (self.chartRect.maxY - self.chartRect.minY))
                let absratio = distanceY * distance

                self.selectRatioLabel.text = String.init(format: "%.2lf%%", absratio * 100)
            }

            
        case .ended:
            self.isLongPressing = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.removeDrawDashLine()
            }
            break
        default:
            break
        }
    }

    func drawDashLine(point: CGPoint, index:NSInteger, drawInLeft:Bool) {
        self.verticalDashLineLayer.removeFromSuperlayer()
        self.verticalDashLineLayer.path = nil
        self.horzionDashLineLayer.removeFromSuperlayer()
        self.horzionDashLineLayer.path = nil
        self.detailView.alpha = 1
        self.detailView.isHidden = false
        
        let linePath = UIBezierPath()
        
        let verPoint = CGPoint.init(x: point.x, y: self.chartRect.minY)
        let verPath = UIBezierPath()
        verPath.lineWidth = 4
        verPath.move(to: verPoint)
        verPath.addLine(to: CGPoint.init(x: point.x, y: self.chartRect.maxY))
        
        let horPoint = CGPoint.init(x:self.chartRect.minX, y: point.y)
        let horPath = UIBezierPath()
        horPath.lineWidth = 4
        horPath.move(to: horPoint)
        horPath.addLine(to: CGPoint.init(x: self.chartRect.maxX, y: point.y))

        linePath.append(verPath)
        linePath.append(horPath)

                
        self.verticalDashLineLayer.path = linePath.cgPath
        self.layer.insertSublayer(self.verticalDashLineLayer, below: self.detailView.layer)
        
        if drawInLeft {
            self.detailView.snp.remakeConstraints { make in
                make.height.equalTo(220)
                make.left.equalToSuperview().offset(self.chartRect.minX + 6.0)
                make.top.equalToSuperview().offset(self.chartRect.minY + 3.0)
                make.width.equalTo(137)
            }
            self.layoutIfNeeded()
        } else {
            self.detailView.snp.remakeConstraints { make in
                make.height.equalTo(220)
                make.right.equalTo(self.snp.right).offset(-self.chartRect.minX + 50)
                make.top.equalToSuperview().offset(self.chartRect.minY + 3.0)
                make.width.equalTo(137)
            }
            self.layoutIfNeeded()
        }
    }
    func removeDrawDashLine () {
        if self.isLongPressing == false {
            self.detailView.isHidden = true
            self.detailView.alpha = 0
            self.verticalDashLineLayer.removeFromSuperlayer()
            self.verticalDashLineLayer.path = nil
            
            self.horzionDashLineLayer.removeFromSuperlayer()
            self.horzionDashLineLayer.path = nil
            self.selectTimeLabel.isHidden = true
            self.selectRatioLabel.isHidden = true
        }
    }
    //画网格线
    @objc func drawCrossingLayer() {
        let linePath = UIBezierPath()

        let minX = self.chartRect.minX
        let maxX = self.chartRect.maxX
        let minY = self.chartRect.minY
        let maxY = self.chartRect.maxY
        let horizonMargin = (maxY - minY) / 3.0
        let verticalMargin = (maxX - minX) / 4.0

        for i in 0..<4 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: minX, y: minY + horizonMargin * CGFloat(i)))
            path.addLine(to: CGPoint(x: maxX, y:minY + horizonMargin * CGFloat(i)))
            linePath.append(path)
        }

//        for i in 0...4 {
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: minX + verticalMargin * CGFloat(i), y: minY))
//            path.addLine(to: CGPoint(x: minX + verticalMargin * CGFloat(i), y: maxY))
//            linePath.append(path)
//        }

        self.crossingLineLayer.path = linePath.cgPath
    }

    //画
    @objc func refreshUI() {
        
        pointCount = 2;
        for item in YXKlineVSTool.shared.selectList {
            let count = item.closePriceList.count;
            if count > 0, pointCount < count {
                pointCount = count
            }
        }

        pointMargin = self.chartRect.width / CGFloat(pointCount - 1)

        let firstItem = YXKlineVSTool.shared.selectList.first ?? YXVSSearchModel()
        var highestRatio: CGFloat = firstItem.highestRatio
        var lowestRatio: CGFloat = firstItem.lowestRatio
        var startTime: UInt64 = firstItem.startTime
        var endTime: UInt64 = firstItem.endTime

        let chartHeight = self.chartRect.height;
        let zeroY = self.chartRect.maxY
        let maxX = self.chartRect.maxX

        firstLegendView.isHidden = true
        secondLegendView.isHidden = true
        thirdLegendView.isHidden = true

        let titleViewArray = [firstLegendView, secondLegendView, thirdLegendView]

        //确认最大，最小值
        for item in YXKlineVSTool.shared.selectList {

            if highestRatio < item.highestRatio {
                highestRatio = item.highestRatio
            }

            if lowestRatio > item.lowestRatio {
                lowestRatio = item.lowestRatio
            }

            if item.startTime > 0, (startTime > item.startTime || startTime == 0) {
                startTime = item.startTime
            }

            if item.endTime > 0, (endTime < item.endTime || endTime == 0)  {
                endTime = item.endTime
            }
        }

        //画图
        for (index, item) in YXKlineVSTool.shared.selectList.enumerated() {

            let key = item.marketSymbol
            var shapeLayer: CAShapeLayer?
            if let layer = matchDictionary[key] {
                shapeLayer = layer
            }

            if shapeLayer == nil {
                if firstLineLayer.isHidden == true {
                    shapeLayer = firstLineLayer
                } else if secondLineLayer.isHidden == true {
                    shapeLayer = secondLineLayer
                } else {
                    shapeLayer = thirdLineLayer
                }

                matchDictionary[key] = shapeLayer
                shapeLayer?.isHidden = false
            }

            //存在YXKlineVSTool.shared.selectList 数组中有数据，但是K线接口还没回来的情况
            //K线数据没回来先不画，正常展示

            //标题展示
            if index < titleViewArray.count {
                let view = titleViewArray[index]
                view.isHidden = false
                view.titleLabel.text = item.secu.name

                view.ratioLabel.text = ratioText(item.historyRatio)
                view.ratioLabel.textColor = YXToolUtility.stockChangeColor(Double(item.historyRatio))

                if shapeLayer == firstLineLayer {
                    view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#0C9CC5")
                } else if shapeLayer == secondLineLayer {
                    view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#944EFF")
                } else {
                    view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#FFC034")
                }
            }

            //价格线展示
            let firstPrice = item.closePriceList.first ?? 0.0
            if item.closePriceList.count > 0, firstPrice != 0 {
                let path  = UIBezierPath()

                for (index, price) in item.closePriceList.reversed().enumerated() {

                    let closeY = YXKLineUtility.getYCoordinate(withMaxPrice: highestRatio, minPrice: lowestRatio, price: (price - firstPrice) / firstPrice, distance: chartHeight, zeroY: zeroY)
                    let closeX = maxX - CGFloat(index) * self.pointMargin

                    if index == 0 {
                        path.move(to: CGPoint(x: closeX, y: closeY))
                    } else {
                        path.addLine(to: CGPoint(x: closeX, y: closeY))
                    }
                }

                shapeLayer?.path = path.cgPath
            }

        }

        let difference = (highestRatio - lowestRatio) / 3.0

        maxRatioLabel.text = ratioText(highestRatio)
        maxRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(highestRatio))

        subMaxRatioLabel.text = ratioText(highestRatio - difference)
        subMaxRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(highestRatio - difference))

        subMinRatioLabel.text = ratioText(highestRatio - 2.0 * difference)
        subMinRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(highestRatio - 2.0 * difference))

        minRatioLabel.text = ratioText(lowestRatio)
        minRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(lowestRatio))

        if startTime > 0 {
            let startDateModel = YXDateToolUtility.dateTime(withTimeValue: TimeInterval(startTime))
            startTimeLabel.text = startDateModel.year + "-" + startDateModel.month + "-" + startDateModel.day
        } else {
            startTimeLabel.text = "--"
        }

        if endTime > 0 {
            let endDateModel = YXDateToolUtility.dateTime(withTimeValue: TimeInterval(endTime))
            endTimeLabel.text = endDateModel.year + "-" + endDateModel.month + "-" + endDateModel.day
        } else {
            endTimeLabel.text = "--"
        }

    }
    
    //画经过处理的UI
    @objc func refreshAfterCalculatelSelectListUI() {
        
        pointCount = 2;
        for item in YXKlineVSTool.shared.selectList {
            let count = item.closePriceAfterCalculateKlineList.count;
            if count > 0, pointCount < count {
                pointCount = count
            }
        }

        pointMargin = self.chartRect.width / CGFloat(pointCount - 1)

        let firstItem = YXKlineVSTool.shared.selectList.first ?? YXVSSearchModel()
        var timeItem:YXVSSearchModel?
        
        var highestRatio: CGFloat = firstItem.highestRatio
        var lowestRatio: CGFloat = firstItem.lowestRatio
        
        allLinehighestRatio = firstItem.highestRatio
        allLinelowestRatio = firstItem.lowestRatio
        
        var startTime: UInt64 = firstItem.startTime
        var endTime: UInt64 = firstItem.endTime

        let chartHeight = self.chartRect.height;
        let zeroY = self.chartRect.maxY
        let maxX = self.chartRect.maxX

        firstLegendView.isHidden = true
        secondLegendView.isHidden = true
        thirdLegendView.isHidden = true

        let titleViewArray = [firstLegendView, secondLegendView, thirdLegendView]

        //确认最大，最小值
        for item in YXKlineVSTool.shared.selectList {
            timeItem = item

            if allLinehighestRatio < item.highestRatio {
                allLinehighestRatio = item.highestRatio
            }

            if allLinelowestRatio > item.lowestRatio {
                allLinelowestRatio = item.lowestRatio
            }

            if item.startTime > 0, (startTime > item.startTime || startTime == 0) {
                startTime = item.startTime
            }

            if item.endTime > 0, (endTime < item.endTime || endTime == 0)  {
                endTime = item.endTime
                timeItem = item
            }
        }

        //画图
        var maxPriceNum = 0 //三个对比价格数组中最大的数量
        for (index, item) in YXKlineVSTool.shared.selectList.enumerated() {
            if maxPriceNum < item.closePriceList.count {
                maxPriceNum = item.closePriceList.count
            }
            
            let key = item.marketSymbol
            var shapeLayer: CAShapeLayer?
            var strokeColor = UIColor.clear
            if let layer = matchDictionary[key] {
                shapeLayer = layer
            }

            if shapeLayer == nil {
                if firstLineLayer.isHidden == true {
                    shapeLayer = firstLineLayer
                    strokeColor = UIColor(cgColor: firstLineLayer.strokeColor ?? UIColor.clear.cgColor)
                } else if secondLineLayer.isHidden == true {
                    shapeLayer = secondLineLayer
                    strokeColor = UIColor(cgColor: secondLineLayer.strokeColor ?? UIColor.clear.cgColor)
                } else {
                    shapeLayer = thirdLineLayer
                    strokeColor = UIColor(cgColor: thirdLineLayer.strokeColor ?? UIColor.clear.cgColor)
                }

                matchDictionary[key] = shapeLayer
                shapeLayer?.isHidden = false
            }

            //存在YXKlineVSTool.shared.selectList 数组中有数据，但是K线接口还没回来的情况
            //K线数据没回来先不画，正常展示
            //标题展示
            if index < titleViewArray.count {
                let view = titleViewArray[index]
                view.isHidden = false
                view.titleLabel.text = item.secu.name

                view.ratioLabel.text = ratioText(item.historyRatio)
                view.ratioLabel.textColor = YXToolUtility.stockChangeColor(Double(item.historyRatio))

                if shapeLayer == firstLineLayer {
                    view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#0C9CC5")
                } else if shapeLayer == secondLineLayer {
                    view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#944EFF")
                } else {
                    view.colorView.backgroundColor = UIColor.qmui_color(withHexString: "#FFC034")
                }
            }
            
            //价格 = (CGFloat(close) / priceBasic)

            let firstPrice = item.closePriceList.first ?? 0.0
            let priceBasic = item.priceBasic
            /* 第一个点不用计算，直接取价格数组的第一个点，不能取构建的数组的第一个点，因为那个点可能不存在
             let firstClose = item.closePriceList.first??.close?.doubleValue ?? 0.0
             let priceBasic = item.priceBasic
             var firstPrice = CGFloat(0)
             if priceBasic != 0 {
                 firstPrice = (CGFloat(firstClose) / priceBasic)
             }
             */
            //用经过计算的点位来画线
            if item.closePriceAfterCalculateKlineList.count > 0 {
                let path  = UIBezierPath()
                var lastItempriceIsZeroOrNil = false
                for (index1, indexItem) in item.closePriceAfterCalculateKlineList.reversed().enumerated() {
                    
                    //算出每个点的价格
                    let close = indexItem?.close?.value ?? 0
                    let basic = item.priceBasic
                    var itemprice = CGFloat(0)
                    if priceBasic != 0 && close != 0 {
                        itemprice = (CGFloat(close) / basic)
                    }
                    //默认每个点的y坐标是0
                    var closeY = CGFloat(0)
                    //默认每个点都是0点
                    var itempriceIsZeroOrNil = true
                    //遇到空数据，价格用0替代
                    if indexItem != nil || itemprice != 0 {
                        closeY = YXKLineUtility.getYCoordinate(withMaxPrice: allLinehighestRatio, minPrice: allLinelowestRatio, price: (itemprice - firstPrice) / firstPrice, distance: chartHeight, zeroY: zeroY)
                        itempriceIsZeroOrNil = false
                    }
                    let closeX = maxX - CGFloat(index1) * self.pointMargin
                    //path绘制时根据itempriceIsZeroOrNil参数去判断绘制路线跳过还是连续
                    if index1 == 0   {
                        path.move(to: CGPoint(x: closeX, y: closeY))
                        
                        if itempriceIsZeroOrNil {
                            lastItempriceIsZeroOrNil = true
                        } else {
                            lastItempriceIsZeroOrNil = false
                        }
                    } else {
                        if itempriceIsZeroOrNil {
                            path.move(to: CGPoint(x: closeX, y: closeY))
                            lastItempriceIsZeroOrNil = true
                        } else {
                            if lastItempriceIsZeroOrNil {
                                path.move(to: CGPoint(x: closeX, y: closeY))
                            } else {
                                path.addLine(to: CGPoint(x: closeX, y: closeY))
                            }
                            lastItempriceIsZeroOrNil = false
                        }
                        //画0线
                        self.drawZeroLine(index1: index1, item: item, closeX: closeX, closeY: closeY,maxPriceNum:item.closePriceAfterCalculateKlineList.count)
                    }
                }
                shapeLayer?.path = path.cgPath
            }
        }

        
        self.drawRatioLabel(allLinehighestRatio: allLinehighestRatio, allLinelowestRatio: allLinelowestRatio)
        self.drawTimeLabel(startTime: startTime, endTime: endTime , maxPriceNum: maxPriceNum)
       
        
    }
    
    func drawZeroLine(index1:Int,item:YXVSSearchModel,closeX:CGFloat,closeY:CGFloat,maxPriceNum:Int) {
        if isDrawzZeroLine == false { //添加0线
            if index1 >=  maxPriceNum - 1 {
                if closeY == 0 {
                    isDrawzZeroLine = false
                    return
                } else {
                    isDrawzZeroLine = true
                }
                let zeroPath = UIBezierPath()
                zeroPath.move(to: CGPoint(x: self.chartRect.minX, y: closeY))
                zeroPath.addLine(to: CGPoint(x: self.chartRect.maxX, y:closeY))
                zerolinePath.append(zeroPath)
                zeroLineLayer.path = zerolinePath.cgPath
                
                let textLayer = CATextLayer()
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.bounds = CGRect.init(x: 0, y: 0, width: 50, height: 20)
                textLayer.position = CGPoint.init(x: self.chartRect.minX - 20, y: closeY + 5)
                zeroPoint = CGPoint.init(x: closeX, y: closeY)
                textLayer.foregroundColor = QMUITheme().stockGrayColor().cgColor
                let font: UIFont =  .systemFont(ofSize: 12)
                let fontRef = CGFont(font.fontName as CFString)
                textLayer.font = fontRef
                textLayer.fontSize = font.pointSize
                textLayer.alignmentMode = .left
                textLayer.string = "0.00%";
//                                self.layer.addSublayer(textLayer)

                if abs(textLayer.position.y - self.maxRatioLabel.layer.position.y) < 10
                || abs(textLayer.position.y - self.subMaxRatioLabel.layer.position.y) < 10
                || abs(textLayer.position.y - self.subMinRatioLabel.layer.position.y) < 10
                || abs(textLayer.position.y - self.minRatioLabel.layer.position.y) < 10
                || self.allLinehighestRatio == 0
                || self.allLinelowestRatio == 0 {
                } else {
                    self.layer.insertSublayer(textLayer, below: self.selectRatioLabel.layer)
                }
            }
        }

    }
    func drawRatioLabel(allLinehighestRatio:CGFloat,allLinelowestRatio:CGFloat) {
        
        let difference = (allLinehighestRatio - allLinelowestRatio) / 3.0

        maxRatioLabel.text = ratioText(allLinehighestRatio)
//        maxRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(allLinehighestRatio))

        subMaxRatioLabel.text = ratioText(allLinehighestRatio - difference)
//        subMaxRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(allLinehighestRatio - difference))

        subMinRatioLabel.text = ratioText(allLinehighestRatio - 2.0 * difference)
//        subMinRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(allLinehighestRatio - 2.0 * difference))

        minRatioLabel.text = ratioText(allLinelowestRatio)
//        minRatioLabel.textColor = YXToolUtility.stockChangeColor(Double(allLinelowestRatio))
    }

    func drawTimeLabel(startTime:UInt64,endTime:UInt64,maxPriceNum:Int) {
        if startTime > 0 {
//            let startDateModel = YXDateToolUtility.dateTime(withTimeValue: TimeInterval(startTime))
//            timeLabel1.text = startDateModel.year + "-" + startDateModel.month + "-" + startDateModel.day
            timeLabel1.text = YXDateHelper.commonDateStringWithNumber(startTime)

        } else {
            timeLabel1.text = "--"
        }

        if endTime > 0 {
//            let endDateModel = YXDateToolUtility.dateTime(withTimeValue: TimeInterval(endTime))
//            timeLabel5.text = endDateModel.year + "-" + endDateModel.month + "-" + endDateModel.day
            timeLabel5.text = YXDateHelper.commonDateStringWithNumber(endTime)
        } else {
            timeLabel5.text = "--"
        }
        
        
        
        
        let timeSpread = maxPriceNum / 4
        let dataSource = YXKlineVSTool.shared.selectList
        
        var latestTime2: UInt64  = NumberUInt64(0).value
        var latestTime3: UInt64 = NumberUInt64(0).value
        var latestTime4: UInt64 = NumberUInt64(0).value

        
        for (_,item) in dataSource.enumerated() {
            if (item.closePriceAfterCalculateKlineList[safe:timeSpread]??.latestTime != nil) {
                latestTime2 = item.closePriceAfterCalculateKlineList[safe:timeSpread]??.latestTime?.value ?? 0
            }
            if (item.closePriceAfterCalculateKlineList[safe:timeSpread*2]??.latestTime != nil) {
                latestTime3 = item.closePriceAfterCalculateKlineList[safe:timeSpread*2]??.latestTime?.value ?? 0
            }
            if (item.closePriceAfterCalculateKlineList[safe:timeSpread*3]??.latestTime != nil) {
                latestTime4 = item.closePriceAfterCalculateKlineList[safe:timeSpread*3]??.latestTime?.value ?? 0
            }
        }
        
        if latestTime2 > 0 {
            timeLabel2.text = YXDateHelper.commonDateStringWithNumber(latestTime2)
        } else {
            timeLabel2.text = "--"
        }
        if latestTime3 > 0 {
            timeLabel3.text = YXDateHelper.commonDateStringWithNumber(latestTime3)
        } else {
            timeLabel3.text = "--"
        }
        if latestTime4 > 0 {
            timeLabel4.text = YXDateHelper.commonDateStringWithNumber(latestTime4)
        } else {
            timeLabel4.text = "--"
        }
    }

    
    func ratioText(_ ratio: CGFloat) -> String {
        var plusStr = ""
        if ratio > 0 {
            plusStr = "+"
        }
        return String(format: "%@%.2f%%", plusStr, ratio * 100.0)
    }
}
extension YXKlineVSView : UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class YXKlineVSSubTitleView: UIView {

    var isLandscape: Bool = false
    init(frame: CGRect, isLandscape: Bool) {
        super.init(frame: frame)
        self.isLandscape = isLandscape
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(colorView)
        addSubview(titleLabel)
        addSubview(ratioLabel)

        if (self.isLandscape) {
            colorView.snp.makeConstraints { (make) in
                make.width.equalTo(12)
                make.height.equalTo(2)
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
            }

            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(colorView.snp.right).offset(4)
                make.centerY.equalToSuperview()
            }

            ratioLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleLabel.snp.right).offset(4)
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
            }
            ratioLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        } else {

            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(14)
                make.height.equalTo(22)
                make.right.equalToSuperview()
                make.top.equalToSuperview()
            }

            colorView.snp.makeConstraints { (make) in
                make.width.equalTo(10)
                make.height.equalTo(2)
                make.left.equalToSuperview()
                make.centerY.equalTo(titleLabel)
            }

            ratioLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom)
                make.right.equalToSuperview()
                make.height.equalTo(19)
            }
        }

    }

    lazy var colorView: UIView = {
        let view = UIView()

        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var ratioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
}

class YXKlineVSDetailView: UIView {
    lazy var dateLable: UILabel = {
        let label = UILabel()
        label.text = "2021-00-00"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var stackView:UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    lazy var eachDataView1:YKLineVSEachDataView = {
        let eachDataView = YKLineVSEachDataView.init(frame: CGRect.zero)
        return eachDataView
    }()

    lazy var eachDataView2:YKLineVSEachDataView = {
        let eachDataView = YKLineVSEachDataView.init(frame: CGRect.zero)
        return eachDataView
    }()
    
    lazy var eachDataView3:YKLineVSEachDataView = {
        let eachDataView = YKLineVSEachDataView.init(frame: CGRect.zero)
        return eachDataView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(dateLable)
        addSubview(stackView)
        
        stackView.addArrangedSubview(eachDataView1)
        stackView.addArrangedSubview(eachDataView2)
        stackView.addArrangedSubview(eachDataView3)
        
        dateLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.right).offset(-8)
            make.top.equalTo(self.snp.top).offset(8)
            make.height.equalTo(14)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.top.equalTo(self.dateLable.snp.bottom)
            make.bottom.equalTo(self.snp.bottom)
        }
        
    }
    
    func resetDeatilView(data1:YXVSSearchModel?,data2:YXVSSearchModel?,data3:YXVSSearchModel?,lineData1:YXKLine?,lineData2:YXKLine?,lineData3:YXKLine?) {
        if let item1 = data1,let item2 = data2,let item3 = data3 {
            eachDataView1.resetDetail(data: item1, lineData: lineData1)
            eachDataView2.resetDetail(data: item2, lineData: lineData2)
            eachDataView3.resetDetail(data: item3, lineData: lineData3)

        } else {
            eachDataView3.isHidden = true
            
            if let item1 = data1 {
                eachDataView1.resetDetail(data: item1, lineData: lineData1)
            }
            if let item2 = data2 {
                eachDataView2.resetDetail(data: item2, lineData: lineData2)
            }
            if let item3 = data3 {
                eachDataView2.resetDetail(data: item3, lineData: lineData3)
            }
        }
        
//        if let line = lineData1 {
//            let dateModel = YXDateToolUtility.dateTime(withTime: String((line.latestTime?.value ?? 0)))
//            dateLable.text = String(format: "%@-%@-%@", dateModel.year, dateModel.month, dateModel.day)
//        } else if let line = lineData2 {
//            let dateModel = YXDateToolUtility.dateTime(withTime: String((line.latestTime?.value ?? 0)))
//            dateLable.text = String(format: "%@-%@-%@", dateModel.year, dateModel.month, dateModel.day)
//        } else if let line = lineData3 {
//            let dateModel = YXDateToolUtility.dateTime(withTime: String((line.latestTime?.value ?? 0)))
//            dateLable.text = String(format: "%@-%@-%@", dateModel.year, dateModel.month, dateModel.day)
//        }
        
        if let line = lineData1 {
            dateLable.text = YXDateHelper.commonDateStringWithNumber(line.latestTime?.value ?? 0)
        } else if let line = lineData2 {
            dateLable.text = YXDateHelper.commonDateStringWithNumber(line.latestTime?.value ?? 0)
        } else if let line = lineData3 {
            dateLable.text = YXDateHelper.commonDateStringWithNumber(line.latestTime?.value ?? 0)
        }
    }
    
}

class YKLineVSEachDataView: UIView {
    
    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.text = "stockCode"
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var priceLeftLable: UILabel = {
        let label = UILabel()
        label.text = "Price"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var priceRightLable: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var chgLeftLable: UILabel = {
        let label = UILabel()
        label.text = "Chg"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var chgRightLable: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var pchgLeftLable: UILabel = {
        let label = UILabel()
        label.text = "Chg(%)"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var pchgRightLable: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(symbolLabel)
        addSubview(priceLeftLable)
        addSubview(priceRightLable)
        addSubview(chgLeftLable)
        addSubview(chgRightLable)
        addSubview(pchgLeftLable)
        addSubview(pchgRightLable)
        
        symbolLabel.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.right).offset(-8)
            make.top.equalTo(self.snp.top).offset(4)
            make.height.equalTo(self.priceLeftLable.snp.height)
        }
        
        priceLeftLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.centerX)
            make.top.equalTo(self.symbolLabel.snp.bottom).offset(4)
            make.height.equalTo(self.chgLeftLable.snp.height)
        }
        
        priceRightLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX)
            make.right.equalTo(self.snp.right).offset(-8)
            make.centerY.equalTo(self.priceLeftLable.snp.centerY)
            make.height.equalTo(self.priceLeftLable.snp.height)
        }
        
        chgLeftLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.centerX)
            make.top.equalTo(self.priceLeftLable.snp.bottom).offset(4)
            make.height.equalTo(self.chgLeftLable.snp.height)
        }
        
        chgRightLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX)
            make.right.equalTo(self.snp.right).offset(-8)
            make.centerY.equalTo(self.chgLeftLable.snp.centerY)
            make.height.equalTo(self.chgLeftLable.snp.height)
        }
        
        pchgLeftLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(8)
            make.right.equalTo(self.snp.centerX)
            make.top.equalTo(self.chgLeftLable.snp.bottom).offset(4)
            make.bottom.equalTo(self.snp.bottom).offset(-4)
        }
        
        pchgRightLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX)
            make.right.equalTo(self.snp.right).offset(-8)
            make.centerY.equalTo(self.pchgLeftLable.snp.centerY)
            make.height.equalTo(self.pchgLeftLable.snp.height)
        }
    }
    
    func resetDetail(data:YXVSSearchModel?,lineData:YXKLine?) {
        //算出每个点的价格
        let close = lineData?.close?.value ?? 0
        let chg = lineData?.netchng?.value ?? 0
        let pchg = Double(lineData?.pctchng?.value ?? 0) / 100

        let priceBasic = data?.priceBasic
        var itemprice = CGFloat(0)
        var chgPrice = CGFloat(0)

        if priceBasic != 0 && close != 0 {
            itemprice = (CGFloat(close) / (priceBasic ?? 1.0))
        }
        if priceBasic != 0 && chg != 0 {
            chgPrice = (CGFloat(chg) / (priceBasic ?? 1.0))
        }
        symbolLabel.text = data?.secu.name

        let upColor = QMUITheme().stockRedColor()
        let downColor = QMUITheme().stockGreenColor()
        let grayColor = QMUITheme().stockGrayColor()

        if chg > 0 {
            chgRightLable.text = "+" + String(format: "%.3f", chgPrice)
            pchgRightLable.text = "+" + String(format: "%.2f%%", pchg)
            chgRightLable.textColor = upColor
            pchgRightLable.textColor = upColor
            priceRightLable.textColor = upColor
        } else if chg < 0 {
            chgRightLable.text =  String(format: "%.3f", chgPrice)
            pchgRightLable.text = String(format: "%.2f%%", pchg)
            chgRightLable.textColor = downColor
            pchgRightLable.textColor = downColor
            priceRightLable.textColor = downColor
        } else {
            chgRightLable.text =  String(format: "%.3f", chgPrice)
            pchgRightLable.text = String(format: "%.2f%%", pchg)
            chgRightLable.textColor = grayColor
            pchgRightLable.textColor = grayColor
            priceRightLable.textColor = grayColor
        }
        if itemprice == 0 {
            priceRightLable.text = "--"
            chgRightLable.text =  "--"
            pchgRightLable.text =  "--"
        } else {
            priceRightLable.text = String(format: "%.3f", itemprice)
        }
    }
}
