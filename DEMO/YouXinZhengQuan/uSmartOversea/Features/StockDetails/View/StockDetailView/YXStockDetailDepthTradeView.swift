//
//  YXStockDetailDepthTradeView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/6/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa

extension YXDepthOrderData {
    var totalCount: Int {
        let askCount = self.ask?.count ?? 0
        let bidCount = self.bid?.count ?? 0
        
        return askCount + bidCount
    }
    
    var isEmpty: Bool {
        return self.totalCount == 0
    }
}

class YXStockDetailDepthTradeView: UIView, YXStockDetailSubHeaderViewProtocol {
    
    @objc enum YXDepthTradeTapType: Int {
        case price = 0
        case number
        case all
    }
    
    @objc var tapBlock: ((_ priceString: String?, _ number: NSNumber?) -> Void)?
    @objc var settingChangeBlock: ((_ type: YXDepthTradeSettingType) -> Void)?
    @objc var gearChangeBlock: ((_ selectIndex: Int) -> Void)?
    
    @objc var totalHeight: CGFloat {
        if emptyView.isHidden == false {
            return headerHeight + cellHeight * CGFloat(10) + bottomMargin
        } else {
            var isShow = YXStockDetailUtility.showDepthTradePriceDistribution()
            if isShow, chartModel?.isEmpty ?? true {
                isShow = false
            }
            
            return headerHeight + cellHeight * CGFloat(gear) + bottomMargin + (isShow ? chartHeight : 0)
        }
    }
    
    //当前档位
    @objc var gear: Int = YXStockDetailUtility.getDepthGearNumber() {
        didSet {
            self.contentHeight = self.totalHeight
            self.gearsButton.setTitle("\(gear)", for: .normal)
        }
    }
    
    fileprivate var latestPrice: Int64 = 0 //股票最新价，外部传入
    fileprivate var bestBidPrice: Int64 = 0
    fileprivate var bestAskPrice: Int64 = 0
    
    var bestBidIndex: Int = -1
    var bestAskIndex: Int = -1
    var maxSize: Int64 = 0  //当前档位下的最大委托数量
    var showColorPrice = YXStockDetailUtility.showDepthTradeColorPrice() //是否展示颜色价位
    
    let cellHeight: CGFloat = 28
    let headerHeight: CGFloat = 56
    let bottomMargin: CGFloat = 20
    let chartHeight: CGFloat = 170

    @objc var posBroker: PosBroker? {
        didSet {
            //美股 买卖档的价格比较 盘前盘后 用收盘价比较， 盘中 用昨收比较
            latestPrice = posBroker?.getRealPreClose()?.value ?? 0
            bestBidPrice = Int64(posBroker?.pos?.posData?.first?.bidPrice?.value ?? 0)
            bestAskPrice = Int64(posBroker?.pos?.posData?.first?.askPrice?.value ?? 0)
            
            if self.model != nil {
                self.bestBidIndex = -1
                self.bestAskIndex = -1
                tcpFilter.onNext(false)
            }
        }
    }
    
    @objc var model: YXDepthOrderData? {
        didSet {
            
            maxSize = 0
            self.bestBidIndex = -1
            self.bestAskIndex = -1

            if model == nil {
                reloadTableView()
            } else {
                tcpFilter.onNext(false)
            }
            
            let askCount = model?.ask?.count ?? 0
            let bidCount = model?.bid?.count ?? 0
            
            var needChangeHeight = false
            if askCount == 0 && bidCount == 0 {
                if emptyView.isHidden {
                    needChangeHeight = true
                }
                emptyView.isHidden = false
            } else {
                if !emptyView.isHidden {
                    needChangeHeight = true
                }
                emptyView.isHidden = true
            }
            if needChangeHeight {
                self.contentHeight = self.totalHeight
            }
        }
    }
    
    @objc var chartModel: YXDepthOrderData? {
        didSet {
            self.chartView.model = chartModel

            if chartModel?.isEmpty ?? true  {
                self.chartView.isHidden = true
                self.chartView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            } else {
                if self.chartView.isHidden == true, YXStockDetailUtility.showDepthTradePriceDistribution() {
                    self.chartView.isHidden = false
                    self.chartView.snp.updateConstraints { make in
                        make.height.equalTo(self.chartHeight)
                    }
                }
            }
            self.contentHeight = self.totalHeight
        }
    }
    
