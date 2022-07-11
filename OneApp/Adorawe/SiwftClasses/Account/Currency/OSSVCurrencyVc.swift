//
//  OSSVCurrencyVc.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/31.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVCurrencyVc: OSSVBaseVcSw {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = STLLocalizedString_("Currency")
        if let currencyList = ExchangeManager.currencyList() as NSArray? {
            self.datasArray = currencyList
        }
        self.currentSelect()
        
        self.stlInitView()
        self.stlAutoLayoutView()
    }
    
    func currentSelect() {
        let rateModel = ExchangeManager.localCurrency()
        for i in 0..<self.datasArray.count {
            
            if let model = self.datasArray[i] as? RateModel,
               let code = model.code as NSString? {
                
                if code.isEqual(to: rateModel?.code ?? "") {
                    self.selectedIndex = i
                    self.sourceIndex = i
                    break
                }
            }
        }
    }
    
    override func stlInitView() {
        //不要保存了
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

//        button.rx.tap.subscribe { [weak self] _ in
//
//            if self?.selectedIndex ?? 0 >= 0 && self?.datasArray.count ?? 0 > self?.selectedIndex ?? 0{
//                if let rateModel = self?.datasArray[self?.selectedIndex ?? 0] as? RateModel {
//                    ExchangeManager.updateLocalCurrency(withRteModel: rateModel)
//
//                    UserDefaults.standard.setValue(true, forKey: kIsSettingCurrentKey)
//                    UserDefaults.standard.synchronize()
//
//                    OSSVLanguageVC.initAppTabBarVCFromChangeLanguge(tabbarIndex: STLMainMoudle.account.rawValue) { success in
//
//                    }
//
//                    OSSVAnalyticsTool.analyticsGAEvent(withName: "select_currency", parameters: ["screen_group":"Currency","currency":rateModel.symbol ?? ""])
//
//                }
//            }
//        }.disposed(by: self.disposeBag)
        
        return button
    }()
    
    lazy var currencyTable: UITableView = {
        let table = UITableView.init(frame: CGRect.zero, style: .grouped)
        table.rowHeight = 52;
        table.backgroundColor = OSSVThemesColors.stlClearColor()
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.showsHorizontalScrollIndicator = false
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth, height: 12))
        headerView.backgroundColor = OSSVThemesColors.col_F5F5F5()
        table.tableHeaderView = headerView
        table.delegate = self
        table.dataSource = self
        table.register(STLSettingNormalMarkCell.self, forCellReuseIdentifier: NSStringFromClass(STLSettingNormalMarkCell.self))
        
        return table
    }()

}

extension OSSVCurrencyVc:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datasArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(STLSettingNormalMarkCell.self), for: indexPath) as! STLSettingNormalMarkCell
        
        if let model = self.datasArray[indexPath.row] as? RateModel {
            var content = "\(model.code ?? "") \(model.symbol ?? "")"
            if OSSVSystemsConfigsUtils.isRightToLeftShow() {
                content = "\(model.symbol ?? "") \(model.code ?? "")"
            }
            cell.contentLabel.text = content
            cell.showLine(show: !(indexPath.row == self.datasArray.count-1))
            cell.isMarked = indexPath.row == self.selectedIndex
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        tableView.roundedGroup(willDisplay: cell, forRowAt: indexPath, radius: 6, backgroundColor: OSSVThemesColors.stlWhiteColor(), horizontolPadding: 12)
//    }
    
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
                
                if self.selectedIndex >= 0 && self.datasArray.count > self.selectedIndex{
                    if let rateModel = self.datasArray[self.selectedIndex] as? RateModel {
                        ExchangeManager.updateLocalCurrency(withRteModel: rateModel)
                        
                        UserDefaults.standard.setValue(true, forKey: kIsSettingCurrentKey)
                        UserDefaults.standard.synchronize()
                        
                        OSSVAnalyticsTool.analyticsGAEvent(withName: "select_currency", parameters: ["screen_group":"Currency","currency":rateModel.symbol ?? ""])
                        
                        OSSVLanguageVC.initAppTabBarVCFromChangeLanguge(tabbarIndex: STLMainMoudle.account.rawValue) { success in
                            
                        }
                    }
                }
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

