//
//  YXOptionalHotStockShadowView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//
import UIKit
import YXKit
import RxSwift
import RxCocoa

@objcMembers class YXOptionalHotStockShadowView: JXBottomSheetView {

    var minY: CGFloat = 30
    var maxY: CGFloat = 290

    override init(contentView: UIScrollView, headerView: UIView) {
        super.init(contentView: contentView, headerView: headerView)
        defaultMininumDisplayHeight = self.minY
        defaultMaxinumDisplayHeight = self.maxY
        headerViewHeight = 0
        displayState = .minDisplay

        self.displayMin()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@objcMembers class YXOptionalHotStockShadowScrollView: UIScrollView {


    var pullDownUpClosure: ((_ isPullUp: Bool) -> Void)?
    var pushToStockDetailClosure: ((_ inputs: [YXStockInputModel], _ selectIndex: Int) -> Void)?
    var refreshQuoteData: (() -> Void)?

    let viewModel = YXOptionalHotStockViewModel()
    var isAppear = false

    var isPushStockDetail = false


    func loadData() {

        loadQuoteAndStockData()
        isAppear = true
        self.hotStockView.tableView.reloadData()

    }

    func loadQuoteAndStockData() {

//        if !isPushStockDetail || (self.viewModel.hotStockModel?.hot_stocks?.isEmpty ?? true)  {
//            loadHotStockData()
//        }
//
//        isPushStockDetail = false
//
//        viewModel.requestQuoteData(isSingle: !self.switchBtn.isSelected)
//        self.singleView.cycleScrollView.autoScroll = !self.switchBtn.isSelected
    }


    func cancelTask() {
        viewModel.cancelQuoteRequest()
        self.singleView.cycleScrollView.autoScroll = false
        isAppear = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        handleBlock()

        backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")
        self.topView.backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")

        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.cornerRadius = 10
        self.delaysContentTouches = false
        self.isScrollEnabled = false

        self.layer.backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")?.cgColor
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 6.0

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleBlock() {
        //登录 成功 监听
        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: YXUserManager.notiUpdateUUID))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] _ in
                guard let `self` = self else { return }
                self.viewModel.resetHotStock()
                self.loadHotStockData()
            })

        _ = NotificationCenter.default.rx.notification(Notification.Name.init(rawValue: kSecuGroupRemoveSecuNotification))
            .subscribe(onNext: {
                [weak self] _ in
                guard let `self` = self else { return }
                if self.isAppear {
                    self.hotStockView.tableView.reloadData()
                }
            }).disposed(by: rx.disposeBag)

        _ = NotificationCenter.default.rx.notification(Notification.Name.init(rawValue: kCustomSecuGroupAddStockNotification))
            .subscribe(onNext: {
                [weak self] _ in
                guard let `self` = self else { return }
                if self.isAppear {
                    self.refreshQuoteData?()
                }
            }).disposed(by: rx.disposeBag)


        self.indexView.onClickIndexPath = {
            [weak self] (inputs, selectIndex) in
            guard let `self` = self else { return }
            self.pushToStockDetailClosure?(inputs, selectIndex)
            self.isPushStockDetail = true
        }

        hotStockView.cellClickBlock = {
            [weak self] (inputs, selectIndex) in
            guard let `self` = self else { return }
            self.pushToStockDetailClosure?(inputs, selectIndex)
            self.isPushStockDetail = true
        }

        hotStockView.changeHotStockBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.loadHotStockData()
        }

        hotStockView.refreshQuoteData = {
            [weak self] in
            self?.refreshQuoteData?()
        }

        singleView.tapBlock = {
            [weak self] in
            guard let `self` = self else { return }
            self.pullDownUpClosure?(true)
        }

        viewModel.hotStockSubject.subscribe(onNext: {
            [weak self] (model, isQuote) in
            guard let `self` = self else { return }

            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.hotStockView.list = model?.hot_stocks ?? []

            if self.hotStockView.list.count > 0 {
                self.superview?.isHidden = false
                self.isHidden = false
            }

            if !isQuote {
                self.singleView.dataSource = model?.hot_stocks ?? []
            }
            if !isQuote, let info = model?.hot_stocks?.first {
                var currentPage = 0
                if info.market == kYXMarketHK {
                    currentPage = 0
                } else if info.market == kYXMarketUS {
                    currentPage = 1
                } else {
                    currentPage = 2
                }
                self.indexView.resetCurrentPage(currentPage)
            }

        }).disposed(by: rx.disposeBag)

        viewModel.indexSubject.subscribe(onNext: {
            [weak self] dataSource in
            guard let `self` = self else { return }

            self.indexView.dataSource = dataSource

        }).disposed(by: rx.disposeBag)

        viewModel.singleSubject.subscribe(onNext: {
            [weak self] quote in
            guard let `self` = self else { return }

            self.singleView.quoteModel = quote

        }).disposed(by: rx.disposeBag)

    }


    func loadHotStockData() {
        if self.topView.isHidden {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
        viewModel.requestHotStockData()
    }

    var maxBottomY: CGFloat = (YXConstant.screenHeight - YXConstant.tabBarHeight() - 30)
    func initUI() {

        let viewWidth = YXConstant.screenWidth

        addSubview(indexView)
        addSubview(hotStockView)
        indexView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(viewWidth)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(51)
        }

        hotStockView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(viewWidth)
            make.top.equalTo(indexView.snp.bottom)
            make.height.equalTo(212)
        }

        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
            make.height.equalTo(30)
        }

        topView.addSubview(singleView)
        singleView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-35)
        }

        addSubview(switchBtn)
        switchBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.top.equalToSuperview().offset(5)
            make.right.equalTo(indexView).offset(-10)
        }

        addSubview(activityIndicator)
        activityIndicator.isHidden = true
        self.activityIndicator.center = CGPoint(x: YXConstant.screenWidth * 0.5, y: 180)

    }

    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)

    lazy var topView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var switchBtn: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.setImage(UIImage(named: "stockKing_up"), for: .selected)
        button.setImage(UIImage(named: "stockKing_up")?.qmui_image(with: .down), for: .normal)
        button.addTarget(self, action: #selector(switchBtnAction(_:)), for: .touchUpInside)
        return button
    }()

    func switchBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.pullDownUpClosure?(sender.isSelected)
    }

    lazy var hotStockView: YXOptionalHotStockView = {
        let view = YXOptionalHotStockView()

        return view
    }()

    lazy var indexView: YXOptionalHotStockIndexView = {
        let view = YXOptionalHotStockIndexView()

        return view
    }()

    lazy var singleView: YXOptionalHotStockSingleView = {
        let view = YXOptionalHotStockSingleView()

        return view
    }()

}

extension YXOptionalHotStockShadowScrollView: JXBottomSheetViewDelegate {

    func bottomSheet(bottomSheet: JXBottomSheetView, didDisplayed state: JXBottomSheetState) {

        if state == .maxDisplay {

            self.switchBtn.isSelected = true

            self.topView.alpha = 0.0
            self.topView.isHidden = true
        } else {

            self.switchBtn.isSelected = false

            self.topView.alpha = 1.0
            self.topView.isHidden = false
        }
        
        isPushStockDetail = true
        loadQuoteAndStockData()
    }

    func bottomSheetWillChange() {

        self.setBgViewAlpha()
    }

    func setBgViewAlpha() {
        let y = self.frame.minY
        var a = (maxBottomY - y) / 32
        if a > 1 {
            a = 1.0
        }
        if a < 0 {
            a = 0.0
        }
        let alpha = 1 - a
        self.topView.alpha = alpha
        if alpha == 0 {
            self.topView.isHidden = true
        } else {
            self.topView.isHidden = false
        }
    }
}

