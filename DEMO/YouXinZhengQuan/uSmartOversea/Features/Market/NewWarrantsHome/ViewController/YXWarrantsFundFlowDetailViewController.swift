//
//  YXWarrantsFundFlowDetailViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXWarrantsFundFlowDetailViewController: YXStockListViewController {
    
    var disposeBag = DisposeBag()
    
    var fundViewModel: YXWarrantsFundFlowDetailViewModel {
        return self.viewModel as! YXWarrantsFundFlowDetailViewModel
    }
    
    override var sortTypes: [Any] {
        get {
            let types: [YXMobileBrief1Type] = [.yxSelection, .longPosition, .warrantBuy, .warrantBull, .shortPosition, .warrantSell, .warrantBear]
            return types.map { (item) -> NSNumber in
                NSNumber.init(value: item.rawValue)
            }
        }
        set {
            
        }
    }
    
    lazy var kLineView: YXWarrantsKLineView = {
        let kLineView = YXWarrantsKLineView()
        return kLineView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 223))
        view.backgroundColor = QMUITheme().foregroundColor()
        let sepView = UIView()
        sepView.backgroundColor = QMUITheme().foregroundColor()
        view.addSubview(kLineView)
        view.addSubview(sepView)
        
        kLineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(sepView.snp.top)
        }
        
        sepView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = YXNewWarrantsSectionType.fundFlow.title
        
        self.tableView.register(YXNewWarrantsFundFlowRankCell.self, forCellReuseIdentifier: NSStringFromClass(YXNewWarrantsFundFlowRankCell.self))
        
        self.tableView.tableHeaderView = headerView
        self.tableView.separatorStyle = .none
        self.rotateButton.isHidden = true
        self.stockListHeaderView.onClickSort = { [weak self](state, type) in
            self?.fundViewModel.didClickSortCommand.execute([state, type] as AnyObject)
            self?.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
        
        self.stockListHeaderView.setDefaultSortState(.descending, mobileBrief1Type: .longPosition)
        
        if #available(iOS 11.0, *) {
            self.edgesForExtendedLayout = .all;
        }
    }
    
    override func tableViewTop() -> CGFloat {
        YXConstant.navBarHeight()
    }
    
    override func loadFirstPage() {
        super.loadFirstPage()
        fundViewModel.getKLine().subscribe { [weak self](kLinemodel) in
            self?.kLineView.kLineData = self?.fundViewModel.kLinemodel
        }.disposed(by: disposeBag)
    }
    
    override func cellClasses() -> [AnyClass]! {
        return [YXNewWarrantsFundFlowRankCell.self]
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXNewWarrantsFundFlowRankCell.self), for: indexPath)
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: 74))
        view.backgroundColor = QMUITheme().foregroundColor()
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "market_capital_net_outflows")
        
        view.addSubview(label)
        view.addSubview(self.stockListHeaderView)
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
        }
        
        self.stockListHeaderView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(label.snp.bottom)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74.0
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = self.tableView.visibleCells
        if let firstCell = cells.first, let indexPath = self.tableView.indexPath(for: firstCell) {
            fundViewModel.requestOffsetDataCommand.execute(NSNumber.init(value: indexPath.row))
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cells = self.tableView.visibleCells
        if let firstCell = cells.first, let indexPath = self.tableView.indexPath(for: firstCell) {
            fundViewModel.requestOffsetDataCommand.execute(NSNumber.init(value: indexPath.row))
        }
    }

}
