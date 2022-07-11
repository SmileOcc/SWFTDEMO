//
//  YXRecommendViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXRecommendViewController: YXHKTableViewController {
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader.init()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    var viewModel: YXRecommendViewModel1!
    var dataSource: [YXSpecialArticleItem] = []
    var recommendChatAsk: YXRecommendChatAskResModel?
    var nextPageNum = 2
    
    let collectAction = PublishSubject<YXSpecialArticleItem?>.init()
    let emptyButtonAction = PublishSubject<()>.init()
    
    override init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindViewModel()
    }
    
    func setUI() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexString: "F9F9F9")
        tableView.register(YXSpecialContentCell.self, forCellReuseIdentifier: NSStringFromClass(YXSpecialContentCell.self))
        tableView.register(YXRecommendChatCell.self, forCellReuseIdentifier: NSStringFromClass(YXRecommendChatCell.self))
        tableView.register(YXRecommendAskCell.self, forCellReuseIdentifier: NSStringFromClass(YXRecommendAskCell.self))
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.showsHorizontalScrollIndicator = false
    }
    
    // 输入
    func initViewModelInput() {
        
        let viewDidLoad = self.rx.methodInvoked(#selector(viewDidLoad)).map { e in
            return ()
        }.asDriver(onErrorJustReturn: ())
        
        let loadMore = refreshFooter.rx.refreshing.map { [weak self]_ in
            guard let `self` = self else { return 2}
            return self.nextPageNum
        }.asDriver(onErrorJustReturn: 2)
        
        viewModel = YXRecommendViewModel1.init(input: (viewDidLoad: viewDidLoad,
                                                      pullRefresh: refreshHeader.rx.refreshing.asDriver(),
                                                      loadMore: loadMore,
                                                      collectAction: collectAction,
                                                      emptyButtonTaps: emptyButtonAction.asDriver(onErrorJustReturn: ())))
    }
    
    // 输出
    func bindViewModel() {
        
        viewModel.activity.drive(loadingHud.rx.isShowNetWorkLoading).disposed(by: disposeBag)
        
        viewModel.resultList.drive { [weak self] value in
            let (res,list) = value
            self?.recommendChatAsk = res
            self?.refreshHeader.endRefreshing()
            if let list = list, list.count > 0 {
                self?.dataSource = list
                self?.tableView.reloadData()
                self?.hideEmptyView()
            }else if list?.count == 0 {
                self?.showEmpty(emptyType: .noArticle)
            }else {
                self?.recommendChatAsk = nil
                self?.dataSource = []
                self?.tableView.reloadData()
                self?.showEmpty(emptyType: .netError)
            }
        }.disposed(by: disposeBag)
        
        viewModel.loadMoreList.drive { [weak self]list in
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
        emptyButtonAction.onNext(())
    }
}

extension YXRecommendViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return recommendChatAsk?.chatGroupList.count == 0 ? 0 : 1
        case 1:
            return recommendChatAsk?.askRecommendList.count ?? 0
        default:
            return dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXRecommendChatCell.self), for: indexPath) as! YXRecommendChatCell
            cell.dataSource = self.recommendChatAsk?.chatGroupList
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXRecommendAskCell.self), for: indexPath) as! YXRecommendAskCell
            cell.model = self.recommendChatAsk?.askRecommendList[indexPath.row]
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXSpecialContentCell.self), for: indexPath) as! YXSpecialContentCell
            let item = dataSource[indexPath.row]
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
                    YXToolUtility.handleBusinessWithLogin {
                        NavigatorServices.shareInstance.pushPath(YXModulePaths.kolHome, context: ["kolId":id], animated: true)
                    }
                }
            }

            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 140
        case 1:
             return 80
        default:
            let item = dataSource[indexPath.row]
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

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else {
            return
        }
        guard indexPath.section != 1 else {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.askDetail(questionId: self.recommendChatAsk?.askRecommendList[indexPath.row].questionId ?? "")]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            return
        }
        let item = dataSource[indexPath.row]
        if let id = item.postId, let type = item.postType{
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if let chatGroupList = recommendChatAsk?.chatGroupList, chatGroupList.count != 0 {
                return 30
            } else {
                return 0.1
            }
        case 1:
            if let chatGroupList = recommendChatAsk?.askRecommendList, chatGroupList.count != 0 {
                return 30
            } else {
                return 0.1
            }
        case 2:
            if dataSource.count != 0 {
                return 30
            } else {
                return 0.1
            }
        default:
            return 0.1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = YXRecommendTitleHeaderView()
        switch section {
        case 0:
            if let chatGroupList = recommendChatAsk?.chatGroupList, chatGroupList.count != 0 {
                view.titleLabel.text = YXLanguageUtility.kLang(key: "nbb_title_chatroom")
                view.moreButton.isHidden = false
                view.moreTapCallback = {
                    YXToolUtility.handleBusinessWithLogin {
                        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.chatList()]
                        NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    }
                }
                return view
            } else {
                return nil
            }
        case 1:
            if let askRecommendList = recommendChatAsk?.askRecommendList, askRecommendList.count != 0 {
                view.titleLabel.text = YXLanguageUtility.kLang(key: "nbb_title_ask")
                view.moreButton.isHidden = false
                view.moreTapCallback = {
                    YXToolUtility.handleBusinessWithLogin {
                        NavigatorServices.shareInstance.pushPath(YXModulePaths.ask, context: nil, animated: true)
                    }
                }
                return view
            } else {
                return nil
            }
        case 2:
            if dataSource.count != 0 {
                view.titleLabel.text = YXLanguageUtility.kLang(key: "nbb_title_articles")
                view.moreButton.isHidden = true
                return view
            } else {
                return nil
            }
        default:
            return nil
        }
        
    }
}