    let buyColors = [UIColor.qmui_color(withHexString: "#2FFF97")!.withAlphaComponent(0.1),
                     UIColor.qmui_color(withHexString: "#2FFF97")!.withAlphaComponent(0.18),
                     UIColor.qmui_color(withHexString: "#2FFF97")!.withAlphaComponent(0.26),
                     
                     UIColor.qmui_color(withHexString: "#2FFFDC")!.withAlphaComponent(0.1),
                     UIColor.qmui_color(withHexString: "#2FFFDC")!.withAlphaComponent(0.18),
                     UIColor.qmui_color(withHexString: "#2FFFDC")!.withAlphaComponent(0.28),
                     
                     UIColor.qmui_color(withHexString: "#2FDCFF")!.withAlphaComponent(0.1),
                     UIColor.qmui_color(withHexString: "#2FDCFF")!.withAlphaComponent(0.18),
                     UIColor.qmui_color(withHexString: "#2FDCFF")!.withAlphaComponent(0.26)]
    
    let sellColors = [UIColor.qmui_color(withHexString: "#FF5432")!.withAlphaComponent(0.1),
                      UIColor.qmui_color(withHexString: "#FF5432")!.withAlphaComponent(0.18),
                      UIColor.qmui_color(withHexString: "#FF5432")!.withAlphaComponent(0.26),
                      
                      UIColor.qmui_color(withHexString: "#FF7632")!.withAlphaComponent(0.1),
                      UIColor.qmui_color(withHexString: "#FF7632")!.withAlphaComponent(0.18),
                      UIColor.qmui_color(withHexString: "#FF7632")!.withAlphaComponent(0.26),
                      
                      UIColor.qmui_color(withHexString: "#FF9932")!.withAlphaComponent(0.1),
                      UIColor.qmui_color(withHexString: "#FF9932")!.withAlphaComponent(0.18),
                      UIColor.qmui_color(withHexString: "#FF9932")!.withAlphaComponent(0.26)]
    
    
    var gearTitles = ["10", "20", "40"]
    
    var priceBase: Int = 0
    
    var isTrade = false
    
    ///是否是新加坡市场
    @objc var isSgMarket = false {
        didSet {
            if isSgMarket {
                self.headerDesLabel.text = "SGX"
                // 判断档位, 如果是选中40档, 重置为20
                if YXStockDetailUtility.getDepthGearNumber() > 20 {
                    YXStockDetailUtility.setDepthGearNumber(20)
                    self.gear = 20
                }
                gearTitles = ["10", "20"]
                gearsButton.titles = gearTitles
            } else {
                self.headerDesLabel.text = "ARCA"
            }
        }
    }
    
    let stockRedColor = QMUITheme().stockRedColor()
    let stockGreenColor = QMUITheme().stockGreenColor()
    let stockGrayColor = QMUITheme().stockGrayColor()
    
