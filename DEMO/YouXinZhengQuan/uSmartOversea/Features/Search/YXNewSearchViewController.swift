//
//  YXNewSearchViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXNewSearchViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXNewSearchViewModel!
    
    var didTouchedCancel :(()->())?
    var didSelectedItem :((YXSearchItem)->())?
    
    var resultView: UIView?
    
    var historyIsEmpty: Bool = true
    var ishiddenLikeButton: Bool = false

    lazy var resultController: YXSearchListController = {
        let viewController = UIStoryboard.init(name: "YXSearchViewController", bundle: nil).instantiateViewController(withIdentifier: "YXSearchListController") as! YXSearchListController
        viewController.newType = true
        viewController.viewModel = viewModel.resultViewModel
        viewController.viewModel?.types = viewModel.types
        viewController.ishiddenLikeButton = ishiddenLikeButton

        return viewController
    }()
    
    lazy var searchBar: YXNewSearchBar = {
        let searchBar = YXNewSearchBar()
        searchBar.textField.tintColor = QMUITheme().mainThemeColor()
        return searchBar
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = QMUITheme().foregroundColor()
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        stackView.qmui_frameDidChangeBlock = { [weak self](view, frame) in
            self?.scrollView.contentSize = CGSize(width: frame.width, height: frame.height)
        }
        
        return stackView
    }()
    
    lazy var historyEmptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_search_empty")
        imageView.contentMode = .center
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: YXLanguageUtility.kLang(key: "search_history_empty"), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: QMUITheme().textColorLevel3()])
        titleLabel.textAlignment = .center
        view .addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        return view
    }()
    
    var historyIsExpand = true
    var hotSearchIsExpand = true
    
    lazy var historyView: UIView = {
        let view = UIView()
        view.clipsToBounds = true

        let titleLabel = UILabel(frame:CGRect(x: 16, y: 20, width: 200, height: 22))
        titleLabel.text = YXLanguageUtility.kLang(key: "search_history_title")
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)
        
        view.addSubview(deleteHistoryButton)
        deleteHistoryButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        historyArrowView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            if ges.state == .ended {
                strongSelf.historyIsExpand = !strongSelf.historyIsExpand
                strongSelf.layoutHistory()
                UIView.animate(withDuration: 0.1) {
                    strongSelf.view.layoutIfNeeded()
                }
//                strongSelf.scrollView.contentSize = CGSize(width: strongSelf.stackView.frame.width, height: strongSelf.stackView.frame.height)
            }
        }).disposed(by: disposeBag)

        view.addSubview(historyFloatView)
        
//        let deleteButton = QMUIButton()
//        deleteButton.titleLabel?.font = .systemFont(ofSize: 12)
//        deleteButton.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
//        deleteButton.setImage(UIImage(named: "search_delete"), for: .normal)
//        deleteButton.setTitle(YXLanguageUtility.kLang(key: "search_clear_history"), for: .normal)
//        deleteButton.imagePosition = .left
//        deleteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
//        deleteButton.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self](_) in
//            self?.viewModel?.removeHistory()
//        }).disposed(by: disposeBag)
//
//        view.addSubview(deleteButton)
//        deleteButton.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(historyFloatView.snp.bottom).offset(16)
//        }
        
        return view
    }()
    
    lazy var historyArrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search_arrow")
        imageView.contentMode = .center
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        return imageView
    }()
    
    lazy var historyFloatView: QMUIFloatLayoutView = {
        let floatView = QMUIFloatLayoutView()
        floatView.padding = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        floatView.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 12)
        floatView.minimumItemSize = CGSize(width: 52, height: 28)
        floatView.clipsToBounds = true
        return floatView
    }()
    
    lazy var hotSearchView: UIView = {
        let view = UIView()
        view.clipsToBounds = true

        let titleLabel = UILabel(frame:CGRect(x: 16, y: 20, width: 200, height: 22))
        titleLabel.text = YXLanguageUtility.kLang(key: "hot_search_stocks")
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)
        
