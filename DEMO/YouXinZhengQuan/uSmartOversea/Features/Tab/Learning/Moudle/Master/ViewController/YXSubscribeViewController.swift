//
//  YXSubscribeViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXSubscribeViewController: YXHKTableViewController {
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader.init()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    var viewModel: YXSubscribeViewModel!
    var dataSource: [Any] = []
    
    var nextPageNum = 2
    
    var KOLListTotalPage = 1
    var refreshKOLPageNum = 1
    
    let emptyButtonAction = PublishSubject<Bool?>.init()
    let collectAction = PublishSubject<YXSpecialArticleItem?>.init()
    
    var subscribeState: Bool?
    
    var isFirstIn = true
    
    lazy var headerView: YXMySubscribeHeaderView = {
        let view = YXMySubscribeHeaderView()
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 164)
        return view
    }()
    
    lazy var refreshKOLButton: UIButton = {
        let button = QMUIButton()
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.qmui_color(withHexString: "#FF8B00"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setImage(UIImage(named: "change_icon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.setTitle(YXLanguageUtility.kLang(key: "change_refresh"), for: .normal)
        return button
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.text = YXLanguageUtility.kLang(key: "nbb_recommend_tip") 
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(refreshKOLButton)
        view.addSubview(label)
        
        refreshKOLButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(88)
            make.height.equalTo(28)
        }
        label.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(refreshKOLButton.snp.bottom).offset(8)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindViewModel()
    }
    
    func setUI() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexString: "F9F9F9")
        tableView.register(YXSpecialWriterCell.self, forCellReuseIdentifier: NSStringFromClass(YXSpecialWriterCell.self))
        tableView.register(YXSpecialContentCell.self, forCellReuseIdentifier: NSStringFromClass(YXSpecialContentCell.self))
        tableView.estimatedRowHeight = UITableView.automaticDimension
//        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20-YXConstant.tabBarHeight())
            make.centerX.equalToSuperview()
        }
    }
    
    // 输入
    func initViewModelInput() {
        
        let viewWillAppear = self.rx.methodInvoked(#selector(viewWillAppear(_:))).map { [weak self] e in
            return self?.subscribeState
        }.asDriver(onErrorJustReturn: nil)
        
        let loadMore = refreshFooter.rx.refreshing.map { [weak self] _ in
            guard let `self` = self else { return 2}
            return self.nextPageNum
        }.asDriver(onErrorJustReturn: 2)
        
        let refreshKOL = refreshKOLButton.rx.tap.do(onNext:{ [weak self] in
            let anim = CABasicAnimation(keyPath: "transform.rotation")
            anim.toValue = 2 * Double.pi
            anim.duration = 0.5
            anim.repeatCount = 1
            anim.isRemovedOnCompletion = true
            self?.refreshKOLButton.imageView?.layer.add(anim,forKey: "rotation")
        }).map { [weak self]_ in
            guard let `self` = self else { return 1 }
            if self.refreshKOLPageNum < self.KOLListTotalPage {
                self.refreshKOLPageNum += 1
            }else {
                self.refreshKOLPageNum = 1
            }
            return self.refreshKOLPageNum
        }.asDriver(onErrorJustReturn: 1)

        viewModel = YXSubscribeViewModel.init(input: (viewWillAppear: viewWillAppear,
                                                      refreshKOL: refreshKOL,
                                                      pullrefresh: self.refreshHeader.rx.refreshing.asDriver(),
                                                      loadMore: loadMore,
                                                      emptyButtonTaps: emptyButtonAction.asDriver(onErrorJustReturn: nil),
                                                      collectAction: collectAction))
        
        headerView.tapKolAction = { [weak self]kolinfo in
            if let id = kolinfo.subscriptId {
                self?.gotoKOLHomePage(id: id)
            }
        }
        
        headerView.tapViewAllAction = {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.myALLSubscribeKOL()]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
        
    }
    
    // 输出
    func bindViewModel() {
        
        viewModel.activity.drive(loadingHud.rx.isShowNetWorkLoading).disposed(by: disposeBag)
        
        // 是否有订阅
        viewModel.checkSubscribe.drive { [weak self]hasSubscribe in
            guard let `self` = self else { return }
            if let v = hasSubscribe {
                if v {
                    self.bottomView.isHidden = true
                    self.tableView.tableHeaderView = self.headerView
                    self.tableView.mj_footer = self.refreshFooter
                    self.tableView.mj_header = self.refreshHeader
                    self.tableView.contentInset = UIEdgeInsets.zero
                }else {
                    if self.isFirstIn {
                        NotificationCenter.default.post(name: NSNotification.Name("FirstInNoScribe"), object: nil)
                        self.isFirstIn = false
                    }
                    self.bottomView.isHidden = false
                    self.tableView.tableHeaderView = nil
                    self.tableView.mj_footer = nil
                    self.tableView.mj_header = nil
                    self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
                }
                
                // 更新状态
                self.subscribeState = hasSubscribe
            }
            
        }.disposed(by: disposeBag)
        
        // 我的订阅
        viewModel.mySubscribeKOLList.drive { [weak self]list in
            self?.headerView.dataSource = list
        }.disposed(by: disposeBag)
        
        // 订阅文章
        viewModel.subscribeArticleList.drive { [weak self]list in
            self?.hideEmptyView()
            self?.refreshHeader.endRefreshing()
            if let list = list, list.count > 0 {
                self?.dataSource = list
            }else if list?.count == 0 {
                self?.dataSource = []
                self?.showEmpty(emptyType: .noArticle)
            }else {
                self?.dataSource = []
                self?.showEmpty(emptyType: .netError)
            }
            self?.tableView.reloadData()
        }.disposed(by: disposeBag)
        
        // 未订阅时的推荐关注KOL列表
        viewModel.unSubscribeInfo.drive { [weak self]res in
            if let r = res {
                self?.dataSource = r.items
                self?.tableView.reloadData()
                self?.KOLListTotalPage = r.pageCount
            }
        }.disposed(by: disposeBag)
        
        // 加载更多订阅文章
        viewModel.loadMoreArticleList.drive { [weak self]list in
            guard let `self` = self else { return }
            if list.count == 0 {
                self.refreshFooter.endRefreshingWithNoMoreData()
            }else {
                self.refreshFooter.endRefreshing()
                self.dataSource = self.dataSource + list
                self.tableView.reloadData()
                self.nextPageNum += 1
            }
        }.disposed(by: disposeBag)
        
        // 点击收藏
        viewModel.collectResult.drive { [weak self]item in
            if item != nil {
                self?.tableView.reloadData()
            }else {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "network_timeout"))
            }
        }.disposed(by: disposeBag)

    }
    
    override func didInitialize() {
        super.didInitialize()
        
        initViewModelInput()
    }
    
    override func emptyRefreshButtonAction() {
        emptyButtonAction.onNext(self.subscribeState)
    }
    
    func gotoKOLHomePage(id: String) {
        YXToolUtility.handleBusinessWithLogin {
            NavigatorServices.shareInstance.pushPath(YXModulePaths.kolHome, context: ["kolId":id], animated: true)
        }
    }

}

