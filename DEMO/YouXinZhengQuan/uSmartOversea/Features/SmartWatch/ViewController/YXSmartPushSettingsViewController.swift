//
//  YXSmartPustSettingsViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/29.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import RxSwift
import RxCocoa
import UserNotifications
import UserNotificationsUI
import YXKit
import Alamofire

class YXSmartPushSettingsViewController: YXHKTableViewController, ViewModelBased, HUDViewModelBased {
    
    var viewModel: YXSmartSettingViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()

    var smartType: YXSmartType = .stockPosition
    override func didInitialize() {
        self.hidesBottomBarWhenPushed = true
    }
    
    convenience override init() {
        self.init(style: .grouped)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dataSource: [YXSmartPushSettingGroup] = []
    let reuseIdentifier = "YXSmartPushSettingsCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = YXLanguageUtility.kLang(key: "smart_settings_title")
        self.view.backgroundColor = QMUITheme().foregroundColor()
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "smart_prompt")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleRightAction))
        
        initializeView()
        bindHUD()
        bindViewModel()
        showOrHiddenNoticeView()
        requestStockSettingData()
    }
    
    @objc func handleRightAction() {
        
    }
    
    func showOrHiddenNoticeView() {
        DispatchQueue.main.async {
            if UIApplication.shared.currentUserNotificationSettings?.types.rawValue == 0 {
                self.noticeView.isHidden = false
            } else {
                self.noticeView.isHidden = true
            }
        }
    }
    
    //MARK:  获取用户监控指标息请求 Method
    func requestStockSettingData() {
        
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        var params: yxSmartGetQuota
        params.fontType = YXUserManager.curLanguage().rawValue
        params.smartType = self.smartType.rawValue
        params.uid = String(format: "%lld", YXUserManager.userUUID())
        self.viewModel.services.request(.getQuota(params), response: (self.viewModel.stockSettingResultResponse)).disposed(by: self.disposeBag)
        
    }
    
    //MARK:  推送用户监控指标息请求 Method
    func postSettingConfigToServer(indexPath: IndexPath, isOn: Bool) {

        if dataSource[indexPath.section].signal != nil {

            var params: yxSmartPostQuota
            params.uid = String(format: "%lld", YXUserManager.userUUID())
            params.smartType = self.smartType.rawValue
            
            dataSource[indexPath.section].signal![indexPath.row].defult = isOn ? 1 : 0
            var list: [yxSmartSettingList] = []
            for groupModel in self.dataSource {
                
                var group: yxSmartSettingList
                group.groupid = groupModel.groupID!
                var signalList: [Int] = []
                if let array = groupModel.signal {
                    for signalModel in array {
                        if let isOn = signalModel.defult, isOn > 0 {
                            signalList.append(signalModel.signalID!)
                        }
                    }
                }
                group.signalid = signalList
                list.append(group)
            }
            params.list = list
            self.viewModel.services.request(.postQuota(params), response: (self.viewModel.stockSettingConfigResultResponse)).disposed(by: self.disposeBag)
        }
    }
    
    func initializeView() {
        self.view.addSubview(noticeView)
        tableView.register(YXSmartPushSettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().backgroundColor()
        tableView.sectionFooterHeight = 10
        tableView.sectionHeaderHeight = 0
        //self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.navigationController?.navigationBar.isTranslucent = false
        
        noticeView.isHidden = true
        noticeView.snp.makeConstraints { ( make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(noticeView.snp.bottom)
        }
        
        noticeView.handleNoticeBlock = {
            if let url = URL.init(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    //重写此方法来屏蔽QMUITableView的自动布局
    override func layoutTableView() {
        
    }
    
    lazy var noticeView: YXSmartNoticeView = {
        let view = YXSmartNoticeView()
        return view
    }()
    
    func showOrHideEmptyView() {
        
        if self.dataSource.count <= 0 {
            self.showErrorEmptyView()
        } else {
            self.hideEmptyView()
        }
    }
    
    override func emptyRefreshButtonAction() {
        requestStockSettingData()
    }
    
}

extension YXSmartPushSettingsViewController {
    
    func bindViewModel() {
        
        _ = NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                self?.showOrHiddenNoticeView()
            })
        
        _ = noticeView.rx.observe(Bool.self, "hidden")
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] isHidden in
                guard let hidden = isHidden else { return }
                DispatchQueue.main.async {
                    if hidden {
                        self?.noticeView.snp.updateConstraints({ (make) in
                            make.height.equalTo(0)
                        })
                    } else {
                        self?.noticeView.snp.updateConstraints({ (make) in
                            make.height.equalTo(32)
                        })
                    }
                }
            })
        
        self.viewModel.settingResultSubject.subscribe(onNext: {
            [weak self] (model, error) in
            guard let strongSelf = self else { return }
            if let model = model, let array = model.list?.group {
                strongSelf.dataSource = array
                strongSelf.dataSource.sort(by: { (obj1, obj2) -> Bool in
                    obj1.groupID! < obj2.groupID!
                })
                
                for model in strongSelf.dataSource {
                    if let _ = model.signal {
                        model.signal!.sort(by: { (obj1, obj2) -> Bool in
                            obj1.signalID! < obj2.signalID!
                        })
                    }
                }
                strongSelf.tableView.reloadData()
            }
            strongSelf.showOrHideEmptyView()
        }).disposed(by: self.disposeBag)
        
        self.viewModel.settingConfigSubject.subscribe(onNext: {
            (model, error) in
            if error != nil {
                //TODO 失败处理
            }
            
        }).disposed(by: self.disposeBag)
    }
    
}

extension YXSmartPushSettingsViewController {
    //MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let subArray = dataSource[section].signal {
           return subArray.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: YXSmartPushSettingsCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! YXSmartPushSettingsCell
        if let subArray = dataSource[indexPath.section].signal {
            cell.reloadData(indexPath, subArray[indexPath.row])
        }
        cell.handleCallBack = {
            [unowned self] (isOn, selectCell) in
            if let selectIndexPath = self.tableView.indexPath(for: selectCell) {
                log(.info, tag: kOther, content: "current cell index section \(selectIndexPath.section) , row \(selectIndexPath.row), switch status \(isOn)")
                self.postSettingConfigToServer(indexPath: selectIndexPath, isOn: isOn)
            }
        }
        
        return cell
    }
    
    
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var detail = ""
        let model: YXSmartPushSettingGroup = dataSource[section]
        let text = model.groupName != nil ? model.groupName! : ""
        if section == 0 {
            detail = YXLanguageUtility.kLang(key: "smart_groupDetail")
        }
        let sectionView = sectionHeaderView(text: text, detailText: detail)
        sectionView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 50)
        return sectionView
    }
    
    func sectionHeaderView(text: String, detailText: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.textAlignment = .left
        titleLabel.text = text
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        detailLabel.textColor = QMUITheme().textColorLevel3()
        detailLabel.textAlignment = .right
        detailLabel.text = detailText
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        
        let headerView = UIView()
        headerView.backgroundColor = QMUITheme().foregroundColor()
        headerView.addSubview(titleLabel)
        headerView.addSubview(detailLabel)
        headerView.addSubview(lineView)
        
        let margin: CGFloat = 18
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.centerY.equalToSuperview()
            make.width.equalTo(headerView.snp.width).multipliedBy(2.0/3.0)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.centerY.equalToSuperview()
            make.width.equalTo(headerView.snp.width).multipliedBy(1.0/3.0)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(1)
        }
        return headerView
    }
}
