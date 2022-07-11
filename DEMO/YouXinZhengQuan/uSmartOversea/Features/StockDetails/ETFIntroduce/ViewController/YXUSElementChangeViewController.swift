//
//  YXElementChangeViewController.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXUSElementChangeViewController: YXTableViewController {
    
    var disposeBag = DisposeBag()
    
    var elementChangeViewModel: YXUSElementChangeViewModel {
        return self.viewModel as! YXUSElementChangeViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        
        self.title = YXLanguageUtility.kLang(key: "brief_element_change")
        self.view.backgroundColor = QMUITheme().foregroundColor()
        
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.showsHorizontalScrollIndicator = false
        tableView.register(YXElementChangeHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(YXElementChangeHeaderView.self))
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        self.loadFirstPage()
    }
    
    override func cellIdentifier(at aIndexPath: IndexPath!) -> String! {
        return "YXElementChangeTableViewCell"
    }
    
    override func cellIdentifiers() -> [AnyHashable : Any]! {
        return ["YXElementChangeTableViewCell":YXElementChangeTableViewCell.className()]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datas = self.elementChangeViewModel.dataSource {
            return datas[0].count
        }
        return 0
    }
    
    override func rowHeight() -> CGFloat {
        return 44
    }
    override func configureCell(_ cell: UITableViewCell!, at indexPath: IndexPath!, with object: Any!) {
        if let model = self.elementChangeViewModel.dataSource[0][indexPath.row] as? YXUSElementChangeItemModel {
            if let cell = cell as? YXElementChangeTableViewCell {
                cell.model = model
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(YXElementChangeHeaderView.self))
    }
       
}