//        view.addSubview(hotSearchArrowView)
//        hotSearchArrowView.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-10)
//            make.centerY.equalTo(titleLabel)
//            make.size.equalTo(CGSize(width: 30, height: 30))
//        }
        
        hotSearchArrowView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            if ges.state == .ended {
                strongSelf.hotSearchIsExpand = !strongSelf.hotSearchIsExpand
                strongSelf.layoutHotSearch()
                UIView.animate(withDuration: 0.1) {
                    strongSelf.view.layoutIfNeeded()
                }
//                strongSelf.scrollView.contentSize = CGSize(width: strongSelf.stackView.frame.width, height: strongSelf.stackView.frame.height)
            }
        }).disposed(by: disposeBag)

        view.addSubview(hotSearchFloatView)
        
        return view
    }()
    
    lazy var hotSearchArrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search_arrow")
        imageView.contentMode = .center
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        return imageView
    }()
    
    lazy var deleteHistoryButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "delete_oversea"), for: .normal)
        button.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self](_) in
            self?.viewModel?.removeHistory()
        }).disposed(by: disposeBag)
        return button
    }()
    
    lazy var hotSearchFloatView: QMUIFloatLayoutView = {
        let floatView = QMUIFloatLayoutView()
        floatView.padding = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        floatView.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 12)
        floatView.minimumItemSize = CGSize(width: 52, height: 28)
        view.clipsToBounds = true
        return floatView
    }()
    
    lazy var multiassetView: YXMultiassetView = {
        let view = YXMultiassetView()
        view.clipsToBounds = true
        view.selectBlock = {[weak self] (indexPath) in
            guard let `self` = self else { return }
            
            if
                let asset = self.viewModel.multiasset.value,
                indexPath.row < asset.blocks?.count ?? 0    ,
                let blocks = asset.blocks?[indexPath.row]   {
                
                let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.STOCKST_MULTIASSET(asset.clomunID, blocks.blockID)]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }
        return view
    }()
    
    lazy var fundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var fundTitleLabel: UILabel = {
        let titleLabel = UILabel(frame:CGRect(x: 18, y: 20, width: 200, height: 22))
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        return titleLabel
    }()
    
    lazy var fundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        
        view.addSubview(fundTitleLabel)
        
        let moreLabel = UILabel()
        moreLabel.textColor = QMUITheme().textColorLevel3()
        moreLabel.text = YXLanguageUtility.kLang(key: "share_info_more")
        moreLabel.font = .systemFont(ofSize: 12)
        moreLabel.textAlignment = .right
        
        moreLabel.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            if ges.state == .ended {
                let userInfo: [String : Any] = [
                    "index" : YXTabIndex.market,
                    "moduleTag" : 1,
                    "subModuleTag": 0
                ]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiUpdateResetRootView), object: nil, userInfo: userInfo)
            }
        }).disposed(by: disposeBag)
        
        view.addSubview(moreLabel)
        moreLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(fundTitleLabel)
            make.width.equalTo(40)
        }
        
        view.addSubview(fundStackView)
        fundStackView.snp.makeConstraints { (make) in
            make.top.equalTo(fundTitleLabel.snp.bottom).offset(12)
            make.left.right.equalTo(view)
        }
        
        return view
    }()
    
    lazy var recommendStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
