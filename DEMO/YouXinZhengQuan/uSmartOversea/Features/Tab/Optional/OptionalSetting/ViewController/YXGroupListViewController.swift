//
//  YXGroupListViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/12/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXGroupListViewController:  YXHKViewController, ViewModelBased {

    var viewModel: YXGroupManageViewModel!
    
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightButton.isHidden = true
        sheet.leftButton.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        return sheet
    }()
    
    lazy var manageBtn: QMUIButton = {
        let image = UIImage(named: "optional_setting") ?? UIImage()
        let button = QMUIButton() //UIBarButtonItem.qmui_item(with: UIImage(named:
        button.setImage(image, for: .normal)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 4
        button.setTitle(YXLanguageUtility.kLang(key: "group_manager_btn"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] () in
            guard let `self` = self else { return }

            if YXUserManager.isLogin() {
                
                if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                    vc.hideWith(animated: true) { (finish) in
                        let vm = YXGroupManageViewModel()
                        let vc = YXGroupManageViewController.instantiate(withViewModel: vm, andServices: self.viewModel.services!, andNavigator: self.viewModel.navigator)
                        self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "group_pop_title")
                        self.bottomSheet.showViewController(vc: vc)
                    }
                }

            } else {
                
                if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                    vc.hideWith(animated: true) { (finish) in
                        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: {_ in
                            vc.showWith(animated: true, completion: nil)
                        }, vc: nil))
                        self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                    }
                }
            }

            
        }).disposed(by: disposeBag)
        
        return button
    }()
    
    lazy var editBtn: QMUIButton = {
        

        let image = UIImage(named: "edit_add") ?? UIImage()
        let button = QMUIButton() //UIBarButtonItem.qmui_item(with: UIImage(named:
        button.setImage(image, for: .normal)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 4
        button.setTitle(YXLanguageUtility.kLang(key: "add_group"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        
        button.rx.tap.subscribe(onNext: { [weak self] () in
            guard let `self` = self else { return }

            if YXUserManager.isLogin() {
                self.presentAddGroupAlert()
            } else {
                if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                    vc.hideWith(animated: true) { (finish) in
                        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: {_ in
                            vc.showWith(animated: true, completion: nil)
                        }, vc: nil))
                        self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                    }
                }
            }
            
        }).disposed(by: disposeBag)
        
        return button
    }()
    
    lazy var bottomView: UIView = {
        let bottomView = UIView()
        
        bottomView.addSubview(editBtn)
        bottomView.addSubview(manageBtn)
        
        editBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
           // make.width.equalTo(YXConstant.screenWidth * 0.5)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(50)
        }
        manageBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(50)
        }
        
        let line1 = UIView.line()
        line1.backgroundColor = QMUITheme().popSeparatorLineColor()
        bottomView.addSubview(line1)
        let line2 = UIView.line()
        line2.backgroundColor = QMUITheme().popSeparatorLineColor()
        bottomView.addSubview(line2)
        
        line1.snp.makeConstraints { make in
            make.width.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        line2.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(0.5)
        }
        
        return bottomView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = QMUITheme().popupLayerColor()
        
        self.title = YXLanguageUtility.kLang(key: "market_watchlist_title")
        
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(YXConstant.tabBarHeight())
        }
        
        initTableView()
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(addGroupTextFieldView)
            addGroupTextFieldView.snp.makeConstraints { (make) in
                make.left.right.top.bottom.equalToSuperview()
            }
            window.bringSubviewToFront(addGroupTextFieldView)
        }
//        view.addSubview(addGroupTextFieldView)
//        addGroupTextFieldView.snp.makeConstraints { (make) in
//            make.left.right.top.bottom.equalToSuperview()
//        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.rowHeight = 52
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var addGroupTextFieldView: YXSetGroupNameTextfieldView = {
        let view = YXSetGroupNameTextfieldView()
        return view
    }()
    
    func initTableView() {
        
        view.addSubview(tableView)
        
        if #available(iOS 11.0, *) {
            tableView.snp.makeConstraints { (make) in
                make.left.right.top.equalTo(view)
                make.bottom.equalTo(bottomView.snp.top)
            }
        } else {
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(64)
                make.left.right.equalTo(view)
                make.bottom.equalTo(bottomView.snp.top)
            }
        }

        
        let CellIdentifier = NSStringFromClass(YXGroupListCell.self)
        tableView.register(YXGroupListCell.self, forCellReuseIdentifier: CellIdentifier)
        viewModel.dataSource.bind(to: tableView.rx.items) {[weak self] (tableView, row, item) in
            guard let `self` = self, let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: IndexPath(row: row, section: 0)) as? YXGroupListCell  else { return YXGroupListCell(style: .default, reuseIdentifier: CellIdentifier) }
            var secuGroup = item
            if (secuGroup.id == YXDefaultGroupID.IDHOLD.rawValue) {
                secuGroup = YXSecuGroupManager.shareInstance().holdSecuGroup
            }else if (secuGroup.id == YXDefaultGroupID.IDLATEST.rawValue) {
                secuGroup = YXSecuGroupManager.shareInstance().latestSecuGroup
            }
            
            var name = secuGroup.name
            if let groupId = YXDefaultGroupID(rawValue: secuGroup.id) {
                switch groupId {
                case .idAll:
                    name = YXLanguageUtility.kLang(key: "common_all")
                case .IDHK:
                    name = YXLanguageUtility.kLang(key: "community_hk_stock")
                case .IDUS:
                    name = YXLanguageUtility.kLang(key: "community_us_stock")
                case .IDCHINA:
                    name = YXLanguageUtility.kLang(key: "community_cn_stock")
                case .IDHOLD:
                    name = YXLanguageUtility.kLang(key: "hold_holds")
                case .IDUSOPTION:
                    name = YXLanguageUtility.kLang(key: "options_options")
                case .IDSG:
                    name = YXLanguageUtility.kLang(key: "community_sg_stock")
                default:
                    break
                }
            }
            cell.selectedGroup = self.viewModel.selectGroup.id == secuGroup.id
            cell.nameLabel.text = "\(name)" + "(\(secuGroup.list.count))"
            
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(YXSecuGroup.self)
                    .subscribe(onNext: { (model) in
            self.viewModel.secuGroup.accept(model)
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
    }
    
    func presentAddGroupAlert() {
        if YXSecuGroupManager.shareInstance().customGroupPool.count >= 10 {
            YXProgressHUD.showError(YXLanguageUtility.kLang(key: "tips_group_count_max"), in: UIApplication.shared.keyWindow)
        } else {
            if let window = UIApplication.shared.keyWindow {
                window.addSubview(addGroupTextFieldView)
                addGroupTextFieldView.snp.makeConstraints { (make) in
                    make.left.right.top.bottom.equalToSuperview()
                }
                window.bringSubviewToFront(addGroupTextFieldView)
                addGroupTextFieldView.textField.text = nil
                addGroupTextFieldView.textField.becomeFirstResponder()
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
