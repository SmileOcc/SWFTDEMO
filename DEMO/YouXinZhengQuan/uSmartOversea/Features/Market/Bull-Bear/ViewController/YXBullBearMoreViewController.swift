//
//  YXBullBearMoreViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXBullBearMoreViewController: YXViewController {
    var disposeBag = DisposeBag()
    var selectedItem: Observable<YXBullBearAsset>?
    var isTableViewScrollEnabled = true
    
    var moreViewModel: YXBullBearMoreViewModel {
        let vm = viewModel as! YXBullBearMoreViewModel
        return vm
    }
    
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
        
        tableView.register(YXBullBearFinancialReportCell.self, forCellReuseIdentifier: NSStringFromClass(YXBullBearFinancialReportCell.self))
        tableView.register(YXBullBearFundFlowInCell.self, forCellReuseIdentifier: NSStringFromClass(YXBullBearFundFlowInCell.self))
        tableView.register(YXBullBearLongShortSignalCell.self, forCellReuseIdentifier: NSStringFromClass(YXBullBearLongShortSignalCell.self))
        
        return tableView
    }()
    
    lazy var footer: YXRefreshAutoNormalFooter? = {
        let footer = YXRefreshAutoNormalFooter.init { [weak self] in
            self?.requestData()
        }
        return footer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        requestData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 当控制器的整个view嵌入一个cell时，为了不让tableview可以滑动，要做定时器处理，否则可能是emptydataset的原因，设置了isScrollEnabled=false时不起作用
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let `self` = self else { return }
            self.tableView.isScrollEnabled = self.isTableViewScrollEnabled
            self.tableView.isScrollEnabled = self.isTableViewScrollEnabled
        }
    }
    
    func setupUI() {
        
        self.title = moreViewModel.section.morePageNavTitle
        
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            guard let `self` = self else { return }
            self.moreViewModel.nextPage = 0
            self.moreViewModel.nextPageUnixTime = 0
            self.footer?.resetNoMoreData()
            self.requestData()
            self.tableView.mj_header.endRefreshing()
        }
        
        tableView.mj_header = refreshHeader
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    func requestData() {
        switch moreViewModel.section {
        case .longShortSignal:
            moreViewModel.getPbSignal().subscribe(onSuccess: { [weak self](model) in
                self?.reloadData()
            }).disposed(by: disposeBag)
        default:
            break
        }
    }
    
    func reloadData() {
        tableView.reloadData()
        
        if tableView.mj_footer == nil {
            switch moreViewModel.section {
            case .longShortSignal:
                if !moreViewModel.pbSignal.list.isEmpty {
                    tableView.mj_footer = footer
                }
            default:
                break
            }
            
        }else {
            if moreViewModel.hasMore {
                tableView.mj_footer.endRefreshing()
            }else {
                tableView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
    }
}


extension YXBullBearMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch moreViewModel.section {
        case .longShortSignal:
            return moreViewModel.pbSignal.list.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch moreViewModel.section {
        
        case .longShortSignal:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXBullBearLongShortSignalCell.self), for: indexPath) as! YXBullBearLongShortSignalCell
            cell.item = self.moreViewModel.pbSignal.list[indexPath.row]
            cell.tapStockNameAction = { [weak self](market, symbol) in
                self?.moreViewModel.gotoStockDetail(market: market, symbol: symbol)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let rect = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 30)
        return YXBullBearSectionHeaderSubTitleView.init(frame: rect, sectionType: moreViewModel.section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if moreViewModel.section == .longShortSignal {
            return 0
        }
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension YXBullBearMoreViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = YXDefaultEmptyEnums.noData.tip() //YXLanguageUtility.kLang(key:"common_no_data")//"暂无数据"
        return NSAttributedString.init(string: str, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel3()])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        YXDefaultEmptyEnums.noData.image()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        switch moreViewModel.section {
        case .longShortSignal:
            return moreViewModel.pbSignal.list.count == 0
        default:
            return true
        }
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 40
    }
}
