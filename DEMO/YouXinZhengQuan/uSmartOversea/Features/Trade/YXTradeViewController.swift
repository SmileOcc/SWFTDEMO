//
//  YXSmartOrderViewController.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/9/13.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

@objcMembers class YXTradeViewModel: YXViewModel {

    fileprivate lazy var normalTradeViewModel: YXNormalTradeViewModel = {
        YXNormalTradeViewModel(services: services, params: params)
    }()
    
    fileprivate lazy var smartTradeViewModel: YXSmartTradeViewModel = {
        YXSmartTradeViewModel(services: services, params: params)
    }()
}

@objc enum TradeMenuType: Int {
    case none
    case trade
    case fractional
    case smart
}

extension TradeMenuType: CaseIterable {
    var title: String {
        switch self {
        case .trade:
            return YXLanguageUtility.kLang(key: "common_trade")
        case .fractional:
            return YXLanguageUtility.kLang(key: "fractional_trading")
        case .smart:
            return YXLanguageUtility.kLang(key: "trading_smart_order")
        default:
            return ""
        }
    }
}

@objcMembers class YXTradeViewController: YXViewController {
    
    lazy var viewControllers: [UIViewController] = {
        return [normalTradeViewController, smartTradeViewController]
    }()
    
    lazy var csBarItem: UIBarButtonItem = {
        let barItem = UIBarButtonItem.qmui_item(with: UIImage(named: "icon_cs")!, target: self, action: #selector(csButtonAction))
        return barItem
    }()

    func csButtonAction() {
        if tradeMenuType == .smart {
            trackViewClickEvent(customPageName: "Smart order detail", name: "Help center_Tab")
        } else {
            trackViewClickEvent(customPageName: "Trade detail", name: "Help center_Tab")
        }
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "trade_email_alert"))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .fullDefault, handler: { _ in
        }))
        alertView.show(in: self)
    }
    
    var autoResetNormalTrade: Bool = false
    @objc func resetNormalTrade() {
        let normalTradeModel = (viewModel as! YXTradeViewModel).normalTradeViewModel.tradeModel
        
        if normalTradeModel.tradeType == .normal {
            autoResetNormalTrade = true
            tradeMenuType = .trade
        } else if normalTradeModel.tradeType == .fractional {
            autoResetNormalTrade = true
            tradeMenuType = .fractional
        }
    }
    
    @objc func changeToNormalTrade(tradeType: TradeType, direction: TradeDirection) {
        (viewModel as! YXTradeViewModel).normalTradeViewModel.tradeModel.direction = direction
        (viewModel as! YXTradeViewModel).normalTradeViewModel.tradeModel.tradeStatus = .limit

        if tradeType == .normal {
            tradeMenuType = .trade
        } else if tradeType == .fractional {
            tradeMenuType = .fractional
        }
    }
    
    var tradeMenuType: TradeMenuType = .none {
        didSet {
            menuButton.setTitle(tradeMenuType.title, for: .normal)
            menuButton.sizeToFit()
            
            if oldValue == .none {
                if tradeMenuType == .smart {
                    pageView.contentView.scrollToRight(animated: false)
                }
                return
            }
            
            if autoResetNormalTrade {
                autoResetNormalTrade = false
                let normalTradeViewModel = (viewModel as! YXTradeViewModel).normalTradeViewModel
                normalTradeViewModel.reset()
                return
            }
            
            let normalTradeViewModel = (viewModel as! YXTradeViewModel).normalTradeViewModel
            let smartTradeViewModel = (viewModel as! YXTradeViewModel).smartTradeViewModel

            let normalTradeModel = normalTradeViewModel.tradeModel
            let smartTradeModel = smartTradeViewModel.tradeModel

            switch tradeMenuType {
            case .trade:
                normalTradeModel.tradeType = .normal
                if oldValue == .smart, smartTradeModel.market != "", smartTradeModel.symbol != "" {
                    normalTradeViewModel.changeStock(smartTradeModel.market, symbol: smartTradeModel.symbol, name: smartTradeModel.name)
                } else {
                    normalTradeViewModel.changeStock(normalTradeModel.market, symbol: normalTradeModel.symbol, name: normalTradeModel.name)
                }
            case .fractional:
                normalTradeModel.tradeType = .fractional
                if oldValue == .smart {
                    if smartTradeModel.market == kYXMarketUS, smartTradeModel.symbol != "" {
                        normalTradeViewModel.changeStock(smartTradeModel.market, symbol: smartTradeModel.symbol, name: smartTradeModel.name)
                    } else {
                        normalTradeViewModel.changeStock(kYXMarketUS, symbol: "", name: "")
                    }
                } else if oldValue == .trade {
                    if normalTradeModel.market == kYXMarketUS, normalTradeModel.symbol != "" {
                        normalTradeViewModel.changeStock(normalTradeModel.market, symbol: normalTradeModel.symbol, name: normalTradeModel.name)
                    } else {
                        normalTradeViewModel.changeStock(kYXMarketUS, symbol: "", name: "")
                    }
                }

            case .smart:
                if normalTradeModel.market != kYXMarketUsOption {
                    smartTradeViewModel.changeStock(normalTradeModel.market, symbol: normalTradeModel.symbol, name: normalTradeModel.name)
                } else {
                    smartTradeViewModel.changeStock(smartTradeModel.market, symbol: "", name: "")
                }
            default:
                break
            }
            
            if tradeMenuType == .smart {
                pageView.contentView.scrollToRight(animated: false)
            } else {
                pageView.contentView.scrollToLeft(animated: false)
            }
        }
    }
    
    var supportMenuTypes: [TradeMenuType] {
        get {
            if YXUserManager.isOpenUsFraction() {
                switch tradeMenuType {
                case .trade:
                    let normalTradeViewModel = (viewModel as! YXTradeViewModel).normalTradeViewModel
                    let normalTradeModel = normalTradeViewModel.tradeModel
                    
                    if normalTradeModel.symbol != "", normalTradeModel.market != kYXMarketUS {
                        return [.trade, .smart]
                    }
                case .smart:
                    let smartTradeViewModel = (viewModel as! YXTradeViewModel).smartTradeViewModel
                    let smartTradeModel = smartTradeViewModel.tradeModel
                    if smartTradeModel.symbol != "", smartTradeModel.market != kYXMarketUS {
                        return [.trade, .smart]
                    }

                default:
                    break
                }
                return [.trade, .fractional, .smart]
            } else {
                return [.trade, .smart]
            }
        }
    }
    
    private lazy var menuButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_trade"), for: .normal)
        button.setImage(UIImage(named: "trade_select"), for: .normal)
        button.spacingBetweenImageAndTitle = 2
        button.imagePosition = .right
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        
        button.qmui_tapBlock = { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if strongSelf.menuView.isShowing() {
                strongSelf.hideMenu()
            } else {
                strongSelf.showMenu()
            }
        }
        return button
    }()
    
    private lazy var menuView: QMUIPopupMenuView = {
        let menuView = QMUIPopupMenuView()
        menuView.backgroundColor = QMUITheme().popupLayerColor()
        menuView.automaticallyHidesWhenUserTap = true
        menuView.maskViewBackgroundColor = .clear
        menuView.arrowSize = .zero
        menuView.preferLayoutDirection = .below
        menuView.itemSeparatorColor = QMUITheme().popSeparatorLineColor()
        menuView.itemTitleColor = QMUITheme().textColorLevel1()
        menuView.itemTitleFont = .systemFont(ofSize: 14)
        menuView.distanceBetweenSource = 16
        menuView.shouldShowItemSeparator = true
        menuView.padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        menuView.cornerRadius = 6
        menuView.itemHeight = 48
        menuView.minimumWidth = 160
        menuView.borderColor = UIColor.themeColor(withNormalHex: "#E1E4E7", andDarkColor: "#212129")
        menuView.sourceView = menuButton

        return menuView
    }()
    
    private func showMenu() {
        UIApplication.shared.keyWindow?.endEditing(true)
        
        menuView.items = supportMenuTypes.map {[weak self] (type) -> QMUIPopupMenuButtonItem in
            let buttonItem = QMUIPopupMenuButtonItem(image: nil, title: type.title) { [weak self] (item) in
                guard let strongSelf = self else { return }
                strongSelf.hideMenu()
                strongSelf.tradeMenuType = type
            }
            buttonItem.button.contentHorizontalAlignment = .center
            return buttonItem
        }
        
        menuView.itemConfigurationHandler = { [weak self] (_, aItem, section, index) in
            guard let strongSelf = self else { return }
            guard let item = aItem as? QMUIPopupMenuButtonItem else { return }
            
            item.button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            item.highlightedBackgroundColor = QMUITheme().foregroundColor().withAlphaComponent(0.6)
            
            if strongSelf.supportMenuTypes[index] == strongSelf.tradeMenuType {
                item.button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
            }
            
            item.button.contentHorizontalAlignment = .center
        }
        menuView.showWith(animated: false)
    }
    
    private func hideMenu() {
        menuView.hideWith(animated: false)
    }

    private lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.contentView.isScrollEnabled = false
        pageView.parentViewController = self
        pageView.viewControllers = viewControllers
        return pageView
    }()
    
    private lazy var normalTradeViewController: YXNormalTradeViewController = {
        YXNormalTradeViewController(viewModel: (viewModel as! YXTradeViewModel).normalTradeViewModel)
    }()
    
    private lazy var smartTradeViewController: YXSmartTradeViewController = {
        YXSmartTradeViewController(viewModel: (viewModel as! YXTradeViewModel).smartTradeViewModel)
    }()

    
    var isOrderList: Bool = false
    
    func setupUI() {
        view.addSubview(pageView)
        
        pageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
                
        if let tradeModel = viewModel.params?["tradeModel"] as? TradeModel {
            if tradeModel.tradeType == .fractional {
                tradeMenuType = .fractional
            } else if tradeModel.tradeOrderType == .smart {
                tradeMenuType = .smart
            } else {
                tradeMenuType = .trade
            }
        } else {
            tradeMenuType = .trade
        }
        menuButton.setTitle(tradeMenuType.title, for: .normal)
        navigationItem.titleView = menuButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = [.top]
        navigationItem.rightBarButtonItems = [csBarItem];

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func qmui_backBarButtonItemTitle(withPreviousViewController viewController: UIViewController?) -> String? {
        return ""
    }
}

