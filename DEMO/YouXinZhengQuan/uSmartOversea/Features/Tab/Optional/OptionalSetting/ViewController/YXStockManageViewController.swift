//
//  YXStockManageViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockManageViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXStockManageViewModel!
    
    lazy var headerView: UIView = {
         let view = UIView()
         view.backgroundColor = UIColor.qmui_color(withHexString: "#20619D")
         return view
     }()
     
     lazy var tabView: YXTabView = {
         let tabLayout = YXTabLayout.default()
         tabLayout.lineHidden = false
         tabLayout.lrMargin = 16
         tabLayout.tabMargin = 8
         tabLayout.tabPadding = 12
         tabLayout.lineHeight = 28
         tabLayout.leftAlign = true
         tabLayout.lineCornerRadius = 14
         tabLayout.lineColor = UIColor.white.withAlphaComponent(0.2)
         tabLayout.linePadding = 6
         tabLayout.lineWidth = 0
         tabLayout.titleFont = .systemFont(ofSize: 14)
         tabLayout.titleSelectedFont = .systemFont(ofSize: 14, weight: .medium)
         tabLayout.titleColor = UIColor.white.withAlphaComponent(0.6)
         tabLayout.titleSelectedColor = QMUITheme().foregroundColor()
         
         let tabView = YXTabView(frame: .zero, with: tabLayout)
         tabView.delegate = self
         tabView.pageView = pageView;
         return tabView
     }()
     
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        pageView.contentView.isScrollEnabled = false
        return pageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let id = viewModel.defaultSelectedId {
            var index: UInt?
            for (i, groupId) in viewModel.groupIds.enumerated() {
                if groupId == id {
                    index = UInt(i)
                    break
                }
            }
            if let index = index, index != 0 {
                tabView.selectTab(at: index)
            }
        }
        viewModel.defaultSelectedId = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setupUI() {
//        view.addSubview(headerView)
//        headerView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(view)
//            make.height.equalTo(40)
//            make.top.equalTo(self.strongNoticeView.snp.bottom)
//        }
//        headerView.addSubview(tabView)
//        tabView.snp.makeConstraints { (make) in
//            make.left.top.bottom.right.equalToSuperview()
//        }
        
        view.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
//            make.top.equalTo(tabView.snp.bottom)
//            make.bottom.equalToSuperview()
        }
    }
    
    func setupViewModel() {
        viewModel.titles.distinctUntilChanged().asObservable().bind(to: tabView.rx.titles).disposed(by: disposeBag)
        viewModel.viewControllers.distinctUntilChanged().asObservable().bind(to: pageView.rx.viewControllers).disposed(by: disposeBag)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension YXStockManageViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
    }
}
