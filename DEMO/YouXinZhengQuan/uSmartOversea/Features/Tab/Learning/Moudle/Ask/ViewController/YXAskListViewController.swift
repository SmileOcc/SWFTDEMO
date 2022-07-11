//
//  YXAskContentViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import YXKit

enum YXAskListType: Int {
    case all = 1
    case waiting = 2
    case question = 3
    case answer = 4
    case kol = 5
}

extension Notification.Name {
    static let AskUserDeleteQuestion = Notification.Name("AskUserDeleteQuestion")
    static let AskUserDeleteAnswer = Notification.Name("AskUserDeleteAnswer")
}

class YXAskListViewController: YXHKTableViewController {
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader.init()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    let businessType = BehaviorRelay<YXAskListType>(value: .all)
    let kolId = BehaviorRelay<String?>(value: nil)
    let selectStocks = BehaviorRelay<[String]?>(value: nil)
    
    var viewModel: YXAskListViewModel!
    var scrollCallBack: YXTabPageScrollBlock?
    let likeAction = PublishSubject<(Bool,String)>()
    let deleteQuestionAction = PublishSubject<String?>()
    let deleteReplyAction = PublishSubject<(String?,String?)>()
    let reloadAction = PublishSubject<()>()
    
    var nextPageNum = 2
    
    var dataSource: [YXAskItemResModel]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var hotStockView: YXAskHotStoctView = {
        let view = YXAskHotStoctView()
        return view
    }()
    
    init(businessType: YXAskListType, kolId: String? = nil) {
        super.init(style: .grouped)
        self.kolId.accept(kolId)
        self.selectStocks.accept(nil)
        self.businessType.accept(businessType)
    }
    
    var selectedAllCallBack: (()->Void)?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInitialize() {
        super.didInitialize()
        initInput()
    }
    
