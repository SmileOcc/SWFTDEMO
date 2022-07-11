//
//  YXDebugJSEntranceViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa
import RxDataSources

class YXDebugJSEntranceViewController: YXHKTableViewController, ViewModelBased {
    var viewModel: YXDebugJSEntranceViewModel!

    var datas: [YXDebugJSEntranceModel] = [YXDebugJSEntranceModel]()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.en_US_POSIX()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let localDatas = YXDebugJSEntranceModel.entrancesModelFromDisk() {
            self.datas = localDatas
        }
        
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelectionDuringEditing = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        self.tableView.register(YXDebugJSEntranceTableViewCell.self, forCellReuseIdentifier: "normal_identifier")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        // Do any additional setup after loading the view.
        self.title = "js调试配置"
        
        let addItem = UIBarButtonItem.qmui_item(withTitle: "添加", target: self, action: nil)
        
        self.navigationItem.rightBarButtonItems = [addItem]
        
        addItem.rx.tap
            .bind { [weak self] in
                let dialog = QMUIDialogTextFieldViewController()
                dialog.title = "增加配置"
                dialog.addTextField(withTitle: "名称", configurationHandler: { (titleLabel, textField, separatorLayer) in
                    textField.placeholder = "配置名称"
                })
                
                dialog.addTextField(withTitle: "URL", configurationHandler: { (titleLabel, textField, separatorLayer) in
                    textField.placeholder = "URL路径"
                    textField.keyboardType = .URL
                })
                dialog.addCancelButton(withText: "取消", block: nil)
                dialog.addSubmitButton(withText: "确定", block: { (aDialogViewController) in
                    if let view = self?.view {
                        let textFieldDialog = aDialogViewController as! QMUIDialogTextFieldViewController
                        let textFields = textFieldDialog.textFields
                        let item = YXDebugJSEntranceModel()
                        item.name = (textFields![0] as QMUITextField).text
                        item.url = (textFields![1] as QMUITextField).text
                        item.date = self?.formatter.string(from: Date())
                        item.showCloseBtn = true
                        
                        self?.datas.append(item)
                        DispatchQueue.global().async {
                            if let datas = self?.datas {
                                YXDebugJSEntranceModel.saveEntranceModel(entranceArray: datas)
                                DispatchQueue.main.async {
                                    self?.tableView.reloadData()
                                    
                                    aDialogViewController.hideWith(animated: true, completion: { (finished) in
                                        QMUITips.show(withText: "配置成功", in: view, hideAfterDelay: 1)
                                    })
                                }
                            }
                        }
                    }
                })
                
                dialog.show()
            }
            .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        103
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normal_identifier", for: indexPath) as! YXDebugJSEntranceTableViewCell
        
        cell.accessoryType = .disclosureIndicator
        cell.nameLabel.text = "名称：\(self.datas[indexPath.row].name ?? "")"
        cell.dateLabel.text = "时间：\(self.datas[indexPath.row].date ?? "")"
        cell.closeBtnTipsLabel.text = self.datas[indexPath.row].showCloseBtn ? "显示关闭按钮" : "不显示关闭按钮"
        cell.closeBtnTipsLabel.isHidden = true
        cell.urlLabel.text = "URL：\(self.datas[indexPath.row].url ?? "")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let url = self.datas[indexPath.row].url, url.count > 0 {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.datas.remove(at: indexPath.row)
            DispatchQueue.global().async {
                YXDebugJSEntranceModel.saveEntranceModel(entranceArray: self.datas)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    QMUITips.show(withText: "删除成功", in: self.view, hideAfterDelay: 1)
                }
            }
        }
    }
}
