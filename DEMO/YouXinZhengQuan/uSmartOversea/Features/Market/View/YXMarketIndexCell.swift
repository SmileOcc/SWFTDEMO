//
//  YXMarketIndexCell.swift
//  uSmartOversea
//
//  Created by ellison on 2018/12/25.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SDCycleScrollView
import FLAnimatedImage


enum YXMarketIndexCellType:Int {
    case index = 0
    case etf = 1
}

class YXMarketIndexSubCell: UICollectionViewCell {
    
    let greyGradientFirstColor = UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#B0B6CB")!.withAlphaComponent(0.35), andDarkColor: UIColor.qmui_color(withHexString: "#858999")!.withAlphaComponent(0.08))
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3 //12.0 / 14.0
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3

        return label
    }()
    
    lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()
    
    lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        
        return label
    }()
    
    lazy var gradientColorView: YXGradientLayerView = {
        let view = YXGradientLayerView()
        view.direction = .vertical
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    var secu: YXV2Quote? {
        didSet {
            update()
        }
    }
    
    var isSelectedItemUI: Bool = false {
        didSet {
            if isSelectedItemUI {
//                qmui_selectedBackgroundColor = QMUITheme().pointColor()
                bottomLine.backgroundColor = priceLabel.textColor
                bottomLine.snp.updateConstraints { (make) in
                    make.height.equalTo(2)
                }
            }else {
//                qmui_selectedBackgroundColor = QMUITheme().pointColor()
                bottomLine.backgroundColor = QMUITheme().separatorLineColor()
                bottomLine.snp.updateConstraints { (make) in
                    make.height.equalTo(1)
                }
            }
        }
    }
    
    @objc var isHK : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeViews() {
        backgroundColor = QMUITheme().foregroundColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        contentView.addSubview(gradientColorView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(rocLabel)
//        contentView.addSubview(bottomLine)
        
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        
        gradientColorView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(8);
            make.left.right.equalTo(nameLabel)
        }
        
        changeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.left.right.equalTo(nameLabel)
        }
        
        rocLabel.snp.makeConstraints { (make) in
            make.top.equalTo(changeLabel.snp.bottom).offset(4)
            make.left.right.equalTo(nameLabel)
        }
        
//        bottomLine.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
    }
    
    func update() {
        if let secuObject = secu {
            var indexName = "--"
            switch secuObject.symbol {
            case "HSI":
                indexName = YXMarketIndex.HSI.indexName
            case "HSCEI":
                indexName = YXMarketIndex.HSCEI.indexName
            case "HSTECH":
                indexName = YXMarketIndex.HSTECH.indexName
            case "HSCCI":
                indexName = YXMarketIndex.HSCCI.indexName
            case "SPHKGEM":
                indexName = YXMarketIndex.SPHKGEM.indexName
            case "VHSI":
                indexName = YXMarketIndex.VHSI.indexName
            case "DIA":
                indexName = YXMarketIndex.DIA.rawValue
            case "QQQ":
                indexName = YXMarketIndex.QQQ.rawValue
            case "SPY":
                indexName = YXMarketIndex.SPY.rawValue
            case "000001":
                indexName = YXMarketIndex.HSSSE.rawValue
            case "399001":
                indexName = YXMarketIndex.HSSZSE.rawValue
            case "399006":
                indexName = YXMarketIndex.HSGEM.rawValue
            default:
                indexName =  "--"
            }
            if let sysmbol = YXMarketIndex.init(rawValue: secuObject.symbol ?? ""),
               (sysmbol == .DJI
                    || sysmbol == .IXIC
                    || sysmbol == .SPX
                    || sysmbol == .HSI
                    || sysmbol == .HSCEI
                    || sysmbol == .HSTECH
                    || sysmbol == .HSCCI
                    || sysmbol == .SPHKGEM
                    || sysmbol == .VHSI){
                if let symbol = secuObject.symbol {
                    let index = YXMarketIndex(rawValue: symbol)
                    indexName = index?.indexName ?? "--"
                }
                nameLabel.text = indexName
            }else {
                nameLabel.text = secuObject.symbol ?? indexName
            }
            
            var op = ""
            if let value = secuObject.netchng?.value, value > 0 {
                op = "+"
                priceLabel.textColor = QMUITheme().stockRedColor()
                changeLabel.textColor = QMUITheme().stockRedColor()
                rocLabel.textColor = QMUITheme().stockRedColor()
                gradientColorView.colors = [QMUITheme().stockRedColor().withAlphaComponent(0.08), QMUITheme().stockRedColor().withAlphaComponent(0)]
            } else if let value = secuObject.netchng?.value, value < 0 {
                priceLabel.textColor = QMUITheme().stockGreenColor()
                changeLabel.textColor = QMUITheme().stockGreenColor()
                rocLabel.textColor = QMUITheme().stockGreenColor()
                gradientColorView.colors = [QMUITheme().stockGreenColor().withAlphaComponent(0.08), QMUITheme().stockGreenColor().withAlphaComponent(0)]
            
            } else {
                priceLabel.textColor = QMUITheme().stockGrayColor()
                changeLabel.textColor = QMUITheme().stockGrayColor()
                rocLabel.textColor = QMUITheme().stockGrayColor()
                gradientColorView.colors = [greyGradientFirstColor, QMUITheme().stockGrayColor().withAlphaComponent(0)]
            }
            
            if let priceBase = secuObject.priceBase?.value, let value = secuObject.latestPrice?.value, value > 0 {
                priceLabel.text = String(format: "%.\(priceBase)f", Double(value)/pow(10.0, Double(priceBase)))
            } else {
                priceLabel.text = "--";
            }
            
            if let priceBase = secuObject.priceBase?.value, let change = secuObject.netchng?.value {
                changeLabel.text = op + String(format: "%.\(priceBase)f", Double(change)/pow(10.0, Double(priceBase)))
            }
            
            if let roc = secuObject.pctchng?.value {
                rocLabel.text = op + String(format: "%.2f%%", Double(roc)/100.0)
            }
            
        }
    }
}


