//
//  CascadeSelectViewController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/6.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import iCarousel

enum SelectLevel: Int{
    case Country = 0
    case Province = 1
    case City = 2
    case Area = 3
}

struct LastSelectItem{
    var country_id:String?
    var province_id:String?
    var city_id:String?
    var area_id:String?
}

struct SelectedResult{
    var country:AddressItemModel?
    var province:AddressItemModel?
    var city:AddressItemModel?
    var area:AddressItemModel?
}

class CascadeSelectViewController: STLBaseCtrl {
    
    var doneSelected = PublishSubject<SelectedResult>()
    
    ///
    var finishedSelect:((AddressItemModel?,AddressItemModel?,AddressItemModel?,AddressItemModel?)->Void)?
    
    weak var toplabel:UILabel?
    weak var levelSelectView:BreadcrumbsView?
    weak var searchBar:AddressSearchView?
    weak var tableView:UITableView?
    
    var lastSelected:LastSelectItem?
    
    var breadStrings:[String] = []
        
    var disposeBag = DisposeBag()
    
    var countryList:[GroupedModel<AddressItemModel>] = []{
        didSet{
            level = .Country
            reloadLevelView(levelStr: [ .selecCountryBreds,""])
            reloadDataAndScrollDownTable()
        }
    }
    ///源数据
    var srcCountryList:[AddressItemModel] = []
    
    var provinceList:[GroupedModel<AddressItemModel>] = []{
        didSet{
            level = .Province
            reloadDataAndScrollDownTable()
            reloadLevelView(levelStr: [selectedCountry?.address_name ?? "", .selecStateBreds,""])
        }
    }
    ///源数据
    var srcProvinceList:[AddressItemModel] = []
    
