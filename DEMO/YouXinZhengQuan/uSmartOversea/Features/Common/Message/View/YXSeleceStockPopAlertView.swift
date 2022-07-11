//
//  YXSeleceStockPopAlertView.swift
//  uSmartOversea
//
//  Created by usmart on 2021/12/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSeleceStockCell: UITableViewCell {
    
    lazy var marketImageView: UIImageView = {
        //市场小写
        let marketImageView = UIImageView()
        return marketImageView
    }()
    
    lazy var stockTitleLabel: UILabel = {
        let stockTitleLabel = UILabel()
        stockTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        stockTitleLabel.textColor = UIColor.qmui_color(withHexString: "#2A2A34")
        
        stockTitleLabel.numberOfLines = 1
        stockTitleLabel.minimumScaleFactor = 0.9
        stockTitleLabel.adjustsFontSizeToFitWidth = true
        return stockTitleLabel
    }()
    
    lazy var stockNameLabel: UILabel = {
        let stockTitleLabel = UILabel()
        stockTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        stockTitleLabel.textColor = UIColor.qmui_color(withHexString: "#555665")
        stockTitleLabel.numberOfLines = 1
        stockTitleLabel.minimumScaleFactor = 0.9
        stockTitleLabel.adjustsFontSizeToFitWidth = true
        return stockTitleLabel
    }()
    
    lazy var stockDescBeginLabel: UILabel = {
        let stockDescLabel = UILabel()
        stockDescLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        stockDescLabel.textColor = UIColor.qmui_color(withHexString: "#414FFF")
        stockDescLabel.numberOfLines = 1
        stockDescLabel.lineBreakMode = .byTruncatingTail
        stockDescLabel.text = "#"
        return stockDescLabel
    }()
    
    lazy var stockDescLabel: UILabel = {
        let stockDescLabel = UILabel()
        stockDescLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        stockDescLabel.textColor = UIColor.qmui_color(withHexString: "#2A2A34")
        stockDescLabel.numberOfLines = 1
        stockDescLabel.textAlignment = .left
        stockDescLabel.lineBreakMode = .byTruncatingTail
        return stockDescLabel
    }()
    
    lazy var stockRateLabel: UILabel = {
        let stockRateLabel = UILabel()
        stockRateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        stockRateLabel.textColor = .white
        stockRateLabel.textAlignment = .center
        stockRateLabel.layer.cornerRadius = 3
        stockRateLabel.layer.masksToBounds = true
        return stockRateLabel
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.qmui_color(withHexString: "#DDDDDD")
        return line
    }()
    
    lazy var selectButton: UIButton = {
        let selectButton = UIButton.init(frame: .zero)
        selectButton.setBackgroundImage(UIImage(named: "noSelectStockBg"), for: .normal)
        selectButton.setBackgroundImage(UIImage(named: "selectStockBg"), for: .selected)
        selectButton.isUserInteractionEnabled = false
//        selectButton.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
//            guard let `self` = self else { return }
//            self.selectButton.isSelected = !self.selectButton.isSelected
//            self.model?.isSelect = self.selectButton.isSelected
//        }).disposed(by: self.rx.disposeBag)
        return selectButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.yx_setOnlyLightStyle()
        selectionStyle = .none
        backgroundColor = .white
        
//        contentView.layer.cornerRadius = 4
//        contentView.layer.masksToBounds = true
        
        contentView.addSubview(stockTitleLabel)
        contentView.addSubview(marketImageView)
        contentView.addSubview(stockNameLabel)
        contentView.addSubview(stockDescBeginLabel)
        contentView.addSubview(stockDescLabel)
        contentView.addSubview(stockRateLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(selectButton)
        
        stockTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualTo(stockRateLabel.snp.leading).offset(-14)
        }
        
        marketImageView.snp.makeConstraints {
            $0.top.equalTo(stockTitleLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(CGSize.init(width: 16, height: 12))
        }
        
        stockNameLabel.snp.makeConstraints {
            $0.leading.equalTo(marketImageView.snp.trailing).offset(2)
            $0.centerY.equalTo(marketImageView.snp.centerY)
            $0.trailing.lessThanOrEqualTo(stockRateLabel.snp.leading).offset(-14)
        }
        
        stockDescBeginLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(marketImageView.snp.bottom).offset(10)
            $0.width.equalTo(8)
        }
        
        stockDescLabel.snp.makeConstraints {
            $0.leading.equalTo(stockDescBeginLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(stockDescBeginLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        stockRateLabel.snp.makeConstraints {
            $0.centerY.equalTo(stockTitleLabel.snp.bottom)
//            $0.trailing.equalTo(lineView.snp.leading).offset(-14)
            $0.right.equalTo(selectButton.snp.left).offset(-12)
            $0.width.equalTo(66)
            $0.height.equalTo(24)
        }
        
        selectButton.snp.makeConstraints {
            $0.centerY.equalTo(stockRateLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }
        
        
        lineView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var model: RecommendStockModel? {
        didSet {
            stockTitleLabel.text = model?.stockName
            selectButton.isSelected = model?.isSelect ?? true
            stockDescLabel.text = model?.desc
            marketImageView.image = UIImage(named: model?.quote?.market ?? "")
            stockNameLabel.text = model?.symbol
            
            if let quote = model?.quote,let value = quote.pctchng?.value ,let sNetchng = quote.netchng?.value{
                
                var uoDownStr = ""
                if sNetchng > 0 {
                    uoDownStr = "+"
                    self.stockRateLabel.backgroundColor = UIColor.qmui_color(withHexString: "#00C767")
                } else if sNetchng < 0 {
                    self.stockRateLabel.backgroundColor = UIColor.qmui_color(withHexString: "#FF6933")
                } else {
                    self.stockRateLabel.backgroundColor = UIColor.qmui_color(withHexString: "#B0B6CB")
                }
                self.stockRateLabel.text = uoDownStr + String(format: "%.2f%%", Double( value )/100.0)
            }
            
        }
        
    }
    

}


class YXSeleceStockPopAlertView: UIView {
    
    var addLikeClosure:((Bool)->())?
    var modelList: [RecommendStockModel]
    lazy var titleImageView: UIImageView = {
        let titleImageView = UIImageView(image: UIImage(named: "seleceStockPop"))
        return titleImageView
    }()
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#2A2A34")
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "market_hot_stock_pop")
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(YXSeleceStockCell.self, forCellReuseIdentifier: NSStringFromClass(YXSeleceStockCell.self))
        return tableView
    }()
    
    lazy var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = .white
        shadowView.layer.shadowColor = UIColor(red: 0.16, green: 0.16, blue: 0.2, alpha: 0.08).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -4)
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 16
        return shadowView
    }()
    
    lazy var coverImageView: UIImageView = {
        let coverImageView = UIImageView(image: UIImage(named: "coverImage"))
        return coverImageView
    }()
    
    lazy var addButton: UIButton = {
        let addButton = UIButton.init(frame: .zero)
        addButton.setTitle(YXLanguageUtility.kLang(key: "market_hot_stock_add"), for: .normal)
        addButton.setTitleColor(UIColor.qmui_color(withHexString: "#FFFFFF"), for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.layer.cornerRadius = 4
        addButton.layer.masksToBounds = true
        addButton.backgroundColor = UIColor.qmui_color(withHexString: "#414FFF")

        let topColor = UIColor.qmui_color(withHexString: "#2F7DFF")
        let bottomColor = UIColor.qmui_color(withHexString: "#015EFF")
        let gradientColors = [topColor!.cgColor, bottomColor!.cgColor]
        //创建CAGradientLayer对象并设置参数
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: 251, height: 40)
//        addButton.layer.insertSublayer(gradientLayer, at: 0)
        
        addButton.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            guard let `self` = self else { return }
            var showHub = false;
            self.modelList.forEach{
                if $0.isSelect {
                    showHub = true
                    let secuID = YXSecuID(string: $0.secu_code ?? "")
                    let secu = YXSecu.init()
                    secu.market = secuID.market
                    secu.symbol = secuID.symbol
                    secu.name = $0.stockName ?? ""
                    YXSecuGroupManager.shareInstance().append(secu)
                }
            }
            self.addLikeClosure?(showHub)
        }).disposed(by: self.rx.disposeBag)
        
        return addButton
    }()
    
    init(frame: CGRect,  modelList:[RecommendStockModel]) {
        self.modelList = modelList
        super.init(frame: frame)
        self.yx_setOnlyLightStyle()
        
        let secus:[Secu] = self.modelList.map {
            let secuID = YXSecuID(string: $0.secu_code ?? "")
            return Secu.init(market: secuID.market, symbol: secuID.symbol)
        }
        
        YXQuoteManager.sharedInstance.onceRtSimpleQuote(secus: secus, level: .delay) { [weak self] list, scheme in
            guard let `self` = self else { return }
            
            list.forEach { quote in
                let market = quote.market ?? ""
                let symbol = quote.symbol ?? ""
                self.modelList.forEach { recommendStockModel in
                    if recommendStockModel.secu_code == (market + symbol) {
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
        
        let topColor = UIColor.qmui_color(withHexString: "#005DFF")
        let bottomColor = UIColor.qmui_color(withHexString: "#82CCFF")
        let gradientColors = [topColor!.cgColor, bottomColor!.cgColor]
        
        //定义每种颜色所在的位置
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        
        //创建CAGradientLayer对象并设置参数
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        //设置其CAGradientLayer对象的frame，并插入view的layer
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: 311, height: 319)
//        self.layer.insertSublayer(gradientLayer, at: 0)
        self.backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addSubview(tableView)
        addSubview(shadowView)
        addSubview(addButton)
        
        let logoImageView = UIImageView(image: UIImage(named: "bgPopImage"))
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(-8)
            $0.size.equalTo(CGSize.init(width: 110, height: 90))
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(37)
            $0.leading.equalToSuperview().offset(15)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalToSuperview().offset(0)
            $0.trailing.equalToSuperview().offset(0)
            $0.height.equalTo(243)
        }
        
        shadowView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tableView.snp.bottom)
        }
        
        addButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }
        
        
    }
}


extension YXSeleceStockPopAlertView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        modelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXSeleceStockCell.self), for: indexPath) as! YXSeleceStockCell
        cell.model = self.modelList[safe:indexPath.row]
        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        81
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView .cellForRow(at: indexPath) as? YXSeleceStockCell {
            cell.selectButton.isSelected = !cell.selectButton.isSelected
            cell.model?.isSelect = cell.selectButton.isSelected
        }
    }

}
