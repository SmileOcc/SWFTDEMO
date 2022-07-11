//
//  YXCryptosViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2021/4/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

class YXCryptosViewController: YXHKTableViewController, RefreshViweModelBased, HUDViewModelBased {
    
    override var pageName: String {
        "Cryptos"
    }
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "quot_cryptos_tip") 
        let imageV = UIImageView.init(image: UIImage(named: "datafrom_icon"))
        view.addSubview(imageV)
        view.addSubview(label)
        imageV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(imageV.snp.right).offset(3)
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXCryptosViewModel! = YXCryptosViewModel()
    let reuseIdentifier = "YXCryptosTableViewCell"
    
    var timer: Timer?
    
    var config = YXNewStockMarketConfig()
    let kCellHeight: CGFloat = 68
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var itemWidth = (YXConstant.screenWidth - 150 - 16 - 20) / 2.0
        if itemWidth < 100 {
            itemWidth = 100
        }
        config = YXNewStockMarketConfig(leftItemWidth: 150, itemWidth: itemWidth)
    
        bindHUD()
        handleBlock()
        bindTableView()
        
        headerView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 30)
        tableView.tableHeaderView = headerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // sectionHeaderView.scrollToSortType(sortType: self.viewModel.sorttype, animated: true)
        startPolling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPolling()
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
                cell = YXCryptosTableViewCell(style: .default, reuseIdentifier: self.reuseIdentifier,sortTypes: self.sortArrs, config: self.config)
                if let marketCell = cell as? YXCryptosTableViewCell {

                    self.viewModel.contentOffsetRelay.asObservable().filter { (point) -> Bool in
                        point != marketCell.scrollView.contentOffset
                    }.bind(to:marketCell.scrollView.rx.contentOffset).disposed(by: self.disposeBag)
                    marketCell.scrollView.rx.contentOffset.filter { [weak self] (point) -> Bool in
                        point != self?.viewModel.contentOffsetRelay.value
                    }.bind(to: self.viewModel.contentOffsetRelay).disposed(by: self.disposeBag)
                }
            }
            let tableCell = (cell as! YXCryptosTableViewCell)
            
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
        
        viewModel.contentOffsetRelay.asObservable().filter({ (point) -> Bool in
            point != view.scrollView.contentOffset
        }).bind(to: view.scrollView.rx.contentOffset).disposed(by: disposeBag)
        view.scrollView.rx.contentOffset.filter({ [weak self] (point) -> Bool in
            point != self?.viewModel.contentOffsetRelay.value
        }).bind(to: viewModel.contentOffsetRelay).disposed(by: disposeBag)
        
//        let mutAttrString = NSMutableAttributedString.qmui_attributedString(with: UIImage(named: "datafrom_icon"), baselineOffset: -1, leftMargin: 0, rightMargin: 3)
//        let attrStr = NSAttributedString.init(string: "Data from Binance.", attributes: [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.baselineOffset : NSNumber(2.5)])
//        mutAttrString?.append(attrStr)
//
//        view.nameLabel.attributedText = mutAttrString
    
        
        let sortSate = self.viewModel.sortdirection == 0 ? YXSortState.ascending : YXSortState.descending
        view.setStatus(sortState: sortSate, mobileBrief1Type: self.viewModel.sorttype)
        
        
        return view
    }()
    
    
    var sortArrs: [YXStockRankSortType]  {
        
        return [.now, .roc]
    }
    
    func handleBlock() {
        self.sectionHeaderView.onClickSort = {
            [weak self] (state, type) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.sorttype = type
            if type == .preRoc || type == .afterRoc {
                strongSelf.viewModel.sorttype = .roc
            }
            
            switch state {
            case .normal:
                strongSelf.viewModel.sortdirection = 1
            case .descending:
                strongSelf.viewModel.sortdirection = 1
            case .ascending:
                strongSelf.viewModel.sortdirection = 0
            @unknown default:
                strongSelf.viewModel.sortdirection = 1
            }
            
            if strongSelf.viewModel.dataSource.value.count > 0 {
               let array =  strongSelf.viewModel.sortResult(strongSelf.viewModel.dataSource.value)
                strongSelf.viewModel.dataSource.accept(array)
                
            }
            
//            if let refreshingBlock = strongSelf.refreshHeader.refreshingBlock {
//                refreshingBlock()
//            }
        }
        
    }
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    func startPolling() {
        
        stopPolling()
        let timeInterval = TimeInterval(YXGlobalConfigManager.configFrequency(.rankFreq))
        
        timer = Timer.scheduledTimer(timeInterval, action: { [weak self](timer) in
            guard let `self` = self else { return }
            
            if let refreshingBlock = self.refreshHeader.refreshingBlock {
                refreshingBlock()
            }
            
        }, userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopPolling()
    }
    
}

extension YXCryptosViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        kCellHeight
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
            //let item = viewModel.dataSource.value[indexPath.row]
            
            var inputs: [YXStockInputModel] = []
            for info in viewModel.dataSource.value {
                let input = YXStockInputModel()
                input.market = info.ID?.market ?? ""
                input.symbol = info.ID?.symbol ?? ""
                input.name = info.name ?? ""
                inputs.append(input)
            }
            
            if inputs.count > 0 {
                YXNavigationMap.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : inputs, "selectIndex" : indexPath.row])
                let info = inputs[indexPath.row]
                trackViewClickEvent(name: "Cryptos_item", other: ["Cryptos_code" : info.symbol, "Cryptos_name": info.name!])
            }
        }
    }
}