    func initInput() {
        
        let viewDidLoad = self.rx.methodInvoked(#selector(viewDidLoad)).map { e in
            return ()
        }.asDriver(onErrorJustReturn: ())
        
        let loadMore = self.refreshFooter.rx.refreshing.map { [weak self] _ in
            return self?.nextPageNum ?? 1
        }.asDriver(onErrorJustReturn: 1)
        
        let refresh = Driver.merge(self.refreshHeader.rx.refreshing.asDriver(),
                                   self.reloadAction.asDriver(onErrorJustReturn: ()))
        
        viewModel = YXAskListViewModel(input: (viewDidLoad: viewDidLoad,
                                               kolId: kolId.asDriver(onErrorJustReturn: nil),
                                               businessType:businessType.asDriver(onErrorJustReturn: .all),
                                               likeAction: likeAction.asDriver(onErrorJustReturn: (false,"")),
                                               deleteQuestionAction: deleteQuestionAction.asDriver(onErrorJustReturn: nil),
                                               deleteReplyAction: deleteReplyAction.asDriver(onErrorJustReturn: (nil,nil)),
                                               stocksAction: selectStocks.asDriver(onErrorJustReturn: nil),
                                               loadMore: loadMore,
                                               reload: refresh))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    func setupUI(){
        self.view.backgroundColor = QMUITheme().foregroundColor()
        if businessType.value == .kol {
            emptyView?.verticalOffset = -YXConstant.screenHeight/5
        }
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.sectionHeaderHeight = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.sectionFooterHeight = 0
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.register(YXAskQuestionCell.self, forCellReuseIdentifier:  NSStringFromClass(YXAskQuestionCell.self))
        tableView.register(YXAnswerQuestionCell.self, forCellReuseIdentifier:  NSStringFromClass(YXAnswerQuestionCell.self))
        
    }
    
    func binding() {
        ///删除是也会删除其他tab
        NotificationCenter.default.rx.notification(Notification.Name.AskUserDeleteQuestion).subscribe (onNext: { [weak self] noti in
            guard let `self` = self else { return }
            if let userInfo = noti.userInfo, let qId = userInfo["qId"] as? String, let _ = self.dataSource {
                var questions = self.dataSource
                for (index,value) in self.dataSource!.enumerated() {
                    if value.questionId == qId {
                        questions?.remove(at: index)
                    }
                }
                self.dataSource = questions
                self.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        ///删除是也会删除其他tab
        NotificationCenter.default.rx.notification(Notification.Name.AskUserDeleteAnswer).subscribe (onNext: { [weak self] noti in
            guard let `self` = self else { return }
            if let userInfo = noti.userInfo, let qId = userInfo["qId"] as? String, let aId = userInfo["aId"] as? String , let _ = self.dataSource {
                for value in self.dataSource! {
                    if value.questionId == qId, let _ = value.replyDTOList {
                        var replyDTOList = value.replyDTOList
                        for (i,v) in value.replyDTOList!.enumerated() {
                            if v.replyId == aId {
                                replyDTOList?.remove(at: i)
                            }
                        }
                        value.replyDTOList = replyDTOList
                    }
                }
                self.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.init(rawValue: "ask_stock_list_refresh_page")).subscribe (onNext: { [weak self] noti in
            self?.reloadAction.onNext(())
        }).disposed(by: disposeBag)
        
        viewModel.listResult.drive { [weak self] res in
            guard let `self` = self else { return }
            self.refreshHeader.endRefreshing()
            if let res = res {
                self.dataSource = res.items
                if (res.items.count == 0) {
                    self.refreshFooter.isHidden = true
                    switch self.businessType.value {
                    case .question:
                        self.showErrorEmptyView(emptyType: .noQuestion)
                    case .answer:
                        self.showErrorEmptyView(emptyType: .noAnswer)
                    default:
                        self.showNoDataEmptyView(emptyType: .noAsk)
                    }
                } else {
                    self.hideEmptyView()
                }
            } else {
                self.dataSource = []
                self.showNoDataEmptyView(emptyType: .noAsk)
            }
        }.disposed(by: disposeBag)
        
        viewModel.likeResult.drive { [weak self] value in
            guard let `self` = self else { return }
            let (res,replyId) = value
            if let res = res {
                if res.code == .success {
                    if let list = self.dataSource {
                        for q in list {
                            if let replys = q.replyDTOList {
                                for a in replys {
                                    if a.replyId == replyId {
                                        if a.likeFlag {
                                            a.likeNum = a.likeNum - 1
                                        } else {
                                            a.likeNum = a.likeNum + 1
                                        }
                                        a.likeFlag = !a.likeFlag
                                    }
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    YXProgressHUD.showError(res.msg)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.deleteQuestionResult.drive { value in
            let (res,questionId) = value
            if let res = res {
                if res.code == .success {
                    NotificationCenter.default.post(name: Notification.Name.AskUserDeleteQuestion, object: nil, userInfo: ["qId":questionId ?? ""])
                } else {
                    YXProgressHUD.showError(res.msg)
                }
            } else {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }
        }.disposed(by: disposeBag)
        
        viewModel.deleteAnswerResult.drive { value in
            let (res,questionId,replyId) = value
            if let res = res {
                if res.code == .success {
                    NotificationCenter.default.post(name: Notification.Name.AskUserDeleteAnswer, object: nil, userInfo: ["qId":questionId ?? "" ,"aId" : replyId ?? ""])
                } else {
                    YXProgressHUD.showError(res.msg)
                }
            } else {
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }
        }.disposed(by: disposeBag)
        
        viewModel.loadMoreListResult.drive { [weak self] list in
            guard let `self` = self else { return }
            if let list = list {
                if list.items.count == 0 {
                    self.refreshFooter.endRefreshingWithNoMoreData()
                }else {
                    self.refreshFooter.endRefreshing()
                    self.dataSource = (self.dataSource ?? [] ) + list.items
                    self.nextPageNum += 1
                }
            }
        }.disposed(by: disposeBag)
        
        hotStockView.didSelectStocksCallback = { [weak self] stocks in
            self?.selectStocks.accept(stocks.compactMap{$0.stockCode})
        }
    }
    
    func showHotStock(hotStocks: [YXAskStockResModel]) {
        hotStockView.addHotStock(stocks: hotStocks)
        self.tableView.tableHeaderView = hotStockView
        self.tableView.reloadData()
    }
    
    override func emptyRefreshButtonAction() {
        self.selectedAllCallBack?()
    }
    
}

extension YXAskListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = dataSource?[section].replyDTOList?.count, count != 0 {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXAskQuestionCell.self), for: indexPath) as! YXAskQuestionCell
            if let model = dataSource?[indexPath.section] {
                cell.line.isHidden = !(indexPath.section == 0)
                cell.configure(model: model, businessType: businessType.value)
                cell.deleteCallback = { [weak self] in
                    YXAlertTool.commonAlert(title: "", message: YXLanguageUtility.kLang(key: "nbb_ask_delete_question"),
                                            leftTitle: YXLanguageUtility.kLang(key: "mine_no"),
                                            rightTitle: YXLanguageUtility.kLang(key: "mine_yes"),
                                            leftBlock: nil) { [weak self] in
                        self?.deleteQuestionAction.onNext(model.questionId ?? "")
                    }
                    
                }
                switch businessType.value {
                case .waiting:
                    if model.replyType == 1 {
                        cell.questionType = .none
                    } else {
                        cell.questionType = model.replyType == 3 ? .forme : .kol
                    }
                default:
                    cell.questionType = .none
                }
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXAnswerQuestionCell.self), for: indexPath) as! YXAnswerQuestionCell
            if let question = dataSource?[indexPath.section], let reply = question.replyDTOList?[indexPath.row-1] {
                cell.configure(model: reply, businessType: businessType.value)
                cell.deleteCallback = { [weak self] in
                    YXAlertTool.commonAlert(title: "", message: YXLanguageUtility.kLang(key: "nbb_ask_delete_answer"),
                                            leftTitle: YXLanguageUtility.kLang(key: "mine_no"),
                                            rightTitle: YXLanguageUtility.kLang(key: "mine_yes"), leftBlock: nil) { [weak self] in
                        self?.deleteReplyAction.onNext((question.questionId ?? "",reply.replyId ?? ""))
                    }
                    
                }
                cell.likeTapCallback = { [weak self, weak cell] in
                    YXToolUtility.handleBusinessWithLogin {
                        self?.likeAction.onNext((cell?.likeBtn.isSelected ?? false, reply.replyId ?? ""))
                    }
                }
                
                if businessType.value != .kol {
                    cell.didTapKolCallBack = {
                        YXToolUtility.handleBusinessWithLogin {
                            NavigatorServices.shareInstance.pushPath(YXModulePaths.kolHome, context: ["kolId":reply.replyUid], animated: true)
                        }
                    }
                }
                cell.kolBtn.isUserInteractionEnabled = reply.replyRole == 2

            }

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let questionId = self.dataSource?[indexPath.section].questionId ?? ""
        YXToolUtility.handleBusinessWithLogin {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.askDetail(questionId: questionId)]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
 
}

extension YXAskListViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack?(scrollView)
    }
}

extension YXAskListViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        return tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallBack = callback
    }
}
