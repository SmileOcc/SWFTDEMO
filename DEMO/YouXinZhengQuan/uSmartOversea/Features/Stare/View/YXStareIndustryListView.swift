//
//  YXStareIndustryListView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

enum YXIndustryListStyle {
    case forStare
    case forStockFilter
}

class YXStareIndustryListCell: UITableViewCell {

    var showSeparatorLine: Bool = false {
        didSet {
            line.isHidden = !showSeparatorLine
        }
    }
    var titleLabel: UILabel
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    lazy var line: UIView = {
        let line = UIView.line()
        return line
    }()

    lazy var selectedIcon: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(named: "normal_selected")
        imageV.isHidden = true
        return imageV
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        self.titleLabel = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.selectionStyle = .none
        contentView.addSubview(line)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectedIcon)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        selectedIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }

}

class YXStareIndustryListView: UIView {

    var uiStyle: YXIndustryListStyle = .forStare

    var tableView: YXTableView
    
    @objc var clickIndustryCallBack: ((_ dic: [String: Any]) -> ())?
    
    var isIndex: Bool = false
    
    var industryDic: [String: Any]? {
        didSet {
            if let sourceDic = self.industryDic {
               let dic = sourceDic.sorted { (obj1, obj2) -> Bool in
            
                    let key1 = NSString(string: obj1.key)
                    let key2 = NSString(string: obj2.key)
                
                    return key1.character(at: 0) < key2.character(at: 0)

                }
                self.titleArr.removeAll()
                self.contentArr.removeAll()
                self.selectedFlagArr.removeAll()
                for (key, value) in dic {
                    self.titleArr.append(key)
                    var subContentArr = [Any]()
                    var subSelectedFlagArr = [Bool]()
                    if let arr = value as? [Any] {
                        for obj in arr {
                            subContentArr.append(obj)
                            subSelectedFlagArr.append(false)
                        }
                    }
                    self.contentArr.append(subContentArr)
                    self.selectedFlagArr.append(subSelectedFlagArr)
                }
                self.tableView.reloadData()
            }

        }
    }
    
    var indexDic: [String: Any]? {
        didSet {
            if let sourceDic = self.indexDic {
                if let market = sourceDic["market"] as? String, let list = sourceDic["list"] as? [Any] {
                    self.titleArr.removeAll()
                    self.contentArr.removeAll()
                    self.titleArr.append(market)
                    self.contentArr.append(list)
                    self.tableView.reloadData()
                }
            }
        }
    }

    lazy var indexKey: String = {
        if YXUserManager.isENMode() {
            return "index_en"
        } else if YXUserManager.curLanguage() == .CN {
            return "index_cn"
        } else {
            return "index_tc"
        }
    }()
    
    var titleArr = [String]()
    var contentArr = [[Any]]()
    var selectedFlagArr = [[Bool]]()

    init(frame: CGRect, uiStyle: YXIndustryListStyle = .forStare) {

        self.tableView = YXTableView.init(frame: .zero, style: .grouped)
        self.uiStyle = uiStyle

        super.init(frame: frame)

        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(YXStareIndustryListCell.self, forCellReuseIdentifier: "YXStareIndustryListCell")
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        if uiStyle == .forStare {

            tableView.snp.makeConstraints { (make) in
                make.leading.equalToSuperview()
                make.top.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-12)
                make.bottom.equalToSuperview().offset(-12)
            }
        }else {

            tableView.snp.makeConstraints { (make) in
                make.left.right.top.bottom.equalToSuperview()
            }
        }
    }

}

extension YXStareIndustryListView {
    
    func getSectionView(with title: String?) -> UIView {
        let view = UIView.init()
        let bgView = UIView.init()
        bgView.backgroundColor = UIColor.qmui_color(withHexString: "F4F4F4")
        let label = UILabel.init(text: title ?? "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 12))!
        
        view.addSubview(bgView)
        bgView.addSubview(label)
        
        if uiStyle == .forStare {
            bgView.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(12)
                make.trailing.equalToSuperview().offset(-49)
                make.height.equalTo(18)
                make.centerY.equalToSuperview()
            }
        }else {
            bgView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                //                make.trailing.equalToSuperview().offset(-49)
                make.height.equalTo(30)
                make.centerY.equalToSuperview()
            }
        }
        
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(13)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
            make.width.equalTo(50)
        }
        
        return view
    }


    func getSelectedItems() -> [Any] {
        var arr: [Any] = []
        for (index, list) in self.contentArr.enumerated() {
            for (subIndex, subItem) in list.enumerated() {
                let isSelected = self.selectedFlagArr[index][subIndex]
                if isSelected {
                    arr.append(subItem)
                }
            }
        }
        return arr
    }
}

extension YXStareIndustryListView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.contentArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let arr = self.contentArr[section]
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "YXStareIndustryListCell", for: indexPath) as! YXStareIndustryListCell
        let arr = self.contentArr[indexPath.section]
        let dic = arr[indexPath.row]
        
        if let dic = dic as? [String : Any] {
            if self.isIndex {
                if let name = dic[self.indexKey] as? String, let count = dic["stock_num"] as? Int {
                    cell.titleLabel.text = name + "(" + "\(count)" + ")"
                } else {
                    cell.titleLabel.text = "--"
                }
            } else {
                if let name = dic["industry_name"] as? String, let count = dic["stock_num"] as? Int {

                    if uiStyle == .forStockFilter {
                        cell.titleLabel.text = name
                    }else {
                        cell.titleLabel.text = name + "(" + "\(count)" + ")"
                    }
                } else {
                    cell.titleLabel.text = "--"
                }
            }
        }

        if uiStyle == .forStockFilter {
            let arr = self.selectedFlagArr[indexPath.section]
            let isSelected = arr[indexPath.row]
            cell.selectedIcon.isHidden = !isSelected
        }

        cell.showSeparatorLine = (uiStyle == .forStockFilter)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if uiStyle == .forStare {
            let arr = self.contentArr[indexPath.section]
            let dic = arr[indexPath.row] as? [String : Any]
            if let dic = dic {
                clickIndustryCallBack?(dic)
            }
        }else if uiStyle == .forStockFilter {
            let arr = self.selectedFlagArr[indexPath.section]
            let isSelected = arr[indexPath.row]
            self.selectedFlagArr[indexPath.section][indexPath.row] = !isSelected

            self.tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if uiStyle == .forStockFilter {
            return 42
        }
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.titleArr[section]
        return self.getSectionView(with: title)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isIndex {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.1
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
      
        if self.isIndex {
            return nil
        }
        return self.titleArr

    }
}

