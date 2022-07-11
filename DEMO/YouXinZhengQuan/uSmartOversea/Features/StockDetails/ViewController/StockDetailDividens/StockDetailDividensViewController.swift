//
//  StockDetailDividensViewController.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/19.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Masonry
import YXKit
import JXPagingView

class StockDetailDividensViewController: YXTableViewController {


    lazy var headerView:StockDetailDividensTableViewHeader = {
        let view =  StockDetailDividensTableViewHeader.init(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 200))
        view.heightDidChange = { [weak self] in
            guard let `self` = self else { return }
            self.headerView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.headerView.height)
            self.tableView.reloadData()
        }
        return view
    }()
    
    private var dividensViewModel: StockDetailDividensViewModel {
        return self.viewModel as! StockDetailDividensViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()

    }

    override func tableViewTop() -> CGFloat {
        return 0
    }
    
    private func setupUI() {
        view.backgroundColor = QMUITheme().foregroundColor()

        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: YXConstant.safeAreaInsetsBottomHeight(), right: 0)
        tableView.register(StockDetailDividensCell.self, forCellReuseIdentifier: NSStringFromClass(StockDetailDividensCell.self))
        tableView.register(StockDetailDividensSectionHeader.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(StockDetailDividensSectionHeader.self))

//        tableView.tableHeaderView = headerView
        
    }

    override func bindViewModel() {
        super.bindViewModel()
                

        dividensViewModel.rx.observe(StockDetailDividensResponse.self, "dataModel")
            .subscribe(onNext: { [weak self] model in
                guard let `self` = self else { return }
                if let count = model?.list.count, count > 0 {
                    self.headerView.model = model
                    self.tableView.tableHeaderView = self.headerView
                } else {
                    self.tableView.tableHeaderView = nil
                }
            }).disposed(by: rx.disposeBag)
        
    }
    

    override func preferredNavigationBarHidden() -> Bool {
        true
    }

}

extension StockDetailDividensViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dividensViewModel.dataSource[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(StockDetailDividensCell.self)) as! StockDetailDividensCell
        cell.model = model
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 36
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 35 + 16
        }
        return 35
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
 
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(StockDetailDividensSectionHeader.self)) as? StockDetailDividensSectionHeader , let model = dividensViewModel.dataModel, model.list.count > 0 {
            headerView.yearLabel.text = model.list[section].date
            if let div_amount = model.list[section].div_amount?.doubleValue {
                let roundedNum = div_amount.roundTo(places: 4)
                headerView.valueLabel.text = String.init(format: "%.3f", roundedNum)
            } else {
                headerView.valueLabel.text = "--"
            }
            return headerView
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

}

extension StockDetailDividensViewController {

    override func customImageForEmptyDataSet() -> UIImage! {
        return UIImage(named: "empty_noData")
    }

    override func customTitleForEmptyDataSet() -> NSAttributedString! {
        return NSAttributedString(
            string: YXLanguageUtility.kLang(key: "no_dividens_data"),
            attributes: [.font: UIFont.normalFont16(), .foregroundColor: QMUITheme().textColorLevel3()]
        )
    }

    override func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 20
    }

}

extension StockDetailDividensViewController: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView { self.tableView }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}
