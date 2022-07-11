//
//  OSSVLanguageVC.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/31.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit


class OSSVLanguageVC: OSSVBaseVcSw {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = STLLocalizedString_("Setting_Cell_Languege")
        
        if let arr = STLLocalizationString.shareLocalizable().languageArray as NSArray? {
            self.datasArray = arr
        }
        self.handleDatas()
        self.stlInitView()
        self.stlAutoLayoutView()
    }
    
    func handleDatas() {
        let selectLang = STLLocalizationString.shareLocalizable().nomarLocalizable ?? ""
        
        for i in 0..<self.datasArray.count {
            if let model = self.datasArray[i] as? OSSVSupporteLangeModel,
               let langugaeCode = model.code as NSString? {
                if langugaeCode.hasPrefix(selectLang) {
                    self.selectedIndex = i
                    break
                }
            }
        }
        
        self.sourceIndex = self.selectedIndex
    }
    
    func saveLangguateAction() {
        
        if self.datasArray.count <= self.selectedIndex {
            return
        }
        OSSVCommonnRequestsManager.getAppCopywriting()
        
        if let supportModel = self.datasArray[self.selectedIndex] as? OSSVSupporteLangeModel,
           let code = supportModel.code as String? {
            
            if !STLIsEmptyString(code) {
                
                let oldLangage = STLLocalizationString.shareLocalizable().nomarLocalizable
                
                let selectLanguage = STLToString(code)
                
                STLLocalizationString.shareLocalizable().nomarLocalizable = selectLanguage
                STLLocalizationString.shareLocalizable().saveUserSelectLanguage(selectLanguage)
                STLLocalizationString.shareLocalizable().saveNomarLocalizableLanguage(selectLanguage)
                
                OSSVAnalyticsTool.sensorsDynamicConfigure()
                
                OSSVLanguageVC.initAppTabBarVCFromChangeLanguge(tabbarIndex: STLMainMoudle.account.rawValue) { success in
                    
                    if !success {
                        
                        STLLocalizationString.shareLocalizable().nomarLocalizable = oldLangage
                        STLLocalizationString.shareLocalizable().saveNomarLocalizableLanguage(oldLangage)
                    }
                }
                
                IQKeyboardManager.shared().toolbarDoneBarButtonItemText = STLLocalizedString_("keyboard_Done")
                OSSVNavigationVC.initialize()
            }
        }
    }
    

    override func stlInitView() {
        //暂时不要保存
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.saveButton)
//        self.saveButton.isEnabled = false
        self.view.addSubview(self.currencyTable)
    }
    
    override func stlAutoLayoutView() {
        self.currencyTable.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    //MARK: - setter
    var datasArray = NSArray.init()
    var selectedIndex: NSInteger = -1
    var sourceIndex: NSInteger = -1
    
    lazy var saveButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = OSSVThemesColors.stlClearColor()
        button.isEnabled = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(OSSVThemesColors.col_0D0D0D(), for: .normal)
        button.setTitleColor(OSSVThemesColors.col_B2B2B2(), for: .disabled)
        
        let title: NSString = STLLocalizedString_("english_save")! as NSString
        let titleSize = title.size(withAttributes: [NSAttributedString.Key.font : UIFont.init(name: button.titleLabel?.font.fontName ?? "", size: button.titleLabel?.font.pointSize ?? 16) ?? UIFont.systemFont(ofSize: 16)])
        button.setTitle(title as String, for: .normal)
        button.frame = CGRect.init(x: 0, y: 0, width: titleSize.width, height: self.navigationController?.navigationBar.height() ?? 44)

        button.rx.tap.subscribe { [weak self] _ in
            self?.saveLangguateAction()
        }.disposed(by: self.disposeBag)
        
        return button
    }()
    
    lazy var currencyTable: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .grouped)
        table.rowHeight = 52;
        table.backgroundColor = OSSVThemesColors.stlClearColor()
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth, height: 12))
        headerView.backgroundColor = OSSVThemesColors.col_F5F5F5()
        table.tableHeaderView = headerView
        table.delegate = self
        table.dataSource = self
        table.register(STLSettingNormalMarkCell.self, forCellReuseIdentifier: NSStringFromClass(STLSettingNormalMarkCell.self))
        
        return table
    }()

}

extension OSSVLanguageVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(STLSettingNormalMarkCell.self), for: indexPath) as! STLSettingNormalMarkCell
        
        if let model = self.datasArray[indexPath.row] as? OSSVSupporteLangeModel,
           let name = model.name as String? {
            cell.contentLabel.text = name
            cell.isMarked = indexPath.row == self.selectedIndex
            cell.showLine(show: !(indexPath.row == self.datasArray.count-1))
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row != self.selectedIndex {
            
            let space: CGFloat = CGFloat.topNavHeight;
            let actView: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
            actView.frame = CGRect.init(x: 0, y: 0, width: 15, height: 15)
            actView.center = CGPoint.init(x: self.view.center.x, y: self.view.center.y - space - 40)
            self.view.addSubview(actView)
            actView.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            self.selectedIndex = indexPath.row
            tableView.reloadData()
            
            STLUtilitySwift.delay(0.3) {
                actView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.saveLangguateAction()
            }
        }
        self.saveButton.isEnabled = self.sourceIndex != self.selectedIndex
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cornerView = STLSettingSectionHeaderCornerView.init(rect: CGRect.zero, size: CGSize.init(width: 6, height: 6))
        cornerView.isHidden = self.datasArray.count > 0 ? false : true
        return cornerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cornerView = STLSettingSectionFooterCornerView.init(rect: CGRect.zero, size: CGSize.init(width: 6, height: 6))
        cornerView.isHidden = self.datasArray.count > 0 ? false : true
        return cornerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.datasArray.count > 0 {
            return 6
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.datasArray.count > 0 {
            return Bool.kIS_IPHONEX ? 34+6 : 12+6
        }
        return 0.01
    }
}


extension OSSVLanguageVC {
    
    class func initAppTabBarVCFromChangeLanguge(tabbarIndex: NSInteger) {
        UIViewController.convertAppUILayoutDirection()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.initAppRootVC()
            appDelegate.tabBarVC.selectedIndex = tabbarIndex
        }
        
        OSSVAccountsManager.saveLeandCloudData()
    }
    
    class func initAppTabBarVCFromChangeLanguge(tabbarIndex: NSInteger, complete:(_ success:Bool)->Void) {
        UIViewController.convertAppUILayoutDirection()

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.initAppRootVC()
//            appDelegate.tabBarVC.selectedIndex = tabbarIndex
        }
        
        OSSVAccountsManager.saveLeandCloudData()
    }
}
