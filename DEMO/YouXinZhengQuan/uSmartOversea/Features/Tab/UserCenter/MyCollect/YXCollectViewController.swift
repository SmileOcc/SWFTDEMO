//
//  YXCollectViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
/* 我的收藏 */
import UIKit
import RxSwift
import RxCocoa
import YXKit
import Lottie

class YXCollectViewController: YXHKTableViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXCollectViewModel!
    
    var editBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_edit"), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .selected)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //LOTAnimationView
        return btn
    }()
    
    var delBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.isHidden = true
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_delete"), for: .normal)
        btn.setTitleColor(UIColor.white , for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setDisabledTheme()
        btn.layer.cornerRadius = 0;
        btn.isEnabled = false
        return btn
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
        bindHUD()
        
        loadData(isRefresh: true)
    }
    
    func initUI() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.register(YXCollectViewCell.self , forCellReuseIdentifier: "collectCell")
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 56))
        headerView.backgroundColor = UIColor.white
        
        let titleLab = QMUILabel()
        titleLab.text = YXLanguageUtility.kLang(key: "mine_collection")
        titleLab.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        titleLab.textColor = QMUITheme().textColorLevel1()
        headerView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(headerView).offset(18)
            make.top.equalTo(headerView).offset(6)
        }
        
        headerView.addSubview(editBtn)
        editBtn.snp.makeConstraints { (make) in
            make.right.equalTo(headerView).offset(-18)
            make.centerY.equalTo(titleLab)
        }
        
        tableView.tableHeaderView = headerView
        
        view.addSubview(delBtn)
        delBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeArea.bottom)
            make.height.equalTo(47)
        }
        
        self.tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }
    //
    @objc func abcd() {}
    
    func bindViewModel() {
        //MARK: - 数据请求成功的回调
        viewModel.loadSuccessSubject.subscribe(onNext: {[weak self] (count) in
            guard let strongSelf = self else {return}
            if count > 0 {
                strongSelf.tableView.mj_footer?.endRefreshing()
                strongSelf.tableView.reloadData()
                //显示
                strongSelf.tableView.mj_footer?.isHidden = false
                strongSelf.editBtn.isHidden = false
            } else {
                if strongSelf.viewModel.isRefresh {
                    strongSelf.showEmptyView()
                    //隐藏
                    strongSelf.tableView.mj_footer?.isHidden = true
                    strongSelf.editBtn.isHidden = true
                }
                strongSelf.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
        }).disposed(by: disposeBag)
        
        editBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            if !strongSelf.editBtn.isSelected && strongSelf.viewModel.newsArr.count == 0 {
                return
            }
            strongSelf.editBtn.isSelected = !strongSelf.editBtn.isSelected
            strongSelf.viewModel.isEditor = strongSelf.editBtn.isSelected
            if !strongSelf.viewModel.isEditor {
                for i in 0 ..< strongSelf.viewModel.newsArr.count {
                    var m = strongSelf.viewModel.newsArr[i]
                    m.isSelected = false
                    strongSelf.viewModel.newsArr[i] = m
                }
                strongSelf.viewModel.newsDelSet.removeAll()
            }
            strongSelf.tableView.reloadData()
            
            if strongSelf.editBtn.isSelected {
                strongSelf.delBtn.isHidden = false
            }else {
                strongSelf.delBtn.isHidden = true
                strongSelf.delBtn.setTitle(YXLanguageUtility.kLang(key: "mine_delete"), for: .normal)
            }
            strongSelf.viewModel.newsDelSet.removeAll()
            strongSelf.layoutTableView()
            strongSelf.delBtn.isEnabled = strongSelf.viewModel.newsDelSet.count > 0
            
        }).disposed(by: disposeBag)
        
        delBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.cleanChaceAlert()
           
        }).disposed(by: disposeBag)
        
        viewModel.collectSuccessSubject.subscribe(onNext: {[weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.viewModel.hudSubject.onNext(.success(YXLanguageUtility.kLang(key: "mine_del_success"), false))
           
            for m in strongSelf.viewModel.newsDelSet {
                strongSelf.viewModel.newsArr.removeAll(where: { (x) -> Bool in
                    x.newsid == m.newsid
                })
            }
            strongSelf.viewModel.newsDelSet.removeAll()
           
            for i in 0 ..< strongSelf.viewModel.newsArr.count {
                var m = strongSelf.viewModel.newsArr[i]
                m.isSelected = false
                strongSelf.viewModel.newsArr[i] = m
            }
                        
            strongSelf.layoutTableView()
            strongSelf.delBtn.isEnabled = strongSelf.viewModel.newsDelSet.count > 0
            strongSelf.tableView.reloadData()
            
        }).disposed(by: disposeBag)
    }
    
    @objc func loadMore() {
        viewModel.isRefresh = false
        loadData(isRefresh: false)
    }
    
    func loadData(isRefresh: Bool) {
        var offset = 0
        if !isRefresh {
            offset = viewModel.newsArr.count
        }else {
            viewModel.hudSubject.onNext(.loading("", false))
        }
        
        viewModel.services.newsService.request(.collectList(offset, pagesize: 30), response: viewModel.collectListResponse).disposed(by: disposeBag)
    }
    override func showEmptyView() {
        super.showEmptyView()
        
        self.emptyView?.detailTextLabel.text = nil
        self.emptyView?.loadingView.isHidden = true
        self.emptyView?.textLabelTextColor = QMUITheme().textColorLevel3()
        self.emptyView?.textLabelFont = UIFont.systemFont(ofSize: 14)
        
        self.emptyView?.setActionButtonTitle("")
        self.emptyView?.actionButton.isHidden = true
        
        if YXNetworkUtil.sharedInstance().reachability.currentReachabilityStatus() == .notReachable {
            self.emptyView?.setImage(UIImage(named: "network_nodata"))
            self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "common_net_error"))
        } else {
            self.emptyView?.imageView.image = UIImage.init(named: "empty_hold")
            self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "user_no_collect"))
        }
    }
    
    override func layoutTableView() {
        var h = view.frame.height
        if editBtn.isSelected {
            h = h - 47
        }
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: h)
    }
    
    func cleanChaceAlert() {
        
        let alertView = YXAlertView(message: String(format: "%@%ld%@", YXLanguageUtility.kLang(key: "mine_confirm_del1"), viewModel.newsDelSet.count, YXLanguageUtility.kLang(key: "mine_confirm_del2")))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "mine_delete"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()

            var newsIds = ""
            for model in self.viewModel.newsDelSet {
                if newsIds.count == 0 {
                    newsIds += model.newsid
                } else {
                    newsIds += "|\(model.newsid)"
                }
            }
            self.viewModel.hudSubject.onNext(.loading("", false))
            self.viewModel.services.newsService.request(.collect(newsIds, collectflag: false), response: self.viewModel.collectResponse).disposed(by: self.disposeBag)
            
        }))
        alertView.showInWindow()
    }
}

