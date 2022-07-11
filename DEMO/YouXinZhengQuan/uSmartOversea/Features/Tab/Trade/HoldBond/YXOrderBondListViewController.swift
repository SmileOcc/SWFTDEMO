//
//  YXOrderBondListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/11/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxDataSources
import YXKit

//class YXOrderBondListViewController: YXOrderListBaseViewController, HUDViewModelBased, RefreshViweModelBased {
//    var isFromAAStock: Bool = false {
//        didSet {
//            if isFromAAStock {
//                //是否禁止使用修正,默认为NO
//                UINavigationConfig.shared().sx_defaultRightFixSpace = 0
//                UINavigationConfig.shared().sx_disableFixSpace = false
//                
//                let navbarHeight = 44.0
//                //按钮的阴影
//                let layer = CALayer()
//                layer.frame = CGRect(x: 2, y: (navbarHeight - 37) / 2.0, width: 93, height: 37)
//                layer.backgroundColor = UIColor.white.cgColor
//                layer.shadowColor = UIColor.black.qmui_color(withAlpha: 0.1, backgroundColor: .clear).cgColor
//                layer.shadowOffset = CGSize(width: 0, height: 0)
//                layer.shadowRadius = 5
//                layer.shadowOpacity = 1
//                layer.cornerRadius = 18.5   //圆角
//                
//                //按钮
//                let button = QMUIButton(frame: layer.frame)
//                button.backgroundColor = .white
//                button.setTitle(YXLanguageUtility.kLang(key: "common_go_back"), for: .normal)
//                button.setImage(UIImage(named: "order_list_AAStock"), for: .normal)
//                button.imagePosition = .right
//                button.spacingBetweenImageAndTitle = 8
//                button.layer.qmui_maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
//
//                button.layer.cornerRadius = layer.cornerRadius  //圆角
//                button.layer.masksToBounds = true
//                
//                button.rx.tap.bind {[weak self] in
//                    //是否禁止使用修正,默认为NO
//                    UINavigationConfig.shared().sx_disableFixSpace = true
//                    self?.isFromAAStock = false
//                    
//                    if let url = URL(string: YXH5Urls.YX_OPEN_AASTOCKS_URL(with: YXConstant.AAStockPageName ?? "") ), UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                    
//                }.disposed(by: self.disposeBag)
//                
//                
//                let baseView = UIView(frame: CGRect(x: 0, y: 0, width: 95, height: navbarHeight))
//                baseView.layer.insertSublayer(layer, at: 0)//阴影位置
//                baseView.addSubview(button)
//                
//                let rightBackItem = UIBarButtonItem(customView: baseView)
//                navigationItem.rightBarButtonItem = rightBackItem
//            }
//            
//        }
//    }
//    
//    lazy var refreshHeader: YXRefreshHeader = {
//        YXRefreshHeader()
//    }()
//    
//    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
//        YXRefreshAutoNormalFooter()
//    }()
//    
//    lazy var selectBgView: UIView = {
//        let view = UIView()
//        view.backgroundColor = QMUITheme().commonTextColor(withAlpha: 0.2)
//        
//        let tapGes = UITapGestureRecognizer()
//        tapGes.rx.event.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak view] (ges) in
//            UIView.animate(withDuration: 0.5, animations: {
//                view?.alpha = 0
//            })
//        }).disposed(by: disposeBag)
//        view.addGestureRecognizer(tapGes)
//        
//        return view
//    }()
//    
//    lazy var selectView: UIView = { [unowned self] in
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 184))
//        view.backgroundColor = .white
//        view.layer.qmui_maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        view.layer.cornerRadius = 20
//        
//        let label = QMUILabel()
//        label.text = YXLanguageUtility.kLang(key: "history_time_limit")
//        label.textColor = QMUITheme().textColorLevel1()
//        view.addSubview(label)
//        label.snp.makeConstraints({ (make) in
//            make.top.left.equalTo(14)
//        })
//        
//        let flags: [YXDateFlag] = [.week, .month, .threeMonth, .year, .thisYear]
//        
//        var buttons = [QMUIButton]()
//        flags.enumerated().forEach({ (offset, flag) in
//            let button = QMUIButton()
//            button.setTitle(flag.text, for: .normal)
//            button.titleLabel?.font = .systemFont(ofSize: 14)
//            button.titleLabel?.adjustsFontSizeToFitWidth = true
//            button.titleLabel?.minimumScaleFactor = 0.3
//            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
//            button.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().commonTextColor(withAlpha: 0.2), size: CGSize(width: 35, height: 35), lineWidth: 1, cornerRadius: 4)?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)), for: .normal)
//            button.setBackgroundImage(UIImage.qmui_image(withStroke: QMUITheme().themeTextColor(), size: CGSize(width: 35, height: 35), lineWidth: 1, cornerRadius: 4)?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)), for: .selected)
//            button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
//            button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
//            
//            if let dateFlag = viewModel.dateFlag.value , flag == dateFlag {
//                button.isSelected = true
//            } else if viewModel.dateFlag.value == nil, flag == .month {
//                button.isSelected = true
//            }
//            
//            button.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self, weak button] (_) in
//                guard let strongSelf = self else { return }
//                
//                buttons.forEach({ (btn) in
//                    btn.isSelected = false
//                })
//                button?.isSelected = true
//                strongSelf.viewModel.dateFlag.accept(flag)
//                
//                UIView.animate(withDuration: 0.3, animations: {
//                    strongSelf.selectBgView.alpha = 0
//                })
//            }).disposed(by: disposeBag)
//            
//            view.addSubview(button)
//            buttons.append(button)
//        })
//        
//        Array(buttons.prefix(4)).snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 10, leadSpacing: 14, tailSpacing: 14)
//        Array(buttons.prefix(4)).snp.makeConstraints({ (make) in
//            make.top.equalTo(label.snp.bottom).offset(14)
//            make.height.equalTo(35)
//        })
//        
//        if let firstButton = buttons.first, let lastButton = buttons.last {
//            lastButton.snp.makeConstraints({ (make) in
//                make.bottom.equalTo(view.snp.bottom).offset(-54)
//                make.left.width.height.equalTo(firstButton)
//            })
//        }
//        
//        return view
//        }()
//    
//    typealias ViewModelType = YXOrderBondListViewModel
//    
//    var viewModel: YXOrderBondListViewModel!
//    
//    var networkingHUD: YXProgressHUD! = YXProgressHUD()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        bindHUD()
//        self.title = YXLanguageUtility.kLang(key: "hold_orders")
//        
//        initTitleView()
//        
//        view.addSubview(selectBgView)
//        selectBgView.alpha = 0
//        selectBgView.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalTo(view)
//            if #available(iOS 11.0, *) {
//                make.top.equalTo(view.safeArea.top)
//            } else {
//                make.top.equalTo(YXConstant.navBarHeight())
//            }
//        }
//        
//        selectBgView.addSubview(selectView)
//        
//        setupRefreshHeader(tableView)
//        
//        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [weak self] (endRefreshing) in
//            self?.viewModel.hudSubject.onNext(.hide)
//            if endRefreshing == .error || endRefreshing == .hasDataWithError {
//                self?.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
//            }
//        }).disposed(by: disposeBag)
//        
//        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [weak self] (endRefreshing) in
//            if endRefreshing == .error || endRefreshing == .hasDataWithError {
//                self?.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
//            }
//        }).disposed(by: disposeBag)
//        
//        
//        //导航栏左侧 - 返回
//        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
//        backItem.rx.tap.bind { [weak self] in
//            guard let `self` = self else { return }
//            if self.isFromAAStock {
//                self.isFromAAStock = false
//                //是否禁止使用修正,默认为NO
//                UINavigationConfig.shared().sx_disableFixSpace = true
//            }
//            self.navigationController?.popViewController(animated: true)
//        }.disposed(by: disposeBag)
//        self.navigationItem.leftBarButtonItems = [backItem]
//        
//    }
//    
//    override func didInitialize() {
//        super.didInitialize()
//    }
//    
//    func initTitleView() {
//        if let vc = self.parent, let mixOrderListVC = vc as? YXMixOrderListViewController {
//            mixOrderListVC.titleView?.style = .subTitleVertical
//            mixOrderListVC.titleView?.accessoryType = .disclosureIndicator
//            mixOrderListVC.titleView?.subAccessoryView = UIImageView(image: UIImage(named: "icon_pull_down"))
//            mixOrderListVC.titleView?.subAccessoryViewOffset = CGPoint(x: -2, y: 0)
//            mixOrderListVC.titleView?.verticalSubtitleFont = .systemFont(ofSize: 12)
//            mixOrderListVC.titleView?.needsAccessoryPlaceholderSpace = true
//            mixOrderListVC.titleView?.subtitleLabel.textColor = QMUITheme().textColorLevel1()
//            mixOrderListVC.titleView?.needsSubAccessoryPlaceholderSpace = false
//            
//            mixOrderListVC.titleView?.isUserInteractionEnabled = true
//            mixOrderListVC.titleView?.rx.controlEvent(.touchUpInside).asControlEvent().takeUntil(rx.deallocated).filter({ [weak mixOrderListVC](_) -> Bool in
//                mixOrderListVC?.tabView.selectedIndex == 1
//            }).subscribe(onNext: { [weak self] (_) in
//                guard let strongSelf = self else { return }
//                UIView.animate(withDuration: 0.3, animations: {
//                    strongSelf.selectBgView.alpha = 1
//                })
//                
//            }).disposed(by: disposeBag)
//        }else {
//            titleView?.style = .subTitleVertical
//            titleView?.accessoryType = .disclosureIndicator
//            titleView?.subAccessoryView = UIImageView(image: UIImage(named: "icon_pull_down"))
//            titleView?.subAccessoryViewOffset = CGPoint(x: -2, y: 0)
//            titleView?.verticalSubtitleFont = .systemFont(ofSize: 12)
//            titleView?.needsAccessoryPlaceholderSpace = true
//            titleView?.subtitleLabel.textColor = QMUITheme().textColorLevel1()
//            titleView?.needsSubAccessoryPlaceholderSpace = false
//            
//            titleView?.isUserInteractionEnabled = true
//            titleView?.rx.controlEvent(.touchUpInside).asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (_) in
//                guard let strongSelf = self else { return }
//                
//                UIView.animate(withDuration: 0.3, animations: {
//                    strongSelf.selectBgView.alpha = 1
//                })
//                
//            }).disposed(by: disposeBag)
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if viewModel.dateFlag.value == nil {
//            viewModel.dateFlag.accept(.month)
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        viewModel.dateFlag.asDriver().drive(onNext: { [weak self] (dateFlag) in
//            guard let strongSelf = self else { return }
//            guard let flag = dateFlag else { return }
//            
//            if let vc = strongSelf.parent, let mixOrderListVC = vc as? YXMixOrderListViewController {
//                mixOrderListVC.titleView?.subtitle = flag.text
//            }else {
//                strongSelf.titleView?.subtitle = flag.text
//            }
//            
//            strongSelf.viewModel.hudSubject.onNext(.loading(nil, false))
//            if let refreshingBlock = strongSelf.refreshHeader.refreshingBlock {
//                refreshingBlock()
//            }
//        }).disposed(by: disposeBag)
//    }
//    
//    override func initTableView() {
//        super.initTableView()
//        
//        view.backgroundColor = .white
//        tableView.dataSource = nil
//        
//        let CellIdentifier = NSStringFromClass(YXOrderBondListCell.self)
//        let ExpandCellIdentifier = NSStringFromClass(YXHKTradeExpandCell.self)
//        
//        let dataSource = RxTableViewSectionedReloadDataSource<YXTimeSection<YXOrderBondListViewModel.IdentifiableModel>>(
//            configureCell: { [weak self] ds, tv, ip, item in
//                guard let strongSelf = self else { return YXOrderBondListCell(style: .default, reuseIdentifier: CellIdentifier) }
//                
//                if item.identity == "" {
//                    if let cell = tv.dequeueReusableCell(withIdentifier: ExpandCellIdentifier) as? YXHKTradeExpandCell {
//                        
//                        cell.isUS = false
//                        cell.isCN = false
//                        
//                        let exchangeType =  self?.viewModel.exchangeType ?? .hk
//                        if exchangeType == .us {
//                            cell.isUS = true
//                            cell.isCN = false
//                        } else if exchangeType != .hk {
//                            cell.isUS = false
//                            cell.isCN = true
//                        }
//                        
//                        cell.isOdd = false
//                        
//                        cell.isFinal = false
//                        if let finalFlag = strongSelf.viewModel.selectedItem?.finalStatus {
//                            cell.isFinal = finalFlag
//                        }
//                        
//                        cell.tradeType = .order
//                        return cell
//                    }
//                    
//                    let cell = YXHKTradeExpandCell(style: .default, reuseIdentifier: ExpandCellIdentifier) as YXHKTradeExpandCell
//                    
//                    let exchangeType =  self?.viewModel.exchangeType ?? .hk
//                    if exchangeType == .us {
//                        cell.isUS = true
//                        cell.isCN = false
//                    } else if exchangeType != .hk {
//                        cell.isUS = false
//                        cell.isCN = true
//                    }
//                    
//                    cell.isOdd = false
////                    if let flag = strongSelf.viewModel.selectedItem?.flag, flag == .odd {
////                        cell.isOdd = true
////                    }
//                    cell.isFinal = false
//                    if let finalFlag = strongSelf.viewModel.selectedItem?.finalStatus {
//                        cell.isFinal = finalFlag
//                    }
//                    
////                    if let dayEnd = strongSelf.viewModel.selectedItem?.dayEnd, dayEnd == 1 {
////                        cell.isFinal = true
////                    }
//                    
////                    if strongSelf.viewModel.selectedItem?.sessionType ?? 0 > 0 {
////                        cell.greyFlag = true
////                    } else {
////                        cell.greyFlag = false
////                    }
//
//                    
//                    cell.tradeType = .order
//                    //【订单明细】
//                    _ = cell.orderButton.rx.tap.asControlEvent().takeUntil(strongSelf.rx.deallocated).subscribe(onNext: { [weak self] (_) in
//                        guard let strongSelf = self else { return }
//                        
//                        if let item = strongSelf.viewModel.selectedItem {
//                            let orderNo = Int64(item.orderNo ?? "")
//                            let context = YXNavigatable(viewModel: YXBondDetailViewModel(orderNo: orderNo ?? 0))
//                            strongSelf.viewModel.navigator.push(YXModulePaths.bondOrderDetail.url, context:context)
//                        }
//                    })
//                    
//                    //【取消订单】
//                    _ = cell.recallButton.rx.tap.asControlEvent().takeUntil(strongSelf.rx.deallocated).subscribe(onNext: { [weak self](_) in
//                        guard let `self` = self else { return }
//                        if let item = self.viewModel.selectedItem {
//                            self.showCancelConfirmAlert {
//                                YXUserUtility.validateTradePwd(inViewController: self, successBlock: { [weak self](token) in
//                                    guard let `self` = self else { return }
//                                    self.cancelBondOrder(orderNo: item.orderNo ?? "", tradeToken: token ?? "")
//                                }, failureBlock: nil, isToastFailedMessage: nil, needToken: true)
//                            }
//                            
//                        }
//
//                        var trackProperties = self.viewModel.trackProperties()
//                        trackProperties[YXSensorAnalyticsPropsConstants.propViewId()] = "trade_order_cancel"
//                        trackProperties[YXSensorAnalyticsPropsConstants.propViewName()] = "交易订单-撤单"
//                        trackProperties[YXSensorAnalyticsPropsConstants.propViewPage()] = self.viewModel.exchangeType == .us ? "户口-美股" : "户口-港股"
//
//                        YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: trackProperties)
//                        
//                    })
//                    
//                    return cell
//                }
//                
//                if let cell = tv.dequeueReusableCell(withIdentifier: CellIdentifier) as? YXOrderBondListCell {
//                    cell.order.accept(item)
//                    return cell
//                }
//                
//                let cell = YXOrderBondListCell(style: .default, reuseIdentifier: CellIdentifier)
//                cell.order.asDriver().drive(onNext: { [weak cell] (order) in
//                    cell?.nameLabel.setStockName(order?.bondName ?? "--")
//                
//                    if let value = order?.minFaceValue {
//                        cell?.symbolLabel.text = "\(YXLanguageUtility.kLang(key: "bond_min_startup"))USD" + String(value) + "/" + YXLanguageUtility.kLang(key: "copies")
//                    }
//                    
//                    let formatter = NumberFormatter()
//                    formatter.locale = Locale(identifier: "zh")
//                    formatter.positiveFormat = "###,##0";
//                    if let entrustPrice = order?.entrustPrice {
//                        cell?.costLabel.text = String(format:"%.4f", Double(entrustPrice) ?? 0.0)
//                    }  else {
//                        cell?.costLabel.text = "--"
//                    }
////                    if let entrustProp = item.entrustProp, entrustProp == "d" {
////                        cell?.costLabel.text = "--"
////                    }
//                    if let failReason = order?.failedRemark, failReason.count > 0 {
//                        cell?.failReasonLabel.isHidden = false
//                        cell?.failReasonLabel.text = YXLanguageUtility.kLang(key: "fail_reason") + ":" + failReason
//                    }else {
//                        cell?.failReasonLabel.isHidden = true
//                    }
//                    
//                    if let entrustAmount = order?.entrustPartQuantity {
//                        cell?.numLabel.text = (formatter.string(from: NSNumber(value: Int64(entrustAmount) ?? 0)) ?? "0") + YXLanguageUtility.kLang(key: "copies")
//                    } else {
//                        cell?.numLabel.text = "--"
//                    }
//                    
////                    if let flag = order?.flag, flag != .normal {
////                        cell?.flagLabel.text = flag.text
////                        cell?.flagLabel.textColor = flag.textColor
////                        cell?.flagLabel.layer.borderColor = flag.textColor?.cgColor
////
////                        cell?.flagLabel.isHidden = false
////                    } else {
////                        cell?.flagLabel.isHidden = true
////                    }
//                    
//                    cell?.statusNameLabel.text = order?.externalStatusName
//                    // 买卖方向,委托类型
//                    
//                    var color = UIColor.qmui_color(withHexString: "#F1B92D")
//                    if let direct = order?.direction, direct.type == 1 {
//                        color = QMUITheme().mainThemeColor()
//                    }
//                    
//                    cell?.entrustDirectionLabel.text = order?.orderDirection
//                    cell?.entrustDirectionLabel.textColor = color
//                    
//                }).disposed(by: strongSelf.disposeBag)
//                
//                cell.order.accept(item)
//                
//                return cell
//        })
//        
//        dataSource.titleForHeaderInSection = { ds, index in
//            ds.sectionModels[index].timeString
//        }
//        
//        viewModel.sectionDataSouce
//            .bind(to: tableView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
//        
//        
//        tableView.rx.itemSelected.asDriver().drive(onNext: { [weak self] (indexPath) in
//            guard let strongSelf = self else { return }
//            var sections = strongSelf.viewModel.sectionDataSouce.value
//            let order = sections[indexPath.section].items[indexPath.row]
//            guard order.orderNo != nil else { return }
//
//            if let selectedIndexPath = strongSelf.viewModel.selectedIndexPath {
//                var array = sections[selectedIndexPath.section].items
//                array.remove(at: selectedIndexPath.row + 1)
//                sections[selectedIndexPath.section].items = array
//                if selectedIndexPath == indexPath {
//                    strongSelf.viewModel.selectedIndexPath = nil
//                    strongSelf.viewModel.selectedItem = nil
//                    strongSelf.viewModel.sectionDataSouce.accept(sections)
//                } else {
//                    var sourceIndexPath = indexPath
//                    if sourceIndexPath.section == selectedIndexPath.section, sourceIndexPath.row > selectedIndexPath.row {
//                        sourceIndexPath = IndexPath(row: sourceIndexPath.row - 1, section: sourceIndexPath.section)
//                    }
//                    
//                    var array = sections[sourceIndexPath.section].items
//                    strongSelf.viewModel.selectedIndexPath = sourceIndexPath
//                    strongSelf.viewModel.selectedItem = array[sourceIndexPath.row]
//                    array.insert(YXBondOrderModel(), at: sourceIndexPath.row + 1)
//                    sections[sourceIndexPath.section].items = array
//                    strongSelf.viewModel.sectionDataSouce.accept(sections)
//                    strongSelf.tableView.scrollToRow(at: IndexPath(row: sourceIndexPath.row + 1, section: sourceIndexPath.section), at: .none, animated: false)
//                }
//            } else {
//                strongSelf.viewModel.selectedIndexPath = indexPath
//                strongSelf.viewModel.selectedItem = order
//                
//                var array = sections[indexPath.section].items
//                array.insert(YXBondOrderModel(), at: indexPath.row + 1)
//                sections[indexPath.section].items = array
//                strongSelf.viewModel.sectionDataSouce.accept(sections)
//                strongSelf.tableView.scrollToRow(at: IndexPath(row: indexPath.row + 1, section: indexPath.section), at: .none, animated: false)
//            }
//        }).disposed(by: disposeBag)
//    }
//    
//    //展示确认撤销弹窗
//    func showCancelConfirmAlert(completed :(()->Void)? = nil) {
//        
//        let title = YXLanguageUtility.kLang(key: "trading_alert_cancel_order_title")
//        let confirmBtnTitle = YXLanguageUtility.kLang(key: "trading_alert_cancel_order_confirm")
//        
//        let alertView: YXAlertView = YXAlertView(title: title, message: nil)
//        alertView.clickedAutoHide = false
//       let alertController = YXAlertController.init(alert: alertView)!
//        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView](action) in
//            alertView?.hide()
//        }))
//        
//        alertView.addAction(YXAlertAction(title: confirmBtnTitle, style: .default, handler: { [weak alertView, weak alertController](action) in
//            alertController?.dismissComplete = {
//                if let action = completed {
//                    action()
//                }
//            }
//            alertView?.hide()
//            
//        }))
//        
//        let vc = UIViewController.current()
//        vc.present(alertController, animated: true, completion: nil)
//    }
//    
//    func cancelBondOrder(orderNo: String, tradeToken: String) {
//        self.viewModel.hudSubject.onNext(.loading(nil, false))
//        self.viewModel.services.tradeService.request(.bondCancelOrder(orderNo, tradeToken), response: { [weak self](response: YXResponseType<JSONAny>) in
//            guard let `self` = self else { return }
//            self.viewModel.hudSubject.onNext(.hide)
//            switch response {
//            case .success(let result, let code):
//                if code == .success {
//                    self.viewModel.dateFlag.accept(self.viewModel.dateFlag.value ?? .month)
//                } else {
//                    if let msg = result.msg {
//                        self.viewModel.hudSubject.onNext(.message(msg, false))
//                    }
//                }
//            case .failed(_):
//                self.viewModel.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
//            }
//        })
//    }
//
//    
//    override func emptyRefreshButtonAction() {
//        viewModel.hudSubject.onNext(.loading(nil, false))
//        if let refreshingBlock = refreshHeader.refreshingBlock {
//            refreshingBlock()
//        }
//    }
//    
//    override func showNoDataEmptyView() {
//        super.showNoDataEmptyView()
//        self.emptyView?.imageView.image = UIImage.init(named: "empty_noOrder")
//        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "hold_no_order"))
//    }
//
//}
//
//extension YXOrderBondListViewController {
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let selectedIndexPath = self.viewModel.selectedIndexPath,  indexPath.row == selectedIndexPath.row + 1, indexPath.section == selectedIndexPath.section {
//            return 64
//        } else {
//            let sections = self.viewModel.sectionDataSouce.value
//            let order = sections[indexPath.section].items[indexPath.row]
//        
//            if let reason = order.failedRemark, reason.count > 0 {
//                return 92
//            }else {
//                return 72
//            }
//            
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        50
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = .white
//        let label = UILabel(frame: CGRect(x: 18, y: 0, width: 300, height: 50))
//        label.text = self.viewModel.sectionDataSouce.value[section].timeString
//        label.textColor = QMUITheme().textColorLevel1()
//        label.font = .systemFont(ofSize: 20)
//        view.addSubview(label)
//        return view
//    }
//}
