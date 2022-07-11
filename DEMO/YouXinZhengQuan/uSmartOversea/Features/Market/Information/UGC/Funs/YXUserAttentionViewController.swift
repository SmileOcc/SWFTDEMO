//
//  YXUserAttentionViewController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXUserAttentionViewController: YXTableViewController {
    let disposbag = DisposeBag()
    lazy var nodataView:YXCommentDetailNoDataView = {
        let view = YXCommentDetailNoDataView()
        view.isWhiteStyle = true
        view.emptyImageView.image = UIImage.init(named: "no_data_follows")
        view.titleLabel.text = self.attentionViewModel.isAttention ? YXLanguageUtility.kLang(key: "no_content") : YXLanguageUtility.kLang(key: "no_content")
        view.backgroundColor = QMUITheme().foregroundColor()
        view.isHidden = true
        return view
    }()
    
    var attentionViewModel:YXUserAttentionViewModel {
        return self.viewModel as! YXUserAttentionViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
  

    fileprivate func initUI() {
       
        self.view.backgroundColor = QMUITheme().backgroundColor()
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.showsHorizontalScrollIndicator = false
        tableView.register(YXUGCRecommandUserTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(YXUGCRecommandUserTableViewCell.self))
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.view.addSubview(self.nodataView)
        self.nodataView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(YXConstant.navBarHeight())
            }
            make.left.right.bottom.equalToSuperview()
        }
        self.nodataView.topOffset = 60

    }
    func updateData() {
        self.attentionViewModel.notShowLoading = true
        self.loadFirstPage()
    }
    override func bindViewModel() {
        
        super.bindViewModel()
        self.attentionViewModel.publishSub.subscribe(onNext: {
            [weak self] showNodata in
            guard let `self` = self else { return }
            self.nodataView.isHidden = showNodata

        }).disposed(by: rx.disposeBag)
      
        self.loadFirstPage()
    }

    override func tableViewTop() -> CGFloat {
        0
    }
    
    override func cellIdentifier(at aIndexPath: IndexPath!) -> String! {
        return "YXUGCRecommandUserTableViewCell"
    }
    
    override func cellIdentifiers() -> [AnyHashable : Any]! {
        return ["YXUGCRecommandUserTableViewCell":YXUGCRecommandUserTableViewCell.className()]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datas = self.attentionViewModel.dataSource {
            return datas[0].count
        }
        return 0
    }
    
    override func rowHeight() -> CGFloat {
        return 82
    }
    override func configureCell(_ cell: UITableViewCell!, at indexPath: IndexPath!, with object: Any!) {
        if let model = self.attentionViewModel.dataSource[0][indexPath.row] as? YXUserAttentionItemModel {
            if let cell = cell as? YXUGCRecommandUserTableViewCell {
                cell.attentionFunsItemModel = model
            }
        }
    }
    
    
}
