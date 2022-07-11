//
//  YXSearchViewController.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import YXKit
import Moya
import NSObject_Rx

//class YXSearchBar: UIView {
//    @IBOutlet weak var cancelBtn :UIButton!
//    @IBOutlet weak var textField :UITextField!
//    @IBOutlet weak var textFieldRightCons: NSLayoutConstraint!
//    @IBOutlet weak var cameraBtn: UIButton!
//    
//    override var intrinsicContentSize: CGSize {
//        self.bounds.size
//    }
//}

class YXSearchViewController: YXHKViewController {
    
//    typealias API = YXSearchAPI
//
//    var networking: MoyaProvider<API> {
//        searchProvider
//    }
//
//    var viewModel = YXSearchViewModel()
//
//    private var resultContorller :YXSearchListController?
//    private var historyContorller :YXSearchListController?
//
//    @IBOutlet weak var searchBar: YXSearchBar!
//
//    @IBOutlet weak var resultView :UIView!
//    @IBOutlet weak var historyView :UIView!
//
//    @IBOutlet weak var innerEmptyView :UIView!
//    @IBOutlet weak var emptyLabel: UILabel!
//
//    var hotSearchList: [YXSearchItem]?
//
//    lazy var layoutView: QMUIFloatLayoutView = {
//        let view = QMUIFloatLayoutView()
//        view.padding = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
//        view.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 16)
//        view.minimumItemSize = CGSize(width: 52, height: 34)
//        view.clipsToBounds = true
//
//        return view
//    }()
//
//    lazy var bannerView: YXBannerView = {
//        let view = YXBannerView(imageType: .four_one)
//
//        view.requestSuccessBlock = {
//            [weak self]  in
//            guard let `self` = self else { return }
//            let bannerWidth = self.tableView.frame.width - 18 * 2
//            let bannerHeight = bannerWidth/4.0
//            self.bannerView.frame = CGRect(x: 18, y: self.hotSearchView.frame.height, width: bannerWidth, height: bannerHeight)
//            self.headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.hotSearchView.frame.height + self.bannerView.frame.height + 20);
//            self.tableView.reloadData()
//        }
//
//        return view
//    }()
//
//    lazy var headerView: UIView = {
//        let headerView = UIView()
//        return headerView
//    }()
//
//    lazy var tableView: UITableView = {
//        var tableView = UITableView()
//        historyView.subviews.forEach { [weak self] (subview) in
//             guard let strongSelf = self else { return }
//             if let view = subview as? UITableView {
//                tableView = view
//             }
//         }
//        return tableView
//    }()
//
//    lazy var hotSearchView: UIView = {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
//        view.clipsToBounds = true
//        let titleLabel1 = UILabel(frame:CGRect(x: 18, y: 0, width: 200, height: 20))
//        titleLabel1.text = YXLanguageUtility.kLang(key: "hot_search_stocks")
//        titleLabel1.textColor = QMUITheme().textColorLevel3()
//        titleLabel1.font = UIFont.systemFont(ofSize: 14)
//        view.addSubview(titleLabel1)
//
//        view.addSubview(layoutView)
//        return view
//    }()
//
//    var didTouchedCancel :(()->())?
//    var didSelectedItem :((YXSearchItem)->())?
//
//    static func instantiate(with type :YXSearchType, param :YXSearchParam? = nil) -> YXSearchViewController {
//        let ctrl = YXSearchViewController.instantiate()
//        ctrl.viewModel.type = type
//        ctrl.viewModel.defaultParam = param
//        ctrl.viewModel.historyViewModel.type = type
//        ctrl.viewModel.resultViewModel.type = type
//        return ctrl
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        layoutView.frame = CGRect(x: 0, y: 35, width: view.bounds.width, height: QMUIViewSelfSizingHeight)
//        if
//            let hotSearchList = self.hotSearchList,
//            layoutView.subviews.count != 0,
//            layoutView.subviews.count == hotSearchList.count,
//            hotSearchView.frame.height != layoutView.frame.height + 35 + 20 {
//
//            if layoutView.frame.height > 134 {
//                layoutView.frame = CGRect(x: 0, y: 35, width: view.bounds.width, height: 134)
//            }
//            hotSearchView.frame = CGRect(x: 0, y: 0, width:
//                tableView.bounds.width, height: layoutView.frame.height + 35 + 20);
//            bannerView.frame = CGRect(x: 18, y: hotSearchView.frame.height, width: bannerView.frame.width, height: bannerView.frame.height)
//            if ( bannerView.frame.height > 0) {
//                headerView.frame = CGRect(x: 0, y: 0, width:
//                    tableView.bounds.width, height: hotSearchView.frame.height + bannerView.frame.height + 20)
//            } else {
//                headerView.frame = CGRect(x: 0, y: 0, width:
//                    tableView.bounds.width, height: hotSearchView.frame.height)
//            }
//
//            tableView.reloadData()
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        headerView.addSubview(bannerView)
//        bannerView.requestBannerInfo(YXNewsType.search)
//        tableView.tableHeaderView = headerView
//
//
//        self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 18 * 2, height: 38)
//
//        self.navigationItem.titleView = self.searchBar
//        searchBar.cancelBtn.setTitle(YXLanguageUtility.kLang(key: "search_cancel"), for: .normal)
//        //MARK: 搜索取消
//        _ = searchBar.cancelBtn.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](_) in
//            self?.didTouchedCancel?()
//        })
//
//        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1, execute: {
//            self.searchBar.textField.becomeFirstResponder()
//        })
//
//        //监听搜索结果
//        _ = self.viewModel.historyViewModel.list.asObservable().filter({ (list) -> Bool in
//            list != nil
//        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
//            if let count = list?.count(), count <= 0 {
//                self?.showHistoryinnerEmptyView()
//            }
//        })
//
//        //监听搜索结果
//        _ = self.viewModel.resultViewModel.list.asObservable().filter({ (list) -> Bool in
//            list != nil
//        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
//            self?.showResultView()
//        })
//
//        searchBar.textField.placeholder = YXLanguageUtility.kLang(key: SearchLanguageKey.placeholder.rawValue)
//
//        _ = searchBar.textField.rx.text.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).filter({ (text) -> Bool in
//            text != nil
//        }).subscribe(onNext: { [weak self](text) in
//            if let text = text,text != "" {
//                _ = self?.viewModel.search(text: text)
//            } else {
//                self?.showHistoryView()
//            }
//        })
//
//        _ = searchBar.textField.rx.text.throttle(RxTimeInterval.seconds(0), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](text) in
//            guard let strongSelf = self else { return }
//            if !(text?.isEmpty ?? true) {//text?.count ?? 0 > 0
//                strongSelf.searchBar.cameraBtn.isHidden = true
//                strongSelf.searchBar.textFieldRightCons.constant = 0;
//            }else {
//                strongSelf.searchBar.cameraBtn.isHidden = false
//                strongSelf.searchBar.textFieldRightCons.constant = strongSelf.searchBar.cameraBtn.frame.width
//            }
//
//        })
//
//        _ = searchBar.textField.rx.controlEvent(.editingDidEndOnExit).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (e) in
//            if let count = self?.viewModel.resultViewModel.list.value?.count(), count == 1 {
//                self?.viewModel.resultViewModel.cellTapAction(at: 0)
//            }
//        })
//
//        _ = viewModel.resultViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](item) in
//            self?.didSelectedItem?(item)
//        })
//
//        _ = viewModel.historyViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](item) in
//            self?.didSelectedItem?(item)
//        })
//
//        self.request(.hotSearch) { [weak self] (response: YXResponseType<YXSearchList>) in
//            guard let strongSelf = self else { return }
//            switch response {
//            case .success(let result, let code):
//                if code == .success, let list = result.data?.list, list.count > 0 {
//                    strongSelf.hotSearchList = list;
//                    strongSelf.innerEmptyView.snp.remakeConstraints { (make) in
//                        make.centerX.equalToSuperview()
//                        make.top.equalTo(320)
//                    }
//
//                    strongSelf.headerView.addSubview(strongSelf.hotSearchView)
//                    for i in 0..<list.count {
//                        let item = list[i]
//                        let button = QMUIGhostButton(ghostColor: QMUITheme().textColorLevel1())
//                        button.cornerRadius = 4
//                        button.titleLabel?.lineBreakMode = .byTruncatingTail
//                        button.setTitle(item.name, for: .normal)
//                        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
//                        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//                        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
//                        button.rx.tap.takeUntil(strongSelf.rx.deallocated).subscribe(onNext: { [weak self] () in
//                            self?.didSelectedItem?(item)
//
//                            YXSensorAnalyticsTrack.track(withEvent: .Search, properties: [YXSensorAnalyticsPropsConstant.PROP_STOCK_ID : YXSensorAnalyticsPropsConstant.stockID(market: item.market, symbol: item.symbol)])
//                        }).disposed(by: strongSelf.rx.disposeBag)
//                        strongSelf.layoutView.addSubview(button)
//                    }
//                }
//            case .failed(let error):
//                log(.error, tag: kNetwork, content: "\(error)")
//            }
//        }.disposed(by: rx.disposeBag)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
////    self.navigationController?.navigationBar?.topItem. = UIBarButtonItem()
////        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
////
////        self.navigationItem.leftBarButtonItem = nil
////        self.navigationItem.hidesBackButton = true
////
////        self.navigationController?.navigationBar.backIndicatorImage = nil
////        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = nil
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//    }
//
//    private func showHotSearchView() {
//
//    }
//
//    //
//    private func showResultView() {
//
//        resultView.isHidden = false
//
//        if let count = self.viewModel.resultViewModel.list.value?.count(), count > 0 {
//            hideResultinnerEmptyView()
//        } else {
//            showResultinnerEmptyView()
//        }
//
//        historyView.isHidden = true
//    }
//
//    private func showHistoryView() {
//
//        historyView.isHidden = false
//
//        if let count = self.viewModel.historyViewModel.list.value?.count(), count > 0 {
//            hideHistoryinnerEmptyView()
//        } else {
//            showHistoryinnerEmptyView()
//        }
//
//        resultView.isHidden = true
//    }
//
//    private func showHistoryinnerEmptyView() {
//        innerEmptyView.isHidden = false
//        emptyLabel.text = YXLanguageUtility.kLang(key: SearchLanguageKey.history_empty.rawValue)
//
//        if let list = hotSearchList, list.count > 0 {
//            innerEmptyView.snp.remakeConstraints { (make) in
//                make.centerX.equalToSuperview()
//                make.top.equalTo(320)
//            }
//        }
//
//        historyView.subviews.forEach { (subview) in
//            if let tableView = subview as? UITableView {
//                tableView.bounces = false
//            }
//        }
//    }
//
//    private func hideHistoryinnerEmptyView() {
//        innerEmptyView.isHidden = true
//
//        historyView.subviews.forEach { (subview) in
//            if let tableView = subview as? UITableView {
//                tableView.bounces = true
//            }
//        }
//    }
//
//    private func showResultinnerEmptyView() {
//        innerEmptyView.isHidden = false
//        emptyLabel.text = YXLanguageUtility.kLang(key: SearchLanguageKey.result_empty.rawValue)
//
//        innerEmptyView.snp.remakeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(80)
//        }
//    }
//
//    private func hideResultinnerEmptyView() {
//        innerEmptyView.isHidden = true
//    }
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "history" {
//            historyContorller = segue.destination as? YXSearchListController
//            viewModel.historyViewModel.loadDiskCache()
//            historyContorller?.viewModel = viewModel.historyViewModel
//        } else if segue.identifier == "result" {
//            resultContorller = segue.destination as? YXSearchListController
//            resultContorller?.viewModel = viewModel.resultViewModel
//        }
//
//    }
//
//    @IBAction func cameraBtnAction(_ sender: UIButton) {
//        self.searchBar.textField.resignFirstResponder()
//        viewModel.navigator.push(YXModulePaths.importPic.url)
//    }
//
//    deinit {
//        print(">>>>>>> \(NSStringFromClass(YXSearchViewController.self)) deinit")
//    }
//
//    override func backBarButtonItemTitle(withPreviousViewController viewController: UIViewController?) -> String? {
//        nil
//    }
//

}