//MARK: 构建UI
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSearchBar()
        setupContentView()
        setupHistoryEmpty()
        setupResult()
        
        if (self.viewModel.showHistory)  {
            setupHistory()
        }
        
        if (self.viewModel.showPopular) {
            setupHotSearch()
            setupFund()
            setupRecommend()
            setupMultiasset()
        }

        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setupHistoryEmpty() {
        view.addSubview(historyEmptyView)
        historyEmptyView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(180)
        }
    }
    
    func showHistoryEmpty() {
        if viewModel.isShowEmpty() && historyIsEmpty {
            historyEmptyView.isHidden = false
        } else {
            historyEmptyView.isHidden = true
        }
    }
    
    func setupResult() {
        resultView = resultController.view
        view.addSubview(resultView!)
        
        resultView?.snp.makeConstraints { (make) in
            make.top.equalTo(YXConstant.navBarHeight())
            make.bottom.left.right.equalTo(view)
        }
        
        resultView?.isHidden = true
        addChild(resultController)
        
        _ = viewModel.resultViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](item) in
            
            self?.jumpPage(with: item)
        })
        
        //监听搜索结果
        _ = viewModel.resultViewModel.list.asObservable().filter({ (list) -> Bool in
            list != nil
        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            self?.showResultView()
        })
    }
    
    func setupSearchBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        
        navigationItem.titleView = searchBar
        searchBar.frame = CGRect(x: 4, y: 0, width: view.bounds.width-32, height: 38)
        
        searchBar.textField.placeholder = YXLanguageUtility.kLang(key: SearchLanguageKey.placeholder.rawValue)
        _ = searchBar.cancelBtn.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self](_) in
            self?.didTouchedCancel?()
        })
        
