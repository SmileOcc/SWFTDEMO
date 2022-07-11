//
//  YXTradeStatementViewController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXTradeStatementViewController: YXViewController {
    let disposeBag = DisposeBag()
    var statementViewModel:YXTradeStatementViewModel {
        return self.viewModel as! YXTradeStatementViewModel
    }
    lazy var pdfModel:YXStatementPdfModel = {
        let model = YXStatementPdfModel()

        return model
    }()
    
    
    lazy var csBarItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem.qmui_item(with: UIImage(named: "icon_cs")!, target: self, action: #selector(csButtonAction))
        return barItem
    }()
    
    @objc func csButtonAction() {
        YXWebViewModel.pushToWebVC(YXH5Urls.YX_HELP_URL())
    }
    
    lazy var settingBarItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem.qmui_item(with: UIImage(named: "statement_settings")!, target: self, action: #selector(settingButtonAction))
        return barItem
    }()
    
    @objc func settingButtonAction() {
        let viewmodel = YXStatementSettingViewModel.init(services: self.statementViewModel.services, params: nil)
        self.statementViewModel.services.push(viewmodel, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        navigationItem.rightBarButtonItems = [csBarItem, settingBarItem];
    }
    
    func initUI() {
        edgesForExtendedLayout = .top
        
        title =  YXLanguageUtility.kLang(key: "statement_jiedan")
                
        view.addSubview(tableview)
        let noticeView = YXStrongNoticeView()
        view.addSubview(noticeView)
        view.addSubview(headerView)

        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeArea.top)
            make.height.equalTo(40)
        }
        
        noticeView.snp.remakeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(noticeView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        let noticeModel = YXNoticeModel(msgId: 0, title: "", content: YXLanguageUtility.kLang(key: "statement_password_remark"), pushType: YXPushType.none, pushPloy: "", msgType: 0, contentType: 0, startTime: 0, endTime: 0, createTime: 0, newFlag: 0)
        noticeView.dataSource = [noticeModel]
        noticeView.noticeType = .custom
        noticeView.selectedBlock = {
            let str = YXLanguageUtility.kLang(key: "statementPop")
            let subStr = YXLanguageUtility.kLang(key: "statementPop_sub")

            let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "wenxin_tips"), message:str)
            alertView.messageLabel.textAlignment = .left
            let attr = NSMutableAttributedString(string: str, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: QMUITheme().textColorLevel1()])
            let subRange =  (str as NSString).range(of: subStr, options: [])
            attr.setAttributes([.foregroundColor: UIColor.qmui_color(withHexString: "#EE3D3D")!], range: subRange)
            alertView.messageLabel.attributedText = attr
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_ok"), style: .default, handler: { _ in
                
            }))
            alertView.show(in: UIViewController.current())
        }

        tableview.mj_header = YXRefreshHeader.init(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            self.statementViewModel.page = 1
            self.loadData()
        })
        
    }
    
    override func bindViewModel() {
        
        super.bindViewModel()
        loadData()
        
    }
    
    fileprivate func addFooter() {
        tableview.mj_footer = YXRefreshAutoNormalFooter.init(refreshingBlock: {
            [weak self] in
            guard let `self` = self else { return }
            self.statementViewModel.page = self.statementViewModel.page + 1
            self.loadData()
        })
    }
    fileprivate func endRefresh() {
        if tableview.mj_header.isRefreshing {
            tableview.mj_header.endRefreshing()
        }
        
    }
    
    fileprivate func endFooterRefresh() {
        if let footer = self.tableview.mj_footer, footer.isRefreshing {
            footer.endRefreshing()
        }
    }
      
    fileprivate func loadData() {
        
        self.statementViewModel.reqStatementSingle().subscribe {[weak self] model in
            guard let `self` = self else { return }
            self.endRefresh()
            if let model = model {
                if model.list.count > 0 {
                    self.addFooter()
                }
                if self.statementViewModel.page > 1  {
                    if model.list.count < 20 {
                        self.tableview.mj_footer.endRefreshingWithNoMoreData()
                    }else{
                        self.endRefresh()
                    }
                }
            }else{
                if self.statementViewModel.page > 1 && self.statementViewModel.resultList.count > 0 {
                    self.tableview.mj_footer.endRefreshingWithNoMoreData()
                }else{
                    self.endRefresh()
                }
            }
            
            if self.statementViewModel.resultList.count == 0 {
                self.tableview.mj_footer = nil
            }
            if self.statementViewModel.page == 1, let footer = self.tableview.mj_footer {
                footer.state = .idle
            }
            self.tableview.reloadData()
        } onError: { error in
            
        }.disposed(by: rx.disposeBag)
    }
    
 
    fileprivate func tipsPop() {
        let bgView = UIView()
        bgView.backgroundColor = .clear
        bgView.frame = UIScreen.main.bounds
        let alterView = YXStatementTipAlterView.init(frame: .zero)
        bgView.addSubview(alterView)
        alterView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alterView.okBlock = { [weak bgView] in
            bgView?.hideInWindow()
        }
        
        bgView.showInWindow()
    }
    
    lazy var tableview:UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.emptyDataSetSource = self
        table.emptyDataSetDelegate = self
        table.separatorColor = QMUITheme().separatorLineColor()
        table.backgroundColor = QMUITheme().foregroundColor()
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if #available(iOS 11.0, *) {
            table.estimatedRowHeight = 0
            table.estimatedSectionFooterHeight = 0
            table.estimatedSectionHeaderHeight = 0
            table.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 1))
        table.register(YXStatementTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(YXStatementTableViewCell.self))
        table.register(YXStatementHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(YXStatementHeaderFooterView.self))
        
        return table
    }()
    
    lazy var headerView:YXStatementHeaderView = {
        let view = YXStatementHeaderView()
        view.clickAccountFileter = { [weak self] type in
            guard let `self` = self else { return }

            if self.statementViewModel.accountType == type {
                return
            }
            
            self.statementViewModel.page = 1
            self.statementViewModel.accountType = type
            self.loadData()
        }
        view.clickStatementFileter = { [weak self] type in
            guard let `self` = self else { return }
            
            if self.statementViewModel.statementType == type {
                return
            }
            
            self.statementViewModel.page = 1
            self.statementViewModel.statementType = type
            self.loadData()
        }
        view.clickTimeFilter = { [weak self] (type, begin, end) in
            guard let `self` = self else { return }
            
            if type != .custom, self.statementViewModel.timeScope == type {
                return
            }

            self.statementViewModel.page = 1
            self.statementViewModel.timeScope = type
            self.statementViewModel.beginDate = begin
            self.statementViewModel.endDate = end
            self.loadData()
        }

        return view
    }()
    
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.en_US_POSIX()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    
   
}

