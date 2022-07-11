//
//  YXCompanySettingsViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXBrokerSettingsViewController: YXHKViewController{

   
    var viewModel: YXBrokerSetViewModel!
    
    var tableView :UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        return tableView
    }()

    
    var logoutBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle("Log out of Broker", for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().mainThemeColor().cgColor
        btn.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        return btn
    }()
    
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        view.backgroundColor = QMUITheme().foregroundColor()
        tableView.backgroundColor = QMUITheme().foregroundColor()
        view.addSubview(tableView)
     
        
        self.title = YXLanguageUtility.kLang(key: "user_set")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(YXMineCommonViewCell.self, forCellReuseIdentifier: NSStringFromClass(YXMineConfigOneColCell.self))
        
        if  YXConstant.appTypeValue == .OVERSEA{
            view.addSubview(logoutBtn)
            logoutBtn.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-30)
                make.left.equalTo(28)
                make.right.equalTo(-28)
                make.height.equalTo(48)
            }
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.safeArea.top)
                make.bottom.width.left.right.equalTo(self.view)
               // make.bottom.equalTo(logoutBtn.snp.top)
            }
        }else {
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.safeArea.top)
                make.bottom.width.left.right.equalTo(self.view)
               // make.bottom.equalTo(logoutBtn.snp.top)
            }
        }
        
//      
        logoutBtn.addBlock(for: .touchUpInside) {[weak self] _ in
            guard let `self` = self else { return }
            YXProgressHUD.showError("Logout success", in: UIViewController.current().view, hideAfterDelay: 1.5)
            self.viewModel.logoutSubject.subscribe(onSuccess: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    YXUserManager.loginOutBroker(request: false)
                }
               
               // self.navigationController?.popViewController(animated: true)
            }, onError: { error in
                
            }).disposed(by: self.disposeBag)
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

extension YXBrokerSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = YXMineCommonViewCell(style: .default, reuseIdentifier: NSStringFromClass(YXMineConfigCell.self))
        cell.cellModel = self.viewModel.dataSource[indexPath.row]
        cell.refreshUI()
        return cell
    }
}

extension YXBrokerSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
//            let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .old, funType: .change, oldPwd: "", pwd: "", captcha: "", vc: self))
//            self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
            if YXUserManager.shared().tradePassword() {
                let context = YXNavigatable(viewModel: YXChangeTradePwdViewModel(type: .old, funType: .change, oldPwd: "", pwd: "", captcha: "", vc: self))
                self.viewModel.navigator.push(YXModulePaths.changeTradePwd.url, context: context)
            }else {
                YXUserUtility.noTradePwdAlert(inViewController: self, successBlock: { (_) in
                }, failureBlock: nil, isToastFailedMessage: nil, autoLogin: false, needToken: false)
            }
        }else if indexPath.row == 1{
            let context = YXNavigatable(viewModel: YXIBAcountViewModel())
            self.viewModel.navigator.push(YXModulePaths.IBAccount.url, context: context)
        }else if indexPath.row == 2{
            let context = YXWebViewModel.init(dictionary: [YXWebViewModel.kWebViewModelUrl:YXH5Urls.MY_COMMISSION()])
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: context)
        }
    }
}
