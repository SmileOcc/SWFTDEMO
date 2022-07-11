//
//  YXMarketMakerRankViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXMarketMakerRankViewController: YXStockListViewController {
    
    override var pageName: String {
         "Issuer Rating"
     }
    
    var disposeBag = DisposeBag()
    
    var rankViewModel: YXMarketMakerRankViewModel {
        return self.viewModel as! YXMarketMakerRankViewModel
    }
    
    override var sortTypes: [Any] {
        get {
            let types: [YXMobileBrief1Type] = [.yxScore, .avgSpread, .openOnTime, .liquidity, .oneTickSpreadProducts, .oneTickSpreadDuration, .amount, .volume]
            return types.map { (item) -> NSNumber in
                NSNumber.init(value: item.rawValue)
            }
        }
        set {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoBarItem = UIBarButtonItem.init(image: UIImage(named: "question_black"), style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        infoBarItem.rx.tap.subscribe(onNext: {
            YXWebViewModel.pushToWebVC(YXH5Urls.marketMakerScoreUrl())
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = infoBarItem
        
        self.title = YXLanguageUtility.kLang(key: "issuer_rating")
        
        self.rotateButton.superview?.isHidden = true
        self.rotateButton.isHidden = true
        self.tableView.separatorStyle = .none
        self.stockListHeaderView.nameLabel.text = YXLanguageUtility.kLang(key: "warrant_issuer")
        
        self.stockListHeaderView.nameLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        self.stockListHeaderView.scrollView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(130)
            make.top.bottom.right.equalToSuperview()
        }
        
        self.stockListHeaderView.onClickSort = { [weak self](state, type) in
            self?.rankViewModel.didClickSortCommand.execute([state, type] as AnyObject)
        }
        
        self.stockListHeaderView.setDefaultSortState(.descending, mobileBrief1Type: .yxScore)
        
        if #available(iOS 11.0, *) {
            self.edgesForExtendedLayout = .all;
        }
    }
    
    override func tableViewTop() -> CGFloat {
        YXConstant.navBarHeight()
    }
    
    override func loadFirstPage() {
        super.loadFirstPage()
        self.stockListHeaderView.setDefaultSortState(.descending, mobileBrief1Type: .yxScore)
    }
    
    override func cellClasses() -> [AnyClass]! {
        return [YXMarketMakerRankCell.self]
    }
    
    override func configureCell(_ cell: UITableViewCell!, at indexPath: IndexPath!, with object: Any!) {
        super.configureCell(cell, at: indexPath, with: object)
        if let ranCcell = cell as? YXMarketMakerRankCell {
            ranCcell.lineView.isHidden = true
            let item = rankViewModel.dataSource[indexPath.section][indexPath.row] as? YXMarketMakerRankItem
            ranCcell.item = item
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = super.tableView(tableView, viewForHeaderInSection: section)
        // 父类里的约束是当有横屏按钮时右边距有段距离，本页面没有横屏按钮，所以重新设置约束
        self.stockListHeaderView.snp.remakeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        return view
    }
    
}
