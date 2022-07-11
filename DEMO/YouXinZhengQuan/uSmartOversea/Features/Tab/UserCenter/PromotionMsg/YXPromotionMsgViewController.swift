//
//  YXPromotionMsgViewController.swift
//  uSmartOversea
//
//  Created by Mac on 2019/8/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
///优惠信息设置
import UIKit

import RxSwift
import RxCocoa

struct YXPromotionValue {
    var phone: Bool = true
    var sms: Bool = true
    var email: Bool = true
    var mail: Bool = true
}

class YXPromotionMsgViewController: YXHKTableViewController, HUDViewModelBased {
    
    let disposeBag = DisposeBag()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXPromotionMsgViewModel!
    
    fileprivate var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = QMUITheme().foregroundColor() //白色
        btn.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 48)
        
        // fillCode
        btn.setBackgroundImage(btnBgImageGradientBlue, for: .normal)
        
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        btn.setTitleColor(UIColor.qmui_color(withHexString: "#EBEBEB"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    fileprivate var kTablefeeterHeight: CGFloat {
        40
    }
    
    var dataSource:[YXPromotionMsgCellData]?
    
    fileprivate let identifier = "YXPromotionMsgIdentifier"

    override var pageName: String {
            return "Promotional Notification Settings"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindHUD()
        bindViewModel()
        
        buildDataSource()
        queryUserConfig()
    }
    
    fileprivate func initUI() {
        //右导航
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableView.separatorStyle = .none
        
        // ====== tableHeaderView
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: kTablefeeterHeight))
        footerView.backgroundColor = QMUITheme().backgroundColor()
        
        
        self.title = YXLanguageUtility.kLang(key: "settings_promotional_message")
        
        let descLab = UILabel()
        descLab.textColor = QMUITheme().textColorLevel4()
        descLab.numberOfLines = 2
        descLab.text = YXLanguageUtility.kLang(key: "settings_promotional_message_means")
        descLab.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerView.addSubview(descLab)
        descLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        self.tableView.tableFooterView = footerView
        //self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.backgroundColor = QMUITheme().backgroundColor()

        self.tableView.register(YXPromotionMsgViewCell.self, forCellReuseIdentifier: identifier)
        tableView.snp.remakeConstraints {[weak self] (make) in
            guard let strongSelf = self else {return}
            make.left.right.equalTo(strongSelf.view)
            make.bottom.equalToSuperview()
            make.top.equalTo(strongSelf.view).offset(YXConstant.navBarHeight())
        }
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
//        view.addSubview(confirmBtn)
//        confirmBtn.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(confirmBtn.qmui_height)
//            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
//        }
    }
    
    //重写tableView布局
    override func layoutTableView() {
        
    }
    
    fileprivate func bindViewModel() {
        confirmBtn.rx.tap.bind {[weak self] in
            guard let `self` = self else {return}
            
            let pm = self.viewModel.promotValue
            self.viewModel.services.userService.request(.modifyUserConfigPromot(pm.phone, pm.sms, pm.email, pm.mail), response: self.viewModel.modifyResponse).disposed(by: self.disposeBag)
            
            }.disposed(by: disposeBag)
        
        self.viewModel.modifySubject.subscribe(onNext: {[weak self] (isSucceed, msg) in
            guard let `self` = self else {return}
            if isSucceed {
                self.buildDataSource()
//                self.navigationController?.popViewController(animated: true)
//                self.viewModel.hudSubject.onNext(.success(msg, true))
            } else {
                switch self.viewModel.curModifyType {
                case .phone:
                    self.viewModel.promotValue.phone = !self.viewModel.promotValue.phone
                case .sms:
                    self.viewModel.promotValue.sms = !self.viewModel.promotValue.sms
                case .email:
                    self.viewModel.promotValue.email = !self.viewModel.promotValue.email
                case .post:
                    self.viewModel.promotValue.mail = !self.viewModel.promotValue.mail
                }
                self.buildDataSource()
                self.viewModel.hudSubject.onNext(.error(msg, false))
            }
            
        }).disposed(by: self .disposeBag)
    }
    
    func queryUserConfig() {
        self.viewModel.hudSubject.onNext(.loading(nil, false))
        /*获取当前用户信息
         get-current-user/v1 */
        self.viewModel.services.userService.request(.getCurrentUser, response: self.viewModel.curUserResponse).disposed(by: self .disposeBag)

        self.viewModel.resultSubject.subscribe(onNext: {[weak self] (succeed) in
            guard let `self` = self else {return}

            self.buildDataSource()

        }).disposed(by: self .disposeBag)
    }
    
    fileprivate func buildDataSource() {
        let cell1 = YXPromotionMsgCellData(with: YXLanguageUtility.kLang(key: "privacy_permission_phone"), isOn: self.viewModel.promotValue.phone, showLine: true, msgType:.phone)
        let cell2 = YXPromotionMsgCellData(with: YXLanguageUtility.kLang(key: "privacy_permission_sms"), isOn: self.viewModel.promotValue.sms, showLine: true, msgType:.sms)
        let cell3 = YXPromotionMsgCellData(with: YXLanguageUtility.kLang(key: "privacy_permission_email"), isOn: self.viewModel.promotValue.email, showLine: true, msgType:.email)
        let cell4 = YXPromotionMsgCellData(with: YXLanguageUtility.kLang(key: "privacy_permission_post"), isOn: self.viewModel.promotValue.mail, showLine: false, msgType:.post)
        self.dataSource = [cell1, cell2, cell3, cell4]
        self.tableView.reloadData()
    }

}