extension YXCollectViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var model = viewModel.newsArr[indexPath.row]
        if viewModel.isEditor {
            if viewModel.newsDelSet.contains(where: { (x) -> Bool in
                x.newsid == model.newsid
            }) {
                viewModel.newsDelSet.removeAll { (x) -> Bool in
                    x.newsid == model.newsid
                }
                model.isSelected = false
            }else {
                viewModel.newsDelSet.append(model)
                model.isSelected = true
            }
            if viewModel.newsDelSet.count > 0 {
                delBtn.setTitle(String(format: "%@(%ld)", YXLanguageUtility.kLang(key: "mine_delete"), viewModel.newsDelSet.count), for: .normal)
            }else {
                 delBtn.setTitle(YXLanguageUtility.kLang(key: "mine_delete"), for: .normal)
            }
            viewModel.newsArr[indexPath.row] = model
            tableView.reloadRows(at: [indexPath], with: .none)
            delBtn.isEnabled = viewModel.newsDelSet.count > 0
        }else {
            var dictionary: Dictionary<String, Any> = [
                "newsId" : model.newsid,
                "source" : YXPropInfoSourceValue.mineCollect,
                "newsTitle" : model.title
            ]
            if model.jumpType == YXInfomationType.Normal.rawValue {
                dictionary["type"] = YXInfomationType.Normal
            } else if model.jumpType == YXInfomationType.Recommend.rawValue {
                dictionary["type"] = YXInfomationType.Recommend
            }
            
            let infoViewModel = YXInfoDetailViewModel(dictionary: dictionary)
            infoViewModel.isCollectEnter = true
            infoViewModel.dataCallback = { [weak self] (isCollect) in
                guard let `self` = self else { return }
                
                if isCollect {
                    if !self.viewModel.newsArr.contains(model) {
                        self.viewModel.newsArr.append(model)
                    }
                } else {
                    if self.viewModel.newsArr.contains(model) {
                        self.viewModel.newsArr.removeAll(where: { element in element == model })
                    }
                }
                
                self.tableView.reloadData()
            }
            let context = YXNavigatable(viewModel: infoViewModel)
            self.viewModel.navigator.push(YXModulePaths.infoDetail.url, context: context)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = viewModel.newsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectCell", for: indexPath) as! YXCollectViewCell
        cell.model = model
        cell.isEditor = viewModel.isEditor
        cell.refreshUI()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.newsArr.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        138
    }
}