class YXMarketIndexCell: UICollectionViewCell {
    
    typealias ClosureIndexPath = (_ indexPath: IndexPath) -> Void
    
    var selectedIndex : Int = 0
    
    var isColorChanged = false // 切换了红涨绿跌
    
    var isFistComeData : Bool = true
    
    var currentPage : Int = 0
    
    var disposeBag: DisposeBag? = DisposeBag()
    
    var onClickOpenAccount:(()->Void)?
    
    var dataSource: [YXV2Quote] = [YXV2Quote]() {
        didSet {
            if dataSource.count < 4 {
                self.collectionView.isScrollEnabled = false
                pageControl.numberOfPages = 1
            } else {
                self.collectionView.isScrollEnabled = true
                pageControl.numberOfPages = 2
            }
            if (dataSource.count > 0 && selectedIndex < dataSource.count && isFistComeData)   { //首次进来的时候选中第一个去拿分时数据，其余的是用户自己的选中
               isFistComeData = false
                if let closure = onClickIndexPath {
                    closure(IndexPath.init(row: 0, section: 0))
                }
            }
            if dataSource.count > 0, dataSource[0].market == kYXMarketUS {
                
                if YXToolUtility.needFinishQuoteNotify() {
                    addSubview(noQuoteView)
                    noQuoteView.snp.makeConstraints { make in
                        make.left.top.right.equalTo(collectionView)
                        make.height.equalTo(106)
                    }
                    
                } else if YXUserManager.isOpenAccount(broker: YXBrokersBitType.sg) {
                    noIndexView.removeFromSuperview()
                } else {
                    addSubview(noIndexView)
                    
                    noIndexView.snp.makeConstraints { make in
                        make.left.top.right.equalTo(collectionView)
                        make.height.equalTo(106)
                    }
                    
                    if noQuoteView.superview != nil {
                        noQuoteView.removeFromSuperview()
                    }
                }
            }
            
            collectionView.reloadData()
        }
    }
    
    @objc var showArrowMore : Bool = false {
        didSet {
            updateArrowButtonUI()
        }
    }
    
