//
//  YXTenShareholderCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTenShareholderView: UIView {
    
    var list: [YXIntroduceToptenshareholder]?  {
        didSet {
            
            self.leftTableView.reloadData()
            self.rightTableView.reloadData()
        }
    }
    
    var market: String = kYXMarketHK {
        didSet {
            if let label = self.viewWithTag(kInterestTag) as? QMUILabel, market == kYXMarketHK {
                label.text = YXLanguageUtility.kLang(key: "stock_detail_interests")
            }
            self.rightTableView.reloadData()
        }
    }
    
    let kInterestTag = 2222
    
    var leftTableView: UITableView
    var rightTableView: UITableView
    var rightScorllView: UIScrollView
    
    override init(frame: CGRect) {
        leftTableView = UITableView.init(frame: .zero, style: .plain)
        rightTableView = UITableView.init(frame: .zero, style: .plain)
        rightScorllView = UIScrollView.init()
        rightScorllView.bounces = false
        
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.backgroundColor = QMUITheme().foregroundColor()
        setupTabelView(with: leftTableView)
        setupTabelView(with: rightTableView)
        let scrollViewWidth: CGFloat = 238;
        rightScorllView.contentSize = CGSize.init(width: scrollViewWidth, height: 0)
        rightScorllView.showsVerticalScrollIndicator = false
        rightScorllView.showsHorizontalScrollIndicator = false
        leftTableView.register(YXTenShareholderLeftCell.self, forCellReuseIdentifier: "YXTenShareholderLeftCell")
        rightTableView.register(YXTenShareholderRightCell.self, forCellReuseIdentifier: "YXTenShareholderRightCell")
        
        // 设置顶部的view
        let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "investor_natural"))
        firstLabel.numberOfLines = 2
        firstLabel.adjustsFontSizeToFitWidth = true
        firstLabel.minimumScaleFactor = 0.7
        firstLabel.frame = CGRect.init(x: 16, y: 0, width: 118, height: 36)
        let leftHeadView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 140, height: 36))
        leftHeadView.backgroundColor = QMUITheme().foregroundColor()
        leftHeadView.addSubview(firstLabel)
        leftTableView.tableHeaderView = leftHeadView
        
        let rightHeadView = self.getRightHeadView()
        rightHeadView.frame = CGRect.init(x: 0, y: 0, width: scrollViewWidth, height: 36)
        rightTableView.tableHeaderView = rightHeadView
        
        addSubview(leftTableView)
        addSubview(rightScorllView)
        rightScorllView.addSubview(rightTableView)
        
        leftTableView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(140)
        }
        
        rightScorllView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            if YXConstant.screenWidth > 320 {
                make.width.equalTo(scrollViewWidth)
            } else {
                make.leading.equalToSuperview().offset(140)
            }
        }
        
        rightTableView.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
            make.width.equalTo(scrollViewWidth)
            make.height.equalTo(leftTableView)
        }
    }
    
    func setupTabelView(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 64
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
    }
    
    func getRightHeadView() -> UIView {
        let view = UIView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "number_piles_held"))
        firstLabel.adjustsFontSizeToFitWidth = true
        firstLabel.minimumScaleFactor = 0.3
        let secondLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "major_proportion"))
        secondLabel.adjustsFontSizeToFitWidth = true
        secondLabel.minimumScaleFactor = 0.3
        let thirdLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "changes_piles_held"))
        thirdLabel.tag = kInterestTag
        thirdLabel.adjustsFontSizeToFitWidth = true
        thirdLabel.minimumScaleFactor = 0.3
        
        firstLabel.numberOfLines = 2
        firstLabel.textAlignment = .right
        
        secondLabel.textAlignment = .right
        thirdLabel.numberOfLines = 2
        thirdLabel.textAlignment = .right
        
        view.addSubview(firstLabel)
        view.addSubview(secondLabel)
        view.addSubview(thirdLabel)
        
        firstLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalTo(75)
            make.leading.equalToSuperview()
        }

        secondLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(firstLabel.snp.trailing).offset(5)
            make.top.equalToSuperview()
            make.width.equalTo(60)
        }

        thirdLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(secondLabel.snp.trailing).offset(5)
            make.top.equalToSuperview()
            make.width.equalTo(75)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        return view
    }
}

