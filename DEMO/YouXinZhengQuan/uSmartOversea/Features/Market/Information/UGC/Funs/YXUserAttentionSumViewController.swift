//
//  YXUserAttentionSumViewController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUserAttentionSumViewController: YXViewController {
    
    var attentionSumViewModel: YXUserAttentionSumViewModel  {
        return self.viewModel as! YXUserAttentionSumViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.attentionSumViewModel.title
        initUI()
        tabView.reloadData()
        
        tabView.selectTab(at: UInt(attentionSumViewModel.selectedIndex))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.tabView.selectedIndex == 0 {
            self.attentionVC.updateData()
        }else{
            self.followVC.updateData()
        }
    }
    
    func initUI() {
        let line = UIView.line()
        self.view.addSubview(self.tabView)
        self.view.addSubview(line)
        self.view.addSubview(self.pageView)
        self.tabView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.strongNoticeView.snp.bottom)
            make.height.equalTo(40)
        }
        line.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.tabView.snp.bottom)
            make.height.equalTo(1)
        }
        self.pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(line.snp.bottom)
        }
        
        if #available(iOS 11.0, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    lazy var attentionVC: YXUserAttentionViewController = {
        let viewmodel = YXUserAttentionViewModel.init(services: self.attentionSumViewModel.services, params: ["target_uid" : self.attentionSumViewModel.target_uid, "isAttention" : true])
        viewmodel.isAttention = true
        let vc = YXUserAttentionViewController.init(viewModel: viewmodel)
        
        return vc
    }()
    
    lazy var followVC: YXUserAttentionViewController = {
        let viewmodel = YXUserAttentionViewModel.init(services: self.attentionSumViewModel.services, params: ["target_uid" : self.attentionSumViewModel.target_uid, "isAttention" : false])
        let vc = YXUserAttentionViewController.init(viewModel: viewmodel)
        return vc
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
    
        pageView.viewControllers = [self.attentionVC, self.followVC]
       
        pageView.contentView.isScrollEnabled = true
        return pageView
    }()
    
    lazy var tabView: YXTabView = {
        let layout = YXTabLayout.default()
        layout.lineHeight = 2
        layout.linePadding = 1
        layout.lineCornerRadius = 1
        layout.lineColor = QMUITheme().mainThemeColor()
        layout.titleFont = UIFont.systemFont(ofSize: 14)
        layout.titleSelectedFont = UIFont.systemFont(ofSize: 14)
        
        layout.titleSelectedColor = QMUITheme().mainThemeColor()
        layout.titleColor = QMUITheme().textColorLevel2()
        let tabView = YXTabView.init(frame: CGRect.zero, with: layout)

        tabView.titles = [YXLanguageUtility.kLang(key: "follow_number"), YXLanguageUtility.kLang(key: "fans_number")]
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.pageView = self.pageView
        tabView.delegate = self
        
        return tabView
    }()
    
}

extension YXUserAttentionSumViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
    }
        
}
