//
//  YXVSSearchViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2021/2/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import YXKit
import Moya
import NSObject_Rx

class YXVSSearchViewController: YXHKViewController {

    var viewModel = YXVSSearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = YXLanguageUtility.kLang(key: "klinevs_title")

        YXKlineVSTool.shared.removeCache()

        initUI()
        bindViewModel()

        self.resultView.viewModel = self.viewModel

        if let item = self.viewModel.selectList.value.first {
            addItemOpeartion(item)
        }
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiQuoteKick))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }

                self.controlShadeView(self.selectView.list)

            }).disposed(by: rx.disposeBag)
    }

    deinit {
        YXKlineVSTool.shared.removeCache()
    }

    lazy var cellHeight: CGFloat = {
        return self.resultView.cellHeight
    }()

    let baseHeight: CGFloat = 37

    func initUI() {

        self.view.backgroundColor = QMUICMI().foregroundColor()

        self.view.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(38)
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview().offset(YXConstant.navBarHeight())
            }

        }

        self.view.addSubview(self.scrollview)
        self.scrollview.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.searchBar.snp.bottom)
        }

        self.scrollview.addSubview(selectView)
        self.scrollview.addSubview(resultView)

        self.selectView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            make.top.equalToSuperview()
            make.height.equalTo(baseHeight + cellHeight)
        }

        self.resultView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            make.top.equalTo(self.selectView.snp.bottom)
            make.height.equalTo(self.baseHeight + 3.5 * self.cellHeight)
        }

        self.scrollview.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(self.view)
            make.height.equalTo(280)
            make.top.equalTo(self.resultView.snp.bottom).offset(15)
            make.bottom.equalTo(self.scrollview.snp.bottom).offset(-30)
        }

        self.chartView.addSubview(rotateButton)
        rotateButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            if YXToolUtility.is4InchScreenWidth() {
                make.right.equalToSuperview().offset(-6)
            } else {
                make.right.equalToSuperview().offset(-12)
            }
            make.height.width.equalTo(20)
        }
        
        self.view.addSubview(stockIndexShadeView)
        stockIndexShadeView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.chartView)
        }
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
            self.searchBar.textField.becomeFirstResponder()
        })
    }


    func bindViewModel() {
        //监听搜索结果
        _ = self.viewModel.listBehavior.asObservable().filter({ (list) -> Bool in
            list != nil
        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            self?.resultView.list = list?.list ?? [];
        })

        self.scrollview.rx.willBeginDragging.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.searchBar.textField.resignFirstResponder()
        }).disposed(by: rx.disposeBag)

        //监听列表选中
        _ = self.viewModel.selectList.asObservable().takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            guard let `self` = self else { return }
            let count = list.count
            if count > 0 {
                self.selectView.isHidden = false
                self.selectView.snp.updateConstraints({ (make) in
                    make.height.equalTo(self.baseHeight + self.cellHeight * CGFloat(count))
                })
                self.chartView.isHidden = false
            } else {
                self.selectView.isHidden = true
                self.selectView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                self.chartView.isHidden = true
            }
            self.selectView.list = list;
        })

        _ = searchBar.textField.rx.text.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](text) in

            if let text = text,text != "" {
                _ = self?.viewModel.search(text: text)
            } else {
                self?.resultView.list = [];
            }
        })

        self.resultView.rightActionBlock = {
            [weak self] (model) in
            guard let `self` = self else { return }
            //增加对比股票
            var isRemove = false
            var list = self.viewModel.selectList.value
            if let model = model {
                for (index, item) in self.viewModel.selectList.value.enumerated() {
                    if item.market == model.market, item.symbol == model.symbol {
                        list.remove(at: index)
                        isRemove = true
                        break
                    }
                }
            }

            if isRemove {

                self.viewModel.selectList.accept(list)
                self.resultView.tableView.reloadData()

                if let item = model {
                    self.removeItemOperation(item)
                }
            } else {
                if list.count >= 3 {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "maxnum_vs_note"), in: self.view, hideAfterDelay: 2)
                } else {
                    if let model = model {
                        list.append(model)
                        self.viewModel.selectList.accept(list)
                        self.resultView.tableView.reloadData()
                        self.addItemOpeartion(model)
                    }
                }
            }
        }

        self.selectView.rightActionBlock = {
            [weak self] (model) in
            guard let `self` = self else { return }
            //删除对比股票
            var list = self.viewModel.selectList.value
            if let model = model {
                for (index, item) in self.viewModel.selectList.value.enumerated() {
                    if item.market == model.market, item.symbol == model.symbol {
                        list.remove(at: index)
                        break
                    }
                }
            }
            self.viewModel.selectList.accept(list)
            self.resultView.tableView.reloadData()
            if let item = model {
                self.removeItemOperation(item)
            }
        }
    }

    func removeItemOperation(_ item: YXSearchItem) {
        YXKlineVSTool.shared.removeItem(item)
        self.chartView.removeItem(item)
        self.chartView.refreshUI()
    }

    func addItemOpeartion(_ item: YXSearchItem) {

        YXKlineVSTool.shared.requestKlineData(item: item) { [weak self] (klineData) in
            guard let `self` = self else { return }
            if self.qmui_isViewLoadedAndVisible() {
                self.chartView.refreshUI()
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.init("YXKLineVSChangeNoti"), object: nil)
            }

        }
    }

    func controlShadeView(_ items: [YXSearchItem]) {
        
        if items.isEmpty {
            stockIndexShadeView.isHidden = true
        } else {

            for searchItem in items {

                if searchItem.type1 == OBJECT_SECUSecuType1.stIndex.rawValue, searchItem.market == kYXMarketUS {
                    let isKick = YXQuoteKickTool.shared.isQuoteLevelKickToDelay(searchItem.market, symbol: searchItem.symbol)
                    if isKick {
                        stockIndexShadeView.setIsKick(true)
                        stockIndexShadeView.isHidden = false
                        break;
                    } else {
                        stockIndexShadeView.setIsKick(false)
                        if YXUserManager.shared().getHighestUsaThreeLevel() == .delay  {
                            stockIndexShadeView.isHidden = false;
                            break;
                        } else {
                            stockIndexShadeView.isHidden = true;
                        }
                    }
                   
                } else {
                    stockIndexShadeView.isHidden = true
                }
            }
        }
    }
    
    lazy var scrollview: UIScrollView = {
        let scrollview = UIScrollView()

        return scrollview
    }()


    lazy var searchBar: YXVSSearchBar = {
        let view = YXVSSearchBar()
        
        return view
    }()

    lazy var resultView: YXVSSearchResultView = {
        let view = YXVSSearchResultView()
        view.type = .result
        return view
    }()

    lazy var selectView: YXVSSearchResultView = {
        let view = YXVSSearchResultView()
        view.type = .select
        return view
    }()

    lazy var chartView: YXKlineVSView = {
        let view = YXKlineVSView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 280), isLandscape: false)

        let tap = UITapGestureRecognizer.init(actionBlock: {
            [weak self] _ in
            guard let `self` = self else { return }
            self.pushLandVC()
        })

        //tap.numberOfTapsRequired = 2
        //[self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];

        view.addGestureRecognizer(tap)
        return view
    }()

    lazy var stockIndexShadeView: YXStockIndexAccessoryShadeView = {
        let view = YXStockIndexAccessoryShadeView()
        view.isHidden = true
        return view
    }()

    @objc func rotateDidClick() {
        self.pushLandVC()
    }

    lazy var rotateButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10
        button.setImage(UIImage(named: "rotate_portrait"), for: .normal)
        button.addTarget(self, action: #selector(rotateDidClick), for: .touchUpInside)
        return button
    }()


    func pushLandVC() {
        if YXKlineVSTool.shared.selectList.count >= 1 {
//            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "min_vs_note"), in: self.view, hideAfterDelay: 2)

            self.viewModel.navigator.push(YXModulePaths.klineVSLand.url, context: nil)
        }
    }


}



