//
//  YXAssetsDescriptionVC.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXStatementSettingVC: YXViewController {
        
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .normalFont14()
        label.numberOfLines = 0
      
        return label
    }()
    
    var desViewModel: YXStatementSettingViewModel {
        let vm = viewModel as! YXStatementSettingViewModel
        return vm
    }
    
    lazy var tableview:UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self

        table.separatorStyle = .none
        table.backgroundColor = QMUITheme().backgroundColor()
        
        if #available(iOS 11.0, *) {
            table.estimatedRowHeight = 0
            table.estimatedSectionFooterHeight = 0
            table.estimatedSectionHeaderHeight = 0
            table.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        table.register(YXStatementSettingTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(YXStatementSettingTableViewCell.self))
        
        return table
    }()

    lazy var chooseView:YXStatementLanguageChooseView = {
        let types:[TradeStatementLanguageType] = [.chinese, .traditional, .en]
        let view = YXStatementLanguageChooseView.init(frame: .zero, types: types, selected: .chinese)
        view.selectedBlock = { [weak self] type in
            guard let `self` = self else { return }
            self.alertSurePop(type: type) {
                self.changeLanguage(type: type)
            }
        }
        
        return view
    }()
    
    lazy var csBarItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem.qmui_item(with: UIImage(named: "icon_cs")!, target: self, action: #selector(csButtonAction))
        return barItem
    }()
    
    @objc func csButtonAction() {
        YXWebViewModel.pushToWebVC(YXH5Urls.YX_HELP_URL())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    

    private func setupUI() {
        self.title = YXLanguageUtility.kLang(key: "statement_setting")
        self.view.backgroundColor = QMUITheme().backgroundColor()
        navigationItem.rightBarButtonItems = [csBarItem];
        self.view.addSubview(tableview)
        tableview.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(YXConstant.navBarHeight())
            }
            make.left.right.bottom.equalToSuperview()
        }
        
        let remark: String = YXLanguageUtility.kLang(key: "wenxin_tips") + ":"
        let sumString:String = remark + "\n" + YXLanguageUtility.kLang(key: "statementPop")

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 8))
        tableview.tableHeaderView = headerView
    
        let attribute:NSMutableAttributedString = NSMutableAttributedString.init(string: sumString, attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.normalFont12()])
        
        let oneString:String = remark
        let range = (sumString as NSString).range(of: oneString)
        attribute.addAttribute(.foregroundColor, value: QMUITheme().textColorLevel1(), range: range)
        attribute.addAttribute(.font, value: UIFont.normalFont14(), range: range)
        
        view.addSubview(tipsLabel)
        tipsLabel.attributedText = attribute
        tipsLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeArea.bottom).offset(-6)
        }
        
        self.view.addSubview(self.chooseView)
        self.chooseView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.chooseView.isHidden = true
    }
    
    fileprivate func loadData() {
        self.desViewModel.reqLanguageSingle().subscribe { [weak self] text in
            guard let `self` = self else { return }
            if text != nil {
                self.chooseView.selectType = self.desViewModel.statementLanguage
                self.tableview.reloadData()
            }else{
                self.chooseView.selectType = self.desViewModel.statementLanguage
            }
        } onError: { err in
            
        }.disposed(by: rx.disposeBag)

    }
    
    fileprivate func changeLanguage(type:TradeStatementLanguageType) {
        self.desViewModel.reqChangeLanguageSingle(type: type).subscribe { text in
            if text != nil {
                self.desViewModel.statementLanguage = type
                self.chooseView.selectType = self.desViewModel.statementLanguage
                self.tableview.reloadData()
            }else{
                self.chooseView.selectType = self.desViewModel.statementLanguage
            }
           
        } onError: { err in
            
        }.disposed(by: rx.disposeBag)

    }
    
    fileprivate func alertPop() {
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "statement_language_details"), message: YXLanguageUtility.kLang(key: "jiedan_language_change_pop"))
        alertView.clickedAutoHide = true

        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView] action in
           
            alertView?.hide()
        }))
        
        alertView.showInWindow()
    }
    
    fileprivate func alertSurePop(type:TradeStatementLanguageType, complish:(() -> Void)?) {
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "statement_language_confirmation"), message: String(format: "%@%@", YXLanguageUtility.kLang(key: "jiedan_sure_change"), type.text))
        alertView.clickedAutoHide = true

        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "search_cancel"), style: .cancel, handler: {[weak alertView] action in
            self.chooseView.selectType = self.desViewModel.statementLanguage
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView] action in
            complish?()
            alertView?.hide()
        }))
        
        alertView.showInWindow()
    }
    
    fileprivate func sheetPop() {
        if self.chooseView.isHidden  {
            self.chooseView.showFilterCondition()
        }else{
            self.chooseView.hideFilterCondition()
        }
    }
    
    @objc func helpAction(_ sender:UIButton) {
        let root = UIApplication.shared.delegate as? YXAppDelegate
        if let navigator = root?.navigator {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_HELP_URL()]
            navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
    

}

extension YXStatementSettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: NSStringFromClass(YXStatementSettingTableViewCell.self)) as! YXStatementSettingTableViewCell
        
        cell.tipClickBlock = { [weak self] in
            guard let `self` = self else { return }
            self.alertPop()
        }
        cell.languageBlock = { [weak self] in
            guard let `self` = self else { return }
            self.sheetPop()
        }
        cell.type = self.desViewModel.statementLanguage
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    
}