    var cityList:[GroupedModel<AddressItemModel>] = []{
        didSet{
            level = .City
            reloadDataAndScrollDownTable()
            reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "" , .selecCityBreds,""])
        }
    }
    
    var srcCityList:[AddressItemModel] = []
    
    var areaList:[GroupedModel<AddressItemModel>] = []{
        didSet{
            level = .Area
            reloadDataAndScrollDownTable()
            reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "" ,selectedCity?.address_name ?? "" , .selecAreaBreds,""])
        }
    }
    var srcAreaList:[AddressItemModel] = []
    
    ///当前选择level
    var level:SelectLevel = .Country
    
    var selectedCountry:AddressItemModel?{
        didSet{
            guard let selectedCountry = selectedCountry else {
                level = .Country
                reloadLevelView(levelStr: [.selectCountryTips])
                return
            }
            reloadLevelView(levelStr: [selectedCountry.address_name ?? "",.selectProvinceTips,""])
            clearSearch()
            ///加载省份数据
            guard let haveChildren = selectedCountry.have_children,
                  haveChildren == "1" else {
                return
            }
            loadAddressList(val:selectedCountry.address_id ?? "",level: .Province) {[weak self] gpList, srcList in
                self?.provinceList = gpList
                self?.srcProvinceList = srcList
                srcList.forEach { item in
                    guard let lastAddresId = self?.lastSelected?.province_id,
                          let currentId = item.address_id
                    else { return }
                    if currentId == lastAddresId{
                        self?.selectedProvince = item
                    }
                }
            }
        }
    }
    
    var selectedProvince:AddressItemModel?{
        didSet{
            guard let selectedProvince = selectedProvince else {
                level = .Province
                reloadLevelView(levelStr:[selectedCountry?.address_name ?? "",.selectProvinceTips,""])
                return
            }
            
            
            clearSearch()
            ///加载城市数据
            guard let haveChildren = selectedProvince.have_children,
                  haveChildren == "1" else {
                reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince.address_name ?? .selectProvinceTips,""])
                return
            }
            reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince.address_name ?? "" ,.selectCityTips,""])
            loadAddressList(val:selectedProvince.address_id ?? "",level: .City) {[weak self] gpList, srcList in
                self?.cityList = gpList
                self?.srcCityList = srcList
                srcList.forEach { item in
                    guard let lastAddresId = self?.lastSelected?.city_id,
                          let currentId = item.address_id
                    else { return }
                    if currentId == lastAddresId{
                        self?.selectedCity = item
                    }
                }
            }
        }
    }
    
    var selectedCity:AddressItemModel?{
        didSet{
            guard let selectedCity = selectedCity else {
                level = .City
                reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "" , .selectCityTips,""])
                return
            }
            
            clearSearch()
            
            guard let haveChildren = selectedCity.have_children,
                  haveChildren == "1" else {
                reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "",selectedCity.address_name ?? .selectCityTips,""])
                return
            }
            reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "",selectedCity.address_name ?? "" ,.selectAreaTips,""])
            loadAddressList(val:selectedCity.address_id ?? "",level: .Area) {[weak self] gpList, srcList in
                self?.areaList = gpList
                self?.srcAreaList = srcList
                srcList.forEach { item in
                    guard let lastAddresId = self?.lastSelected?.area_id,
                          let currentId = item.address_id
                    else { return }
                    if currentId == lastAddresId{
                        self?.selectedArea = item
                    }
                }
            }
        }
    }
    
    var selectedArea:AddressItemModel?{
        didSet{
            guard let selectedArea = selectedArea else {
                level = .Area
                reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "" , selectedCity?.address_name ?? "",.selectAreaTips,""])
                return
            }
            reloadLevelView(levelStr: [selectedCountry?.address_name ?? "",selectedProvince?.address_name ?? "" ,selectedCity?.address_name ?? "", selectedArea.address_name ?? "",""])
            clearSearch()
            
        }
    }
    
    func reloadLevelView(levelStr:[String], needScrollToTrailling:Bool = true){
        breadStrings = levelStr
        reloadTopTitle()
        levelSelectView?.reloadData()
        if needScrollToTrailling{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                if let view = self?.levelSelectView {
                    let contentWidth = view.contentSize.width
                    let viewWidth = view.bounds.width
                    if contentWidth > viewWidth {
                        self?.levelSelectView?.scrollRectToVisible(CGRect(x: contentWidth - 1, y: 0, width: 1, height: 1), animated: false)
                    }
                }
            }
        }
    }
    
    func reloadTopTitle() {
        switch level {
        case .Country:
            toplabel?.text = .selectCountryTips
        case .Province:
            toplabel?.text = .selectProvinceTips
        case .City:
            toplabel?.text = .selectCityTips
        case .Area:
            toplabel?.text = .selectAreaTips
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSubViews()
        loadData()
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.keyWindow?.backgroundColor = OSSVThemesColors.col_0D0D0D().withAlphaComponent(0.3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.keyWindow?.backgroundColor = .white
    }
    
    ///选择完成 退出
    func completed() {
        dismiss(animated: true) {
            self.finishedSelect?(self.selectedCountry,self.selectedProvince,self.selectedCity,self.selectedArea)
            self.doneSelected.onNext(SelectedResult(country: self.selectedCountry, province: self.selectedProvince, city: self.selectedCity, area: self.selectedArea))
            self.lastSelected = nil
        }
    }
    
    func reloadDataAndScrollDownTable() {
        
        UIView.animate(withDuration: 0.5) {
            self.tableView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        } completion: { _ in
            self.tableView?.reloadData()
        }
    }
}

///子视图
extension CascadeSelectViewController{
    
    func setupSubViews() {
        setupTopsView()
        setUpLevelView()
        setupSearchBar()
        setupTableView()
        
//        setupBg()
    }
    
    func setupTopsView() {
//        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let topLbl = UILabel()
        view.addSubview(topLbl)
        toplabel = topLbl
        topLbl.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin).offset(14)
            make.height.equalTo(19)
            make.centerX.equalTo(view.snp.centerX)
        }
        topLbl.font = UIFont.boldSystemFont(ofSize: 16)
        topLbl.text = STLLocalizedString_("text_select_country_title")
        topLbl.textColor = OSSVThemesColors.col_0D0D0D()
        
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "address_close"), for: .normal)
        view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalTo(0)
            make.centerY.equalTo(topLbl.snp.centerY)
        }
        closeBtn.rx.tap.subscribe {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        
        
    }
    
    func setUpLevelView() {
        let levelView = BreadcrumbsView()
        levelView.breadcrumbsViewDelegate = self
        levelView.backgroundColor = UIColor.white
        levelSelectView = levelView
        view.addSubview(levelView)
        levelView.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.height.equalTo(44)
            make.top.equalTo(toplabel!.snp.bottom).offset(14)
        }
//        levelView.backgroundColor = UIColor.cyan
        
        levelView.register(BreadItemCell.self, forCellWithReuseIdentifier: .crumb)
        levelView.register(BreadIntevalCell.self, forCellWithReuseIdentifier: .interval)
        levelView.intervalItemSize = CGSize(width: 14, height: 40)