extension YXTradeStatementViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

extension YXTradeStatementViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.statementViewModel.resultList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.statementViewModel.resultList.count > 0 {
            let model = self.statementViewModel.resultList[section]
            return model.list.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.statementViewModel.resultList.count > 0 {
            let model = self.statementViewModel.resultList[indexPath.section]
            if model.list.count > 0 {
                return 70
            }
            
        }
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.statementViewModel.resultList.count > 0 {
            return 24
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:YXStatementHeaderFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(YXStatementHeaderFooterView.self)) as! YXStatementHeaderFooterView
        if self.statementViewModel.resultList.count > 0 {
            let model = self.statementViewModel.resultList[section]
            headerView.titleLabel.text = model.time
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: NSStringFromClass(YXStatementTableViewCell.self)) as! YXStatementTableViewCell
        if self.statementViewModel.resultList.count > 0 {
            let model = self.statementViewModel.resultList[indexPath.section]
            let itemModel:YXStatementListItemModel = model.list[indexPath.row]
            cell.updateUI(model: itemModel, statementType: self.statementViewModel.statementType)
            cell.lookPdfBlock = { [weak self] in
                guard let `self` = self else { return }
                self.downLoadPdf(url: itemModel.cosUrl)

            }
        }
       
        return cell
    }
    fileprivate func downLoadPdf(url:String) {
        let hub:YXProgressHUD = YXProgressHUD.showLoading("", in: self.view)
        pdfModel.getsecretKey(url) {[weak self] isSuc, pdfUrl in
            guard let `self` = self else { return }
            if isSuc {
                DispatchQueue.main.async {
                    hub.hide(animated: true)
                    let viewmodel = YXStatementWebViewModel.init(services: self.statementViewModel.services, params: ["pdfUrl":pdfUrl])
                    self.statementViewModel.services.push(viewmodel, animated: true)
                }
               
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        if self.statementViewModel.resultList.count > 0 {
            let model = self.statementViewModel.resultList[indexPath.section]
            let itemModel:YXStatementListItemModel = model.list[indexPath.row]
            
            self.downLoadPdf(url: itemModel.cosUrl)
        }
    }

    
}


extension YXTradeStatementViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "empty_noData")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return ( self.statementViewModel.resultList.count == 0 )
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 60
    }
}