extension YXTradeViewController: YXTabViewDelegate {
//    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
//        let normalTradeViewModel = (viewModel as! YXTradeViewModel).normalTradeViewModel
//        let smartTradeViewModel = (viewModel as! YXTradeViewModel).smartTradeViewModel
//
//        let normalTradeModel = normalTradeViewModel.tradeModel
//        let smartTradeModel = smartTradeViewModel.tradeModel
//
//        if index == 0 {
//            if smartTradeModel.market != "", smartTradeModel.symbol != ""  {
//                normalTradeViewModel.changeStock(smartTradeModel.market, symbol: smartTradeModel.symbol, name: smartTradeModel.name)
//            } else if normalTradeModel.market != "", normalTradeModel.symbol != "" {
//                normalTradeViewModel.changeStock(normalTradeModel.market, symbol: normalTradeModel.symbol, name: normalTradeModel.name)
//            }
//        } else if index == 2, normalTradeModel.market != "", normalTradeModel.symbol != "" {
//            if normalTradeModel.market != kYXMarketUsOption {
//                smartTradeViewModel.changeStock(normalTradeModel.market, symbol: normalTradeModel.symbol, name: normalTradeModel.name)
//            } else {
//                smartTradeViewModel.changeStock(smartTradeModel.market, symbol: "", name: "")
//            }
//        }
//    }
}
