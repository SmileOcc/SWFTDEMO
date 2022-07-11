//
//  YXPrivacyViewController.swift
//  uSmartOversea
//
//  Created by ysx on 2022/3/30.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit
import QCloudCore
import QMUIKit

class YXPrivacyViewController: YXHKTableViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXPrivacyViewModel!
    
    
    var dataSource: [[CommonCellData]] = {
        //section = 0
        var cellArr = [CommonCellData]()
        
        var serviceCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "login_privacy_tip_link_key_words_1"), describeStr: nil, showArrow: true, showLine: true)
        cellArr.append(serviceCell)
        
        let privacyCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "login_privacy_tip_link_key_words_2"), describeStr: nil, showArrow: true, showLine: false)
        cellArr.append(privacyCell)
        
        return [cellArr]
    }()
    
    override var pageName: String {
           return "Privacy"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
    }

    func initUI() {
        
        self.tableView.separatorStyle = .none

        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.view.backgroundColor = QMUITheme().foregroundColor()
        
        title = YXLanguageUtility.kLang(key: "user_privacy")
    }
    
    func bindViewModel() {
    }
}


extension YXPrivacyViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = YXMineCommonViewCell(style: .default, reuseIdentifier: "YXMineCommonViewCell")
        cell.cellModel = dataSource[indexPath.section][indexPath.row]
        cell.refreshUI()
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 { //服务
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.USER_REGISTRATION_AGREEMENT_URL(),
                    YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }else if indexPath.row == 1{//隐私
                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.PRIVACY_POLICY_URL(),
                    YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                ]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                
            }
            
        default:
            print("nothing")
        }
        
    }
    //row的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    //footer in section的高度
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    //footer insection
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        }
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        if section == 0 {
            v.backgroundColor = QMUITheme().backgroundColor()
            let lab = QMUILabel()
            lab.text = YXLanguageUtility.kLang(key: "agreement_statement")
            lab.textColor = QMUITheme().textColorLevel3()
            lab.font = UIFont.systemFont(ofSize: 12)
            lab.numberOfLines = 0
            v.addSubview(lab)
            lab.snp.makeConstraints { (make) in
                make.left.equalTo(v).offset(16)
                make.centerY.equalTo(v)
                make.right.equalTo(v).offset(-16)
            }
        }
        return v
    }
  
}
