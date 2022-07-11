//
//  YXBullBearAssetListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXBullBearAssetListViewController: YXViewController {
    
    var disposeBag = DisposeBag()
    var selectedItem: Observable<YXBullBearAsset>?
    
    var assetListViewModel: YXBullBearAssetListViewModel {
        let vm = viewModel as! YXBullBearAssetListViewModel
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
        
        tableView.register(YXBaseStockListCell.self, forCellReuseIdentifier: NSStringFromClass(YXBaseStockListCell.self))
        
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50.0))
        let bgView = UIView()
        bgView.backgroundColor = QMUITheme().searchBarBackgroundColor()
        bgView.layer.cornerRadius = 4
        view.addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(6)
            make.height.equalTo(38)
        }
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage.init(named: "icon_search")
        bgView.addSubview(iconImageView)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "search_warrant")
        bgView.addSubview(label)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        
        bgView.rx.tapGesture().skip(1).subscribe(onNext: { [weak self](tap) in
            guard let `self` = self else { return }
            let didSelectedItem: (YXSearchItem)->() = { [weak self] (item) in
                guard let `self` = self else { return }
                let asset = YXBullBearAsset.init()
                asset.name = item.name
                asset.market = item.market
                asset.symbol = item.symbol
                self.assetListViewModel.selectedItemSubject.onNext(asset)
                self.navigationController?.popViewController(animated: false)
            }
            let dic = ["didSelectedItem": didSelectedItem, "warrantType": YXStockWarrantsType.bullBear, "isFromBullBearAssetSearch": true, "bullBearAssetViewModel": self.assetListViewModel] as [String : Any]
            YXNavigationMap.navigator.present(YXModulePaths.stockWarrantsSearch.url, context: dic)
        }).disposed(by: disposeBag)
        
        return view
    }()
    
    lazy var sortArrs: [YXStockRankSortType] = {
        [.now, .roc]
    }()
    
    lazy var priceSortButton: YXNewStockMarketedSortButton = {
        YXNewStockMarketedSortButton.button(sortType: .now, sortState: .normal)
    }()
    
    lazy var rocSortButton: YXNewStockMarketedSortButton = {
        YXNewStockMarketedSortButton.button(sortType: .roc, sortState: .descending)
    }()
    
    lazy var sectionHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        label.font = UIFont.systemFont(ofSize: 14)
        
        priceSortButton.addTarget(self, action: #selector(sortButtonAction(sender:)), for: .touchUpInside)
        rocSortButton.addTarget(self, action: #selector(sortButtonAction(sender:)), for: .touchUpInside)
        
        view.addSubview(label)
        view.addSubview(priceSortButton)
        view.addSubview(rocSortButton)
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
        }
        
        priceSortButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-110)
            make.centerY.equalToSuperview()
        }
        
        rocSortButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }

        return view
    }()
    
    @objc func sortButtonAction(sender: YXNewStockMarketedSortButton) {
        var sortDirection: YXAssetListSortDirection
        var sortType: YXAssetListSortType
        if sender.sortState == .descending {
            sender.sortState = .ascending
            sortDirection = .ascending
        } else {
            sender.sortState = .descending
            sortDirection = .descending
        }
        
        if sender.mobileBrief1Type == .roc {
            priceSortButton.sortState = .normal
            sortType = .roc
        }else {
            rocSortButton.sortState = .normal
            sortType = .price
        }
        
        requestData(sortType: sortType, sortDirection: sortDirection)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        requestData(sortType: .roc, sortDirection: .descending)
    }
    
    func setupUI() {
        self.title = assetListViewModel.derivativeType.assetListNavTitle
        
        let refreshHeader = YXRefreshHeader.init { [weak self] in
            guard let `self` = self else { return }
            self.requestData(sortType: .roc, sortDirection: .descending)
            self.tableView.mj_header.endRefreshing()
        }
        
        tableView.tableHeaderView = headerView
        tableView.mj_header = refreshHeader
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    func requestData(sortType: YXAssetListSortType, sortDirection: YXAssetListSortDirection) {
        self.assetListViewModel.getAssetlist(sortType: sortType, sortDirection: sortDirection).subscribe(onSuccess: { [weak self](asset) in
        self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }

}

extension YXBullBearAssetListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        self.assetListViewModel.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.assetListViewModel.dataSource?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXBaseStockListCell.self), for: indexPath) as! YXBaseStockListCell
        cell.nameLabel.text = item?.name ?? "--"
        cell.symbolLabel.text = "\(item?.symbol ?? "--").\(item?.market?.uppercased() ?? "--")"
        if let priceBase = item?.priceBase, let price = item?.latestPrice, let roc = item?.pctchng {
            var op = ""
            var color = QMUITheme().stockGrayColor()
            if roc > 0 {
                op = "+"
                color = QMUITheme().stockRedColor()
            }else if roc < 0 {
                color = QMUITheme().stockGreenColor()
            }
            cell.priceLabel.text = String(format: "%.\(priceBase)lf", Double(price)/(pow(10.0, Double(priceBase))))
            cell.rocLabel.text = op + String(format: "%.2f%%", Double(roc)/100.0)
            cell.priceLabel.textColor = color
            cell.rocLabel.textColor = color
        }else {
            cell.priceLabel.text = "--"
            cell.rocLabel.text = "--"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = self.assetListViewModel.dataSource?[indexPath.row] {
            self.assetListViewModel.selectedItemSubject.onNext(item)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension YXBullBearAssetListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = YXLanguageUtility.kLang(key:"common_no_data")//"暂无数据"
        return NSAttributedString.init(string: str, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: QMUITheme().textColorLevel3()])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        UIImage.init(named: "empty_net")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        self.assetListViewModel.dataSource?.count == 0
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        40
    }
}
