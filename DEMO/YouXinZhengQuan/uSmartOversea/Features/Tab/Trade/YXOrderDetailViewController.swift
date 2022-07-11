//
//  YXOrderDetailViewController.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import FLAnimatedImage

class YXOrderDetailViewController: YXHKViewController, HUDViewModelBased {
    
    typealias ViewModelType = YXOrderDetailViewModel
    
    var viewModel: YXOrderDetailViewModel!
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var exchangeType: YXExchangeType?

    lazy var containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        stackView.qmui_frameDidChangeBlock = { [weak self](view, frame) in
            self?.scrollView.contentSize = CGSize(width: frame.width, height: frame.height)
        }
        
        return stackView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never;
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        return scrollView
    }()
    
    let headerView = UIView()
    
    lazy var tipImgView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icon_warning_grey"))
        iv.contentMode = .center
        return iv
    }()
    
    lazy var tipLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
    //    label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 18)
        
//        label.addSubview(tipImgView)
//        tipImgView.snp.makeConstraints { (make) in
//            make.left.equalTo(0)
//            make.width.height.equalTo(30)
//            make.centerY.equalToSuperview()
//        }
        return label
    }()
    
    //headerView
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var marketIconLabel: YXMarketIconLabel = {
        let label = YXMarketIconLabel()
        return label
    }()
    
    lazy var statusNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        return label
    }()
    
    var directionLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "down_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel1()))
        return imageView
    }()
    
    var expandOrderViews = [UIView]()
    
    var isExpand = false
    
    lazy var expandOrderView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "hold_detailed_order") + "    "
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        
        view.addSubview(label)
        label.addSubview(arrowView)
        
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(label.snp.right)
            make.centerY.equalToSuperview()
        }
        
        view.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            
            if ges.state == .ended {
                for view in strongSelf.expandOrderViews {
                    view.isHidden = strongSelf.isExpand
                }
                strongSelf.isExpand = !strongSelf.isExpand
                if strongSelf.isExpand {
                    strongSelf.arrowView.image = UIImage(named: "up_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel1())
                } else {
                    strongSelf.arrowView.image = UIImage(named: "down_arrow")?.qmui_image(withTintColor: QMUITheme().textColorLevel1())
                }
            }
        }).disposed(by: disposeBag)
        
        return view
    }()
    
    //報價
//    lazy var quoteButton: QMUIButton = {
//        let btn = QMUIButton()
//        btn.setTitle(YXLanguageUtility.kLang(key: "hold_quote"), for: .normal)
//        btn.setImage(UIImage(named: "user_mymarket"), for: .normal)
//        btn.imagePosition = .left
//        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
//        btn.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (_) in
//            guard let strongSelf = self else { return }
//
//            if strongSelf.viewModel.market == kYXMarketUsOption, YXUserManager.shared().getOptionLevel() == .delay {
//                YXToolUtility.goBuyOptionOnlineAlert()
//                return
//            }
//
//            let input = YXStockInputModel()
//            input.market = strongSelf.viewModel.market
//            input.symbol = strongSelf.viewModel.symbol
//            input.name = strongSelf.viewModel.name
//            strongSelf.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
//        }).disposed(by: disposeBag)
//        return btn
//    }()
    //竖线
    lazy var verLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = YXLanguageUtility.kLang(key: "hold_order_detail")
        
        bindHUD()
        
//        let lineView = UIView()
//        lineView.backgroundColor = QMUITheme().lightLineColor().withAlphaComponent(0.5)
//        view.addSubview(lineView)
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(view)
//            make.height.equalTo(1)
//            make.bottom.equalTo(view.safeArea.bottom).offset(-49)
//        }
        
//        view.addSubview(quoteButton)
//        quoteButton.snp.makeConstraints { (make) in
//            make.centerX.equalTo(view)
//            make.top.equalTo(lineView.snp.bottom)
//            make.bottom.equalTo(view.safeArea.bottom)
//            make.width.equalTo(200)
//        }
        
//        view.addSubview(tipImgView)
//        view.addSubview(tipLabel)
//        tipImgView.snp.makeConstraints { (make) in
//            make.left.equalTo(18)
//            make.width.height.equalTo(15)
//            make.top.equalTo(tipLabel.snp.top).offset(2)
//        }
//
//        tipLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(tipImgView.snp.right).offset(2)
//            make.right.equalTo(view).offset(-18)
//            make.bottom.equalTo(lineView).offset(-5)
//            //make.height.equalTo(64)
//        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(YXConstant.navBarHeight())
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeArea.bottom)
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.width.equalTo(scrollView)
        }
        
        viewModel.hudSubject.subscribe(onNext: { [weak self] (type) in
            guard let strongSelf = self else { return }
            
            if case .error(_, _) = type, strongSelf.viewModel.detail.value == nil {
                strongSelf.showErrorEmptyView()
                strongSelf.view.insertSubview(strongSelf.emptyView!, belowSubview: strongSelf.networkingHUD)
            }
        }).disposed(by: disposeBag)
        