    lazy var tcpFilter: PublishSubject<Bool> = {
        let filter = PublishSubject<Bool>()
        filter.throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                [weak self] isOnlyRefresh in
                guard let `self` = self else { return }
                
                self.reloadTableView()
                
            }).disposed(by: self.rx.disposeBag)
        
        return filter
    }()
    
    func reloadTableView() {
        self.priceBase = Int(model?.priceBase?.value ?? 0)
        
        var needFillColor = false
        if let askInfo = self.model?.ask?.first, askInfo.colorIndex == nil {
            needFillColor = true
        } else if let bidInfo = self.model?.bid?.first, bidInfo.colorIndex == nil {
            needFillColor = true
        }
        
        if needFillColor {
            self.fillPriceColor()
        }
        if maxSize == 0 {
            self.getMaxSize()
        }
        
        if self.bestBidIndex < 0 && self.bestAskIndex < 0 {
            self.getBestIndex()
        }
        self.buyTableView.reloadData()
        self.sellTableView.reloadData()
    }
    
    
    @objc init(frame: CGRect, isTrade: Bool = false) {
        super.init(frame: frame)
        
        self.isTrade = isTrade
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(headerView)
        addSubview(chartView)
        addSubview(buyTableView)
        addSubview(sellTableView)
        addSubview(buyBestLineView)
        addSubview(sellBestLineView)
        
        addSubview(emptyView)
        
        let margin: CGFloat = 18
        let tableWidth = YXConstant.screenWidth / 2.0 - margin
        
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(headerHeight)
            make.top.equalToSuperview()
        }
        
        let isShow = YXStockDetailUtility.showDepthTradePriceDistribution()
        chartView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(isShow ? chartHeight : 0)
        }
        chartView.isHidden = !isShow
        
        buyTableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-bottomMargin)
            make.left.equalToSuperview().offset(margin)
            make.top.equalTo(chartView.snp.bottom)
            make.width.equalTo(tableWidth)
        }
        
        sellTableView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-bottomMargin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(chartView.snp.bottom)
            make.width.equalTo(tableWidth)
        }
        
        buyBestLineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(self.buyTableView)
            make.right.equalTo(self.buyTableView)
            make.top.equalTo(self.buyTableView).offset(cellHeight)
        }
        
        sellBestLineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(self.sellTableView)
            make.right.equalTo(self.sellTableView)
            make.top.equalTo(self.sellTableView).offset(cellHeight)
        }
        
        emptyView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
    }
    
    lazy var buyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = buyColors.first
        return tableView
    }()
    
    
    lazy var sellTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = sellColors.first
        
        return tableView
    }()
    
    
    lazy var headerDesLabel: UILabel = {
        let label = UILabel.init(text: "ARCA", textColor: QMUITheme().textColorLevel1(), textFont: .systemFont(ofSize: 14))!
        return label
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        
        let label = UILabel()
        if self.isTrade {
            label.font = UIFont.systemFont(ofSize: 14)
            headerDesLabel.font = .systemFont(ofSize: 12)
        } else {
            label.font = .systemFont(ofSize: 20, weight: .medium)
            headerDesLabel.font = .systemFont(ofSize: 14)
        }
        label.text = YXLanguageUtility.kLang(key: "depth_order")
        
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
       
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
        }
        
        view.addSubview(promptButton)
        promptButton.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.width.height.equalTo(15)
            make.left.equalTo(label.snp.right).offset(3)
        }
       
        headerDesLabel.textColor = QMUITheme().textColorLevel1()
        
        view.addSubview(headerDesLabel)
        
        view.addSubview(self.gearsButton)
        view.addSubview(self.settingButton)
        
        //view.addSubview(self.providerButton)
        
        headerDesLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
            make.right.equalTo(self.gearsButton.snp.left).offset(-27)
        }
        
        self.gearsButton.snp.makeConstraints { make in
            make.right.equalTo(self.settingButton.snp.left).offset(-24)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        
        
        self.settingButton.snp.makeConstraints { make in
           
            make.right.equalToSuperview().offset(self.isTrade ? 0 : 0)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
//        self.providerButton.snp.makeConstraints { make in
//            make.right.equalTo(self.settingButton.snp.left).offset(-12)
//            make.height.equalTo(20)
//            make.width.equalTo(40)
//            make.centerY.equalToSuperview()
//        }
        
        return view
    }()
    
    
    //MARK: 档位变化处理
    lazy var gearsButton: YXStockDetailAskBidPopoverButton = {
        
        let button = YXStockDetailAskBidPopoverButton(frame: .zero, titles: gearTitles)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.borderColor = QMUITheme().pointColor().cgColor
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.clickItemBlock = {
            [weak self, weak button] index in
            guard let `self` = self else { return }
            
            if index < self.gearTitles.count, let num = Int(self.gearTitles[index])  {
                self.gear = num
                YXStockDetailUtility.setDepthGearNumber(num)
            }
            self.maxSize = 0
            self.bestBidIndex = -1
            self.bestAskIndex = -1
            self.reloadTableView()
        }
        button.setTitle("\(self.gear)", for: .normal)
        return button
    }()
    
    lazy var settingButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.layer.cornerRadius = 2.0
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "depth_trade_set"), for: .normal)
        
        button.rx.tap.subscribe(onNext: {
            [weak self, weak button] _ in
            guard let `self` = self, let currentButton = button else { return }
            
            let popView = self.setUpPopView()
            self.popover.show(popView, from: currentButton)
            
        }).disposed(by: self.rx.disposeBag)
        return button
    }()
    
    lazy var providerButton: UIButton = {
        let button = UIButton()
        button.setTitle("ARCA", for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        return button
    }()
    
    
    lazy var popover: YXStockPopover = {
        let view = YXStockPopover()
        
        return view
    }()
    
    
    lazy var buyBestLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#00C767")
        view.isHidden = true
        return view
    }()
    
    lazy var sellBestLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#FF6933")
        view.isHidden = true
        return view
    }()
    
    lazy var emptyView: YXDepthTradeEmptyView = {
        return YXDepthTradeEmptyView()
    }()
    
    lazy var promptButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "analyze_info_acra"), for: .normal)
        button.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
//            USDEPTH
            if self.isSgMarket {
                YXWebViewModel.pushToWebVC(YXH5Urls.DEPTH_ORDER_EXPLAIN_URL(with: "SGDEPTH"))
            } else {
                YXWebViewModel.pushToWebVC(YXH5Urls.DEPTH_ORDER_EXPLAIN_URL(with: "USDEPTH"))
            }
            
        }).disposed(by: self.rx.disposeBag)
        return button
    }()
    
    lazy var chartView: YXStockDetailDepthDistributionView = {
        let margin: CGFloat = 36
        let view = YXStockDetailDepthDistributionView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: chartHeight), isTrade: self.isTrade)
        return view
    }()
    
}