    fileprivate lazy var noIndexView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.backgroundColor = QMUITheme().foregroundColor()
        var data : NSData = NSData.init()
        let gifName : String = "noUSIndex".themeSuffix
        let path  = Bundle.main.path(forResource: gifName , ofType: "gif")
        do {
            data =  try NSData.init(contentsOfFile: path ?? "")
            
        } catch {
        }
        let image : FLAnimatedImage = FLAnimatedImage.init(animatedGIFData: data as Data)
        imageView.animatedImage = image
        imageView.isUserInteractionEnabled = true
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 19))
       
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "open_Acct")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = true
        label.textColor = QMUITheme().mainThemeColor()

        let control = UIControl()
        imageView.addSubview(control)
        let leftLabel = UILabel()
        leftLabel.text = YXLanguageUtility.kLang(key: "stock_index_real_detail_des")
        leftLabel.textColor = QMUITheme().textColorLevel1()
        leftLabel.font = .systemFont(ofSize: 14)
        leftLabel.numberOfLines = 0
        control.addSubview(leftLabel)
        control.addSubview(label)
        
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(6)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(label.snp.left).offset(-22)
        }
        
     
        label.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.size.equalTo(CGSize(width: 110, height: 19))
            make.centerY.equalToSuperview()
        }
        
        control.qmui_tapBlock = { [weak self] sender in
            self?.onClickOpenAccount?()
        }
        control.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        
        return imageView
    }()

    lazy var noQuoteView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.backgroundColor = QMUITheme().foregroundColor()
        var data : NSData = NSData.init()
        let gifName : String = "noUSIndex".themeSuffix
        let path  = Bundle.main.path(forResource: gifName , ofType: "gif")
        do {
            data =  try NSData.init(contentsOfFile: path ?? "")
        } catch {
        }
        let image : FLAnimatedImage = FLAnimatedImage.init(animatedGIFData: data as Data)
        imageView.animatedImage = image
        imageView.isUserInteractionEnabled = true
        
        let label = QMUILabel(frame: CGRect(x: 0, y: 0, width: 74, height: 34)) //[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 74, 34)];
        label.textAlignment = .right
        label.text = YXLanguageUtility.kLang(key: "optionQuoteStatementGo")
        label.font = .mediumFont16()
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = true
        label.textColor = QMUITheme().mainThemeColor()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        let snapShot = label.qmui_snapshotLayerImage()

        let button = QMUIButton()
        button.imagePosition = .right
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.titleLabel?.numberOfLines = 0
        button.setTitle(YXLanguageUtility.kLang(key: "optionQuoteStatement"), for: .normal)
        button.setImage(snapShot, for: .normal)
        button.spacingBetweenImageAndTitle = 24;
        imageView.addSubview(button)
        
        button.qmui_tapBlock = { sender in
            let context = YXNavigatable(viewModel: YXUSAuthStateWebViewModel(dictionary: [:]))
            YXNavigationMap.navigator.push(YXModulePaths.USAuthState.url, context: context)
        }
        button.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        return imageView
    }()
    
    var timeLineData: YXTimeLineData? {
        didSet {
            if oldValue?.market == timeLineData?.market, oldValue?.symbol == timeLineData?.symbol, oldValue?.list?.count == timeLineData?.list?.count, isColorChanged == false  {
                return
            }
            isColorChanged = false
            simpleLineView.market = timeLineData?.market ?? ""
            //simpleLineView.symbol = timeLineData?.symbol ?? ""
            if self.selectedIndex < self.dataSource.count {
                simpleLineView.quote = self.dataSource[self.selectedIndex]
            }
            
            var prePrice: Int64 = 0
            if let data = timeLineData, let first = data.list?.first {
                prePrice = first.preClose?.value ?? 0
            }
            
            //中午时的值
            if let list = self.timeLineData?.list {
                setMidValue(list: list)
            }
            
            let timeLineModel = YXTimeLineModel()
            timeLineModel.price_base = "\(timeLineData?.priceBase?.value ?? 0)"
            timeLineModel.market = timeLineData?.market ?? ""
            timeLineModel.type = Int(timeLineData?.type?.value ?? 0)
            
            let priceBase = timeLineModel.price_base
            
            let timeLineList =  timeLineData?.list?.map({ (simpleTimeLine) -> YXTimeLineSingleModel in
                let singleModel = YXTimeLineSingleModel()
                singleModel.pclose = "\(simpleTimeLine.preClose?.value ?? 0)"
                singleModel.price = "\(simpleTimeLine.price?.value ?? 0)"
                singleModel.priceBase = priceBase
                singleModel.time = "\(simpleTimeLine.latestTime?.value ?? 0)"
                return singleModel
            }) ?? []
            
            timeLineModel.list = NSMutableArray(array: timeLineList)
            let sortlist = timeLineData?.list?.sorted { (a, b) -> Bool in
                (a.price?.value ?? 0) > (b.price?.value ?? 0)
            }
            
            if let list = sortlist, list.count > 0 {
                let digit = timeLineData?.priceBase?.value ?? 2 // 保留几位
                let priceBasic = pow(10.0, Double(timeLineData?.priceBase?.value ?? 0))
                
                // 最高价和最高涨幅
                var maxPrice = 0.0
                if let maxp = list[0].price?.value {
                    
                    maxPrice = max(Double(maxp), Double(prePrice))
                    
                    var opMax = ""
                    if maxPrice > Double(prePrice) {
                        opMax = "+"
                        maxPriceLabel.textColor = QMUITheme().stockRedColor()
                    }else if maxPrice < Double(prePrice) {
                        maxPriceLabel.textColor = QMUITheme().stockGreenColor()
                    }else {
                        maxPriceLabel.textColor = QMUITheme().stockGrayColor()
                    }
                    
                    maxPriceLabel.text = String(format: "%.\(digit)lf", maxPrice / priceBasic)
                    
                    // 最高涨幅
                    if prePrice > 0 {
                        let maxRoc = (maxPrice - Double(prePrice)) / Double(prePrice)
                        maxRocLabel.text = String(format: "%@%.2lf%%", opMax, maxRoc * 100.0)
                    }else {
                        maxRocLabel.text = "--"
                    }
                    
                }else {
                    maxPriceLabel.text = "--"
                    maxRocLabel.text = "--"
                }
                
                // 最低价和最低涨幅
                var minPrice = 0.0
                if let minp = list[list.count-1].price?.value {
                    
                    minPrice = min(Double(minp), Double(prePrice))
                    
                    var opMin = ""
                    if minPrice > Double(prePrice) {
                        opMin = "+"
                        minPriceLabel.textColor = QMUITheme().stockRedColor()
                    }else if minPrice < Double(prePrice) {
                        minPriceLabel.textColor = QMUITheme().stockGreenColor()
                    }else {
                        minPriceLabel.textColor = QMUITheme().stockGrayColor()
                    }
                    
                    minPriceLabel.text = String(format: "%.\(digit)lf", minPrice / priceBasic)
                    
                    if prePrice > 0 {
                        let minRoc = (minPrice - Double(prePrice)) / Double(prePrice)
                        minRocLabel.text = String(format: "%@%.2lf%%", opMin, minRoc * 100.0)
                    }else {
                        minRocLabel.text = "--"
                    }
                    
                }else {
                    minPriceLabel.text = "--"
                    minRocLabel.text = "--"
                }
                
                minRocLabel.textColor = minPriceLabel.textColor
                maxRocLabel.textColor = maxPriceLabel.textColor
            }

            simpleLineView.dashPointCount = 50
            simpleLineView.timeModel = timeLineModel
        }
    }
    
    // 找出12：00 13:00时和11：30时的值
    func setMidValue(list: [YXTimeLine]) {
        var midHourEnd: String
        var midMinuteEnd: String
        var midHourStart: String
        var midMinuteStart: String
        var midEndColor: UIColor = .clear
        var midEndValue: String?
        var midStartValue: String?
        var midStartColor: UIColor = .clear
        if simpleLineView.market == "hk" {
            midHourEnd = "12"
            midMinuteEnd = "00"
            midHourStart = "13"
            midMinuteStart = "00"
            vLine.snp.remakeConstraints { (make) in
                make.centerX.equalTo(hLine).offset(-15.0/YXConstant.screenWidth*375.0)
                make.centerY.equalTo(hLine)
                make.width.equalTo(1)
                make.height.equalTo(6)
            }
        }else if simpleLineView.market == "us" {
            midHourEnd = "12"
            midMinuteEnd = "45"
            midHourStart = "12"
            midMinuteStart = "45"
        }else {
            midHourEnd = "11"
            midMinuteEnd = "30"
            midHourStart = "13"
            midMinuteStart = "00"
        }
        
        let priceBase = self.timeLineData?.priceBase?.value ?? 0
        var prePrice: Int64 = 0
        if let data = self.timeLineData, let first = data.list?.first {
            prePrice = first.preClose?.value ?? 0
        }
        
        for model in list {
            if let time = model.latestTime?.value {
                let dateModel = YXDateToolUtility.dateTime(withTime: "\(time)")
                if dateModel.hour == midHourEnd, dateModel.minute == midMinuteEnd {
                    midEndValue = YXToolUtility.stockPriceData(Double(model.price?.value ?? 0), deciPoint: Int(priceBase), priceBase: Int(priceBase))
                    midEndColor = YXToolUtility.priceTextColor(Double(model.price?.value ?? 0), comparedData: Double(prePrice))
                }
                
                if simpleLineView.market != "us", dateModel.hour == midHourStart, dateModel.minute == midMinuteStart {
                    midStartValue = YXToolUtility.stockPriceData(Double(model.price?.value ?? 0), deciPoint: Int(priceBase), priceBase: Int(priceBase))
                    midStartColor = YXToolUtility.priceTextColor(Double(model.price?.value ?? 0), comparedData: Double(prePrice))
                    
                    break
                }
            }
        }
        
        if let endValue = midEndValue {
            let font = UIFont.systemFont(ofSize: 12)
            let attrStr = NSMutableAttributedString.init(string: endValue, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: midEndColor])
            if let startValue = midStartValue {
                let char = NSAttributedString.init(string: "/", attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: QMUITheme().stockGrayColor()])
                let startValueAttrStr = NSAttributedString.init(string: startValue, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: midStartColor])
                
                attrStr.append(char)
                attrStr.append(startValueAttrStr)
            }
            midPriceLabel.attributedText = attrStr
        }
    }
    
    @objc func colorChanged() {
        isColorChanged = true
    }
    
    @objc var onClickIndexPath: ClosureIndexPath?
    
    var onClickTimeLineView: ((_ selectedIndex: Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged), name: NSNotification.Name(YXUserManager.notiUpdateColor), object: nil)
        backgroundColor = UIColor.white
        initializeViews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
                
        var data : NSData = NSData.init()
        let gifName : String = "noUSIndex".themeSuffix
        let path  = Bundle.main.path(forResource: gifName , ofType: "gif")
        do {
            data =  try NSData.init(contentsOfFile: path ?? "")
            
        } catch {
        }
        let image : FLAnimatedImage = FLAnimatedImage.init(animatedGIFData: data as Data)
        self.noIndexView.animatedImage = image
        self.noQuoteView.animatedImage = image        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
    fileprivate func updateArrowButtonUI () {
        DispatchQueue.main.async {
            if self.showArrowMore {
                self.arrowRightButton.isHidden = (self.currentPage == 0) ? false : true
                self.arrowLeftButton.isHidden = (self.currentPage == 0)

                let leftOffset = (self.currentPage == 0) ? 18 : 32
                let rightOffset = (self.currentPage == 0) ? -32 : -18

                self.collectionView.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(leftOffset)
                    make.right.equalToSuperview().offset(rightOffset)
                    make.bottom.equalToSuperview().offset(0)
                    make.height.equalTo(96)
                }
            }else{
                self.arrowRightButton.isHidden = true
                self.arrowLeftButton.isHidden = true
                self.collectionView.snp.updateConstraints { (make) in
                    make.left.equalToSuperview().offset(18)
                    make.right.equalToSuperview().offset(-18)
                    make.bottom.equalToSuperview().offset(0)
                    make.height.equalTo(96)
                }
            }
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .zero
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.register(YXMarketIndexSubCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMarketIndexSubCell.self))
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.backgroundColor = QMUITheme().foregroundColor()

        return collectionView
    }()
    
    lazy var simpleLineView: YXSimpleTimeLine = {
        let view = YXSimpleTimeLine(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth-36, height: 112), market: YXMarketType.HK.rawValue)
        _ = view.rx.tapGesture().skip(1).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](_) in
            if let action = self?.onClickTimeLineView {
                if let selectedIndex = self?.selectedIndex {
                    action(selectedIndex)
                }
            }
        })
        
        view.enableLongPress = true
        
        return view
    }()
    
    lazy var minPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var maxPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var minRocLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var maxRocLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var startTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var endTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var hLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().itemBorderColor()
        return view
    }()
    
    lazy var vLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().itemBorderColor()
        return view
    }()
    
    lazy var midTimeLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var midPriceLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    
    lazy var arrowLeftButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage.init(named: "arrow_more_left"), for: .normal)
        button.addTarget(self, action: #selector(arrowButtonAction), for: .touchUpInside)
        button.isHidden = true
        button.makeCorners(with: 1)
        button.layer.borderWidth = 1
        button.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        
        return button
    }()
    
    lazy var arrowRightButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage.init(named: "arrow_more_right"), for: .normal)
        button.addTarget(self, action: #selector(arrowButtonAction), for: .touchUpInside)
        button.isHidden = true
        button.makeCorners(with: 1)
        button.layer.borderWidth = 1
        button.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        
        return button
    }()
    
    @objc func arrowButtonAction()
    {
        let pageWidth : CGFloat = CGFloat(YXConstant.screenWidth - 18 - 32)
        
        let rowItemOffsetX : CGFloat = (self.currentPage == 0) ? pageWidth : 0
        self.collectionView.setContentOffset(CGPoint.init(x: rowItemOffsetX, y: 0), animated: true)
    }
    
    fileprivate lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.hidesForSinglePage = true
        
        var selectedColor: UIColor?
        var normalColor: UIColor?
        selectedColor = QMUITheme().mainThemeColor()
        normalColor = QMUITheme().textColorLevel4()
        pageControl.dotImage = UIImage(color: normalColor!, size: CGSize(width: 8, height: 2))
        pageControl.currentDotImage = UIImage(color: selectedColor!, size: CGSize(width: 8, height: 2))
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = 0
        pageControl.spacingBetweenDots = 0
        
        return pageControl
    }()
    
    fileprivate func initializeViews() {
        contentView.addSubview(collectionView)
        contentView.addSubview(pageControl)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(8)
        }
    }

}