//        searchBar.cameraBtn.rx.tap.subscribe(onNext: { [weak self] () in
//            self?.searchBar.textField.resignFirstResponder()
//            self?.viewModel.navigator.push(YXModulePaths.importPic.url)
//        }).disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.1, execute: {
            self.searchBar.textField.becomeFirstResponder()
        })
        
        _ = searchBar.textField.rx.text.throttle(RxTimeInterval.seconds(0), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](text) in
            guard let strongSelf = self else { return }
            if !(text?.isEmpty ?? true) {//text?.count ?? 0 > 0
//                strongSelf.searchBar.cameraBtn.isHidden = true
                strongSelf.searchBar.textField.snp.updateConstraints { (make) in
                    make.right.equalToSuperview().offset(0)
                }
            }else {
//                strongSelf.searchBar.cameraBtn.isHidden = false
                strongSelf.searchBar.textField.snp.updateConstraints { (make) in
                    make.right.equalToSuperview().offset(-45)
                }
            }
        })
        
        _ = searchBar.textField.rx.controlEvent(.editingDidEndOnExit).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (e) in
            if let count = self?.viewModel.resultViewModel.list.value?.count(), count == 1 {
                self?.viewModel.resultViewModel.cellTapAction(at: 0)
            }
        })
        
        _ = searchBar.textField.rx.text.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).filter({ (text) -> Bool in
            text != nil
        }).subscribe(onNext: { [weak self](text) in
            if let text = text,text != "" {
                _ = self?.viewModel.search(text: text)
                
                var dict = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:""]
                
                self?.trackViewEvent(act: "click", other: dict)
                
            } else {
                self?.hideResultView()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(YXConstant.navBarHeight())
            make.bottom.left.right.equalTo(view)
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.left.right.width.equalTo(scrollView)
        }
    }
    
    func setupHistory() {
        stackView.addArrangedSubview(historyView)
        
        YXSearchHistoryManager.shared.list.asObservable().subscribe(onNext: { [weak self] (searchList) in
            guard let strongSelf = self else { return }
            
            var newList = searchList
            let types = strongSelf.viewModel.types
            if types != [] {
                newList = YXSearchList()
                
                if let count = searchList?.count() {
                    let markets = types.map{ $0.rawValue }
                    for i in (0..<count).reversed() {
                        if
                            let item = searchList?.item(at: i),
                            markets.contains(item.market),
                            let type1 = item.type1,
                            let secuType1 = OBJECT_SECUSecuType1(rawValue: type1),
                            (secuType1 == .stStock || secuType1 == .stFund || secuType1 == .stFuture || secuType1 == .stBond || secuType1 == .stOption)
                        {
                            newList?.add(item: item)
                        }
                    }
                }
            }
            
            strongSelf.historyFloatView.subviews.forEach { (subView) in
                subView.removeFromSuperview()
            }
            
            if let list = newList?.list, list.count > 0 {
                strongSelf.historyIsEmpty = false
                for i in 0..<list.count {
                    let item = list[i]
                    let button = QMUIButton.creatGhostButton(with: QMUITheme().separatorLineColor())
                    button.cornerRadius = 4
                    button.titleLabel?.lineBreakMode = .byTruncatingTail
                    button.setTitle(item.name, for: .normal)
                    button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
                    strongSelf.historyFloatView.addSubview(button)
                    
                    button.rx.tap.takeUntil(strongSelf.rx.deallocated).subscribe(onNext: { [weak self] () in
                        self?.jumpPage(with: item)
                    }).disposed(by: strongSelf.rx.disposeBag)
                }
                
            } else {
                strongSelf.historyIsEmpty = true
                strongSelf.historyIsExpand = false
            }
            strongSelf.layoutHistory()
            strongSelf.showHistoryEmpty()
        }).disposed(by: disposeBag)
    }
    
    func setupHotSearch() {
        stackView.addArrangedSubview(hotSearchView)
        
        viewModel.hotSearchList.subscribe(onNext: { [weak self] (list) in
            guard let strongSelf = self else { return }
            
            for i in 0..<list.count {
                let item = list[i]
                let button = QMUIButton()
                button.cornerRadius = 4
                button.clipsToBounds = true
                button.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1)
                button.titleLabel?.lineBreakMode = .byTruncatingTail
                button.setTitle(item.name, for: .normal)
                button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
                button.rx.tap.takeUntil(strongSelf.rx.deallocated).subscribe(onNext: { [weak self] () in
                    self?.didSelectedItem?(item)
                    
                }).disposed(by: strongSelf.rx.disposeBag)
                strongSelf.hotSearchFloatView.addSubview(button)
            }
            strongSelf.showHistoryEmpty()
            strongSelf.layoutHotSearch()
//            strongSelf.scrollView.contentSize = CGSize(width: strongSelf.stackView.frame.width, height: strongSelf.stackView.frame.height)
        }).disposed(by: disposeBag)
        viewModel.services.searchService.request(.hotSearch, response: self.viewModel.hotSearchResponse)
            .disposed(by: disposeBag)
    }
    
    func setupRecommend() {
        stackView.addArrangedSubview(recommendStackView)
//        recommendStackView.snp.updateConstraints { (make) in
//            make.height.equalTo(0)
//        }

        viewModel.recommendList.subscribe(onNext: { [weak self] (list) in
            guard let strongSelf = self else { return }
            
            strongSelf.recommendStackView.subviews.forEach { (subView) in
                subView.removeFromSuperview()
            }
            
            if list.count > 0 {
                var height = 0
                list.forEach { (recommend) in
                    if let items = recommend.items, items.count > 0 {
                        let recommendSubView = YXSearchRecommendView()
                        recommendSubView.recommend = recommend
                        recommendSubView.navigator = strongSelf.viewModel.navigator
                        strongSelf.recommendStackView.addArrangedSubview(recommendSubView)
                        
                        if let title = recommend.subTitle, title.count > 0 {
                            recommendSubView.snp.makeConstraints { (make) in
                                make.height.equalTo(50 + 86 * items.count)
                            }
                            height += 50 + 86 * items.count
                        } else {
                            recommendSubView.snp.makeConstraints { (make) in
                                make.height.equalTo(40 + 86 * items.count)
                            }
                            height += 40 + 86 * items.count
                        }

                    }
                }
                strongSelf.recommendStackView.snp.updateConstraints { (make) in
                    make.height.equalTo(height + 10)
                }
            }
            strongSelf.showHistoryEmpty()
//            strongSelf.scrollView.contentSize = CGSize(width: strongSelf.stackView.frame.width, height: strongSelf.stackView.frame.height)
        }).disposed(by: disposeBag)
        
//        viewModel.services.searchService.request(.recommend, response: viewModel.recommendResponse)
//            .disposed(by: disposeBag)
    }
    
    func setupMultiasset() {
        stackView.addArrangedSubview(multiassetView)
        multiassetView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        
//        viewModel.multiasset.subscribe(onNext: { [weak self] (multiasset) in
//            guard let strongSelf = self else { return }
//            if let multiasset = multiasset {
//                strongSelf.multiassetView.reloadData(multiasset)
//                strongSelf.multiassetView.snp.updateConstraints { (make) in
//                    make.height.equalTo(230)
//                }
//            } else {
//                strongSelf.multiassetView.reloadData(nil)
//                strongSelf.multiassetView.snp.updateConstraints { (make) in
//                    make.height.equalTo(0)
//                }
//            }
//            strongSelf.showHistoryEmpty()
//        }).disposed(by: disposeBag)
//        
//        viewModel.services.stockSTService.request(.queryMultiassethomepage, response: viewModel.multiassetResponse)
//        .disposed(by: disposeBag)
    }
    
    func setupFund() {
        stackView.addArrangedSubview(fundView)
        fundView.snp.updateConstraints { (make) in
            make.height.equalTo(0)
        }
        
        viewModel.fundHomeOne.subscribe(onNext: { [weak self] (fundHomeOne) in
            guard let strongSelf = self else { return }
            
            strongSelf.fundStackView.subviews.forEach { (subView) in
                subView.removeFromSuperview()
            }
            
            if let fundHomeOne = fundHomeOne, let array = fundHomeOne.data, array.count > 0 {
                strongSelf.fundTitleLabel.text = fundHomeOne.masterTitle
                
                for i in 0..<array.count {
                    let fund = array[i]
                    let selectFundView = YXSelectFundView()
                    selectFundView.fund = fund
                    if i == 0 {
                        selectFundView.isFirst = true
                    } else {
                        selectFundView.isFirst = false
                    }
                    strongSelf.fundStackView.addArrangedSubview(selectFundView)
                    
                    selectFundView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
                        guard let strongSelf = self else { return }
                        if ges.state == .ended, let fundId = fund.fundID  {
                            let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_DETAIL_PAGE_URL(with: fundId)]
                            strongSelf.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                        }
                    }).disposed(by: strongSelf.disposeBag)
                    selectFundView.snp.makeConstraints { (make) in
                        make.height.equalTo(50)
                        make.width.equalTo(strongSelf.fundStackView)
                    }
                }
                
                strongSelf.fundView.snp.updateConstraints { (make) in
                    make.height.equalTo(array.count*50+42+12)
                }
            } else {
                strongSelf.fundView.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
            }
            strongSelf.showHistoryEmpty()
