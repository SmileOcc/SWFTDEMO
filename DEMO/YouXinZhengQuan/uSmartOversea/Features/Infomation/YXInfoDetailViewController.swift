//
//  YXInfoDetailViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MessageUI

class YXInfoDetailViewController: YXWebViewController {
    let YX_INFO_DETAIL_CHANGE_FONT_SIZE_NOTIFICATION_NAME = "info_detail_change_font_size"
    let YX_News_FontSize = "YXNewsFontSize"
    let YX_News_BigFont = "big"
    let YX_News_NormalFont = "normal"

    var infoDetailViewModel: YXInfoDetailViewModel {
        get {
            self.viewModel as! YXInfoDetailViewModel
        }
    }
    
    var needChangeFontSize: Bool? = false
    
    lazy var favorite: QMUIMoreOperationItemView = {
        let favorite = QMUIMoreOperationItemView(image: UIImage(named: "share-unfavorite"), selectedImage: UIImage(named: "share-favorite"), title: YXLanguageUtility.kLang(key: "news_favorite"), selectedTitle: YXLanguageUtility.kLang(key: "news_unfavorite")) { [weak self] (controller, itemView) in
            guard let `self` = self else { return }
            
            // 点击后执行的block
            controller.hideToBottom()
            if YXUserManager.isLogin() {
                if itemView.isSelected {
                    self.getPublishTime().subscribe(onNext: { (publishTime) in
                        
                    }).disposed(by: self.disposeBag)
                } else {
                    self.getPublishTime().subscribe(onNext: { (publishTime) in
                        
                    }).disposed(by: self.disposeBag)
                }
                self.requestCollect(!(itemView.isSelected))
            } else {
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
                self.infoDetailViewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context, from: self.navigationController)
            }
        }
        return favorite
    }()
    
    lazy var font: QMUIMoreOperationItemView = {
        let font = QMUIMoreOperationItemView(image: UIImage(named: "share-small-font"), selectedImage: UIImage(named: "share-large-font"), title: YXLanguageUtility.kLang(key: "news_set_font"), selectedTitle: YXLanguageUtility.kLang(key: "news_set_font")) { [weak self] (controller, itemView) in
            guard let `self` = self else { return }
            
            // 点击后执行的block
            controller.hideToBottom()
            
            self.changeFontSize(itemView.isSelected)
        }
        return font
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YX_INFO_DETAIL_CHANGE_FONT_SIZE_NOTIFICATION_NAME))
            .subscribe(onNext: { [weak self] (ntf) in
                guard let `self` = self else { return }
                
                if let dic = ntf.object as? Dictionary<String, Any>,
                   let webView = self.webView {
                    YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: dic, callback: "changeArticleSize", completionCallback: { (_, _) in
                    })
                }
            }).disposed(by: self.disposeBag)
        
        bindViewModel()
    }
    
    override func initUI() {
        super.initUI()
        
        self.title = YXLanguageUtility.kLang(key: "news_details")
        self.view.backgroundColor = UIColor.white
        if self.infoDetailViewModel.type != .Recommend {
            // 需要字體大小調整
            self.needChangeFontSize = true
        }
        
        let moreItem = UIBarButtonItem.qmui_item(with: UIImage(named: "more") ?? UIImage(), target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [moreItem]
        
        moreItem.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
            
                self.showShareAlert()
            }.disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        
        requestCollectStatus()
        
        self.infoDetailViewModel.isCollectRelay.skip(1).subscribe(onNext: { [weak self] (isCollect) in
            guard let `self` = self else { return }
            
            self.favorite.isSelected = isCollect
        }).disposed(by: self.disposeBag)
    }
    
    func requestCollectStatus() {
        if let newsId = self.infoDetailViewModel.newsId {
            self.infoDetailViewModel.services.newsService
                .request(.isCollect(newsId), response: self.infoDetailViewModel.isCollectResponse)
                .disposed(by: self.disposeBag)
        }
    }
    
    func requestCollect(_ favorite: Bool) {
        if let newsId = self.infoDetailViewModel.newsId {
            self.infoDetailViewModel.services.newsService
                .request(.collect(newsId, collectflag: favorite), response: self.infoDetailViewModel.collectResponse)
                .disposed(by: self.disposeBag)
        }
    }
    
    func changeFontSize(_ big: Bool) {
        let dic: Dictionary<String, Any> = [
            "size" : (big ? YX_News_NormalFont : YX_News_BigFont)
        ]
        
        if let webView = self.webView {
            YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: dic, callback: "changeArticleSize") { [weak self] (jsData, error) in
                guard let `self` = self else { return }
                
                if error == nil {
                    self.font.isSelected = !(self.font.isSelected)
                    MMKV.default().set((self.font.isSelected) ? self.YX_News_BigFont : self.YX_News_NormalFont, forKey: self.YX_News_FontSize)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.YX_INFO_DETAIL_CHANGE_FONT_SIZE_NOTIFICATION_NAME), object: nil)
                } else {
                    self.infoDetailViewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        if let backItem = self.backItem {
            self.navigationItem.leftBarButtonItems = [backItem]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 神策事件：开始记录
        YXSensorAnalyticsTrack.trackTimerStart(withEvent: .ViewScreen)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.getPublishTime().subscribe(onNext: { (publishTime) in
            
        }).disposed(by: self.disposeBag)
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        var fontSize = MMKV.default().string(forKey: YX_News_FontSize, defaultValue: YX_News_NormalFont)
        
        if fontSize == nil {
            fontSize = YX_News_NormalFont
        } else {
            if fontSize == YX_News_BigFont {
                self.font.isSelected = true
            }
        }
        
        if let url = self.infoDetailViewModel.url {
            var urlStr = url
            
            if self.infoDetailViewModel.type != .Recommend,
                let fontSize = fontSize,
                let newsUrl = self.infoDetailViewModel.url {
                urlStr = "\(newsUrl)&fontSize=\(fontSize)"
            }
            
            if !(self.infoDetailViewModel.source?.isEmpty ?? true),
                let source = self.infoDetailViewModel.source {  //self.infoDetailViewModel.source?.count ?? 0 > 0,
                urlStr = "\(urlStr)&source=\(source)"
            }
            
            if !(self.infoDetailViewModel.algorithm?.isEmpty ?? true),
                let algorithm = self.infoDetailViewModel.algorithm { //self.infoDetailViewModel.algorithm?.count ?? 0 > 0
                urlStr = "\(urlStr)&algid=\(algorithm)"
            }
            
            
            if let urlReq = URL(string: urlStr) {
                self.webView?.load(URLRequest(url: urlReq))
            }
        }
    }
    
    private func showShareAlert() {
        if let webView = self.webView {
            YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: ["shareType" : "freedom"], callback: "window.callShare", completionCallback: nil)
        }
    }
    
    override func onCommandShare(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        // shareType如果没有的话，则默认使用freedom
        let shareType: String = (paramsJsonValue?["shareType"] as? String) ?? "freedom"
        
        let title = paramsJsonValue?["title"] as? String
        let description = paramsJsonValue?["description"] as? String
        let pageUrl = paramsJsonValue?["pageUrl"] as? String
        var shortUrl = paramsJsonValue?["shortUrl"] as? String
        //如果shortUrl没有值，那就用pageUrl
        if shortUrl?.isEmpty ?? true { //shortUrl?.count == 0
            shortUrl = pageUrl
        }
        let overseaPageUrl = paramsJsonValue?["overseaPageUrl"] as? String  //页面url
        
        let thumbUrl = paramsJsonValue?["thumbUrl"] as? String
        let image: Any = (thumbUrl?.isEmpty ?? true) ? UIImage(named: "icon")! : thumbUrl!
        
        let isDialogBgNone = paramsJsonValue?["isDialogBgNone"] as? Bool
        
        // 分享结束后的回调
        let shareResultBlock: (Bool) -> Void = { [weak self] (result) in
            guard let `self` = self else { return }
            
            if result {
                if  let webView = self.webView,
                    let successCallback = successCallback,
                    successCallback.count > 0 {
                    YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
                    
                    self.getPublishTime().subscribe(onNext: { (publishTime) in
                        
                    }).disposed(by: self.disposeBag)
                    
                    let newsId: String = self.infoDetailViewModel.newsId ?? ""
                    self.infoDetailViewModel.services.newsService
                        .request(.share(newsId), response: { (response) in
                            
                        } as YXResultResponse<JSONAny>).disposed(by: self.disposeBag)
                }
            } else {
                if let errorCallback = errorCallback,
                    errorCallback.count > 0,
                    let webView = self.webView {
                    YXJSActionUtil.invokeJSCallbackForError(withWebview: webView, errorDesc: "share failed", callback: errorCallback)
                }
            }
        }
        
        if var pageURL = URL(string: pageUrl ?? ""),
            let title = title {
            //改变url的block
            let changeUrlBlock = {
                if !(overseaPageUrl?.isEmpty ?? true) {//let overseaLength = overseaPageUrl?.count, overseaLength > 0
                    pageURL = URL(string: overseaPageUrl!)!
                }
            }
            
            if shareType == "freedom" {
                // 資訊的不支持freedom
                var section0_items: [QMUIMoreOperationItemView] = []
                // 1.Whats app
                if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                    let whatsapp = QMUIMoreOperationItemView(image: UIImage(named: "share-whats"), title: YXShareSDKHelper.title(forPlatforms: .typeWhatsApp)) { (controller, itemView) in
                        
                        // 点击后执行的block
                        controller.hideToBottom()
                        
                        let shareText = "\(title)\n\n\(description ?? "")\n\(shortUrl ?? "")"
                        YXShareSDKHelper.shareInstance()?.share(.typeWhatsApp, text: shareText, images: nil, url: nil, title: nil, type: .auto, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    }
                    section0_items.append(whatsapp)
                } else {
                    shareResultBlock(false)
                }
                // 2.facebook
                let fb = QMUIMoreOperationItemView(image: UIImage(named: "share-fb"), title: YXShareSDKHelper.title(forPlatforms: .typeFacebook)) { (controller, itemView) in
                    // 点击后执行的block
                    controller.hideToBottom()
                    
                    changeUrlBlock()
                    if YXShareSDKHelper.isClientIntalled(.typeFacebook) {
                        YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: description, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    } else {
                        YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: description, images: nil, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
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
                        // facebook messenger 只支持网络图片
                        changeUrlBlock()
                        
                        YXShareSDKHelper.shareInstance()?.share(.typeFacebookMessenger, text: description, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    }
                    
                    section0_items.append(fbMessenger)
                } else {
                    shareResultBlock(false)
                }
                // 4.wechat
                if YXShareSDKHelper.isClientIntalled(.typeWechat) {
                    // 已安装微信
                    let wechat = QMUIMoreOperationItemView(image: UIImage(named: "share-wechat"), title: YXShareSDKHelper.title(forPlatforms: .typeWechat)) { (controller, itemView) in
                        // 点击后执行的block
                        controller.hideToBottom()
                        
                        YXShareSDKHelper.shareInstance()?.share(.typeWechat, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    }
                    
                    let moment = QMUIMoreOperationItemView(image: UIImage(named: "share-moments"), title: YXShareSDKHelper.title(forPlatforms: .subTypeWechatTimeline)) { (controller, itemView) in
                        // 点击后执行的block
                        controller.hideToBottom()
                        YXShareSDKHelper.shareInstance()?.share(.subTypeWechatTimeline, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    }
                    
                    section0_items.append(wechat)

                    section0_items.append(moment)
                } else {
                    shareResultBlock(false)
                }
                
                // 5.twitter
                let twitter = QMUIMoreOperationItemView(image: UIImage(named: "share-twitter"), title: YXShareSDKHelper.title(forPlatforms: .typeTwitter)) { (controller, itemView) in
                    // 点击后执行的block
                    controller.hideToBottom()
                    changeUrlBlock()
                    if let shortURL = URL(string: shortUrl ?? "") {
                        YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: description, images: nil, url: shortURL, title: nil, type: .webPage, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    } else {
                        YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                            shareResultBlock(success)
                        })
                    }
                }
                section0_items.append(twitter)
                
                // 6.短信
                let message = QMUIMoreOperationItemView(image: UIImage(named: "share-message"), title: YXLanguageUtility.kLang(key: "share_message")) { [weak self] (controller, itemView) in
                    guard let `self` = self else { return }
                    
                    // 点击后执行的block
                    controller.hideToBottom()
                    
                    if MFMessageComposeViewController.canSendText() {
                        let c = MFMessageComposeViewController()
                        let content = "\(self.infoDetailViewModel.newsTitle ?? "")\n\(shortUrl ?? "")"
                        c.body = content
                        c.messageComposeDelegate = self
                        self.present(c, animated: true, completion: nil)
                    } else {
                        self.infoDetailViewModel.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "share_not_support_message"), false))
                    }
                }
                
                section0_items.append(message)
                
                // 7.更多
                let more = QMUIMoreOperationItemView(image: UIImage(named: "share-more"), title: YXLanguageUtility.kLang(key: "share_info_more")) { [weak self] (controller, itemView) in
                    guard let `self` = self else { return }
                    
                    // 点击后执行的block
                    controller.hideToBottom()
                    
                    let title = self.infoDetailViewModel.newsTitle ?? ""
                    let image = UIImage(named: "icon")!
                    if let shortURL = URL(string: shortUrl ?? "") {
                        let vc = UIActivityViewController(activityItems: [title, image, shortURL], applicationActivities: nil)
                        let completeBlock: UIActivityViewController.CompletionWithItemsHandler = { [weak self] (activityType, completed, items, error) in
                            guard let `self` = self else { return }
                            
                            if completed {
                                let newsId: String = self.infoDetailViewModel.newsId ?? ""
                                self.infoDetailViewModel.services.newsService
                                    .request(.share(newsId), response: { (response) in
                                        } as YXResultResponse<JSONAny>).disposed(by: self.disposeBag)
                            } else {
                                log(.verbose, tag: kModuleViewController, content: "information: send failed")
                            }
                            vc.dismiss(animated: true, completion: nil)
                        }
                        vc.completionWithItemsHandler = completeBlock
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                
                section0_items.append(more)
                
                var section1_items: [QMUIMoreOperationItemView] = []
                
                // 收藏
                self.favorite.removeTarget(nil, action: nil, for: .allEvents)
                section1_items.append(self.favorite)
                
                if self.needChangeFontSize ?? false {
                    // 字体放大缩小
                    self.font.removeTarget(nil, action: nil, for: .allEvents)
                    section1_items.append(self.font)
                }
                
                let vc = YXMoreOperationViewController()
                vc.contentEdgeInsets = UIEdgeInsets(top: 0, left: uniHorLength(10), bottom: YXConstant.deviceScaleEqualToXStyle() ? 0 : 34, right: uniHorLength(10))
                vc.items = [section0_items, section1_items]
                vc.showFromBottom(withBackgroundClear: isDialogBgNone ?? false)
            } else if shareType == "wechat_friend" {
                if YXShareSDKHelper.isClientIntalled(.typeWechat) {
                    YXShareSDKHelper.shareInstance()?.share(.typeWechat, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    shareResultBlock(false)
                }
            } else if shareType == "wechat_friends_circle" {
                if YXShareSDKHelper.isClientIntalled(.subTypeWechatTimeline) {
                    YXShareSDKHelper.shareInstance()?.share(.subTypeWechatTimeline, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    shareResultBlock(false)
                }
            } else if shareType == "whatsapp" {
                if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                    let shareText = "\(title)\n\n\(description ?? "")\n\(shortUrl ?? "")"
                    YXShareSDKHelper.shareInstance()?.share(.typeWhatsApp, text: shareText, images: nil, url: nil, title: nil, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    shareResultBlock(false)
                }
            } else if shareType == "facebook" {
                // facebook 只支持网络图片
                changeUrlBlock()
                if YXShareSDKHelper.isClientIntalled(.typeFacebook) {
                    YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: description, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: description, images: nil, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
            } else if shareType == "twitter" {
                changeUrlBlock()
                if let shortURL = URL(string: shortUrl ?? "") {
                    YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: description, images: nil, url: shortURL, title: nil, type: .webPage, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: description, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                }
                
            } else if shareType == "messenger" {
                if YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger) {
                    // facebook messenger 只支持网络图片
                    changeUrlBlock()
                    
                    YXShareSDKHelper.shareInstance()?.share(.typeFacebookMessenger, text: description, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        shareResultBlock(success)
                    })
                } else {
                    shareResultBlock(false)
                }
            } else if shareType == "qq" {
                shareResultBlock(false)
            } else if shareType == "weibo" {
                shareResultBlock(false)
            }
        } else {
            shareResultBlock(false)
        }
    }
    
    override func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        switch result {
        case .sent:
            let newsId: String = self.infoDetailViewModel.newsId ?? ""
            self.infoDetailViewModel.services.newsService
                .request(.share(newsId), response: { (response) in
                    
                    } as YXResultResponse<JSONAny>).disposed(by: self.disposeBag)
        case .failed:
            print("infomation: send message failed")
        default:
            print("infomation: default")
        }
    }
}
