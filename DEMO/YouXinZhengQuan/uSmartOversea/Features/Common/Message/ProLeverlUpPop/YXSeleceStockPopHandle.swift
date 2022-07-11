//
//  YXSeleceStockPopHandele.swift
//  YouXinZhengQuan
//
//  Created by lennon on 2021/10/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

let socketAllMarket = ["sh", "sz", "hk", "us", "usoption", "cryptos"]

class YXSeleceStockCell1: UITableViewCell {
    
    
    lazy var marketImageView: UIImageView = {
        //市场小写
        let marketImageView = UIImageView()
        return marketImageView
    }()
    
    lazy var stockTitleLabel: UILabel = {
        let stockTitleLabel = UILabel()
        stockTitleLabel.font = UIFont.systemFont(ofSize: 16)
        stockTitleLabel.textColor = QMUITheme().textColorLevel1()
        stockTitleLabel.numberOfLines = 1
        stockTitleLabel.minimumScaleFactor = 0.9
        stockTitleLabel.adjustsFontSizeToFitWidth = true
        return stockTitleLabel
    }()
    
    lazy var stockDescLabel: UILabel = {
        let stockDescLabel = UILabel()
        stockDescLabel.font = UIFont.systemFont(ofSize: 10)
        stockDescLabel.textColor = QMUITheme().textColorLevel3()
        stockDescLabel.numberOfLines = 1
        stockDescLabel.lineBreakMode = .byTruncatingTail
        return stockDescLabel
    }()
    
    lazy var stockRateButton: QMUIButton = {
        let stockRateButton = QMUIButton()
        stockRateButton.imagePosition = .left
        stockRateButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        stockRateButton.setTitleColor(UIColor.qmui_color(withHexString: "#FFFFFF"), for: .normal)
        stockRateButton.backgroundColor = QMUITheme().stockRedColor()
        stockRateButton.layer.cornerRadius = 3
        stockRateButton.layer.masksToBounds = true
        stockRateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        stockRateButton.titleLabel?.minimumScaleFactor = 0.8
        stockRateButton.isUserInteractionEnabled = false
        return stockRateButton
    }()
    
    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.07)
        return lineView
    }()
    
    lazy var selectButton: YXExpandAreaButton = {
        let selectButton = YXExpandAreaButton.init(frame: .zero)
        selectButton.setBackgroundImage(UIImage(named: "noSelectStockBg"), for: .normal)
        selectButton.setBackgroundImage(UIImage(named: "selectStockBg"), for: .selected)
        selectButton.isUserInteractionEnabled = false
//        selectButton.expandX = 5
//        selectButton.expandY = 5
//        selectButton.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
//            guard let `self` = self else { return }
//            self.selectButton.isSelected = !self.selectButton.isSelected
//            self.model?.isSelect = self.selectButton.isSelected
//        }).disposed(by: self.rx.disposeBag)
        return selectButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = UIColor.qmui_color(withHexString: "#F6F6F6")
        
        contentView.addSubview(marketImageView)
        contentView.addSubview(stockTitleLabel)
        contentView.addSubview(stockDescLabel)
        contentView.addSubview(stockRateButton)
        contentView.addSubview(selectButton)
        contentView.addSubview(lineView)
        
        marketImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(17)
            $0.height.equalTo(11)
        }
        
        stockTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.lessThanOrEqualTo(stockRateButton.snp.leading).offset(-14)
        }
        
        stockDescLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalTo(stockTitleLabel)
            $0.trailing.lessThanOrEqualTo(stockRateButton.snp.leading).offset(-14)
        }
        
        stockRateButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(selectButton.snp.leading).offset(-19)
            $0.width.equalTo(75)
            $0.height.equalTo(20)
        }
        
        selectButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(16)
            $0.height.equalTo(15)
        }
        
        lineView.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var model: RecommendStockModel? {
        didSet {
            
            switch YXUserManager.curLanguage() {
            case .CN:
                stockDescLabel.text = model?.introductionCn
            case .EN:
                stockDescLabel.text = model?.introductionEn
            case .HK:
                stockDescLabel.text = model?.introductionTc
            case .unknown, .ML, .TH:
                stockDescLabel.text = model?.introductionEn
            }
            
            selectButton.isSelected = model?.isSelect ?? true
            marketImageView.image = UIImage(named: model?.quote?.market ?? "")
            
            
            if let quote = model?.quote,let value = quote.pctchng?.value ,let sNetchng = quote.netchng?.value{

                if sNetchng > 0 {
                    self.stockRateButton.backgroundColor = QMUITheme().stockRedColor()
                    self.stockRateButton.setImage(UIImage(named: "up"), for: .normal)
                } else if sNetchng < 0 {
                    self.stockRateButton.backgroundColor = QMUITheme().stockGreenColor()
                    self.stockRateButton.setImage(UIImage(named: "down"), for: .normal)

                } else {
                    self.stockRateButton.backgroundColor = QMUITheme().stockGrayColor()
                }
                self.stockRateButton.setTitle(String(format: "%.2f%%", Double( abs(value) )/100.0), for: .normal)
                self.stockTitleLabel.text = quote.name ?? ""

            }
            
        }
        
    }
    
    
}

