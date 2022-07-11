//
//  YXA-HKRankListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXA_HKRankListViewController: YXViewController {
    
    var rankListViewModel: YXA_HKRankListViewModel {
        let vm = viewModel as! YXA_HKRankListViewModel
        return vm
    }
    
    var disposeBag = DisposeBag()
    
    var tabPageViewScrollCallBack: YXTabPageScrollBlock?
    
    lazy var tableView: YXTableView = {
        let tableView = YXTableView.init(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = QMUITheme().backgroundColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.separatorStyle = .none
        
        if #available(iOS 11.0, *) {
            tableView.estimatedRowHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        tableView.register(YXA_HKRankCell.self, forCellReuseIdentifier: NSStringFromClass(YXA_HKRankCell.self))
        tableView.register(YXA_HKLimitWarnCell.self, forCellReuseIdentifier: NSStringFromClass(YXA_HKLimitWarnCell.self))
        
        return tableView
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        let footer = YXRefreshAutoNormalFooter.init { [weak self] in
            self?.requestData()
        }
        return footer
    }()
    
    lazy var headerView: YXA_HKRankHeaderView = {
        let rect = CGRect.init(x: 0, y: 0, width: self.view.size.width, height: 100)
        let view = YXA_HKRankHeaderView.init(frame: rect, rankType: rankListViewModel.rankType)
        view.tapSortButtonAction = { [weak self](sort) in
            self?.refreshFooter?.resetNoMoreData()
            self?.tableView.contentOffset = CGPoint.zero
            self?.rankListViewModel.page = 0
            self?.rankListViewModel.rankSort = sort
            self?.requestData()
        }
        
        view.selectTimeButton.rx.tap.subscribe(onNext: { [weak self] in
            let vc = YXAlertController.init(alert: self?.datePickerView, preferredStyle: .actionSheet)
            guard let `self` = self, let viewController = vc else { return }
            viewController.backgoundTapDismissEnable = true
            self.present(viewController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        return view
    }()
    
    lazy var datePickerView: YXA_HKRankDatePickerView = {
        let view = YXA_HKRankDatePickerView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.safeAreaInsetsBottomHeight()+230))
        view.selectedDateSubject.subscribe(onNext: { [weak self](date) in
            // 去掉日期”-“
            let str = date.replacingOccurrences(of: "-", with: "")
            let dateModel = YXDateToolUtility.dateTimeAndWeek(withTime: str + "000000000")
            self?.headerView.selectTimeButton.setTitle(date + " \(dateModel.week)", for: .normal)
            self?.headerView.selectTimeButton.setButtonImagePostion(.right, interval: 2)
            // 转成服务端需要的时间格式
            let day: Int64 = (Int64(str) ?? 0) * 1000000000
            self?.rankListViewModel.day = day
            self?.rankListViewModel.page = 0
            self?.requestData()
            self?.tableView.contentOffset = CGPoint.zero
        }).disposed(by: disposeBag)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            if rankListViewModel.rankType == .fundDirection || rankListViewModel.rankType == .volume {
                make.height.equalTo(87)
            }else {
                make.height.equalTo(57)
            }
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.dealAmountSortButton.setButtonImagePostionRight(3)
        headerView.fundFlowSortButton.setButtonImagePostionRight(3)
        headerView.dealRatioSortButton.setButtonImagePostionRight(3)
    }
    
    func reloadData() {
        
        tableView.reloadData()
        
        if tableView.mj_footer == nil {
            if !rankListViewModel.rankDataSource.isEmpty {
                tableView.mj_footer = refreshFooter
            }
        }else {
            
            if rankListViewModel.canLoadMore {
                tableView.mj_footer.endRefreshing()
            }else {
                tableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
    }
    
    func refreshData() {
        self.rankListViewModel.page = 0
        requestData()
        
        if rankListViewModel.rankType == .fundDirection || rankListViewModel.rankType == .volume {
            requestTradeDate()
        }
    }
    
    func requestData() {
        switch rankListViewModel.rankType {
        case .fundDirection:
            self.rankListViewModel.getFundDirection().subscribe(onSuccess: { [weak self](res) in
                self?.reloadData()
            }).disposed(by: disposeBag)
        case .roc:
            break
        case .volume:
            self.rankListViewModel.getVolume().subscribe(onSuccess: { [weak self](res) in
                self?.reloadData()
            }).disposed(by: disposeBag)
        case .limitWarning:
            self.rankListViewModel.getLimitWarning().subscribe(onSuccess: { [weak self](res) in
                self?.reloadData()
            }).disposed(by: disposeBag)
        }
    }
    
    func requestTradeDate() {
        self.rankListViewModel.getTradeDate().subscribe(onSuccess: { [weak self](res) in
            if let arr = self?.rankListViewModel.tradeDates, arr.count > 0 {
                let firstDate = arr.first ?? ""
                // 去掉日期”-“
                let str = firstDate.replacingOccurrences(of: "-", with: "")
                let dateModel = YXDateToolUtility.dateTimeAndWeek(withTime: str + "000000000")
                if self?.headerView.selectTimeButton.titleLabel?.text == "--" {
                    self?.headerView.selectTimeButton.setTitle(firstDate + " \(dateModel.week)", for: .normal)
                    self?.headerView.selectTimeButton.setButtonImagePostion(.right, interval: 2)
                }
                
                if self?.rankListViewModel.rankMarket.direction == .south {
                    if self?.rankListViewModel.rankType == .fundDirection {
                        let updateText = YXLanguageUtility.kLang(key: "bubear_update_time")
                        let text = YXLanguageUtility.kLang(key: "bubear_T+2_day")
                        self?.headerView.updateTimeLabel.text = "\(updateText)：\(firstDate)(\(text))"
                    }
                }else {
                    if self?.rankListViewModel.rankType == .fundDirection {
                        let updateText = YXLanguageUtility.kLang(key: "bubear_update_time")
                        let text = YXLanguageUtility.kLang(key: "bubear_T_day")
                        self?.headerView.updateTimeLabel.text = "\(updateText)：\(firstDate)(\(text))"
                    }
                }
                
                self?.datePickerView.dataSource = self?.rankListViewModel.tradeDates
            }
        }).disposed(by: disposeBag)
    }
}

extension YXA_HKRankListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.rankListViewModel.rankDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = rankListViewModel.rankDataSource[indexPath.row]
        if rankListViewModel.rankType == .limitWarning {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXA_HKLimitWarnCell.self), for: indexPath) as! YXA_HKLimitWarnCell
            cell.model = item
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXA_HKRankCell.self), for: indexPath) as! YXA_HKRankCell
            cell.model = item
            cell.type = rankListViewModel.rankType
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        //let item = rankListViewModel.rankDataSource[indexPath.row]
        rankListViewModel.goToStockDetail(indexPath.row)
    }
}

extension YXA_HKRankListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let parentVC = self.parent
        if let vc = parentVC as? YXA_HKRankPageViewController {
            vc.tabPageViewScrollCallBack?(scrollView)
        }

    }
    
}

extension YXA_HKRankListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = YXLanguageUtility.kLang(key: "common_string_of_emptyPicture")
        return NSAttributedString.init(string: str, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel3()])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        UIImage.init(named: "empty_noData")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        self.rankListViewModel.rankDataSource.count == 0
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        40
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        true
    }
}