//        levelView.itemSize = CGSize(width: 50 , height: 40)
    }
    
    func setupSearchBar() {
        let searchBar = AddressSearchView()
        view.addSubview(searchBar)
//        searchBar.backgroundColor = .brown
        searchBar.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.top.equalTo(levelSelectView!.snp.bottom)
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
            make.top.equalTo(toplabel!.snp.top).offset(-14)
            make.bottom.equalTo(tableView!.snp.top)
            make.leading.trailing.equalTo(view)
        }
    }
    
    func updateSearchResult(searchString:String){
        
        var targetArr:[AddressItemModel] = []
        switch level{
        case .Country:
            targetArr = self.srcCountryList
            break
        case .Province:
            targetArr = self.srcProvinceList
            break
        case .City:
            targetArr = self.srcCityList
            break
        case .Area:
            targetArr = self.srcAreaList
            break
        }
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
        
        switch level{
            
        case .Country:
            self.countryList = gpList.map({ item in
                let gpModel = GroupedModel<AddressItemModel>()
                gpModel.key = item.key
                gpModel.list = item.list
                return gpModel
            })
        case .Province:
            self.provinceList = gpList.map({ item in
                let gpModel = GroupedModel<AddressItemModel>()
                gpModel.key = item.key
                gpModel.list = item.list
                return gpModel
            })
        case .City:
            self.cityList = gpList.map({ item in
                let gpModel = GroupedModel<AddressItemModel>()
                gpModel.key = item.key
                gpModel.list = item.list
                return gpModel
            })
        case .Area:
            self.areaList = gpList.map({ item in
                let gpModel = GroupedModel<AddressItemModel>()
                gpModel.key = item.key
                gpModel.list = item.list
                return gpModel
            })
        }
    }
    
    func clearSearch(){
        searchBar?.inputField?.text = ""
        self.updateSearchResult(searchString: "")
    }
    
    func setupTableView() {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = OSSVThemesColors.col_FAFAFA()
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
        tableView.register(AddressCountrySelectCell.self, forCellReuseIdentifier: .kAddressCountrySelctCellId)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
}


//MARK: 面包屑导航代理
extension CascadeSelectViewController:BreadcrumbsViewDelegate{
    func numberOfRows(in breadcrumbsView: BreadcrumbsView) -> Int {
        breadStrings.count
    }
    
    func breadcrumbsView(_ breadcrumbsView: BreadcrumbsView, willDisplay cell: AnyObject, forItemAt indexPath: IndexPath) {
        if let itemCell = cell as? BreadItemCell{
            itemCell.contentLbl?.text = breadStrings[indexPath.item]
            if let level = SelectLevel(rawValue: indexPath.item) {
                itemCell.isSelected = level == self.level
            }
        }
    }
    
    func breadcrumbsView(_ breadcrumbsView: BreadcrumbsView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let str =  breadStrings[indexPath.item / 2]
        let temp = UILabel()
        temp.font = UIFont.boldSystemFont(ofSize: 14)
        temp.text = str
        let width = temp.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20)).width + 10
        return CGSize(width: width, height: 44)
    }
    
    func breadcrumbsView(_ breadcrumbsView: BreadcrumbsView, didSelectItemAt indexPath: IndexPath) {
        guard let level = SelectLevel(rawValue: indexPath.item),
        indexPath.item != breadStrings.count - 1 else {//最后一个是空的 为了展示箭头
            return
        }
        self.level = level
        reloadDataAndScrollDownTable()
        clearSearch()
        reloadTopTitle()
        reloadLevelView(levelStr: breadStrings,needScrollToTrailling: false)
    }

}