//            strongSelf.scrollView.contentSize = CGSize(width: strongSelf.stackView.frame.width, height: strongSelf.stackView.frame.height)
        }).disposed(by: disposeBag)
        
//        viewModel.services.quotesDataService.request(.getFund(1), response: viewModel.fundResponse)
//        .disposed(by: disposeBag)
    }
    
    
    func jumpPage(with item: YXSearchItem) {
        
        trackViewClickEvent(name: "stocklist_item", other: ["stock_code" : (item.market + item.symbol), "stock_name" : item.name ?? ""])
        if let type2 = item.type2, type2 == OBJECT_SECUSecuType2.stOtcFund.rawValue {
            // 场外基金
            let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_DETAIL_PAGE_URL(item.symbol)]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        } else {
            self.didSelectedItem?(item)
        }
        
    }
    
//MARK: 更新UI
    private func showResultView() {
        resultView?.isHidden = false
    }
    
    private func hideResultView() {
        resultView?.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutHistory()
        layoutHotSearch()
      
//        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    func layoutHistory() {
        if historyFloatView.subviews.count > 0 {
            historyFloatView.frame = CGRect(x: 0, y: 52, width: view.bounds.width, height: QMUIViewSelfSizingHeight)
            var historyFloatHeight = historyFloatView.frame.height
            var maxHistoryFloatHeight: CGFloat = 40
            var historyHeight: CGFloat = 42 + maxHistoryFloatHeight
            var bottomHeight: CGFloat = 10
            historyArrowView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
            if historyIsExpand {
                historyArrowView.transform = .identity
                maxHistoryFloatHeight = 126
                bottomHeight = 20
            }
            if historyFloatHeight > maxHistoryFloatHeight {
                historyFloatHeight = maxHistoryFloatHeight
            }
            historyHeight = 42 + historyFloatHeight + bottomHeight
            historyFloatView.frame = CGRect(x: 0, y: 42, width: view.bounds.width, height: historyFloatHeight)
            
            historyView.snp.updateConstraints { (make) in
                make.height.equalTo(historyHeight)
            }
        } else {
            historyFloatView.frame = .zero
            historyView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }
    }
    
    func layoutHotSearch() {
        if hotSearchFloatView.subviews.count > 0 {
            hotSearchFloatView.frame = CGRect(x: 0, y: 52, width: view.bounds.width, height: QMUIViewSelfSizingHeight)
            var hotSearchFloatHeight = hotSearchFloatView.frame.height
            var maxHotSearchFloatHeight: CGFloat = 40
            hotSearchArrowView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
            if hotSearchIsExpand {
                hotSearchArrowView.transform = .identity
                maxHotSearchFloatHeight = 116
            }
            if hotSearchFloatHeight > maxHotSearchFloatHeight {
                hotSearchFloatHeight = maxHotSearchFloatHeight
            }
            let hotSearchHeight: CGFloat = 42 + hotSearchFloatHeight + 10
            hotSearchFloatView.frame = CGRect(x: 0, y: 42, width: view.bounds.width, height: hotSearchFloatHeight)
            
            hotSearchView.snp.updateConstraints { (make) in
                make.height.equalTo(hotSearchHeight)
            }
        } else {
            hotSearchFloatView.frame = .zero
            hotSearchView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        }
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

class YXNewSearchBar: UIView {
    lazy var cancelBtn: QMUIButton = {
        let button = QMUIButton(type: .custom)
        button.setTitle(YXLanguageUtility.kLang(key: "search_cancel"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        return button
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
//    lazy var cameraBtn: QMUIButton = {
//        let button = QMUIButton(type: .custom)
//        button.setImage(UIImage(named: "import_stock_new"), for: .normal)
//        return button
//    }()
    
    override var intrinsicContentSize: CGSize {
        self.bounds.size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cancelBtn)
        cancelBtn.sizeToFit()
        cancelBtn.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn.frame.width)
        }
        
        let leftView = UIView()
        leftView.layer.cornerRadius = 4
        leftView.layer.masksToBounds = true
        leftView.backgroundColor = QMUITheme().blockColor()//QMUITheme().searchBarBackgroundColor()
        addSubview(leftView)
        
        leftView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(cancelBtn.snp.left).offset(-12)
        }
        
        let iconView = UIImageView()
        iconView.image = UIImage(named: "icon_search")
        iconView.contentMode = .center
        leftView.addSubview(iconView)
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(22)
        }
        
        leftView.addSubview(textField)
        
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(8)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-45)
        }
        
//        leftView.addSubview(cameraBtn)
//        cameraBtn.snp.makeConstraints { (make) in
//            make.width.equalTo(45)
//            make.top.bottom.equalToSuperview()
//            make.right.equalToSuperview()
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXNewSearchViewController {
    @objc public override var pageName: String {
            return "Search_Page"
        }
}

extension YXNewSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.textField.resignFirstResponder()
    }
}


extension QMUIButton {
    
    class func creatGhostButton(with color: UIColor) -> QMUIButton {
        let btn = QMUIButton.init()
        btn.setTitleColor(color, for: .normal)
        btn.layer.borderColor = color.cgColor
        btn.layer.borderWidth = 1
        btn.cornerRadius = QMUIButtonCornerRadiusAdjustsBounds
        return btn
    }
}