class YXSeleceStockPopAlertView1: UIView {
    
    var addLikeClosure:(()->())?
    var modelList: [RecommendStockModel]
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = QMUITheme().mainThemeColor()
        titleLabel.text = YXLanguageUtility.kLang(key: "select_stock_title")
        return titleLabel
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(YXSeleceStockCell1.self, forCellReuseIdentifier: NSStringFromClass(YXSeleceStockCell1.self))
        return tableView
    }()
    
    lazy var addButton: UIButton = {
        let addButton = UIButton.init(frame: .zero)
        addButton.setTitle(YXLanguageUtility.kLang(key: "select_stock_add_self_like"), for: .normal)
        addButton.setTitleColor(UIColor.qmui_color(withHexString: "#FFFFFF"), for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addButton.layer.cornerRadius = 4
        addButton.layer.masksToBounds = true
        let topColor = QMUITheme().buy()
        let bottomColor = QMUITheme().buy()
        let gradientColors = [topColor.cgColor, bottomColor.cgColor]
        
        //创建CAGradientLayer对象并设置参数
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint.init(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint.init(x: 1.0, y: 0.0)
        
        //设置其CAGradientLayer对象的frame，并插入view的layer
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: 250, height: 47)
        addButton.layer.insertSublayer(gradientLayer, at: 0)
        addButton.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            guard let `self` = self else { return }
            self.modelList.forEach{
                if $0.isSelect {
                    let secuID = YXSecuID(string: $0.symbol ?? "")
                    let secu = YXSecu.init()
                    secu.market = secuID.market
                    secu.symbol = secuID.symbol
                    secu.name = $0.stockName ?? ""
                    YXSecuGroupManager.shareInstance().append(secu)
                }
            }
            self.addLikeClosure?()
        }).disposed(by: self.rx.disposeBag)
        return addButton
    }()
    
    init(frame: CGRect,  modelList:[RecommendStockModel]) {
        self.modelList = modelList
        super.init(frame: frame)
        
        let secus:[Secu] = self.modelList.map {
            let secuID = YXSecuID(string: $0.symbol ?? "")
            return Secu.init(market: secuID.market, symbol: secuID.symbol)
        }
        YXQuoteManager.sharedInstance.onceRtSimpleQuote(secus: secus, level: .user) { [weak self] list, scheme in
            guard let `self` = self else { return }
            
            list.forEach { quote in
                let market = quote.market ?? ""
                let symbol = quote.symbol ?? ""
                self.modelList.forEach { recommendStockModel in
                    if recommendStockModel.symbol == (market + symbol) {
                        recommendStockModel.quote = quote
                    }
                }
            }
            self.tableView .reloadData()
        }
        
        self.initUI()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(addButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(69)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(180)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-31)
            $0.height.equalTo(47)
        }
        
        
    }
}


extension YXSeleceStockPopAlertView1: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        modelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXSeleceStockCell1.self), for: indexPath) as! YXSeleceStockCell1
        cell.model = self.modelList[indexPath.row]
        return cell
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView .cellForRow(at: indexPath) as? YXSeleceStockCell1 {
            cell.selectButton.isSelected = !cell.selectButton.isSelected
            cell.model?.isSelect = cell.selectButton.isSelected
        }
    }
    
}

class YXSeleceStockPopHandle: NSObject {
    
    var marKetRecommendStockMap:[Int: [RecommendStockModel]] = [:]
    var opthionRecommendStockMap:[Int:[RecommendStockModel] ] = [:]
    var stockKingRecommendStockMap:[Int: [RecommendStockModel]] = [:]
    var fundRecommendStockMap:[Int:[RecommendStockModel]] = [:]
    var userCenterRecommendStockMap:[Int:[RecommendStockModel]] = [:]
    
