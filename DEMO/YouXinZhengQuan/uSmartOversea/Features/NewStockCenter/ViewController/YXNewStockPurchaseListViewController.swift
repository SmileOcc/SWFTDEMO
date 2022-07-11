//
//  YXNewStockPurchaseListViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YXKit

import MessageUI

class YXNewStockPurchaseListViewController: YXHKTableViewController, ViewModelBased, HUDViewModelBased, RefreshViweModelBased {
    
    var viewModel: YXNewStockPurchaseListViewModel! = YXNewStockPurchaseListViewModel()
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    lazy var refreshHeader: YXRefreshHeader = {
        YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter? = {
        YXRefreshAutoNormalFooter()
    }()
    
    let ipoReuseIdentifier = "YXNewStockPurcahseListCell_IPO"
    let ecmReuseIdentifier = "YXNewStockPurcahseListCell_ECM"
    let depositReuseIdentifier = "YXNewStockPurcahseListCell_DEPOSIT"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.title = YXLanguageUtility.kLang(key: "newStock_purchase_list")
        bindHUD()
        bindTableView()
        initNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    fileprivate func initNavigationBar() {
        
        navigationItem.rightBarButtonItems = [messageItem]
    }
    
    lazy var tableHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 7)
        return view
    }()
    
    @objc func handleLeftAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func bindTableView() {
        
        self.view.backgroundColor = QMUITheme().backgroundColor()
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().backgroundColor()
        tableView.tableHeaderView = tableHeaderView
        
        setupRefreshHeader(tableView)
        
        viewModel.hudSubject.onNext(.loading(nil, false))
        tableView.dataSource = nil
        viewModel.dataSource.bind(to: tableView!.rx.items) { [unowned self] (tableView, row, item) in
            var type: YXNewStockPurcahseListCell.SubsListCellType = .ipo
            if item.recordType == 1 || item.applyType == YXNewStockSubsType.internalAppointmentSubs.rawValue {
                type = .deposit
            } else if item.applyType == YXNewStockSubsType.internalSubs.rawValue || item.applyType == YXNewStockSubsType.reserveSubs.rawValue {
                type = .ecm
            } else {
                type = .ipo
            }
            
            var cell: UITableViewCell?
            if type == .ipo {
                //认购记录的cell
                cell = tableView.dequeueReusableCell(withIdentifier: self.ipoReuseIdentifier)
                if cell == nil {
                    cell = YXNewStockPurcahseListCell(reuseIdentifier: self.ipoReuseIdentifier, type: type, exchangeType: self.viewModel.exchangeType)
                }
                let tableCell:YXNewStockPurcahseListCell = (cell as! YXNewStockPurcahseListCell)
                tableCell.refreshUI(model: item)
                
            } else if type == .ecm {
               cell = tableView.dequeueReusableCell(withIdentifier: self.ecmReuseIdentifier)
               if cell == nil {
                   cell = YXNewStockPurcahseListCell(reuseIdentifier: self.ecmReuseIdentifier, type: type, exchangeType: self.viewModel.exchangeType)
               }
               let tableCell = (cell as! YXNewStockPurcahseListCell)
               tableCell.refreshUI(model: item)
               
            } else {
               cell = tableView.dequeueReusableCell(withIdentifier: self.depositReuseIdentifier)
               if cell == nil {
                   cell = YXNewStockPurcahseListCell(reuseIdentifier: self.depositReuseIdentifier, type: type, exchangeType: self.viewModel.exchangeType)
               }
               let tableCell = (cell as! YXNewStockPurcahseListCell)
               tableCell.refreshUI(model: item)
               
            }
            
            if item.xchannel == 1 {
                let tableCell = (cell as! YXNewStockPurcahseListCell)
                if let order = self.featchOrderModel(with: item) {
                    tableCell.refreshGroupInfo(with: order)
                }
                
                tableCell.pinTuanBlock = { [unowned self] (order:YXUserGroupInfoOrderList,type) in
                    self.pinTuanShare(with: order,type:type)
                }
            }
            return cell!
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(YXNewStockPurchaseListDetailModel.self)
            .subscribe(onNext: { [weak self](model) in
                guard let `self` = self else { return }
                
                var type: YXNewStockPurcahseListCell.SubsListCellType = .ipo
                if model.recordType == 1 || model.applyType == YXNewStockSubsType.internalAppointmentSubs.rawValue {
                    type = .deposit
                } else if model.applyType == YXNewStockSubsType.internalSubs.rawValue || model.applyType == YXNewStockSubsType.reserveSubs.rawValue {
                    type = .ecm
                } else {
                    type = .ipo
                }
                if type == .ipo {
                    if let applyID = model.applyID {
                        let context: [String : Any] = [
                            "applyID" : applyID,
                            "exchangeType" : self.viewModel.exchangeType,
                            "applyType" : YXNewStockSubsType.subscriptionType(model.applyType)
                        ]
                        self.viewModel.navigator.push(YXModulePaths.newStockIPOListDetail.url, context: context)
                    }
                } else if type == .ecm {
                    if let applyID = model.applyID {
                        
                        if self.viewModel.exchangeType == .hk {
                            let dic: [String: Any] = [
                                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_NEWSTOCK_LIST_DETAIL_URL(applyID)
                            ]
                            self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                        } else {
                            let context: [String : Any] = [
                                "applyID" : applyID,
                                "exchangeType" : self.viewModel.exchangeType,
                                "applyType" : YXNewStockSubsType.internalSubs
                            ]
                            self.viewModel.navigator.push(YXModulePaths.newStockECMListDetail.url, context: context)
                        }
                    }
                } else {
                    
                    if let applyID = model.applyID {
                        
                        let dic: [String: Any] = [
                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_NEWSTOCK_BOOKING_DETAIL_URL(applyID)
                        ]
                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    }
                }
                
            }).disposed(by: rx.disposeBag)
        
        //头部刷新
        viewModel.endHeaderRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
        }).disposed(by: rx.disposeBag)
        
        //底部刷新
        viewModel.endFooterRefreshStatus?.asDriver().drive(onNext: { [unowned self] (status) in
            if status == .error {
                self.networkingHUD.showMessage(YXLanguageUtility.kLang(key: "common_net_error"), in: self.view, hideAfter: 1.5)
            }
        }).disposed(by: rx.disposeBag)
        
        //有团购订单
        viewModel.xchannelArrSubject.subscribe(onNext: { [unowned self] (xchannelArr:[YXNewStockPurchaseListDetailModel]) in
            if xchannelArr.count > 0 {
                var orderList = [ [String: Any] ]()
                for model in xchannelArr {
                    var orderDict = [String: Any]()
                    orderDict["biz_id"] = model.applyID
                    orderDict["order_id"] = model.applyID
                    
                    var type: YXNewStockPurcahseListCell.SubsListCellType = .ipo
                    if model.recordType == 1 || model.applyType == YXNewStockSubsType.internalAppointmentSubs.rawValue {
                        type = .deposit
                    } else if model.applyType == YXNewStockSubsType.internalSubs.rawValue || model.applyType == YXNewStockSubsType.reserveSubs.rawValue {
                        type = .ecm
                    } else {
                        type = .ipo
                    }
                    if type == .ecm {
                        orderDict["biz_type"] = 1
                    } else {
                        orderDict["biz_type"] = 0
                    }
                    orderList.append(orderDict)
                    
                }
                
                /* http://szshowdoc.youxin.com/web/#/32?page_id=802 -->
                拼团 --> 认购记录（批量）  --> zt-group-apiserver/api/v1/group/batchGet-user-group-info  */
                let api : YXNewStockAPI = .batchGetUserGroupInfo(["biz_order_list":orderList])
                
                self.viewModel.services.request(api, response: self.viewModel.groupInfoResponse).disposed(by: self.rx.disposeBag)
            }
        }).disposed(by: rx.disposeBag)
        
        
        viewModel.groupInfoSubject.subscribe(onNext: { [unowned self] (hasNum) in
            
            if hasNum {
                self.tableView.reloadData()
            }
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func emptyRefreshButtonAction() {
        viewModel.hudSubject.onNext(.loading(nil, false))
        if let refreshingBlock = refreshHeader.refreshingBlock {
            refreshingBlock()
        }
    }
    
    override func showErrorEmptyView() {
        super.showErrorEmptyView()
        
        tableHeaderView.isHidden = true
    }
    
    override func showNoDataEmptyView() {
        super.showNoDataEmptyView()
        tableHeaderView.isHidden = true
        self.emptyView?.setImage(UIImage(named: "empty_noOrder"))
    }
    
    override func hideEmptyView() {
        super.hideEmptyView()
        tableHeaderView.isHidden = false
    }
    
    
    fileprivate func featchOrderModel(with item:YXNewStockPurchaseListDetailModel) -> YXUserGroupInfoOrderList? {
        
        var orderList: YXUserGroupInfoOrderList?
        if self.viewModel.groupInfoOrderList.count > 0 {
            
            for temp in self.viewModel.groupInfoOrderList {
                if temp.orderIDStr == item.applyID {
                    orderList = temp
                    orderList?.productName = item.stockName ?? ""
                }
            }
        }
        return orderList
    }
    
}

extension YXNewStockPurchaseListViewController {
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = 216
        if indexPath.row < viewModel.dataSource.value.count {
            let model = viewModel.dataSource.value[indexPath.row]
            
            if model.recordType == 1 || model.applyType == YXNewStockSubsType.internalAppointmentSubs.rawValue {
                height = 186
            } else if model.applyType == YXNewStockSubsType.internalSubs.rawValue || model.applyType == YXNewStockSubsType.reserveSubs.rawValue {
                height = 216
                if self.viewModel.exchangeType == .hk {
                    height += 30
                }
            } else {
                height = 216
                if self.viewModel.exchangeType == .hk {
                    height += 30
                }
            }
            if model.xchannel == 1 {
                if let order = self.featchOrderModel(with: model) {
                    if order.status == 1 || order.status == 2 || order.status == 3 {
                        height += (45 + 19 + 20)
                    }
                }
            }
        }
        
        return height
    }
    
}



