//
//  YXAreaCodeViewController.swift
//  uSmartOversea
//
//  Created by Mac on 2019/10/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import YXKit

import RxSwift

class YXAreaCodeViewController: YXHKTableViewController, HUDViewModelBased {
    
    typealias ViewModelType = YXAreaCodeViewModel
    var viewModel: YXAreaCodeViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    let areaCodeViewCellID = "areaCodeViewCellID"
    let areaCodeSecHeaderViewID = "areaCodeSecHeaderViewID"
    
    lazy var codeSearchBar: YXAreaCodeSearchBar = {
        let bar = YXAreaCodeSearchBar(frame: CGRect(x: 16, y: 0, width: YXConstant.screenWidth-32, height: 44))
        return bar
    }()
    
    lazy var headView : YXAreaCodeHeadView = {
        let headView = YXAreaCodeHeadView.init(frame: .zero)
        headView.titleLabel.text = YXLanguageUtility.kLang(key: "common_select_area_code")
        return headView
    }()
    
    lazy var emptyLab: QMUILabel = {
        let lab = QMUILabel()
        lab.text = YXLanguageUtility.kLang(key: "common_no_result")
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
        bindHUD()
        setupNavigationBar()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel = nil
    }
    //重写tableView布局，
    override func layoutTableView() {
        
    }
    
    func initUI() {
        self.title = YXLanguageUtility.kLang(key: "common_select_area_code")
        
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.headView.backgroundColor = QMUITheme().foregroundColor()

        self.view.addSubview(codeSearchBar)
        self.view.addSubview(headView)
        
        codeSearchBar.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(headView.snp.bottom)
            make.height.equalTo(44)
        }
        
        var v = 12.0
        if let cv = Double(UIDevice.current.systemVersion.split(separator: ".").first ?? "") {
            v = cv
        }

        headView.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.top.right.equalTo( v > 13.0 ? 0 :  (YXConstant.deviceScaleEqualToXStyle() ? 24 : 0))
            make.left.equalTo(0)
        }
        
       
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableView.separatorStyle = .none
        tableView.register(YXAreaCodeTableViewCell.self, forCellReuseIdentifier: areaCodeViewCellID)
        tableView.register(YXSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: areaCodeSecHeaderViewID)
        tableView.snp.remakeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.left.right.equalTo(strongSelf.view)
            make.bottom.equalToSuperview()
            make.top.equalTo(strongSelf.codeSearchBar.snp.bottom)
            //make.top.equalTo(YXConstant.navBarHeight())
        }
        
        self.emptyLab.isHidden = true
        view.addSubview(self.emptyLab)
        self.emptyLab.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.tableView).offset(80)
        }
        
        // 索引
        // 设置索引值颜色
        self.tableView.sectionIndexColor = QMUITheme().mainThemeColor() //QMUITheme().holdMark()   //#1E93F3
        // 设置选中时的索引背景颜色
        self.tableView.sectionIndexTrackingBackgroundColor = .clear
        // 设置索引的背景颜色
        self.tableView.sectionIndexBackgroundColor = .clear

    }
    
    func bindViewModel() {
        _ = codeSearchBar.textField.rx.text.throttle(RxTimeInterval.seconds(0), scheduler: MainScheduler.instance).distinctUntilChanged().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](searchText) in
            guard let `self` = self, let text = searchText else { return }
            
            self.viewModel.matchingCodeArr(with: text)
            
            if self.viewModel.searchedArr.count == 0 {
                self.emptyLab.isHidden = false
            } else {
                self.emptyLab.isHidden = true
            }
            
            self.tableView.reloadData()
        })
        
        headView.backBtn.rx.tap.subscribe(onNext:{[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    //MARK: - 导航栏
    func setupNavigationBar() {
        //导航栏右按钮
        let helpItem = UIBarButtonItem.qmui_item(with: UIImage(named: "service") ?? UIImage(), target: self, action: nil)
        helpItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            self.serviceAction()
            
            }.disposed(by: self.disposeBag)
        navigationItem.rightBarButtonItems = [helpItem]
    }

}

extension YXAreaCodeViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: areaCodeViewCellID) as! YXAreaCodeTableViewCell
        let codeModel = self.viewModel.searchedArr[indexPath.section]
        cell.update(with: codeModel.sectionArr[indexPath.row])
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.searchedArr.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let codeModel =  viewModel.searchedArr[section]
        return codeModel.sectionArr.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: areaCodeSecHeaderViewID) as! YXSectionHeaderView
        let codeModel = viewModel.searchedArr[section]
        header.update(with: codeModel.title)
        return header
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        53

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let codeModel = self.viewModel.searchedArr[indexPath.section]
        let areaModel: Country = codeModel.sectionArr[indexPath.row]
        var code = "852"
        if let temp = areaModel.area {
            code = temp.replacingOccurrences(of: "+", with: "")
        }
        viewModel.didSelectSubject.onNext(code)
        self.dismiss(animated: true, completion: nil)
       // self.navigationController?.popViewController(animated: true)
    }
    
    // 索引值数组
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        self.viewModel.wordArray
    }
    
    // 索引值与列表关联点击事件
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        for i in 0 ..< self.viewModel.searchedArr.count {
            let codeModel = self.viewModel.searchedArr[i]
            if codeModel.title == title {
                return i
            }
        }

        return index
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滚动时收起键盘
        codeSearchBar.textField.resignFirstResponder()
    }
}



class YXSectionHeaderView: UITableViewHeaderFooterView {
    private lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.textColor = QMUITheme().mainThemeColor()   //#1E93F3
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        self.contentView.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-18)
        }
    }
    func update(with text:String) {
        titleLab.text = text
    }
}

class YXAreaCodeTableViewCell: QMUITableViewCell {
    private lazy var areaNameLab: QMUILabel = {
        let lab = QMUILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    private lazy var codeLab: QMUILabel = {
        let lab = QMUILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    
    private lazy var bottomLine:UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        //QMUITheme().textColorLevel2()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initialUI()  {
        self.backgroundColor = QMUITheme().foregroundColor()
        
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        
        contentView.addSubview(areaNameLab)
        areaNameLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(codeLab)
        codeLab.snp.makeConstraints { (make) in
            make.leading.equalTo(areaNameLab.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-18)
        }
        //bottomLine
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.trailing.equalToSuperview().offset(-18)
        }
        
    }
    
    func update(with areaModel: Country?) {
        var areaName: String? = areaModel?.hk
        switch YXUserManager.curLanguage() {
        case .CN:
            areaName = areaModel?.cn
        case .HK:
            areaName = areaModel?.hk
        case .EN:
            areaName = areaModel?.en
        case .ML:
            areaName = areaModel?.my
        case .TH:
            areaName = areaModel?.th
        default:
            break
        }
        areaNameLab.text = areaName
        codeLab.text = areaModel?.area
        
    }
}
