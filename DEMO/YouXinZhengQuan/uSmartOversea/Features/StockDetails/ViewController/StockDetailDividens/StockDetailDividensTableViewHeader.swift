//
//  StockDetailDividensTableViewHeader.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/20.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class DividensYearDataView: UIView {
    
    lazy var dataLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont24()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var typeLabel:UILabel = {
        let label = UILabel.init()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(dataLabel)
        addSubview(typeLabel)
        
        dataLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        typeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dataLabel.snp.bottom).offset(4)
        }
    }
}

class DividensTopView: UIView,YXStockDetailSubHeaderViewProtocol {
    
    var model:StockDetailDividensResponse? {
        didSet {
            guard let model = model,model.list.count > 0 else {
                return
            }
            //年份按钮倒叙
            let dateModel = YXDateToolUtility.dateTime(withTime: model.date)
            
            if let showModel = model.list.first {
                if let div_amount = showModel.div_amount?.doubleValue {
                    rateView.dataLabel.text = String.init(format: "%.3f", div_amount)
                } else {
                    rateView.dataLabel.text = "--"
                }
                if showModel.date == dateModel.year {
                    yieldView.typeLabel.text = YXLanguageUtility.kLang(key: "market_dividends_yield")
                    rateView.typeLabel.text = YXLanguageUtility.kLang(key: "market_dividends_rate")
                } else {
                    yieldView.typeLabel.text = YXLanguageUtility.kLang(key: "market_dividends_yield") + "(" + showModel.date + ")"
                    rateView.typeLabel.text = YXLanguageUtility.kLang(key: "market_dividends_rate") + "(" + showModel.date + ")"
                }
                if let div_yield = showModel.div_yield?.doubleValue {
                    yieldView.dataLabel.text = String.init(format: "%.2f%%", div_yield * 100)
                } else {
                    yieldView.dataLabel.text = "--"
                }
                
            }

        }
    }
    
    
    private lazy var rateView: DividensYearDataView = {
         let view = DividensYearDataView.init()
         view.backgroundColor = QMUITheme().blockColor()
         view.layer.cornerRadius = 4
         view.layer.masksToBounds = true
         return view
     }()
     
     private lazy var yieldView: DividensYearDataView = {
         let view = DividensYearDataView.init()
         view.backgroundColor = QMUITheme().blockColor()
         view.layer.cornerRadius = 4
         view.layer.masksToBounds = true
         return view
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(rateView)
        addSubview(yieldView)
        
        let topViewHeight = (YXConstant.screenWidth - 47)/2
        rateView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(16)
            make.height.equalTo(88)
            make.width.equalTo(topViewHeight)
        }
        yieldView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(88)
            make.width.equalTo(topViewHeight)
        }
    }
}

class DividensYearListView: UIView,YXStockDetailSubHeaderViewProtocol {
    
    @objc var selectCallBack: ((_ title: String) -> ())?
    
    let columnCount = 4
    
    lazy var yearListView:QMUIGridView = {
        let view = QMUIGridView.init(column: columnCount, rowHeight: 30)!
        view.backgroundColor = .clear
        view.padding = UIEdgeInsets.init(top: 0, left: 16, bottom: 34, right: 16)
        view.separatorWidth = 10
        view.separatorColor = .clear
        return view
    }()
    
    var  selectTypeBtn:QMUIButton? = nil
    
    var defaultSelectIndex = 0
    
    var row:Int?
    
