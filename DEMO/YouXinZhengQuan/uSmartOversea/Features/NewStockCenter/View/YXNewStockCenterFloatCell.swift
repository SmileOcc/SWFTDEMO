//
//  YXNewStockCenterFloatCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import URLNavigator

class YXNewStockCenterFloatCell: UITableViewCell {

    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        
        contentView.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        pageView.viewControllers = [hkVC, usVC]
    }
    
    func setNavigator(_ navigator: NavigatorServicesType) {
        hkVC.viewModel.navigator = navigator
        usVC.viewModel.navigator = navigator
    }

    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.frame.height))
        pageView.contentView.isScrollEnabled = false
        return pageView
    }()
    
    lazy var hkVC: YXNewStockCenterMarketVC = {
        let viewModel = YXNewStockCenterViewModel()
        viewModel.exchangeType = .hk
        let vc = YXNewStockCenterMarketVC.init(viewModel: viewModel)
        
        return vc
    }()
    
    lazy var usVC: YXNewStockCenterMarketVC = {
        let viewModel = YXNewStockCenterViewModel()
        viewModel.exchangeType = .us
        let vc = YXNewStockCenterMarketVC.init(viewModel: viewModel)
        return vc
    }()
}

class YXNewStockGestureTableView: QMUITableView, UIGestureRecognizerDelegate {
 
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
