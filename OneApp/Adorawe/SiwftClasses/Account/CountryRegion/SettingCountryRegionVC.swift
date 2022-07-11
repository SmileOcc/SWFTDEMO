//
//  SettingCountryRegionVC.swift
//  Adorawe
//
//  Created by odd on 2021/9/25.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class SettingCountryRegionVC: OSSVBaseVcSw {

    var topView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = STLRandomColor()
        return view
    }()
    var searchBar:AddressSearchView?
    var tableView:UITableView?

    var countryList:[GroupedModel<AddressItemModel>] = []{
        didSet{
            reloadDataAndScrollDownTable()
        }
    }
    ///源数据
    var srcCountryList:[AddressItemModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = STLLocalizedString_("country_region")

        self.view.addSubview(self.topView)
        
        self.topView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(self.view)
            make.height.equalTo(60)
        }
        
        setupSearchBar()
        setupTableView()
    }
    
    
    func setupSearchBar() {
        let searchBar = AddressSearchView()
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.top.equalTo(self.topView.snp.top)
            make.height.equalTo(60)
        }
        self.searchBar = searchBar
        
        searchBar.inputField?.rx.text.subscribe(onNext: {[weak self] text in
            if let searchText = text {
                self?.updateSearchResult(searchString: searchText)
            }else{
                self?.updateSearchResult(searchString: "")
            }
        }).disposed(by: disposeBag)
    }

    func setupBg(){
        let bgView = UIView()
        bgView.backgroundColor = UIColor.white
        view.insertSubview(bgView, at: 0)
        bgView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.top).offset(-14)
            make.bottom.equalTo(tableView!.snp.top)
            make.leading.trailing.equalTo(view)
        }
    }
    
    ///选择完成 退出
    func completed() {
        
    }
    
    func updateSearchResult(searchString:String){
        
        let targetArr:[AddressItemModel] = self.srcCountryList
        
        let filteredArr:[AddressItemModel] = targetArr.filter({ model in
            searchString.isEmpty ? true : model.address_name?.uppercased().contains(searchString.uppercased()) ?? false
        })
        
        let gpDict = Dictionary(grouping: filteredArr) { item in
            item.address_name?.first?.uppercased()
        }
        var gpList:[GroupedModel<AddressItemModel>] = []
        gpDict.forEach { key,value in
            let gp = GroupedModel<AddressItemModel>()
            gp.key = key
            gp.list = value
            gpList.append(gp)
        }
        gpList = gpList.sorted { val1, val2 in
            val1.key ?? "0" < val2.key ?? "0"
        }
        
        self.countryList = gpList.map({ item in
            let gpModel = GroupedModel<AddressItemModel>()
            gpModel.key = item.key
            gpModel.list = item.list
            return gpModel
        })
    }

    
    func clearSearch(){
        searchBar?.inputField?.text = ""
        self.updateSearchResult(searchString: "")
    }
    
    func setupTableView() {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = OSSVThemesColors.stlClearColor()
        view.addSubview(tableView)
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(searchBar!.snp.bottom)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
        tableView.sectionIndexColor = OSSVThemesColors.col_666666()
        tableView.register(STLSettingNormalMarkCell.self, forCellReuseIdentifier: NSStringFromClass(STLSettingNormalMarkCell.self))
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func reloadDataAndScrollDownTable() {
        
        UIView.animate(withDuration: 0.5) {
            self.tableView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        } completion: { _ in
            self.tableView?.reloadData()
        }
    }
    
    var selectedCountry:AddressItemModel?{
        didSet{
            guard let selectedCountry = selectedCountry else {
                return
            }
            clearSearch()
        }
    }

}


extension SettingCountryRegionVC:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return countryList.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList[section,true]?.list.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(STLSettingNormalMarkCell.self), for: indexPath)
        if let cell = cell as? STLSettingNormalMarkCell {
            
            
            let titleString:String? = countryList[indexPath.section,true]?.list[indexPath.row,true]?.address_name
            let compareString:String? = selectedCountry?.address_name
            cell.contentLabel.text = titleString
            
            var cellSelected = false
            if let titleString = titleString,
            let compareString = compareString,
            
            titleString == compareString{
                cellSelected = true
            }
            
//            cell.showLine(show: !(indexPath.row == self.datasArray.count-1))
//            cell.isMarked = indexPath.row == self.selectedIndex
            cell.isMarked = cellSelected
            cell.showLine(show: true)
            
            
        }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        return countryList.map { model in
            model.key ?? ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return countryList[section,true]?.key
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let headerTitle = UILabel()
        headerTitle.tag = 10010
        headerTitle.font = UIFont.boldSystemFont(ofSize: 14)
        headerTitle.text = countryList[section,true]?.key
        header.addSubview(headerTitle)
        header.backgroundColor = OSSVThemesColors.col_FAFAFA()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        24
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let title = view.viewWithTag(10010){
            title.snp.remakeConstraints { make in
                make.centerY.equalTo(view.snp.centerY)
                make.leading.equalTo(14)
            }
        }
    }

// MARK: tabledelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectcountry = countryList[indexPath.section,true]?.list[indexPath.row,true]
        selectedCountry = selectcountry
        guard let haveChildren = selectcountry?.have_children,
              haveChildren == "1" else {
            completed()
            return
        }
    }
}
