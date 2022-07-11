//
//  YXStockCompanyMainBusView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockCompanyMainBusView: UIView {
    
    var selecIndexCallBack: (() -> ())?
    
    var model: YXStockIntroduceModel? {
        didSet {
            self.refreshUI()
        }
    }
    
    var HSModel: YXHSStockIntroduceModel? {
        didSet {
            self.HSRefreshUI()
        }
    }
    
    var configModel: YXStockIntroduceConfigModel = YXStockIntroduceConfigModel.init()

    let colorsArray = YXToolUtility.stockColorArrays()
    
    let firstBtn = UIButton.init()
    let secondBtn = UIButton.init()
    let bottomLineView = UIView.init()
    
    let tableView = UITableView.init(frame: .zero, style: .plain)
    
    var pieView = YXStockPieChartView.init(frame: CGRect.init(x: 0, y: 54, width: YXConstant.screenWidth, height: 240))
    
    let emptyView = YXStockEmptyDataView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        
        self.pieView.centerText = YXLanguageUtility.kLang(key: "business")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var firstTabLabel: QMUILabel?
    
    func initUI() {
        
        self.clipsToBounds = true

        addSubview(tapButtonView)
        addSubview(pieView)

        tapButtonView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(30)
        }
        
        let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "primary_business"))
        let secondLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "business_income"))
        let thirdLabel = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "major_proportion"))

        self.firstTabLabel = firstLabel
        firstLabel.numberOfLines = 1
        secondLabel.numberOfLines = 1
        thirdLabel.numberOfLines = 1
        
        addSubview(firstLabel)
        addSubview(secondLabel)
        addSubview(thirdLabel)
        
        firstLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(320)
            make.height.equalTo(28)
            make.trailing.lessThanOrEqualTo(secondLabel.snp.leading).offset(-10)
        }
        secondLabel.snp.makeConstraints { (make) in
            make.height.equalTo(28)
            make.top.equalToSuperview().offset(320)
            make.trailing.equalToSuperview().offset(-100)
        }
        thirdLabel.snp.makeConstraints { (make) in
            make.height.equalTo(28)
            make.top.equalToSuperview().offset(320)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(YXCompanySingleCell.self, forCellReuseIdentifier: "YXCompanySingleCell")
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(firstLabel.snp.bottom)
            make.height.equalTo(0)
        }
        
        self.emptyView.isHidden = true
        addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(tapButtonView.snp.bottom).offset(5)
        }
    }

    lazy var tapButtonView: YXTapButtonView = {
        let view = YXTapButtonView.init(titles: [YXLanguageUtility.kLang(key: "business"), YXLanguageUtility.kLang(key: "area")])
        view.tapAction = { [weak self] index in
            guard let `self` = self else { return }
            if index == 0 {
                self.configModel.isSelectCompbus = true
            }else {
                self.configModel.isSelectCompbus = false
            }

            self.selecIndexCallBack?()
        }
        return view
    }()
    
    // MARK: - 刷新UI
    func refreshUI() {
        log(.warning, tag: kOther, content: "[fix bugs]YXStockCompanyMainBusView refreshUI")
        log(.warning, tag: kOther, content: "[fix bugs]secuCode = \(self.model?.profile?.secuCode ?? ""), companyName = \(self.model?.profile?.companyName ?? "")")
        var count = 0
        var list = [YXIntroduceMaincomp]()
        if self.configModel.isSelectCompbus {
            count = self.model?.maincompbus?.count ?? 0
            list = self.model?.maincompbus ?? [YXIntroduceMaincomp]()
        } else {
            count = self.model?.maincomparea?.count ?? 0
            list = self.model?.maincomparea ?? [YXIntroduceMaincomp]()
        }
        
        list = list.sorted { (s1, s2) -> Bool in
            (s1.proportion ?? 0) > (s2.proportion ?? 0)
        }
        
        // 排序
        if self.configModel.isSelectCompbus {
            self.model?.maincompbus = list
            tapButtonView.resetSelectIndex(0)
            self.firstTabLabel?.text = YXLanguageUtility.kLang(key: "primary_business")
            self.pieView.centerText = YXLanguageUtility.kLang(key: "business")
        } else {
            self.model?.maincomparea = list
            tapButtonView.resetSelectIndex(1)
            self.firstTabLabel?.text = YXLanguageUtility.kLang(key: "primary_area")
            self.pieView.centerText = YXLanguageUtility.kLang(key: "area")
        }
        
        var height = 0
        if count > 5 {
            height = count * 40 + 40
        } else {
            height = count * 40
        }
        self.tableView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        self.emptyView.isHidden = count > 0
        
        var colors = [UIColor]()
        var numbers = [NSNumber]()
        let colorsRes = YXToolUtility.stockColorArrays()
        for i in 0..<list.count {
            let model = list[i]
            let number = NSNumber.init(value: (model.proportion ?? 0) / 100)
            var color: UIColor = colorsRes.last ?? UIColor.white
            if i < colorsRes.count {
                color = colorsRes[i]
            }
            numbers.append(number)
            colors.append(color)
        }
        
        pieView.setForPieViewData(numbers, andColor: colors)
        
        self.tableView.reloadData()
    }
    
    // MARK: - 刷新UI
    func HSRefreshUI() {
        
        var count = 0
        var list = [YXHSIntroduceMaincomp]()
        if self.configModel.isSelectCompbus {
            count = self.HSModel?.maincompbus?.count ?? 0
            list = self.HSModel?.maincompbus ?? [YXHSIntroduceMaincomp]()
        } else {
            count = self.HSModel?.maincomparea?.count ?? 0
            list = self.HSModel?.maincomparea ?? [YXHSIntroduceMaincomp]()
        }
        
        list = list.sorted { (s1, s2) -> Bool in
            (s1.businessIncomeRate ?? 0) > (s2.businessIncomeRate ?? 0)
        }
        
        // 排序
        if self.configModel.isSelectCompbus {
            self.HSModel?.maincompbus = list
            tapButtonView.resetSelectIndex(0)
            self.firstTabLabel?.text = YXLanguageUtility.kLang(key: "primary_business")
        } else {
            self.HSModel?.maincomparea = list
            tapButtonView.resetSelectIndex(1)
            self.firstTabLabel?.text = YXLanguageUtility.kLang(key: "primary_area")
        }
        
        if list.count > YXToolUtility.stockColorArrays().count {
            let c = list.count - (YXToolUtility.stockColorArrays().count )
            list.removeLast(c+1)
        }
        
        
        var height = 0
        if count > 5 {
            height = count * 40 + 50
        } else {
            height = count * 40
        }
        self.tableView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        self.emptyView.isHidden = count > 0

        
        var colors = [UIColor]()
        var numbers = [NSNumber]()
        for i in 0..<list.count {
            let model = list[i]
            let number = NSNumber.init(value: (model.businessIncomeRate ?? 0) / 100)
            if YXToolUtility.stockColorArrays().count > i {
                let color = YXToolUtility.stockColorArrays()[i]
                colors.append(color)
            } else {
                let color = UIColor.clear
                colors.append(color)
            }
            numbers.append(number)
        }
        pieView.setForPieViewData(numbers, andColor: colors)
        
        self.tableView.reloadData()
    }


}