struct YXPromotionMsgCellData {
    var title: String?
    var isOn = true
    var showLine = true
    var msgType: YXPromotionMsgType = .phone
    
    init() {
        
    }
    init(with title: String?, isOn: Bool, showLine: Bool, msgType: YXPromotionMsgType) {
        self.title = title
        self.isOn = isOn
        self.showLine = showLine
        self.msgType = msgType
    }
}

extension YXPromotionMsgViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource?.count ?? 0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = YXPromotionMsgViewCell(style: .default, reuseIdentifier: identifier)
        if let mode = dataSource?[indexPath.row] {
            cell.cellModel = mode
        }
        cell.refreshUI()
        cell.selectSubject.subscribe(onNext: {[weak self] (type, isOn) in
            guard let `self` = self else { return }
            switch type {
            case .phone:
                self.viewModel.promotValue.phone = isOn
            case .sms:
                self.viewModel.promotValue.sms = isOn
            case .email:
                self.viewModel.promotValue.email = isOn
            case .post:
                self.viewModel.promotValue.mail = isOn
            }
            self.viewModel.curModifyType = type
            self.viewModel.hudSubject.onNext(.loading("", true))
            let pm = self.viewModel.promotValue
            self.viewModel.services.userService.request(.modifyUserConfigPromot(pm.phone, pm.sms, pm.email, pm.mail), response: self.viewModel.modifyResponse).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        return cell
    }
    //header in section的高度
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //row的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        55
    }
}

class YXPromotionMsgViewCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    var cellModel = YXPromotionMsgCellData.init()
    
    let selectSubject = PublishSubject<(YXPromotionMsgType,Bool)>()
    
    var titleLab: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "initial_settings_smart_sorting")
        return label
    }()
    var switchView: UISwitch = {
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = QMUITheme().mainThemeColor()
//        switchView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        return switchView
    }()
    //底部的横线
    var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        return line
    }()
    
    
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLab)
        contentView.addSubview(switchView)
       // contentView.addSubview(lineView)
        
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(17)
            make.centerY.equalToSuperview()
        }
        switchView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-17)
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleLab.snp.right).offset(5)
        }
        
//        /// 底部横线
//        lineView.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview()
//            make.left.equalToSuperview().offset(10)
//            make.right.equalToSuperview().offset(-10)
//            make.height.equalTo(1)
//        }
        
        switchView.rx.isOn.asObservable().subscribe(onNext: {[weak self] (isOn) in
            guard let `self` = self else { return }
            self.selectSubject.onNext((YXPromotionMsgType(rawValue: self.switchView.tag) ?? .phone, self.switchView.isOn))
        }).disposed(by: disposeBag)

    }
    
    func refreshUI() {
        if let title = cellModel.title {
            titleLab.text = title
        }
      //  lineView.isHidden = !cellModel.showLine
        
        switchView.isOn = cellModel.isOn
        switchView.tag = cellModel.msgType.rawValue
    }
}