extension YXNewStockPurchaseListViewController {
    
    func pinTuanShare(with model: YXUserGroupInfoOrderList,type: YXNewStockPurcahseListCell.SubsListCellType) {
        
        let bitId = model.bizIDStr ?? ""
        
        let groupId = model.groupID ?? 0
        let orderId = model.orderIDStr ?? ""
        let pageUrl = YXH5Urls.YX_PIN_TUAN_SHARING_URL(with: bitId, orderId:orderId, groupId: groupId, appType:model.appType)
        
        let image = UIImage(named: "hold_pin_tuan_share_img")!
        
        let title = String(format: YXLanguageUtility.kLang(key: "pin_tuan_share_title"), model.productName)
        
        let text = YXLanguageUtility.kLang(key: "pin_tuan_share_desc")
        
        let url = URL(string: pageUrl)
            
        // 分享结束后的回调
       let shareResultBlock: (Bool) -> Void = {(result) in
           
       }
       
       //MARK: section0
       var section0_items: [QMUIMoreOperationItemView] = []
       
       // 1.Whats app
       if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
           let whatsapp = QMUIMoreOperationItemView(image: UIImage(named: "share-whats"), title:YXShareSDKHelper.title(forPlatforms: .typeWhatsApp)) { (controller, itemView) in
                // 点击后执行的block
                controller.hideToBottom()
                
                let shareText = "\(title)\n\n\(text)\n\(pageUrl)"
                YXShareSDKHelper.shareInstance()?.share(.typeWhatsApp, text: shareText, images: nil, url: nil, title: nil, type: .auto, withCallback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
            
           }
           
           section0_items.append(whatsapp)
       }
       
       // 2.facebook
       let fb = QMUIMoreOperationItemView(image: UIImage(named: "share-fb"), title: YXShareSDKHelper.title(forPlatforms: .typeFacebook)) { (controller, itemView) in
           
           // 点击后执行的block
           controller.hideToBottom()
        
            if YXShareSDKHelper.isClientIntalled(.typeFacebook) {
                YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: text, images: image, url: url, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
                
            } else {
                YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: text, images: nil, url: url, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
            }
       }
       
       section0_items.append(fb)
       
       // 3.facebook messenger
       if YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger) {
           
           let fbMessenger = QMUIMoreOperationItemView(image: UIImage(named: "share-fb-messenger"), title: YXShareSDKHelper.title(forPlatforms: .typeFacebookMessenger)) { (controller, itemView) in
               
               // 点击后执行的block
               controller.hideToBottom()
            
                YXShareSDKHelper.shareInstance()?.share(.typeFacebookMessenger, text: text, images: image, url: url, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
           }
           
           section0_items.append(fbMessenger)
       }
       
       
       // 4.wechat
       if YXShareSDKHelper.isClientIntalled(.typeWechat) {
           // 已安装微信
           let wechat = QMUIMoreOperationItemView(image: UIImage(named: "share-wechat"), title: YXShareSDKHelper.title(forPlatforms: .typeWechat)) { (controller, itemView) in
               // 点击后执行的block
               controller.hideToBottom()
                YXShareSDKHelper.shareInstance()?.share(.typeWechat, text: text, images: image, url: url, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
           }
           
           let moment = QMUIMoreOperationItemView(image: UIImage(named: "share-moments"), title: YXShareSDKHelper.title(forPlatforms: .subTypeWechatTimeline)) { (controller, itemView) in
               
               // 点击后执行的block
               controller.hideToBottom()
                YXShareSDKHelper.shareInstance()?.share(.subTypeWechatTimeline, text: text, images: image, url: url, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                    shareResultBlock(success)
                })
           }
           
           section0_items.append(wechat)
           section0_items.append(moment)
       }
       
       // 5.twitter
       let twitter = QMUIMoreOperationItemView(image: UIImage(named: "share-twitter"), title: YXShareSDKHelper.title(forPlatforms: .typeTwitter)) { (controller, itemView) in
           // 点击后执行的block
           controller.hideToBottom()
            YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: text, images: image, url: url, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                shareResultBlock(success)
            })
       }
       
       section0_items.append(twitter)
       
       // 6.短信
       let message = QMUIMoreOperationItemView(image: UIImage(named: "share-message"), title: YXLanguageUtility.kLang(key: "share_message")) { [weak self] (controller, itemView) in
           guard let `self` = self else { return }
           
           // 点击后执行的block
           controller.hideToBottom()
        
            
            let content = "\(title)\n\n\(text)\n\(pageUrl)"
            self.shareToMessage(content: content, sharingImage: image, imageUrlString: nil, shareResultBlock: shareResultBlock)
       }
       
       section0_items.append(message)
       
       //MARK: section1
       var section1_items: [QMUIMoreOperationItemView] = []
       
       // 2.更多選項
       let more = QMUIMoreOperationItemView(image: UIImage(named: "share-more"), title: YXLanguageUtility.kLang(key: "share_more")) { [weak self] (controller, itemView) in
           // 点击后执行的block
           guard let `self` = self else { return }
           
           // 点击后执行的block
           controller.hideToBottom()
        if let tempUrl = url {
            self.shareToMore(activityItems: [title + "\n\n" + text, image, tempUrl], shareResultBlock: shareResultBlock)
        }
        
       }
       
       section1_items.append(more)
       
        
        let vc = YXMoreOperationViewController()
        vc.contentEdgeInsets = UIEdgeInsets(top: 0, left: uniHorLength(10), bottom: YXConstant.deviceScaleEqualToXStyle() ? 0 : 34, right: uniHorLength(10))
        vc.items = [section0_items, section1_items]
        vc.showFromBottom()
    }
    
    //MARK: 1.分享到短信
    fileprivate func shareToMessage(content: String?, sharingImage: UIImage?, imageUrlString: String?, shareResultBlock: ((Bool) -> Void)?) {
        // 分享短信
        // 1.判断能不能发短信
        if MFMessageComposeViewController.canSendText() {
            // 开始转菊花，进行图片下载
            
            let c = MFMessageComposeViewController()
            c.shareResultBlock = shareResultBlock
            c.body = content
            c.messageComposeDelegate = self
            
            let presentBlock: (_ image:UIImage?) -> Void = {[weak c,self] (image) in
                guard let strongC = c else {return}
                if let data = image?.pngData(), data.count > 0 {
                    strongC.addAttachmentData(data, typeIdentifier: "public.png", filename: "icon.png")
                    self.present(strongC, animated: true, completion: nil)
                }
                else if let data = image?.jpegData(compressionQuality: 1), data.count > 0 {
                    strongC.addAttachmentData(data, typeIdentifier: "public.jpeg", filename: "icon.png")
                    self.present(strongC, animated: true, completion: nil)
                }
                else {
                    self.present(strongC, animated: true, completion: nil)
                }
            }
            if MFMessageComposeViewController.canSendAttachments() {
                // 1. 仅支持jpg、png图片的短信分享
                // 2. 图片需要做缓存
                // 3. 图片下载完成后，present vc && 隐藏菊花
                // 4. 图片下载失败后，present vc (without image) && 隐藏菊花
                // 5. 没有需要分享的图片链接时，不需要分享图片
                // https://developer.apple.com/documentation/messageui/mfmessagecomposeviewcontroller/1614075-issupportedattachmentuti
                if MFMessageComposeViewController.isSupportedAttachmentUTI("public.png") ||
                    MFMessageComposeViewController.isSupportedAttachmentUTI("public.jpeg") {
                    if let sharingImage = sharingImage {
                        presentBlock(sharingImage)
                    } else {
                        if let imageUrlString = imageUrlString,imageUrlString.isEmpty == false {
                            self.networkingHUD.showLoading("", in: self.view)
                            let temp = URL(string: imageUrlString)!
                            SDWebImageManager.shared.loadImage(with: temp, options: SDWebImageOptions.retryFailed, progress: { (_, _, _) in
                                
                            }) { [weak self] (image, data, error, cacheType, finished, imageURL) in
                                self?.networkingHUD.hideHud()
                                presentBlock(image)
                            }
                        } else {
                            presentBlock(nil)
                        }
                    }
                } else {
                    presentBlock(nil)
                }
            } else {
                presentBlock(nil)
            }
        } else {
            // 不能发短信时
            shareResultBlock?(false)
            self.viewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "share_not_support_message"), false))
        }
    }
    
    //MARK: 2.分享到更多
    fileprivate func shareToMore(activityItems: [Any], shareResultBlock: ((Bool) -> Void)?) {
        
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        let completeBlock: UIActivityViewController.CompletionWithItemsHandler = { [weak vc] (activityType, completed, items, error) in
            
            guard let strongVC = vc else { return }
            
            shareResultBlock?(completed)
            
            if completed {
                log(.verbose, tag: kModuleViewController, content: "information: send success")
            } else {
                log(.verbose, tag: kModuleViewController, content: "information: send failed")
            }
            strongVC.dismiss(animated: true, completion: nil)
        }
        
        vc.completionWithItemsHandler = completeBlock
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension YXNewStockPurchaseListViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result {
        case .sent:
            controller.shareResultBlock!(true)
        case .failed:
            controller.shareResultBlock!(false)
        default:
            controller.shareResultBlock!(false)
        }
    }
}