extension CascadeSelectViewController:UITableViewDelegate,UITableViewDataSource{
    
// MARK: TabledataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        switch level{
        case .Country:
            return countryList.count
        case .Province:
            return provinceList.count
        case .City:
            return cityList.count
        case .Area:
            return areaList.count
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch level{
        case .Country:
            return countryList[section,true]?.list.count ?? 0
        case .Province:
            return provinceList[section,true]?.list.count ?? 0
        case .City:
            return cityList[section,true]?.list.count ?? 0
        case .Area:
            return areaList[section,true]?.list.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .kAddressCountrySelctCellId, for: indexPath)
        if let cell = cell as? AddressCountrySelectCell {
            var titleString:String?
            var compareString:String?
            switch level{
            case .Country:
                titleString = countryList[indexPath.section,true]?.list[indexPath.row,true]?.address_name
                compareString = selectedCountry?.address_name
                break
            case .Province:
                titleString = provinceList[indexPath.section,true]?.list[indexPath.row,true]?.address_name
                compareString = selectedProvince?.address_name
                break
            case .City:
                titleString = cityList[indexPath.section,true]?.list[indexPath.row,true]?.address_name
                compareString = selectedCity?.address_name
                break
            case .Area:
                titleString = areaList[indexPath.section,true]?.list[indexPath.row,true]?.address_name
                compareString = selectedArea?.address_name
                break

            }
            cell.countrynameLbl?.text = titleString
            var cellSelected = false
            if let titleString = titleString,
            let compareString = compareString,
            titleString == compareString{
                cellSelected = true
            }
            cell.setSelected(cellSelected, animated: true)
            
        }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        switch level{
        case .Country:
            return countryList.map { model in
                model.key ?? ""
            }
        case .Province:
            return provinceList.map { model in
                model.key ?? ""
            }
        case .City:
            return cityList.map { model in
                model.key ?? ""
            }
        case .Area:
            return areaList.map { model in
                model.key ?? ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch level{
        case .Country:
            return countryList[section,true]?.key
        case .Province:
            return provinceList[section,true]?.key
        case .City:
            return cityList[section,true]?.key
        case .Area:
            return areaList[section,true]?.key
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let headerTitle = UILabel()
        headerTitle.tag = 10010
        headerTitle.font = UIFont.boldSystemFont(ofSize: 14)
        switch level{
        case .Country:
            headerTitle.text = countryList[section,true]?.key
        case .Province:
            headerTitle.text = provinceList[section,true]?.key
        case .City:
            headerTitle.text = cityList[section,true]?.key
        case .Area:
            headerTitle.text = areaList[section,true]?.key
        }
        
        header.addSubview(headerTitle)
        header.backgroundColor = OSSVThemesColors.col_FAFAFA()
        return header
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
        switch level{
        case.City:
            ///城市选择了就返回到上一个界面
            let selectedCity = cityList[indexPath.section,true]?.list[indexPath.row,true]
            self.selectedCity = selectedCity
            guard let haveChildren = selectedCity?.have_children,
                  haveChildren == "1" else {
                      selectedArea = nil
                completed()
                return
            }
            break
        case .Country:
            let selectcountry = countryList[indexPath.section,true]?.list[indexPath.row,true]
            lastSelected = nil
            selectedCountry = selectcountry
            guard let haveChildren = selectcountry?.have_children,
                  haveChildren == "1" else {
                selectedArea = nil
                selectedCity = nil
                selectedProvince = nil
                completed()
                return
            }
            break
        case .Province:
            let selectProvince = provinceList[indexPath.section,true]?.list[indexPath.row,true]
            self.selectedProvince = selectProvince
            guard let haveChildren = selectProvince?.have_children,
                  haveChildren == "1" else {
                selectedArea = nil
                selectedCity = nil
                completed()
                return
            }
            break
        case .Area:
            let selectArea = areaList[indexPath.section,true]?.list[indexPath.row,true]
            self.selectedArea = selectArea
            
            completed()
            break
        }
    }
}

typealias LoadFinishedCallback = (([GroupedModel<AddressItemModel>],[AddressItemModel])->Void)

///网络操作
extension CascadeSelectViewController{
    
    ///初始化加载国家
    func loadData() {
        loadAddressList(level:.Country) {[weak self] gpList, srcList in
            self?.countryList = gpList
            self?.srcCountryList = srcList
            srcList.forEach { item in
                guard let lastCountryId = self?.lastSelected?.country_id,
                      let currentId = item.address_id
                else { return }
                if currentId == lastCountryId{
                    self?.selectedCountry = item
                }
            }
        }
    }

    ///分级加载
    func loadAddressList(val:String = "",level:SelectLevel ,loadFinished:LoadFinishedCallback?) {
        
        STLNetworkStateManager.shared().networkState {
            let api = AddressCascadeAPI(val: val, type: 1, level: level.rawValue + 1)
            if let accessory = STLRequestAccessory(apperOn: self.view){
                api.accessoryArray.add(accessory)
            }
            
            api.start { req in
                if let reqJson = OSSVNSStringTool.desEncrypt(toString: req),
                   let respMode =  CascadeApiResponseModel(JSONString: reqJson){
                    if respMode.statusCode == 200 {
                        
                        let addressList = respMode.result ?? []
                        let gpDict =  Dictionary(grouping: addressList) { item in
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
                        
                        loadFinished?(gpList,addressList)
                        
                    }else{
                        HUDManager.showHUD(withMessage: .errorMsg)
                    }
                }
            } failure: { req, err in
                HUDManager.showHUD(withMessage: .errorMsg)
            }
        } exception: {
            HUDManager.showHUD(withMessage: .errorMsg)
        }

    }
}