extension YXStockDetailDepthTradeView {
    
    //颜色价位，委托数量弹窗
    func setUpPopView() -> UIView {
        
        let settingTypes: [YXDepthTradeSettingType] = [.colorPrice, .orderNumber, .combineSamePrice, .priceDistribution]
        let popView = UIView()
        popView.backgroundColor = QMUITheme().popupLayerColor()
        popView.layer.contents = 6
        var maxWidth: CGFloat = 0
        for type in settingTypes {
            let width = (type.text as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).size.width
            if maxWidth < width {
                maxWidth = width
            }
        }
        
        let itemHeight: CGFloat = 48
        //popView.frame = CGRect(x: 0, y: 0, width: maxWidth + 30 + 10.0, height: itemHeight * CGFloat(settingTypes.count))
        popView.frame = CGRect(x: 0, y: 0, width: 183, height: 198)
    
        
        for (index, type) in settingTypes.enumerated() {
            let button = YXStockDetailDepthTradeSettingControl()
            popView.addSubview(button)
            button.contentLabel.text = type.text
            button.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(itemHeight)
                make.top.equalToSuperview().offset(itemHeight * CGFloat(index)+2)
            }
            button.type = type
            button.isSelected = type.shouldShow
                    
            button.rx.controlEvent(.touchUpInside).subscribe(onNext: {
                [weak self, weak button] _ in
                guard let `self` = self, let selectButton = button else { return }
                
                selectButton.isSelected = !selectButton.isSelected
                
                self.settingTypeChanged(selectButton.type)
                
            }).disposed(by: self.rx.disposeBag)
            
            
            if index == settingTypes.count - 1  {
                button.lineView.isHidden = true
            }
            
            
        }
        
        
        return popView;
    }
    
    
    //MARK: 颜色价位、委托数量、同价合并修改 处理
    func settingTypeChanged(_ type: YXDepthTradeSettingType) {
        if type == .combineSamePrice {
            self.settingChangeBlock?(type)
        } else if type == .priceDistribution {
            
            let isShow = type.shouldShow
            if isShow == false {
                self.chartView.isHidden = true
                self.chartView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }
            
            self.settingChangeBlock?(type)
        } else {
            if type == .orderNumber {
                getMaxSize()
            } else if type == .colorPrice {
                showColorPrice = YXStockDetailUtility.showDepthTradeColorPrice()
            }
            
            self.buyTableView.reloadData()
            self.sellTableView.reloadData()
        }
    }
    
    //获取最大委托数量
    func getMaxSize() {
        var max: Int64 = 0
        if YXStockDetailUtility.showDepthTradeOrderNumber() {
            if let list = model?.ask {
                
                for (index, info) in list.enumerated() {
                    if index >= self.gear {
                        break;
                    }
                    
                    if let size = info.size?.value, max < size  {
                        max = size
                    }
                }
            }
            
            if let list = model?.bid {
                for (index, info) in list.enumerated() {
                    if index >= self.gear {
                        break;
                    }
                    
                    if let size = info.size?.value, max < size  {
                        max = size
                    }
                }
            }
        }
        
        maxSize = max
    }
    
    //确定颜色价位 颜色
    func fillPriceColor() {
        if let list = model?.bid {
            
            var colorIndex: Int32 = 0
            var lastPrice: Int64 = 0
            let count = self.buyColors.count
            for info in list {
                
                if lastPrice == info.price?.value {
                    if colorIndex == 0 {
                        colorIndex = Int32(count - 1)
                    } else {
                        colorIndex -= 1
                    }
                }
                
                info.colorIndex = NumberInt32.init(colorIndex)
                
                lastPrice = info.price?.value ?? 0
                colorIndex += 1
                if colorIndex >= count {
                    colorIndex = 0
                }
            }
        }
        
        
        if let list = model?.ask {
            
            var colorIndex: Int32 = 0
            var lastPrice: Int64 = 0
            let count = self.sellColors.count
            for info in list {
                
                if lastPrice == info.price?.value {
                    if colorIndex == 0 {
                        colorIndex = Int32(count - 1)
                    } else {
                        colorIndex -= 1
                    }
                }
                
                info.colorIndex = NumberInt32.init(colorIndex)
                
                lastPrice = info.price?.value ?? 0
                colorIndex += 1
                if colorIndex >= count {
                    colorIndex = 0
                }
            }
        }
    }
    
    //获取最优价格位置
    func getBestIndex() {
        var askIndex: Int = -1
        var bidIndex: Int = -1
        if let list = model?.ask {
            let count = list.count
            for index in 0..<count {
                let info = list[count - index - 1]
                if let price = info.price?.value, price == bestAskPrice {
                    askIndex = count - index
                    break
                }
            }
        }
        
        if let list = model?.bid {
            let count = list.count
            for index in 0..<count {
                let info = list[count - index - 1]
                if let price = info.price?.value, price == bestBidPrice {
                    bidIndex = count - index
                    break
                }
            }
        }
        
        self.bestBidIndex = bidIndex
        self.bestAskIndex = askIndex
        
        showBestLineView(true)
    }
    
    //展示最优价格
    func showBestLineView(_ animated: Bool = true) {
        
        
        if self.bestBidIndex >= 0, self.bestBidIndex < self.gear {
            self.buyBestLineView.isHidden = false
            self.buyBestLineView.snp.updateConstraints { make in
                make.top.equalTo(self.buyTableView).offset(cellHeight * CGFloat(self.bestBidIndex))
            }
            
            if animated {
                UIView.animate(withDuration: 0.1) {
                    self.buyBestLineView.layoutIfNeeded()
                }
            }
        } else {
            self.buyBestLineView.isHidden = true
        }
        
        if self.bestAskIndex >= 0, self.bestAskIndex < self.gear {
            self.sellBestLineView.isHidden = false
            self.sellBestLineView.snp.updateConstraints { make in
                make.top.equalTo(self.sellTableView).offset(cellHeight * CGFloat(self.bestAskIndex))
            }
            
            if animated {
                UIView.animate(withDuration: 0.1) {
                    self.sellBestLineView.layoutIfNeeded()
                }
            }
        } else {
            self.sellBestLineView.isHidden = true
        }
    }
}
extension YXStockDetailDepthTradeView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if tableView == self.buyTableView {
            count = self.model?.bid?.count ?? 0
        } else {
            count = self.model?.ask?.count ?? 0
        }
        
        if count > self.gear {
            count = self.gear
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        var model: YXDepthOrder?
        if tableView == self.buyTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "YXStockDetailDepthTradeCellBuy")
            if cell == nil {
                cell = YXStockDetailDepthTradeCell(style: .default, reuseIdentifier: "YXStockDetailDepthTradeCellBuy", isBuy: true, isTrade: self.isTrade)
            }
            
            if let list = self.model?.bid, indexPath.row < list.count {
                model = list[indexPath.row]
            }
            
            if showColorPrice {
                cell?.contentView.backgroundColor = self.buyColors[Int(model?.colorIndex?.value ?? 0)]
            } else {
                cell?.contentView.backgroundColor = self.buyColors.first
            }
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "YXStockDetailDepthTradeCellSell")
            if cell == nil {
                cell = YXStockDetailDepthTradeCell(style: .default, reuseIdentifier: "YXStockDetailDepthTradeCellSell", isBuy: false, isTrade: self.isTrade)
            }
            
            if let list = self.model?.ask, indexPath.row < list.count {
                model = list[indexPath.row]
            }
            
            if showColorPrice {
                cell?.contentView.backgroundColor = self.sellColors[Int(model?.colorIndex?.value ?? 0)]
            } else {
                cell?.contentView.backgroundColor = self.sellColors.first
            }
        }
        
        
        if let cell = cell as? YXStockDetailDepthTradeCell {
            
            cell.refreshUI(model, latestPrice: latestPrice, priceBase: priceBase, maxSize: maxSize)
            
            if let market = self.model?.market, market == kYXMarketSG {
                cell.nameLabel.text = "SGX"
            } else {
                cell.nameLabel.text = "ARCA"
            }
            
            if let price = model?.price?.value {
                if price > latestPrice {
                    cell.priceLabel.textColor = stockRedColor
                } else if price < latestPrice {
                    cell.priceLabel.textColor = stockGreenColor
                } else {
                    cell.priceLabel.textColor = stockGrayColor
                }
            }
            
            cell.tapBlock = {
                [weak self] (priceString, number) in
                guard let `self` = self else { return }
                
                self.tapBlock?(priceString, number)
            }
        }
        
        return cell ?? UITableViewCell()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cellHeight
    }
}



class YXDepthTradeEmptyView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(imageView)
        addSubview(contentLabel)

        imageView.snp.makeConstraints { make in
            make.height.equalTo(136)
            make.width.equalTo(170)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.image = YXDefaultEmptyEnums.noData.image()
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.4)
        label.font = .systemFont(ofSize: 14)
        label.text = YXLanguageUtility.kLang(key: "depth_order_noData")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
}
