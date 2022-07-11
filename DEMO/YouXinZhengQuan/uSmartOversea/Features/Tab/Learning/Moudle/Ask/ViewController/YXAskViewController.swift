//
//  YXAskViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit
import YXKit
import SDWebImage
import RxCocoa
import RxSwift

//kol主页
class YXAskViewController: YXHKViewController {
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader.init()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    let viewModel = YXAskViewModel()
    
    let isKol = YXUserManager.shared().curLoginUser?.kol ?? false
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.tabMargin = 20
        tabLayout.lineHeight = 4
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 18, weight: .semibold)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        let tabView = YXTabView(frame: CGRect(x: 44, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.pageView = pageView
        tabView.delegate = self
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var allAskViewController: YXAskListViewController = {
        return YXAskListViewController(businessType: .all)
    }()
    
    lazy var questionAskViewController: YXAskListViewController = {
        let vc = YXAskListViewController(businessType: .question)
        vc.selectedAllCallBack = { [weak self] in
            self?.tabView.selectTab(at: 0)
        }
        return vc
    }()
    
    lazy var answerAskViewController: YXAskListViewController = {
        let vc = YXAskListViewController(businessType: .answer)
        vc.selectedAllCallBack = { [weak self] in
            self?.tabView.selectTab(at: 0)
        }
        return vc
    }()
    
    lazy var askBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.backgroundColor = .clear
        btn.setImage(UIImage(named: "ask_btn_icon"), for: .normal)
        btn.cornerRadius = QMUIButtonCornerRadiusAdjustsBounds
        return btn
    }()
    
    lazy var backBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "nav_back"), for: .normal)
        let _ = btn.rx.tap.subscribe(onNext:{ [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()

        view.addSubview(tabView)
        view.addSubview(pageView)
        view.addSubview(askBtn)
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { make in
            make.centerY.equalTo(tabView.snp.centerY)
            make.left.equalToSuperview()
            make.size.equalTo(46)
        }
        
        askBtn.snp.makeConstraints { make in
            make.size.equalTo(66)
            make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight()-20)
            make.right.equalToSuperview().offset(-16)
        }
        
        tabView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(YXConstant.statusBarHeight())
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview()
            make.height.equalTo(46)
        }
        
        pageView.snp.makeConstraints { make in
            make.top.equalTo(tabView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        if isKol {
            tabView.titles = [YXLanguageUtility.kLang(key: "nbb_tab_ask_all"),
                              YXLanguageUtility.kLang(key: "nbb_tab_ask_waiting"),
                              YXLanguageUtility.kLang(key: "nbb_tab_ask_questions"),
                              YXLanguageUtility.kLang(key: "nbb_tab_ask_answers")]
            pageView.viewControllers = [allAskViewController,
                                        YXAskListViewController(businessType: .waiting),
                                        questionAskViewController,
                                        answerAskViewController]
        } else {
            tabView.titles = [YXLanguageUtility.kLang(key: "nbb_tab_ask_all"),
                              YXLanguageUtility.kLang(key: "nbb_tab_ask_questions"),
                              YXLanguageUtility.kLang(key: "nbb_tab_ask_waiting"),
                              YXLanguageUtility.kLang(key: "nbb_tab_ask_answers")]
            pageView.viewControllers = [allAskViewController,
                                        questionAskViewController,
                                        YXAskListViewController(businessType: .waiting),
                                        answerAskViewController]
        }
        
        tabView.reloadData()
        pageView.reloadData()
        
        
        
    }
    
    override func didInitialize() {
        super.didInitialize()
    }

    func binding() {
        
        viewModel.getRedDotAndHotStock().subscribe { [weak self] resModel in
            guard let `self` = self else { return }
            if let resModel = resModel {
                if resModel.waitingFlag == true {
                    self.tabView.showBadge(at: self.isKol ? 1 : 2)
                } else {
                    self.tabView.hideBadge(at: self.isKol ? 1 : 2)
                }
                if let hotStock = resModel.hotStockInfoVOList, hotStock.count > 0 {
                    self.allAskViewController.showHotStock(hotStocks: hotStock )
                }
            }
        } onError: { err in
            
        }.disposed(by: disposeBag)
        
        
        askBtn.rx.tap.subscribe(onNext:{ _ in
                YXToolUtility.handleBusinessWithLogin {
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.ask()]
                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
        }).disposed(by: disposeBag)
    }
    

    
}

extension YXAskViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        if (isKol && index == 1) || (!isKol && index == 2)  {
            self.tabView.hideBadge(at: index)
        }
    }
}