extension YXStockCompanyMainBusView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        if self.model != nil {
            if self.configModel.isSelectCompbus {
                count = self.model?.maincompbus?.count ?? 0
                if count > 5 && !self.configModel.isMainBusinessIsExpand {
                    return 5
                }
            } else {
                count = self.model?.maincomparea?.count ?? 0
                if count > 5 && !self.configModel.isMainAeraIsExpand {
                    return 5
                }
            }
        } else {
            if self.configModel.isSelectCompbus {
                count = self.HSModel?.maincompbus?.count ?? 0
                if count > 5 && !self.configModel.isMainBusinessIsExpand {
                    return 5
                }
            } else {
                count = self.HSModel?.maincomparea?.count ?? 0
                if count > 5 && !self.configModel.isMainAeraIsExpand {
                    return 5
                }
            }
        }
        
        if count > YXToolUtility.stockColorArrays().count {
            count = YXToolUtility.stockColorArrays().count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXCompanySingleCell", for: indexPath) as! YXCompanySingleCell
        if self.model != nil {
            if self.configModel.isSelectCompbus {
                cell.model = self.model?.maincompbus?[indexPath.row]
            } else {
                cell.model = self.model?.maincomparea?[indexPath.row]
            }
        } else {
            if self.configModel.isSelectCompbus {
                cell.HSModel = self.HSModel?.maincompbus?[indexPath.row]
            } else {
                cell.HSModel = self.HSModel?.maincomparea?[indexPath.row]
            }
        }


        if indexPath.row < colorsArray.count {
            cell.cycleView.backgroundColor = colorsArray[indexPath.row]
        } else {
            cell.cycleView.backgroundColor = colorsArray.last
        }

        
        return cell
    }
    
    // 底部的view
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var count = 0
        if self.model != nil {
            if self.configModel.isSelectCompbus {
                count = self.model?.maincompbus?.count ?? 0
            } else {
                count = self.model?.maincomparea?.count ?? 0
            }
        } else {
            if self.configModel.isSelectCompbus {
                count = self.HSModel?.maincompbus?.count ?? 0
            } else {
                count = self.HSModel?.maincomparea?.count ?? 0
            }
        }
       
        
        if count > 5 {
            return 40
        } else {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var count = 0
        if self.model != nil {
            if self.configModel.isSelectCompbus {
                count = self.model?.maincompbus?.count ?? 0
            } else {
                count = self.model?.maincomparea?.count ?? 0
            }
        } else {
            if self.configModel.isSelectCompbus {
                count = self.HSModel?.maincompbus?.count ?? 0
            } else {
                count = self.HSModel?.maincomparea?.count ?? 0
            }
        }
        
        
        if count > 5 {
            let btn = self.getFootBtn()
            if self.configModel.isSelectCompbus {
                btn.isSelected = self.configModel.isMainBusinessIsExpand
            } else {
                btn.isSelected = self.configModel.isMainAeraIsExpand
            }
            return btn
        } else {
            return UIView.init()
        }
    }
    
    func getFootBtn() -> UIButton {
        let btn = UIButton.init(frame: .zero)
        btn.setTitle(YXLanguageUtility.kLang(key: "show_more"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "stock_detail_pack_up"), for: .selected)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(self.showMoreBtnDidClick(_:)), for: .touchUpInside)
        
        return btn
    }
}

extension YXStockCompanyMainBusView {
    @objc func showMoreBtnDidClick(_ sender: UIButton) {
        
        if self.configModel.isSelectCompbus {
            self.configModel.isMainBusinessIsExpand = !self.configModel.isMainBusinessIsExpand
        } else {
            self.configModel.isMainAeraIsExpand = !self.configModel.isMainAeraIsExpand
        }
        
        self.selecIndexCallBack?()
    }
}