//        if YXGlobalConfigManager.isDynamicShow() {
//            //是否显示分享
//            viewModel.shareSubject.subscribe(onNext: { [weak self] (exchangeType) in
//                guard let `self` = self else {return}
//
//                let itemWidth = (YXConstant.screenWidth - 1) / 2.0
//                self.quoteButton.snp.remakeConstraints { (make) in
//                    make.left.equalToSuperview()
//                    make.width.equalTo(itemWidth)
//                    make.top.equalTo(lineView.snp.bottom)
//                    make.bottom.equalTo(self.view.safeArea.bottom)
//                }
//                self.view.addSubview(self.verLineView)
//                self.verLineView.snp.makeConstraints { (make) in
//                    make.top.equalTo(lineView.snp.bottom)
//                    make.bottom.equalTo(self.view.safeArea.bottom)
//                    make.width.equalTo(1.0)
//                    make.left.equalTo(self.quoteButton.snp.right)
//                }
//                //分享
//                self.view.addSubview(self.shareButton)
//                self.shareButton.snp.makeConstraints { (make) in
//                    make.right.equalToSuperview()
//                    make.left.equalTo(self.verLineView.snp.right)
//                    make.top.equalTo(lineView.snp.bottom)
//                    make.bottom.equalTo(self.view.safeArea.bottom)
//                }
//                self.viewModel.shareUrl = String(format: "%@?type=share&id=%@&exchangeType=%ld", YXH5Urls.DYNAMIC_SUNDRYING_URL(), self.viewModel.entrustId, exchangeType ?? 0)
//                self.shareButton.rx.tap.asObservable().subscribe(onNext: { [weak self] in
//                    guard let `self` = self else { return }
//                    //
//                    let dic = [YXWebViewModel.kWebViewModelUrl: self.viewModel.shareUrl]
//                    print("dic:\(dic)")
//                    self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                }).disposed(by: self.disposeBag)
//
//            }).disposed(by: disposeBag)
//        }
        
        
        viewModel.detail.asDriver().drive(onNext: { [weak self] (detail) in
            guard let strongSelf = self else { return }
            
            if let data = detail {
                data.exchangeType = YXExchangeType.exchangeType(data.market?.lowercased())
                if data.exchangeType == .us && data.symbolType == "4" {//symbolType  证券类别：1-股票；3-涡轮牛熊；4-期权， 美股期权的时候 market 还是US
                    data.exchangeType = .usop
                }
                //分享
                if data.status == 20 || data.status == 28 || data.status == 29 { // 部分成交, 部成撤单, 全部成交
                    let imageView = FLAnimatedImageView()
                    imageView.contentMode = .scaleToFill
                    imageView.snp.makeConstraints { make in
                        make.width.height.equalTo(24)
                    }

                    let gifName = YXThemeTool.isDarkMode() ? "gif_share_dark" : "gif_share"
                    if let path = Bundle.main.path(forResource: gifName, ofType: "gif"),
                       let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                        let image = FLAnimatedImage(animatedGIFData: data)
                        imageView.animatedImage = image
                    }

                    imageView.rx.tapGesture().subscribe(onNext: { ges in
                        if ges.state == .ended {
                            strongSelf.shareAction()
                        }
                    }).disposed(by: strongSelf.rx.disposeBag)

                    strongSelf.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
                } else {
                    strongSelf.navigationItem.rightBarButtonItem = nil
                }
                
                switch data.tradePeriod {
                    case "N":
                        data.sessionType = 0
                    case "B":
                        data.sessionType = 2
                    case "A":
                        data.sessionType = 1
                    case "AB":
                        data.sessionType = 12
                    default:
                        data.sessionType = nil
                }
                
                strongSelf.exchangeType = data.exchangeType
                strongSelf.hideEmptyView()
                strongSelf.nameLabel.text = "--"
                if let name = data.symbolName, name.count > 0, let symbol = data.symbol, symbol.count > 0 {
                    if data.exchangeType == .usop {
                        strongSelf.nameLabel.text = name
                    } else {
                        strongSelf.nameLabel.text = name + "(" + symbol + ")" 
                    }
                }
                
                strongSelf.marketIconLabel.market = data.exchangeType?.market
                
                if let document = data.document, document.count > 0 {
                    strongSelf.tipLabel.text = YXLanguageUtility.kLang(key: "order_detial_tips") + ":\n" + document
                    strongSelf.tipLabel.isHidden = false
                } else {
                    strongSelf.tipLabel.text = ""
                    strongSelf.tipLabel.isHidden = true
                }
                                                
                strongSelf.statusNameLabel.text = data.statusName
                //买入卖出
                if data.entrustSide == "B" {
                    data.entrustType = .buy
                } else {
                    data.entrustType = .sell
                }
                strongSelf.directionLabel.text = data.entrustType?.text
                if data.sessionType == 3 {
                    if data.entrustType == .buy {
                        strongSelf.directionLabel.text =  YXLanguageUtility.kLang(key: "grey_mkt_buy")
                    } else if data.entrustType == .sell {
                        strongSelf.directionLabel.text =  YXLanguageUtility.kLang(key: "grey_mkt_sell")
                    }
                }
                
                strongSelf.directionLabel.textColor = data.entrustType?.textColor
                
                let numberFormatter = NumberFormatter()
                numberFormatter.positiveFormat = "###,##0.00"
                numberFormatter.locale = Locale(identifier: "zh")
                let countFormatter = NumberFormatter()
                countFormatter.positiveFormat = "###,##0"
                countFormatter.locale = Locale(identifier: "zh")
                
                let count = data.detailList?.count ?? 0
                data.detailList?.enumerated().forEach({ [weak self] (index, item) in
                    guard let strongSelf = self else { return }
                    
                    let orderStatus = item.detailStatus ?? 0
                    let orderStatusString = "\(orderStatus)"
                    if index == 0 {
                        //下单失败是12，改单失败是22，撤单失败是32  // 日内融订单失败只有 -1 一种
                        
                        let entrustView = YXOrderEntrustView.init(
                            frame: CGRect.zero,
                            exchangeType:strongSelf.exchangeType ?? .hk,
                            sessionType:data.sessionType ?? 0,
                            orderModel: item,
                            orderType: data.orderType ?? 0,
                            symbolType: data.symbolType ?? "",
                            oddTradeType: data.oddTradeType ?? 0,
                            allOrderType: strongSelf.viewModel.allOrderType
                        )
                        strongSelf.containerView.insertArrangedSubview(entrustView, at: 1)
//                        let paddingView = strongSelf.getPaddingView()
//                        paddingView.isHidden = true
//                        strongSelf.containerView.insertArrangedSubview(paddingView, at: 1)
                        
                        var height: CGFloat = 210
                        if (item.entrustProp == "MKT") {
                            height = 180;
                        }
                        if entrustView.failReasonHeight > 0 {
                            height += entrustView.failReasonHeight + 5
                        }
                        
                        if strongSelf.exchangeType == .us {
                            height += 30
                            if data.sessionType == 12 {
                                height += 45
                            }
                        }
                        height += 16

                        if data.symbolType == "2" {
                            height += 45
                        }
                        
                        entrustView.snp.makeConstraints { (make) in
                            make.height.equalTo(height)
                        }
                        entrustView.item = item
//                        strongSelf.containerView.insertArrangedSubview(strongSelf.expandOrderView, at: 1)
                        
//                        strongSelf.expandOrderView.snp.makeConstraints { (make) in
//                            make.height.equalTo(40)
//                        }
//                        let paddingView = strongSelf.getPaddingView()
//                        strongSelf.containerView.insertArrangedSubview(paddingView, at: 1)
                        
                    } else if (String(orderStatusString.prefix(1)) == "2" &&  item.detailStatus ?? 0 < 24)
                                || item.detailStatus == 11
                                || item.detailStatus == 25
                                || ((strongSelf.viewModel.allOrderType == .option || strongSelf.viewModel.allOrderType == .shortSell) &&  (item.detailStatus == 120 || item.detailStatus == 130)) {
                        let paddingView = strongSelf.getPaddingView()
//                        paddingView.isHidden = true
                        strongSelf.containerView.insertArrangedSubview(paddingView, at: 1)
                        let changeView = YXOrderChangeView(
                            frame: CGRect.zero,
                            orderModel: item,
                            exchangeType: strongSelf.exchangeType ?? .hk,
                            symbolType: data.symbolType ?? "",
                            oddTradeType: data.oddTradeType ?? 0,
                            allOrderType: strongSelf.viewModel.allOrderType
                        )
//                        changeView.isHidden = true
                        strongSelf.containerView.insertArrangedSubview(changeView, at: 1)

                        var failHeight: CGFloat = 0
                        if changeView.failReasonHeight > 0 {
                            failHeight = changeView.failReasonHeight + 5
                        }
                        failHeight += 16
                        changeView.snp.makeConstraints { (make) in
                            make.height.equalTo(CGFloat(160) + failHeight)
                        }
                        changeView.item = item
//                        if let retractMark = item.retractMark, retractMark == 1 {
//                            strongSelf.expandOrderView.isHidden = false
//                            strongSelf.expandOrderViews.append(changeView)
//                            strongSelf.expandOrderViews.append(paddingView)
//                        }
                    } else if orderStatus == 1 || ((strongSelf.viewModel.allOrderType == .option || strongSelf.viewModel.allOrderType == .shortSell) && item.detailStatus == 60) {
                        let paddingView = strongSelf.getPaddingView()
//                        paddingView.isHidden = true
                        strongSelf.containerView.insertArrangedSubview(paddingView, at: 1)
                        let partView = YXOrderPartView.init(frame: .zero, symbolType: data.symbolType ?? "", oddTradeType: data.oddTradeType ?? 0)
                        partView.exchangeType = strongSelf.exchangeType ?? .hk
//                        partView.isHidden = true
                        strongSelf.containerView.insertArrangedSubview(partView, at: 1)

                        partView.snp.makeConstraints { (make) in
                            make.height.equalTo(176)
                        }
                        partView.item = item
//                        if let retractMark = item.retractMark, retractMark == 1 {
//                            strongSelf.expandOrderView.isHidden = false
//                            strongSelf.expandOrderViews.append(partView)
//                            strongSelf.expandOrderViews.append(paddingView)
//                        }
                    } else if index + 1 == count {
                        let exchangeType = strongSelf.exchangeType ?? .hk
                        let finishView = YXOrderFinishView(
                            frame: .zero,
                            exchangeType: exchangeType,
                            symbolType: data.symbolType ?? "",
                            oddTradeType: data.oddTradeType ?? 0,
                            orderModel: item,
                            allOrderType: strongSelf.viewModel.allOrderType,entrustSide:data.entrustType ?? .buy
                        )
                        
                        let paddingView = strongSelf.getPaddingView()
                        strongSelf.containerView.insertArrangedSubview(paddingView, at: 1)
                        
                        strongSelf.containerView.insertArrangedSubview(finishView, at: 1)

                        var failHeight: CGFloat = 0;
                        if finishView.failReasonHeight > 0 {
                            failHeight = finishView.failReasonHeight + 5
                        }
                        
                        failHeight += 16
                        finishView.snp.makeConstraints { make in
                            make.height.equalTo(178 + failHeight)
                        }
                        finishView.item = item;
                        
                        finishView.clickExpand = { [weak finishView] in
                            guard let finishView = finishView else { return }
                            
                            finishView.snp.updateConstraints { make in
                                if finishView.isExpand {
                                    make.height.equalTo(178.0 + finishView.feeHeight + failHeight)
                                } else {
                                    make.height.equalTo(178.0 + failHeight)
                                }
                            }
                        }
                        
                        finishView.feeExplainView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
                            if ges.state == .ended {
                                let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.TRANSACTION_FEE_DESCRIPTION_URL()]
                                self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                            }
                        }).disposed(by: strongSelf.rx.disposeBag)
                    }
                })
            } else {
                strongSelf.tipLabel.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        setupHeaderView()
        containerView.addArrangedSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        
        viewModel.requestDetail()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    override func emptyRefreshButtonAction() {
        viewModel.requestDetail()
    }

    func leftLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14);
        return label
    }
    
    func rightLabel() -> QMUILabel {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14);
        label.textAlignment = .right
        return label
    }
    
    func setupHeaderView() {
        containerView.addArrangedSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.height.equalTo(90)
        }
        
        headerView.addSubview(statusNameLabel)
        headerView.addSubview(directionLabel)
        headerView.addSubview(nameLabel)
        headerView.addSubview(marketIconLabel)
        
        statusNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview()
            make.height.equalTo(34)
        }
        
        directionLabel.snp.makeConstraints { make in
            make.right.equalTo(headerView).offset(0)
            make.centerY.equalTo(marketIconLabel)
        }
        
        marketIconLabel.snp.makeConstraints { make in
            make.left.equalTo(statusNameLabel)
            make.top.equalTo(statusNameLabel.snp.bottom).offset(10)
            make.width.equalTo(20)
            make.height.equalTo(15)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(marketIconLabel.snp.right).offset(6)
            make.centerY.equalTo(marketIconLabel)
            make.right.lessThanOrEqualTo(directionLabel.snp.left).offset(-10)
        }
    }
    
    
    func getPaddingView() -> UIView {
        let view = UIView.init()
        
        view.snp.makeConstraints { make in
            make.height.equalTo(12)
        }
        return view
    }
    
    //点击分享
    @objc func shareAction(){
        guard let orderDetail = self.viewModel.detail.value else {
            return
        }

        orderDetail.entrustId = self.viewModel.entrustId

        YXHoldShareView.showShareView(
            type: .order,
            exchangeType: orderDetail.market?.lowercased().exchangeType.rawValue ?? 0,
            model: orderDetail
        )
    }
    
    override var pageName: String {
        "Order Detail"
    }
}