extension YXSubscribeViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = dataSource[indexPath.row] as? YXSpecialKOLItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXSpecialWriterCell.self), for: indexPath) as! YXSpecialWriterCell
            cell.model = item
            return cell
            
        }else if let item = dataSource[indexPath.row] as? YXSpecialArticleItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXSpecialContentCell.self), for: indexPath) as! YXSpecialContentCell
            cell.model = item
            
            cell.tapCollect = { [weak self] in
                YXToolUtility.handleBusinessWithLogin {
                    self?.collectAction.onNext(item)
                }
            }
            
            cell.tapComment = {
                if let id = item.postId {
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleComment(postId: id)]
                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
            }
            
            cell.tapKOL = {
                if let id = item.authorId {
                    self.gotoKOLHomePage(id: id)
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataSource[indexPath.row] is YXSpecialKOLItem {
            return UITableView.automaticDimension
            
        }else if let item = dataSource[indexPath.row] as? YXSpecialArticleItem {
            
            var titleHeight =  YXToolUtility.getStringSize(with: item.postTitle ?? "", andFont: .systemFont(ofSize: 16, weight: .semibold), andlimitWidth: (Float(tableView.width)-64.0), andLineSpace: 5).height
            var contentHeight =  YXToolUtility.getStringSize(with: item.postContentSummary ?? "", andFont: .systemFont(ofSize: 14), andlimitWidth: (Float(tableView.width)-64.0), andLineSpace: 5).height
            
            if titleHeight > 44 {
                titleHeight = 44
            }
            
            if contentHeight > 60 {
                contentHeight = 60
            }
            
            let h = 90 + 8 + titleHeight + contentHeight + 72
            
            return h
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource[indexPath.row] as? YXSpecialKOLItem, let id = item.subscriptId {
            gotoKOLHomePage(id: id)
            
        }else if let item = dataSource[indexPath.row] as? YXSpecialArticleItem, let id = item.postId, let type = item.postType {
            if type == "2" {
                YXToolUtility.handleBusinessWithLogin {
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleDetail(postId: id)]
                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
            }else {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleDetail(postId: id)]
                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }
    }
}
