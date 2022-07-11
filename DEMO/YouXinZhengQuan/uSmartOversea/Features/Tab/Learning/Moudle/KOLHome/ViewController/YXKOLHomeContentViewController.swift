//
//  YXKOLHomeContentViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import YXKit
import RxSwift
import RxCocoa
import QMUIKit
import SnapKit

enum YXKOLHomeContentType {
    case articles
    case chat
    case video
}

class YXKOLHomeContentViewController: YXHKTableViewController {
    
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader.init()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    
    let collectAction = PublishSubject<YXSpecialArticleItem?>()
    let kolId = BehaviorRelay<String>(value: "")
    let businessType = BehaviorRelay<YXKOLHomeContentType>(value: .articles)
    var viewModel: YXKOLHomeContentViewModel!
    var scrollCallBack: YXTabPageScrollBlock?
    var nextPageNum = 2
    var dataSource: [Any]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(kolId: String?, businessType: YXKOLHomeContentType) {
        super.init()
        self.businessType.accept(businessType)
        self.kolId.accept(kolId ?? "")
    }
    
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
        
        viewModel = YXKOLHomeContentViewModel(input: (viewDidLoad: viewDidLoad,
                                                      kolId: kolId.asDriver(onErrorJustReturn: ""),
                                                      businessType:businessType.asDriver(onErrorJustReturn: .articles),
                                                      collectAction: collectAction,
                                                      loadMore: loadMore,
                                                      reload: self.refreshHeader.rx.refreshing.asDriver()))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    func setupUI(){
        self.view.backgroundColor = QMUITheme().foregroundColor()

        emptyView?.verticalOffset = -YXConstant.screenHeight/5
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.sectionHeaderHeight = 0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.sectionFooterHeight = 0
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.register(YXViewsContentCell.self, forCellReuseIdentifier:  NSStringFromClass(YXViewsContentCell.self))
        tableView.register(YXKOLChatRoomCell.self, forCellReuseIdentifier:  NSStringFromClass(YXKOLChatRoomCell.self))
        
    }
    
    func binding() {
        
        viewModel.result.drive { [weak self] list in
            guard let `self` = self else { return }
            if let list = list {
                self.dataSource = list
                if (list.count == 0) {
                    self.showNoDataEmptyView(emptyType: self.businessType.value == .articles ? .noArticle : .noChat)
                } else {
                    self.hideEmptyView()
                }
                if (list.count < YXKOLHomeContentViewModel.pageSize) {
                    self.refreshFooter.isHidden = true
                } else {
                    self.refreshFooter.isHidden = false
                }
            } else {
                self.hideEmptyView()
            }

        }.disposed(by: disposeBag)
        
        viewModel.loadMoreListResult.drive { [weak self] list in
            guard let `self` = self else { return }
            if let list = list {
                if list.count == 0 {
                    self.refreshFooter.endRefreshingWithNoMoreData()
                } else {
                    self.refreshFooter.endRefreshing()
                    self.dataSource = (self.dataSource ?? [] ) + list
                    self.nextPageNum += 1
                }
            } else {
                self.refreshFooter.endRefreshing()
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
}

extension YXKOLHomeContentViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = dataSource?[indexPath.row] as? YXSpecialArticleItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXViewsContentCell.self), for: indexPath) as! YXViewsContentCell
            cell.topline.isHidden = !(indexPath.row == 0)
            cell.model = item
//            cell.tapCollect = { [weak self] in
//                YXToolUtility.handleBusinessWithLogin {
//                    self?.collectAction.onNext(item)
//                }
//            }
            
//            cell.tapComment = {
//                if let id = item.postId {
//                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleComment(postId: id)]
//                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                }
//            }
            
            return cell
        } else if let item = dataSource?[indexPath.row] as? YXKOLChatGroupResModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXKOLChatRoomCell.self), for: indexPath) as! YXKOLChatRoomCell
            cell.model = item
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let item = dataSource?[indexPath.row] as? YXSpecialArticleItem {
            var height = 118.0
            if let pictureUrl = item.postCover, pictureUrl.count > 0 {
                height = 118
            } else {
                height = (25 + 25)
                var h = YXToolUtility.getStringSize(with: item.postTitle ?? "", andFont: UIFont.systemFont(ofSize: 16, weight: .medium), andlimitWidth: Float(self.tableView.width - 32)).height
                if h <= 21 {
                    h = 21
                } else if (h > 21 && h < 42){
                    h = 42
                } else {
                    h = 42
                }
                height += Double(h)
                
                height += 18 + 8
            }

            return CGFloat(height)
       }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource?[indexPath.row] as? YXSpecialArticleItem, let id = item.postId, let type = item.postType {
            if type == "2" {
                YXToolUtility.handleBusinessWithLogin {
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleDetail(postId: id)]
                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
            }else {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleDetail(postId: id)]
                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        } else if let item = dataSource?[indexPath.row] as? YXKOLChatGroupResModel, let id = item.chatGroupId {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.chatRoom(chatRoomId: id)]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
}

extension YXKOLHomeContentViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack?(scrollView)
    }
}

extension YXKOLHomeContentViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        return tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallBack = callback
    }
}