extension YXTenShareholderView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.list?[indexPath.row]
        if tableView == leftTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YXTenShareholderLeftCell", for: indexPath) as! YXTenShareholderLeftCell
            if let text = model?.investor,text.count > 0 {
                cell.titleLabel.text = text
            } else {
                cell.titleLabel.text = "--"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "YXTenShareholderRightCell", for: indexPath) as! YXTenShareholderRightCell
            if let number = model?.heldSharesVolume, number > 0 {
                cell.firstLabel.text = YXToolUtility.stockData(Double(number), deciPoint: 2, stockUnit: "", priceBase: 0)
            } else {
                cell.firstLabel.text = "--"
            }
            
            if let ratio = model?.proportion, ratio > 0 {
                cell.secondLabel.text = String(format: "%.2f%@", ratio, "%")
            } else {
                cell.secondLabel.text = "--"
            }
            
            if market == kYXMarketHK {
                cell.thirdLabel.yx_setDefaultText(with: model?.holdTypeDesc)
            } else {
                if let number = model?.shareholdingChange {
                    if number == 0 {
                        cell.thirdLabel.text = YXLanguageUtility.kLang(key: "stock_detail_share_unchanged")
                    } else if number > 0{
                        cell.thirdLabel.text = "+" +  YXToolUtility.stockData(Double(number), deciPoint: 2, stockUnit: "", priceBase: 0)
                    } else {
                        cell.thirdLabel.text = YXToolUtility.stockData(Double(number), deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                } else {
                    cell.thirdLabel.text = "--"
                }
            }
   
            return cell
        }
    }
    
}


class YXTenShareholderLeftCell: UITableViewCell {
    
    var titleLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        titleLabel.numberOfLines = 2
        self.selectionStyle = .none
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-5)
        }
    }
}

class YXTenShareholderRightCell: UITableViewCell {
    
    let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    let secondLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    let thirdLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
        thirdLabel.textAlignment = .right
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(thirdLabel)
        
        firstLabel.numberOfLines = 2
        firstLabel.minimumScaleFactor = 8.0 / 14.0
        firstLabel.adjustsFontSizeToFitWidth = true
        firstLabel.textAlignment = .right
        
        secondLabel.numberOfLines = 2
        secondLabel.adjustsFontSizeToFitWidth = true
        secondLabel.minimumScaleFactor = 8.0 / 14.0
        secondLabel.textAlignment = .right
        
        thirdLabel.numberOfLines = 2
        thirdLabel.adjustsFontSizeToFitWidth = true
        thirdLabel.minimumScaleFactor = 8.0 / 14.0

        firstLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(75)
            make.leading.equalToSuperview()
        }

        secondLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(firstLabel.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }

        thirdLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(secondLabel.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(75)
            make.trailing.equalToSuperview().offset(-16)
        }

    }
}


class YXTenShareholderCell: UITableViewCell {

    var list: [YXIntroduceToptenshareholder]? {
        didSet {
            if (self.list?.count ?? 0) > 0 {
                self.emptyView.isHidden = true
            } else {
                self.emptyView.isHidden = false
            }
            self.tenShareholderView.list = self.list
        }
    }
    
    var market: String = kYXMarketHK {
        didSet {
            tenShareholderView.market = market
        }
    }
    
    let tenShareholderView = YXTenShareholderView.init()
    
    let emptyView = YXStockEmptyDataView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
        contentView.addSubview(tenShareholderView)
        tenShareholderView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.emptyView.isHidden = true
        contentView.addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.equalTo(bottomLineView.snp.bottom).offset(5)
            make.edges.equalToSuperview()
        }
    }
    
}
