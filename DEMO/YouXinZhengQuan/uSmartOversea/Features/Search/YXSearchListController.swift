//
//  YXSearchListController.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXSearchListController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerRightBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    var ishiddenLikeButton = false // 是否隐藏添加自选按钮
    
    var newType = false
    
    var viewModel: YXSearchListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        if newType {
            view.backgroundColor = QMUITheme().foregroundColor()
            tableView.emptyDataSetSource = self
            tableView.emptyDataSetDelegate = self
        }
        
        _ = viewModel?.list.asObservable().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (list) in
            
            if let headerRightNormalImage = self?.viewModel?.headerRightNormalImage, let count = self?.viewModel?.list.value?.count(), count > 0 {
                self?.headerRightBtn.setImage(UIImage(named:headerRightNormalImage), for: .normal)
                self?.headerRightBtn.isHidden = false
            } else {
                self?.headerRightBtn.isHidden = true
            }
        })
        
        initiateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    func initiateUI() {
        
        titleLabel.text = viewModel?.title
        titleLabel.textColor = QMUITheme().textColorLevel3()
        
        if let headerRightNormalImage = viewModel?.headerRightNormalImage, let count = viewModel?.list.value?.count(), count > 0 {
            headerRightBtn.setImage(UIImage(named:headerRightNormalImage), for: .normal)
        } else {
            headerRightBtn.isHidden = true
        }
        
        _ = headerRightBtn.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            self?.viewModel?.headerRightAction(sender: self?.headerRightBtn)
        })
        
        _ = viewModel?.list.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (list) in
            self?.tableView.reloadData()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.list.value?.count() ?? 0
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        headerView
//    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "YXSearchListCell") as! YXSearchListCell
        cell.rightBtn.isHidden = ishiddenLikeButton
        
        if let list = viewModel?.list.value, let item = list.item(at: indexPath.row) {
            
            if item.market == kYXMarketCryptos {
                ishiddenLikeButton = true
            }
            
            if let type2 = item.type2, type2 == OBJECT_SECUSecuType2.stOtcFund.rawValue {
                // 场外基金
                cell.rightBtn.isHidden = true
            } else {
                cell.rightBtn.isHidden = ishiddenLikeButton
            }
            cell.stockInfoView.nameLabel.attributedText = item.attributedName(with: list.param?.q)
            cell.stockInfoView.symbolLabel.attributedText = item.attributedSymobl(with: list.param?.q)
            cell.stockInfoView.market = item.market
                                                            
            if let image = viewModel?.cellRightNormalImage {
                cell.rightBtn.setImage(UIImage(named:image), for: .normal)
            }
            if let image = viewModel?.cellRightSelectedImage {
                cell.rightBtn.setImage(UIImage(named:image), for: .selected)
            }
            cell.rightBtn.isSelected = YXSecuGroupManager.shareInstance().containsSecu(item)
        }
        
        cell.rightBtnAction = { [weak self](sender) in
            
            if let searchCtrl = self?.next?.next as? YXNewSearchViewController {
                searchCtrl.searchBar.textField.resignFirstResponder()
            }
            
            self?.viewModel?.cellRightAction(sender: sender, at: indexPath.row)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.viewModel?.cellTapAction(at: indexPath.row)
        
        
    }

    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXSearchListController.self)) deinit")
    }
}

extension YXSearchListController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
       // UIImage(named: "icon_search_noData")
        YXDefaultEmptyEnums.noSearch.image()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        NSAttributedString(string: YXLanguageUtility.kLang(key: "search_result_empty"), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: QMUITheme().textColorLevel3()])
        NSAttributedString(string: YXDefaultEmptyEnums.noSearch.tip(), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: QMUITheme().textColorLevel3()])
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        40
       
    }
}