//MARK: - UICollectionViewDelegate
extension YXMarketIndexCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let indexCell:YXMarketIndexSubCell = cell as! YXMarketIndexSubCell
        let obj = dataSource[indexPath.item]
        indexCell.secu = obj
//        if indexPath.item == selectedIndex {
//            indexCell.isSelectedItemUI = true
//        }else{
//            indexCell.isSelectedItemUI = false
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.item == selectedIndex {
//            return
//        }
//        selectedIndex = indexPath.item
        if let closure = onClickIndexPath {
            closure(indexPath)
        }
//        collectionView.reloadData()
    }

}

//MARK: - UICollectionViewDataSource
extension YXMarketIndexCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : YXMarketIndexSubCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMarketIndexSubCell.self), for: indexPath) as! YXMarketIndexSubCell
       return cell
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension YXMarketIndexCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var itemWidth : Double = 0
//        if showArrowMore { //左右边距
//            itemWidth = Double(YXConstant.screenWidth - 18 - 32)
//        }else{
//            itemWidth = Double(YXConstant.screenWidth - 18 - 18)
//        }
//        return CGSize(width: (itemWidth - 10) / 3.0, height: 76)
        let width = (collectionView.width - 2 * 8.0) / 3.0
        return CGSize(width: width , height: 106)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension YXMarketIndexCell: UIScrollViewDelegate {
    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print("scrollViewDidEndScrollingAnimation")
//        self.scrollViewEndChangeUI(scrollView)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("scrollViewDidEndDragging")
//        if !decelerate {
//            self.scrollViewEndChangeUI(scrollView)
//        }
//    }

    //scrollView 已结束 减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

//        self.scrollViewEndChangeUI(scrollView);
        let index = self.collectionView.contentOffset.x / self.collectionView.width
        self.pageControl.currentPage = Int(index)
//        if index == 1 {
//            var point = self.collectionView.contentOffset
//            point.x = point.x + 8
//            UIView.animate(withDuration: 0.05) {
//                self.collectionView.contentOffset.x = point.x
//            }
////            self.collectionView.setContentOffset(point, animated: true)
//        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 港股有6个指标,collectionview被分成两页,由于item之间有8的间距,如果不调整,则当滑到下一页时,显示位置会右偏8距离,这里简单处理,尝试调整到正确位置
        if velocity.x > 0 {
            self.collectionView.contentOffset.x = self.collectionView.contentOffset.x + 8
        }
    }
    
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        print("########")
//        self.collectionView.contentOffset.x = self.collectionView.contentOffset.x + 8
//    }

//    func scrollViewEndChangeUI(_ scrollView: UIScrollView) {
//        var itemWidth : CGFloat = 0
//        if showArrowMore { //左右边距
//            itemWidth = CGFloat(YXConstant.screenWidth - 18 - 32)
//        }else{
//            itemWidth = CGFloat(YXConstant.screenWidth - 18 - 18)
//        }
//        let index = scrollView.contentOffset.x / itemWidth
//        if ( Int(index) == currentPage) {
//            return
//        }
//        self.currentPage = Int(index)
//        updateArrowButtonUI()
//    }
}