    var titles: [String]? {
     
        didSet {
            
            guard let titles = titles else { return }

            row = titles.count / columnCount + (titles.count % columnCount > 0 ? 1 : 0)

            yearListView.removeAllSubviews()

            for (i, year) in titles.enumerated() {
                let btn = QMUIButton.init()
                btn.setTitle(year, for: .normal)
                btn.layer.cornerRadius = 4
                btn.clipsToBounds = true
                btn.titleLabel?.font = .systemFont(ofSize: 12)
                btn.titleLabel?.adjustsFontSizeToFitWidth = true
                btn.titleLabel?.minimumScaleFactor = 0.6
                btn.layer.borderColor = QMUITheme().pointColor().cgColor
                btn.layer.borderWidth = 1.0
                btn.setTitleColor(UIColor.themeColor(withNormal: UIColor.qmui_color(withHexString: "#414FFF")!, andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!), for: .selected)
                btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
                btn.setBackgroundImage(UIImage.tabItemNoramalDynamicImage(), for: .normal)
                btn.setBackgroundImage(UIImage.tabItemSelectedDynamicImage(), for: .selected)
                
                if i == defaultSelectIndex {
                    self.selectTypeBtn = btn;
                    btn.layer.borderColor = UIColor.clear.cgColor
                    btn.isSelected = true
                }
                btn.tag = i;
                btn.titleLabel?.adjustsFontSizeToFitWidth = true

                btn.qmui_tapBlock = { [weak self] sender in
                    guard let `self` = self, let b = sender, let btn = b as? QMUIButton, !btn.isSelected else { return }
                    btn.isSelected = true
                    btn.layer.borderColor = UIColor.clear.cgColor
                    self.selectTypeBtn?.isSelected = false
                    self.selectTypeBtn?.layer.borderColor = QMUITheme().pointColor().cgColor
                    self.selectTypeBtn? = btn
                    self.selectCallBack?(btn.titleLabel?.text ?? "")
                }
                yearListView.addSubview(btn)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(yearListView)
        yearListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class StockDetailDividensTableViewHeader: UIView,YXStockDetailHeaderViewProtocol {
    
    var model:StockDetailDividensResponse? {
        didSet {
            guard let model = model,model.list.count > 0 else {
                return
            }
            let defaultModle = model.list.reversed().last
            topView.model = model
            
            yearTitles = model.list.reversed().map{ $0.date }
            //先取chartView选中的类型 没有在默认选中最后一个
            if let selectModel = self.chartView.selectModel {
                yearListView.defaultSelectIndex = self.getSelectYearIndex(yearStr: selectModel.date)
            } else {
                yearListView.defaultSelectIndex = self.getSelectYearIndex(yearStr: defaultModle?.date ?? "")
                self.chartView.selectModel = defaultModle
            }
            yearListView.titles = yearTitles
            if let row = yearListView.row {
                yearListView.contentHeight = CGFloat(row*40 + 24)
            }
            //柱状图倒序
            self.chartView.model = model.list.reversed()
        }
    }
    
    var yearTitles:[String] = []
    
    func getSelectYearIndex(yearStr:String) ->Int {
        return yearTitles.map{ $0.int64Value }.firstIndex(of: yearStr.int64Value) ?? 0
    }
    
    var heightDidChange: (() -> Void)?
        
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    var bottomMargin: CGFloat {
        return 8
    }
    
    private lazy var topView: DividensTopView = {
        let view = DividensTopView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    
    private lazy var chartView:DividensChartView = {
        let view = DividensChartView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.selectCallBack = { [weak self] index in
            guard let `self` = self else { return }
            if index ==  1 {
                self.yearListView.contentHeight = 0
                self.yearListView.isHidden = true
                self.chartView.updateUI(type: .Year)
            } else if index == 0 {
                if let row = self.yearListView.row {
                    self.yearListView.contentHeight = CGFloat(row*40 + 24)
                }
                self.yearListView.isHidden = false
                if let yearStr = self.chartView.selectModel?.date {
                    self.chartView.updateUI(type: .Quarter(yearStr:yearStr))
                }
            }
        }
        return view
    }()
    
    private lazy var yearListView:DividensYearListView = {
        let view = DividensYearListView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.selectCallBack = { [weak self] title in
            guard let `self` = self else { return }
            self.chartView.updateUI(type: .Quarter(yearStr: title))
        }
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        backgroundColor = QMUITheme().backgroundColor()
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.bottomMargin)
            make.top.equalToSuperview().offset(self.topMargin)
        }
        
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(chartView)
        stackView.addArrangedSubview(yearListView)

        
        
        topView.contentHeight = 128
        chartView.contentHeight = 326
        yearListView.contentHeight = 80 + 24
        
        configStackView()
        
        
    }
}
