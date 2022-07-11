//
//  YXUSElementViewController.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXUSElementViewController: YXTableViewController {

    var disposeBag = DisposeBag()
    
    var elementViewModel: YXUSElementViewModel {
        return self.viewModel as! YXUSElementViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        // Do any additional setup after loading the view.
    }
    
    func initUI() {
        
        self.title = YXLanguageUtility.kLang(key: "brife_element_list")
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
        return "YXElementTableViewCell"
    }
    
    override func cellIdentifiers() -> [AnyHashable : Any]! {
        return ["YXElementTableViewCell":YXElementTableViewCell.className()]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datas = self.elementViewModel.dataSource {
            return datas[0].count
        }
        return 0
    }
    
    override func rowHeight() -> CGFloat {
        return 50
    }
    override func configureCell(_ cell: UITableViewCell!, at indexPath: IndexPath!, with object: Any!) {
        if let model = self.elementViewModel.dataSource[0][indexPath.row] as? YXUSElementItemModel {
            if let cell = cell as? YXElementTableViewCell {
                cell.refreshUI(indexPath: indexPath, model: model, maxValue: self.elementViewModel.maxValue)
            }
        }
    }

}