    func getSeleceStockList()  {
        
        let requestModel = YXOtherAdvertisementRequestModel()
        requestModel.show_page = 11 //推荐股票弹窗
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock { [weak self] (model)  in
            if model.code == .success, model.data != nil {
                
                if let responseData = try? JSONSerialization.data(withJSONObject: model.data, options: .prettyPrinted), let adModel = try? JSONDecoder().decode(YXADModel.self, from:  responseData) {
                    
                    guard let `self` = self else { return }
                    adModel.adList?.forEach{
                        
                        if let adID = $0.adID, let showpage = $0.showPage, let adShowPage = AdShowPage.init(rawValue: showpage),
                           let popRecommendStockList = $0.popRecommendStockList, popRecommendStockList.count > 2 {
                            
                            switch adShowPage {
                            case .market:
                                self.marKetRecommendStockMap[adID] = popRecommendStockList
                            case .option:
                                self.opthionRecommendStockMap[adID] = popRecommendStockList
                            case .stockKing:
                                self.stockKingRecommendStockMap[adID] = popRecommendStockList
                            case .fund:
                                self.fundRecommendStockMap[adID] = popRecommendStockList
                            case .userCenter:
                                self.userCenterRecommendStockMap[adID] = popRecommendStockList
                            }
                        }
                    }
                    
                    //请求成功显示一条市场广告
//                    if UIViewController.current() is YXMarketViewController
//                    {
//                        self.showSeleceStockPop(by: .market)
//                    }
                }
                
            }
        } failure: { (baseRequest) in
            
        }
        
    }
    
    func  showSeleceStockPop(by type:AdShowPage)  {
        
        var modelList: [RecommendStockModel] = []
        switch type {
        case .market:
            if let adID = self.marKetRecommendStockMap.keys.first, let stockList = self.marKetRecommendStockMap[adID] {
                let cacheAdId = MMKV.default().int32(forKey: String(adID), defaultValue: -1)
                if cacheAdId != adID {
                    modelList = stockList
                    self.marKetRecommendStockMap.removeValue(forKey: adID)
                    MMKV.default().set(Int32(adID), forKey: String(adID))
                }
            }
        case .option:
            if let adID = self.opthionRecommendStockMap.keys.first, let stockList = self.opthionRecommendStockMap[adID] {
                let cacheAdId = MMKV.default().int32(forKey: String(adID), defaultValue: -1)
                
                if cacheAdId != adID {
                    modelList = stockList
                    self.opthionRecommendStockMap.removeValue(forKey: adID)
                    MMKV.default().set(Int32(adID), forKey: String(adID))
                }
            }
        case .stockKing:
            if let adID = self.stockKingRecommendStockMap.keys.first, let stockList = self.stockKingRecommendStockMap[adID]{
                let cacheAdId = MMKV.default().int32(forKey: String(adID), defaultValue: -1)
                if cacheAdId != adID {
                    modelList = stockList
                    self.stockKingRecommendStockMap.removeValue(forKey: adID)
                    MMKV.default().set(Int32(adID), forKey: String(adID))
                }
            }
        case .fund:
            if let adID = self.fundRecommendStockMap.keys.first, let stockList = self.fundRecommendStockMap[adID] {
                let cacheAdId = MMKV.default().int32(forKey: String(adID), defaultValue: -1)
                if cacheAdId != adID {
                    modelList = stockList
                    self.fundRecommendStockMap.removeValue(forKey: adID)
                    MMKV.default().set(Int32(adID), forKey: String(adID))
                }
            }
        case .userCenter:
            if let adID = self.userCenterRecommendStockMap.keys.first, let stockList = self.userCenterRecommendStockMap[adID] {
                let cacheAdId = MMKV.default().int32(forKey: String(adID), defaultValue: -1)
                if cacheAdId != adID {
                    modelList = stockList
                    self.userCenterRecommendStockMap.removeValue(forKey: adID)
                    MMKV.default().set(Int32(adID), forKey: String(adID))
                }
            }
        }
        
        if modelList.isEmpty {
            return
        }
        
        var showList: [RecommendStockModel] = []
        modelList.forEach { (recommendStockModel) in
            if !YXSecuGroupManager.shareInstance().allSecuGroup.list.contains(where: { ($0.market + $0.symbol) == recommendStockModel.symbol }) {
                showList.append(recommendStockModel)
            }
        }
        
        if showList.count < 3 {
            return
        }
        
//        if showList.count > 4 {
//            showList = showList.prefix(4).map{$0}
//        }
        
        //背景
        let bgView = UIView()
        bgView.backgroundColor = .clear
        
        let alertView = YXSeleceStockPopAlertView1(frame: .zero, modelList: showList )
        alertView.addLikeClosure = { [weak bgView]  in
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "add_selflike_success"))
            bgView?.hide()
        }
        bgView.addSubview(alertView)
        
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(311)
            $0.height.equalTo(340)
        }
        
        let logoImageView = UIImageView(image: UIImage(named: "selectStockLogo"))
        bgView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.trailing.equalTo(alertView).offset(-21)
            $0.top.equalTo(alertView.snp.top).offset(-22)
        }
        
        //关闭按钮
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pop_close"), for: .normal)
        bgView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.top.equalTo(alertView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        bgView.frame = UIScreen.main.bounds
        UIView.hideOldShowAlertView()
        bgView.showInWindow()
        
        //关闭响应
        button.rx.tap.asObservable().subscribe(onNext: { [weak bgView] (_) in
            bgView?.hide()
        }).disposed(by: self.rx.disposeBag)
        
    }
    
}
