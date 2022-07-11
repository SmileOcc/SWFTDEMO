//
//  YXModuleMoreViewController.swift
//  uSmartOversea
//
//  Created by Evan on 2022/3/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class YXModuleMoreViewController: YXHKViewController, ViewModelBased  {

    var viewModel: YXModuleMoreViewModel!

    private lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightBtnOnlyImage(iamge: UIImage.init(named: "nav_info"))
        sheet.rightButtonAction = {
            if let vc = UIViewController.current() as? QMUIModalPresentationViewController {
                vc.hideWith(animated: true) { (finish) in
                    YXWebViewModel.pushToWebVC(YXH5Urls.smartHelpUrl())
                }
            }
        }
        return sheet
    }()

    private lazy var collectionView: UICollectionView = {
        let column: CGFloat = 4
        let padding: CGFloat = 16
        let minimumSpacing: CGFloat = 12.0
        let maximumWidth: CGFloat = 76

        var spacing = minimumSpacing
        // 先按最小间距计算 cell 宽度
        var width = (YXConstant.screenWidth - padding * 2 - (column - 1) * minimumSpacing) / column

        if width > maximumWidth {// 宽度超过最大宽度
            width = maximumWidth
            // 重新计算间距
            spacing = (YXConstant.screenWidth - padding * 2 - column * width) / (column - 1)
        }

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = CGSize(width: width, height: width)
        layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 50)
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = QMUITheme().foregroundColor()
        view.register(
            YXModuleMoreCell.self,
            forCellWithReuseIdentifier: NSStringFromClass(YXModuleMoreCell.self)
        )
        view.register(
            YXModuleMoreHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NSStringFromClass(YXModuleMoreHeaderView.self)
        )
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = YXLanguageUtility.kLang(key: "share_info_more")
        view.backgroundColor = QMUITheme().foregroundColor()

        bindViewModel()
    }

    override func initSubviews() {
        super.initSubviews()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindViewModel() {
        let items = Observable.just(
            [
                SectionModel(
                    model: YXLanguageUtility.kLang(key: "common_trade"),
                    items: [
                        ModuleCategory.trade,
                        ModuleCategory.smartOrder,
                        ModuleCategory.fractionalTrading,
                        ModuleCategory.allOrders
                    ]
                ),
                SectionModel(
                    model: YXLanguageUtility.kLang(key: "module_more_funds"),
                    items: [
                        ModuleCategory.deposit,
                        ModuleCategory.withdrawal,
                        ModuleCategory.exchange,
                        ModuleCategory.cashFlow
                    ]
                ),
                SectionModel(
                    model: YXLanguageUtility.kLang(key: "hold_stock_name"),
                    items: [
                        ModuleCategory.stockDeposit
                    ]
                ),
                SectionModel(
                    model: YXLanguageUtility.kLang(key: "accounts"),
                    items: [
                        ModuleCategory.statement
                    ]
                )
            ]
        )

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, ModuleCategory>>(
            configureCell:  { (dataSource, collectionView, indexPath, element) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NSStringFromClass(YXModuleMoreCell.self),
                    for: indexPath
                ) as! YXModuleMoreCell
                cell.bind(to: element)
                return cell
            },
            configureSupplementaryView: { (dataSource ,collectionView, kind, indexPath) in
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: NSStringFromClass(YXModuleMoreHeaderView.self),
                    for: indexPath
                ) as! YXModuleMoreHeaderView
                header.titleLabel.text = "\(dataSource[indexPath.section].model)"
                return header
            }
        )

        items.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        collectionView.rx.modelSelected(ModuleCategory.self)
            .subscribe(onNext:{ [weak self] item in
                self?.clickModule(item)
            })
            .disposed(by: rx.disposeBag)
    }

    private func clickModule(_ model: ModuleCategory) {
        switch model {
        case .trade:
            let tradeModel = TradeModel()
            tradeModel.symbol =  ""
            tradeModel.tradeType = .normal
            tradeModel.market = self.viewModel.market
            let viewModel = YXTradeViewModel(services: self.viewModel.navigator, params: ["tradeModel": tradeModel])
            self.viewModel.navigator.push(viewModel, animated: true)
        case .smartOrder:
            let viewModel = YXSmartTradeGuideViewModel(services:self.viewModel
                                                        .navigator, params:nil)
            let vc = YXSmartTradeGuideViewController(viewModel: viewModel)
            self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "account_stock_order_title")
            self.bottomSheet.showViewController(vc: vc)
        case .allOrders:
            let orderListViewModel = YXAggregatedOrderListViewModel.init(defaultTab: nil, exchangeType: nil)
            let context = YXNavigatable(viewModel: orderListViewModel)
            self.viewModel.navigator.push(YXModulePaths.allOrderList.url, context: context)
        case .fractionalTrading:
            YXToolUtility.handleCanTradeFractional { [weak self] in
                guard let `self` = self else { return }
                let tradeModel = TradeModel()
                tradeModel.symbol =  ""
                tradeModel.tradeType = .fractional
                tradeModel.market = self.viewModel.market
                let viewModel = YXTradeViewModel(services: self.viewModel.navigator, params: ["tradeModel": tradeModel])
                self.viewModel.navigator.push(viewModel, animated: true)
            }
        case .deposit:
            var url = YXH5Urls.DEPOSIT_GUIDELINE_SG_URL()
            if YXUserManager.shared().curBroker == .sg {
                url = YXH5Urls.DEPOSIT_GUIDELINE_SG_URL()
            }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: url
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        case .withdrawal:
            var url = YXH5Urls.WITHDRAWAL_GUIDELINE_SG_URL()
            if YXUserManager.shared().curBroker == .sg {
                url = YXH5Urls.WITHDRAWAL_GUIDELINE_SG_URL()
            }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: url
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        case .exchange:
            let context = YXNavigatable(viewModel: YXCurrencyExchangeViewModel(market: self.viewModel.market))
            self.viewModel.navigator.push(YXModulePaths.exchange.url, context: context)
        case .cashFlow:
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.cashFlowURL(with: self.viewModel.market)
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        case .myBankAcc:
            break
        case .stockDeposit:
            let url = YXH5Urls.stockDepositURL()
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: url
            ]
            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        case .statement:
            let viewModel = YXTradeStatementViewModel(services: self.viewModel.navigator, params: nil)
            self.viewModel.navigator.push(viewModel, animated: true)
        case .more:
            break
        }
    }

}
