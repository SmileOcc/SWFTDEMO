//
//  YXStockManageListViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockManageListViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXStockManageListViewModel!
    
//    lazy var headerView: YXEditSecuHeaderView = {
//        let headerView = YXEditSecuHeaderView(frame:)
//        return headerView
//    }()
    lazy var headerView: YXEditSecuHeaderView = {
        let headerView = YXEditSecuHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 36))
        return headerView
    }()
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        return YXBottomSheetViewTool()
    }()
    
    lazy var bottomView: YXEditSecuBottomView = {
        let bottomView = YXEditSecuBottomView(frame: .zero)
        bottomView.onClickSelectedAll = { [weak self] (isSelected) in
            if isSelected {
                self?.viewModel.allCheck()
            } else {
                self?.viewModel.removeAllCheck()
            }
        }
        
        bottomView.onClickDelete = { [weak self] () in
            guard let strongSelf = self, let secuGroup = strongSelf.viewModel.secuGroup.value  else { return }
            
            var title = YXLanguageUtility.kLang(key: "tip_for_delete_optional_stock")
            if secuGroup.groupType() != .custom {
                title = YXLanguageUtility.kLang(key: "tips_for_delete_stock_from_all_group")
            }
            let alertView = YXAlertView(message: title)
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { (action) in
                
            }))
            
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak strongSelf, weak secuGroup] (action) in
                guard let strongSelf = strongSelf, let secuGroup = secuGroup  else { return }

                YXSecuGroupManager.shareInstance().remove(strongSelf.viewModel.checkedSecus, secuGroup: secuGroup)
                strongSelf.viewModel.checkedSecusRelay.accept([])
                strongSelf.viewModel.checkedSecus = []
            }))
            
            let alertController = YXAlertController(alert: alertView)
            strongSelf.present(alertController!, animated: true, completion: nil)
        }
        
        bottomView.onClickChange = { [weak self] () in
            guard let `self` = self else { return }
            guard let secuGroup = self.viewModel.secuGroup.value else { return }
            if YXUserManager.isLogin() {
                let groupSettingView = YXGroupSettingView(secus: self.viewModel.checkedSecus, secuName:"", currentOperationGroup: secuGroup, settingType: YXGroupSettingTypeAdd)

                self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "add_to_group")
                self.bottomSheet.rightButtonAction = { [weak groupSettingView, weak self] in
                    groupSettingView?.sureButtonAction()
                    self?.bottomSheet.hide()
                }
                self.bottomSheet.showView(view: groupSettingView)
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
        }
        
        return bottomView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = QMUITheme().popupLayerColor()
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(YXConstant.tabBarHeight())
        }
        
        initTableView()
        
        viewModel.checkedSecusRelay.subscribe(onNext: { [weak self] (checks) in
            guard let strongSelf = self else { return }
            
            strongSelf.bottomView.checkedCount = UInt(checks.count)
            strongSelf.bottomView.selectAllButton.isSelected = (checks.count == strongSelf.viewModel.secuGroup.value?.list.count && checks.count != 0)
            
            strongSelf.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.rowHeight = 63
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    func initTableView() {
        
        view.addSubview(tableView)
        
//        tableView.tableHeaderView = self.headerView;
        tableView.isEditing = true;
        tableView.allowsSelectionDuringEditing = true
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(view)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        let CellIdentifier = NSStringFromClass(YXEditSecuCell.self)
        tableView.register(YXEditSecuCell.self, forCellReuseIdentifier: CellIdentifier)
        
        viewModel.dataSource.bind(to: tableView.rx.items) { [weak self] (tableView, row, item) in
            guard
                let strongSelf = self, let secuGroup = strongSelf.viewModel.secuGroup.value,
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: IndexPath(row: row, section: 0)) as? YXEditSecuCell
                else { return YXEditSecuCell(style: .default, reuseIdentifier: CellIdentifier) }
            
            let market = item.market
            let symbol = item.symbol
            let name = item.name
            
            cell.symbolLabel.text = "--"
            if name.count > 0 {
                cell.symbolLabel.text = name
            }
            let secuId = YXSecuID(market: market, symbol: symbol)
            
            cell.nameLabel.text = symbol
            
            cell.marketLabel.market = market
            
            cell.checked = strongSelf.viewModel.isChecked(secuId)
            cell.indexPath = IndexPath(row: row, section: 0)
            
            cell.onClickCheck = { [weak strongSelf, weak cell] () in
                guard let strongSelf = strongSelf else { return }
                guard let cell = cell else { return }
                
                if cell.checked {
                    strongSelf.viewModel.check(secuId)
                } else {
                    strongSelf.viewModel.unCheck(secuId)
                }
            }
            
            cell.onClickStick = { [weak secuGroup]  () in
                guard let secuGroup = secuGroup else { return }
                
                YXSecuGroupManager.shareInstance().stick(secuGroup, secu: secuId)
                YXProgressHUD.showMessage(String(format: YXLanguageUtility.kLang(key: "stock_toTop"), name))
            }
            
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.itemMoved.subscribe(onNext: { [weak self] (sourceIndex, destinationIndex) in
            guard let strongSelf = self else { return }
            if let secuGroup = strongSelf.viewModel.secuGroup.value {
                let secu = strongSelf.viewModel.dataSource.value[sourceIndex.row]
                YXSecuGroupManager.shareInstance().exchange(secuGroup, secu: secu, to: destinationIndex.row)
                strongSelf.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            guard let strongSelf = self else { return }
            if let cell = strongSelf.tableView.cellForRow(at: indexPath) as? YXEditSecuCell {
                cell.checkButtonAction()
            }
        }).disposed(by: disposeBag)
        
        tableView.delegate = self
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

extension YXStockManageListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = tableView.cellForRow(at: indexPath) as? YXEditSecuCell {
            let secu = self.viewModel.dataSource.value[indexPath.row]
            let secuId = YXSecuID(market: secu.market, symbol: secu.symbol)
            if cell.checked {
                self.viewModel.unCheck(secuId)
            } else {
                self.viewModel.check(secuId)
            }
        }
    }
}

extension YXStockManageListViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        true
    }
    
}

extension YXStockManageListViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        UIImage(named: "optional_setting_empty")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        NSAttributedString(string: YXLanguageUtility.kLang(key: "opt_stock_empty"), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: QMUITheme().textColorLevel3()])
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        40
    }
}

