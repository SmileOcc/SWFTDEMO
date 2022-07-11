//
//  YXNewStockDeliveredViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXNewStockDeliveredViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    @objc var tabPageViewScrollCallBack: YXTabPageScrollBlock?
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXNewStockDeliveredViewModel! = YXNewStockDeliveredViewModel()
    let reuseIdentifier = "YXNewStockDeliveredListCell"
    
    var sortArrs = [YXStockRankSortType.deliverApplyDate,
                       YXStockRankSortType.deliverStatus]
    
    let config = YXNewStockMarketConfig.init(leftItemWidth: YXConstant.screenWidth - 2 * 100 - 10 - 18)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "delivered_company")
        bindHUD()
        initNavigationBar()
        handleBlock()
        bindTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    fileprivate func initNavigationBar() {
//        let recordItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "newStock_purchase_list"), target: self, action: nil)
//        recordItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], for: .normal)
//        recordItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], for: .highlighted)
//        recordItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], for: .disabled)
        navigationItem.rightBarButtonItems = [messageItem]

//        recordItem.rx.tap.bind { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.viewModel.navigator.push(YXModulePaths.newStockPurcahseList.url)
//            }.disposed(by: disposeBag)
    }
    
    func bindTableView() {
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        setupRefreshHeader(tableView)
    
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
        tableView.dataSource = nil

        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
                var cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier)
                if cell == nil {
                    cell = YXNewStockDeliveredListCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
                    if let marketCell = cell as? YXNewStockDeliveredListCell {
            
                        self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                            point != marketCell.scrollView.contentOffset
                        }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                        marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                            point != self?.viewModel.contentOffsetRelay.value
                        }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                    }
                }
                let tableCell = (cell as! YXNewStockDeliveredListCell)
                tableCell.refreshUI(model: item, isLast: row == self.viewModel.dataSource.value.count - 1 ? true : false)
                return cell!
            }
            .disposed(by: disposeBag)
        
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
     
        }).disposed(by: rx.disposeBag)
        
        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    lazy var sectionHeaderView: YXNewStockMarketedSortView = {
       
        let view = YXNewStockMarketedSortView.init(sortTypes: sortArrs, config: self.config)
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.kSectionHeaderHeight)
        view.nameLabel.text = YXLanguageUtility.kLang(key: "delivered_company_name")
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        
        for subview in view.scrollView.subviews {
            if subview.isKind(of: YXNewStockMarketedSortButton.self), let button = subview as? YXNewStockMarketedSortButton {
                if button.mobileBrief1Type == .deliverStatus {
                    button.setImage(nil, for: .normal)
                    button.hiddenImage = true
                }
                button.titleLabel?.numberOfLines = 2
            }
        }
        return view
    }()
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
           [weak self] (state, type) in
            guard let strongSelf = self else { return }
            if type == .deliverApplyDate {
                switch state {
                case .normal:
                    strongSelf.viewModel.orderDirection = 0
                case .descending:
                    strongSelf.viewModel.orderDirection = 0
                case .ascending:
                    strongSelf.viewModel.orderDirection = 1
                }
            }
            if let refreshingBlock = strongSelf.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
        }
    }
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock =  refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        
        self.emptyView?.imageView.image = UIImage.init(named: "empty_noData")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "deliver_no_apply_company"))
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tabPageViewScrollCallBack?(scrollView)
    }
}

extension YXNewStockDeliveredViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = viewModel.dataSource.value[indexPath.row]
        
        if let booked = item.booked {
            if booked {
                return (YXUserManager.isENMode()) ? 100 : 85.0
            } else if item.subscribeFlag == 1, item.subscribeStatus == 20 {
                return (YXUserManager.isENMode()) ? 100 : 85.0
            }
        }
        return 60.0;
    }

    var kSectionHeaderHeight: CGFloat {
        34
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        kSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row < viewModel.dataSource.value.count {
            let item = viewModel.dataSource.value[indexPath.row]
            guard let subscribeId = item.subscribeId else {
                return
            }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_NEWSTOCK_BOOKING_URL(subscribeId)
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
    }
}

extension YXNewStockDeliveredViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        return self.tableView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        self.tabPageViewScrollCallBack = callback
    }
    
    
}
