//
//  YXGroupManageViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXGroupManageViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXGroupManageViewModel!
    
    lazy var headerView: YXEditGroupHeaderView = {
        let headerView = YXEditGroupHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 36))
        return headerView
    }()
    
    lazy var bottomView: YXEditGroupBottomView = {
        let bottomView = YXEditGroupBottomView(frame: .zero)
        bottomView.onClickAdd = { [weak self] () in
            if YXUserManager.isLogin() {
                self?.presentAddGroupAlert()
            } else {
                if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                    vc.hideWith(animated: true) { (finish) in
                        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: {_ in
                            vc.showWith(animated: true, completion: nil)
                        }, vc: nil))
                        self?.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                    }
                }
                
            }
        }
        
        return bottomView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = QMUITheme().popupLayerColor()
        
        self.title = YXLanguageUtility.kLang(key: "group_pop_title")
        
        
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
        tableView.allowsSelectionDuringEditing = true;
        return tableView
    }()
    
    lazy var addGroupTextFieldView: YXSetGroupNameTextfieldView = {
        let view = YXSetGroupNameTextfieldView()
        return view
    }()
    
    func initTableView() {
        
        view.addSubview(tableView)
        
//        tableView.tableHeaderView = self.headerView;
        tableView.isEditing = true;
        
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

        
        let CellIdentifier = NSStringFromClass(YXEditGroupCell.self)
        tableView.register(YXEditGroupCell.self, forCellReuseIdentifier: CellIdentifier)
        
        viewModel.dataSource.bind(to: tableView.rx.items) { [weak self] (tableView, row, item) in
            guard let strongSelf = self,
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: IndexPath(row: row, section: 0)) as? YXEditGroupCell  else { return YXEditGroupCell(style: .default, reuseIdentifier: CellIdentifier) }
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
            cell.secuID = Int32(secuGroup.id)
            cell.nameTextField.text = "\(name)"
            cell.nameTextField.rx.controlEvent(.editingDidEnd).subscribe {[weak cell,weak secuGroup] _ in
                if let name = cell?.nameTextField.text,name.isEmpty == false, let curSecru = cell?.secuID, curSecru == Int32(secuGroup!.id) ,let sName = secuGroup?.name, sName != name{
                    YXSecuGroupManager.shareInstance().change(secuGroup!, name: name)
                }
            }.disposed(by: self!.disposeBag)
//            cell.nameLabel.text = "\(name)"
            if secuGroup.groupType() == .custom {
                cell.nameTextField.isUserInteractionEnabled = true
                cell.deleteButton.isHidden = false
                cell.editButton.isHidden = false
                cell.nameTextField.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(48);
                    make.centerY.equalToSuperview();
                    make.width.equalTo(YXConstant.screenWidth/2.0)
                }
            } else {
                cell.nameTextField.isUserInteractionEnabled = false
                cell.deleteButton.isHidden = true
                cell.editButton.isHidden = true
                cell.nameTextField.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(18);
                    make.centerY.equalToSuperview();
                    make.width.equalTo(YXConstant.screenWidth/2.0)
                }
            }
            cell.onClickEdit = { [weak strongSelf, weak secuGroup] () in
                guard let secuGroup = secuGroup else { return }
                guard let strongSelf = strongSelf else { return }
                
                strongSelf.presentChangeGroupAlert(secuGroup)
            }
            
            cell.onClickDelete = { [weak strongSelf, weak secuGroup] () in
                guard let secuGroup = secuGroup else { return }
                guard let strongSelf = strongSelf else { return }
               // Stock will be deleted from all groups.Confirm to deleted?
                
                let alertView = YXAlertView.alertView(message: String(format: YXLanguageUtility.kLang(key: "tip_for_delete_group_and_stocks"), secuGroup.name))
                alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in
                    
                }))
                
                alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak secuGroup] (action) in
                    guard let secuGroup = secuGroup else { return }
                    YXSecuGroupManager.shareInstance().removeGroup(withGroupID: secuGroup.id)
                }))
                
                let alertController = YXAlertController(alert: alertView)!
                strongSelf.present(alertController, animated: true, completion: nil)
            }
            
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe(onNext: { [weak self] (sourceIndex, destinationIndex) in
            guard let strongSelf = self else { return }
            let secuGroup = strongSelf.viewModel.dataSource.value[sourceIndex.row]
            
            YXSecuGroupManager.shareInstance().exchange(secuGroup, to: destinationIndex.row)
            strongSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        tableView.delegate = self
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
    
    func presentChangeGroupAlert(_ secuGroup: YXSecuGroup) {
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "rename_stock_group"), message: "")
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] (action) in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak alertView, weak secuGroup] (action) in
            guard let secuGroup = secuGroup else { return }
            alertView?.hide()
            let name = alertView?.textField?.text ?? ""
            if name == secuGroup.name {
            } else {
                YXSecuGroupManager.shareInstance().change(secuGroup, name: name)
            }
            alertView?.hide()
        }))
        
        alertView.addTextField(maxNum: 12) { [weak secuGroup] (textField) in
            guard let secuGroup = secuGroup else { return }
            textField.text = secuGroup.name
            textField.keyboardDistanceFromTextField = 212
            if UIScreen.main.bounds.width < 375 {
                textField.keyboardDistanceFromTextField = YYTextCGFloatPixelRound(UIScreen.main.bounds.height/667.0 * 212.0)
            }
        }
        
        let alertController = YXAlertController(alert: alertView)!
        self.present(alertController, animated: true, completion: nil)

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

extension YXGroupManageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
}

