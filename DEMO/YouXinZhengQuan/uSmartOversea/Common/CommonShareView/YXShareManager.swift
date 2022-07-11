//
//  YXShareManager.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/9/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import MobileCoreServices
import MessageUI
import TYAlertController
import sqlcipher

@objc enum YXShareSceneKey: Int {
    case stockDetail = 0
    case fastNews      //7x24
    case news          //资讯详情
    case unknown
    
    var sceneKey: String {
        switch self {
        case .stockDetail:
            return "stock_dt"
        case .fastNews:
            return "7x24"
        case .news:
            return "news_dt"
        default:
            return ""
        }
    }
}

extension YXSharePlatform {
    
    var SSDKPlatform: SSDKPlatformType {
        switch self {
        case .wechat:
            return .typeWechat
        case .facebook:
            return .typeFacebook
        case .facebookMessenger:
            return .typeFacebookMessenger
        case .whatsApp:
            return .typeWhatsApp
        case .aliSocial:
            return .typeAliSocial
        case .dingTalk:
            return .typeDingTalk
        case .twitter:
            return .typeTwitter
        case .QQ:
            return .typeQQ
        case .sinaweibo:
            return .typeSinaWeibo
        case .wechatFriend:
            return .subTypeWechatTimeline
        case .instagram:
            return .typeInstagram
        case .line:
            return .typeLine
        case .telegram:
            return .typeTelegram
        default:
            return .typeUnknown
        }
    }

    var shareChannalTypeId: Int {
        return 0
    }
}

extension YXShareImageType {
    
    var config: YXShareConfig {
        let config = YXShareConfig()
        config.showWework = true
        config.showSave = true
        config.showCopy = true
        switch self {
        case .stockDetail:
            config.desc = YXLanguageUtility.kLang(key: "stock_share_tip")
        case .discuss:
            config.followLogin = false
            config.longUrl = YXQRCodeHelper.appQRString(shareId: "pages", bizid: "portfolio")
        case .fastNews:
            config.sceneKey = .fastNews
            config.desc = YXLanguageUtility.kLang(key: "fast_new_share_7X24")
            config.lrMargin = (14.0 * YXConstant.screenWidth / 375.0)
            config.cornerRadius = 8
            config.longUrl = YXQRCodeHelper.appQRString(shareId: "pages", bizid: "portfolio")
        case .webScreen:
            config.splicingQRView = false
        case .account:
            config.splicingQRView = false
            config.isHoldShare = true
            config.lrMargin = (20.0 * YXConstant.screenWidth / 375.0)
        default:
            break
        }
        return config
    }
}

class YXShareConfig: NSObject {
    
    //@objc var shareType: String?
    @objc var title: String = ""
    @objc var desc: String = ""  //description
    @objc var shortUrl: String = "" //二维码
    @objc var pageUrl: String = ""
    @objc var thumbUrl: String?
    @objc var wechatDescription: String = ""
    
    @objc var overseaPageUrl: String?
    @objc var wxUserName: String?
    @objc var wxPath: String?     //小程序分享path
    @objc var withShareTicket: Bool = false
    @objc var miniProgramType: UInt = 0
    @objc var isDialogBgNone: Bool = false
    
    @objc var imageData: Any?

    @objc var sceneKey: YXShareSceneKey = .unknown
    @objc var followLogin: Bool = true  //是否跟随用户登录态
    @objc var longUrl: String = ""
    @objc var splicingQRView = true //图片分享时是否要拼接二维码视图
    
    @objc var subPlatform: YXSharePlatform = .unKnown
    @objc var subImage: UIImage?
    
    @objc var isMoreTop = false
    
    @objc var showWework = true
    @objc var showMore = false
    @objc var showSave = false
    @objc var showCopy = false
    @objc var showSMS = false
    @objc var isHoldShare = false
    //是否显示社区
    @objc var isShowCommunity = false
    //视图相关配置
    @objc var lrMargin: CGFloat = (30.0 * YXConstant.screenWidth / 375.0)
    @objc var cornerRadius: CGFloat = 0
    
    //分享小程序配图
    @objc var miniProgramImage: UIImage?
    
    //内部默认统一弹出提示
    @objc var isDefaultShowMessage = false
    
    @objc class func linkConfig(title: String = "", desc: String = "", shortUrl: String = "", pageUrl: String = "", wechatDescription: String = "", thumbUrl: String? = nil) -> YXShareConfig {
        let config = YXShareConfig()
        config.title = title
        config.desc = desc
        config.shortUrl = shortUrl
        config.pageUrl = pageUrl
        config.wechatDescription = wechatDescription
        config.thumbUrl = thumbUrl
        
        config.showMore = true
        config.showCopy = true
        config.showSMS = true
        return config
    }

}


class YXShareManager: NSObject {
    
    @objc static let shared = YXShareManager()
    
    typealias ResultBlock = (_ platform: YXSharePlatform, _ result: Bool) -> Void
    
    typealias ConfigBlock = (_ platform: YXSharePlatform) -> YXShareConfig?
    
    typealias OperationItemViewBlock = () -> [QMUIMoreOperationItemView]?
    
}

//MARK: - 展示方法
extension YXShareManager {
    //链接分享
    @objc func showLink(_ config: YXShareConfig) {
        self.showLink(config, shareResultBlock: nil)
    }
    
    @objc func showLink(_ config: YXShareConfig, shareResultBlock: ResultBlock?) {
       
        self.showLink(config, configBlock: nil, itemViewBlock: nil, shareResultBlock: shareResultBlock)
    }
    
    
    /// 分享链接的通用方法
    /// - Parameters:
    ///   - config: 配置信息
    ///   - configBlock: 获取某个平台独有的配置信息 如：  "\(title)\n\n\(description ?? "")\n\(shortUrl ?? "")" 及  "\(title)\n\(shortUrl ?? "")" 可以配置 config.desc为空来实现
    ///   - itemViewBlock: 获取额外配置的平台 eg. 收藏，字体等和页面关联紧密的视图
    ///   - shareResultBlock: 分享结果
    @objc func showLink(_ config: YXShareConfig, configBlock: ConfigBlock? = nil, itemViewBlock: OperationItemViewBlock? = nil, shareResultBlock: ResultBlock? = nil) {
        loadServerConfig(.link, config: config) {
             [weak self] in
            guard let `self` = self else { return }
            self.showLinkPlatformView(config, configBlock: configBlock, itemViewBlock: itemViewBlock, shareResultBlock: shareResultBlock)
        }
    }
    
    //图片分享
    @objc func showImage(_ config: YXShareConfig, shareImage: UIImage?, shareResultBlock: ResultBlock? = nil) {
        
        loadServerConfig(.image, config: config) {
            YXShareImageBaseView.show(config: config, shareImage: shareImage)
        }
    }
    //新增
//    @objc func showImage(_ type: YXShareImageType, shareImage: UIImage?) {
//        self.showImage(type, shareImage: shareImage, shareResultBlock: nil)
//    }
    
//    func showImage(_ type: YXShareImageType, shareImage: UIImage?, shareResultBlock: ResultBlock?) {
//        self.show(.image, config: type.config, shareImage: shareImage, imageType: type, shareResultBlock: shareResultBlock)
//    }
//
//     private func show(_ shareType: YXShareType, config: YXShareConfig, shareImage: UIImage? = nil, imageType: YXShareImageType = .default, shareResultBlock: ResultBlock?) {
//    
//        loadServerConfig(shareType, config: config) {
//             [weak self] in
//            guard let `self` = self else { return }
//            
//            switch shareType {
//            case .link:
//                
//                let shareView = YXSharePlatformView.init(frame: .zero, config: config)
//        
//                shareView.shareBlock = {
//                    [weak shareView, weak self] platform in
//                    shareView?.hide()
//                    guard let `self` = self else { return }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        self.shareLink(to: platform, config: config, shareResultBlock: shareResultBlock)
//                    }
//                }
//                
//                if let shareVC = TYAlertController(alert: shareView, preferredStyle: .actionSheet, transitionAnimation: .scaleFade) {
//                    shareVC.backgoundTapDismissEnable = true
//                    if config.isDialogBgNone {
//                        shareVC.backgroundView.backgroundColor = UIColor.clear
//                    }
//                    shareVC.dismissComplete = {
//                        [weak shareView] in
//                        shareView?.removeFromSuperview()
//                        shareView = nil
//                    }
//                
//                    UIViewController.current().present(shareVC, animated: true, completion: nil)
//                }
//            case .image:
//                if (imageType == .account) {
//                    
//                } else {
//                    YXShareImageBaseView.show(config: config, shareImage: shareImage)
//                }
//                
//            default:
//                shareResultBlock?(.unKnown, true)
//                break
//            }
//        }
//        
//    }

    func loadServerConfig(_ shareType: YXShareType, config: YXShareConfig, excute:(() -> Void)?) {
        
        if config.sceneKey != .unknown {
            let hud = YXProgressHUD.showLoading("", in: UIApplication.shared.keyWindow)
            YXShareConfigRequestModel.startRequest(type: config.sceneKey) { model in
                
                if let url = model?.registerPageLink, !url.isEmpty {
                    config.shortUrl = url
                }
                if let desc = model?.guideCopywriting, !desc.isEmpty {
                    config.desc = desc
                }
                if let thumbUrl = model?.sharingLinkIcon, !thumbUrl.isEmpty {
                    config.thumbUrl = thumbUrl
                }
               
                if config.followLogin, YXUserManager.isLogin() {
                    SDWebImageManager.shared.loadImage(with: URL(string: YXUserManager.shared().curLoginUser?.avatar ?? ""), options: .retryFailed, progress: nil) { image, data, error, cacheType, finished, imageURL in
                        hud.hide(animated: true)
                        excute?()
                    }
                } else {
                    hud.hide(animated: false)
                    excute?()
                }
            }
        } else if !config.longUrl.isEmpty {
            let hud = YXProgressHUD.showLoading("")
            YXShortUrlRequestModel.startRequest(longUrl: config.longUrl) { [weak hud] url in
                hud?.hide(animated: false)
                config.shortUrl = url
                excute?()
            }
        } else {
            excute?()
        }
        
    }
    
    func showLinkPlatformView(_ config: YXShareConfig, configBlock: ConfigBlock?, itemViewBlock: OperationItemViewBlock?, shareResultBlock: ResultBlock?) {
        
        if QMUIModalPresentationViewController.isAnyModalPresentationViewControllerVisible() {
            return
        }
        
        func shareTo(_ platform: YXSharePlatform) {
            
            var tempConfig = config
            if let configgg = configBlock?(platform) {
                tempConfig = configgg
            }
            if YXShareManager.isNeedHiddeModalPresent(platform) {
                if let modalVC =  UIViewController.current() as? QMUIModalPresentationViewController {
                    modalVC.hideWith(animated: false, completion: { finished in
                        self.shareLink(to: platform, config: tempConfig, shareResultBlock: shareResultBlock)

                    })
                    return
                }
            }
            self.shareLink(to: platform, config: tempConfig, shareResultBlock: shareResultBlock)
        }
        
        
        var thirdPlatforms:[YXSharePlatform] = [.facebook,.facebookMessenger,.whatsApp,.twitter]
        if config.isShowCommunity {
            thirdPlatforms.append(.uSmartSocial)
        }
        thirdPlatforms.append(.telegram)
        thirdPlatforms.append(.line)
        if config.showSMS {
            thirdPlatforms.append(.sms)
        }
        var toolsPlatforms:[YXSharePlatform] = [.more]
        if config.showCopy {
            toolsPlatforms.insert(.copy, at: 0)
        }


        let shareView = YXShareImageContentView(frame: UIScreen.main.bounds, shareType: .link, toolTypes: toolsPlatforms,thirdTypes: thirdPlatforms) { shareItem in
            
            if shareItem.sharePlatform == .unKnown {
                
            } else {
                shareTo(shareItem.sharePlatform)
            }
            
            
        } cancelCallBlock: {
            
        }
        shareView.isDefaultShowMessage = config.isDefaultShowMessage
        shareView.showShareView()
    }
    
    //传入nil，取默认
    class func getThirdShareItems(_ sharePlatforms:[YXSharePlatform]?,_ shareType:YXShareType) -> [YXShareItemModel] {
        
        var thirdShareDatas:[YXShareItemModel] = []
        
        //默认
        var defaultPlatforms:[YXSharePlatform] = [.facebook,.facebookMessenger,.whatsApp,.twitter,.telegram,.line]
        if shareType == .image {
            defaultPlatforms = [.facebook,.facebookMessenger,.whatsApp,.twitter,.instagram,.uSmartSocial,.telegram,.line]
        }
        if let platforms = sharePlatforms {
            defaultPlatforms = platforms
        }
        
        for platform in defaultPlatforms {
            switch platform {
            case .uSmartSocial:
                let communityModel = YXShareItemModel.init()
                communityModel.shareName = YXLanguageUtility.kLang(key: "share_usmart_community")
                communityModel.shareImageName = "share-usmart-community"
                communityModel.shareType = "shareUsmartCommunity"
                communityModel.sharePlatform = YXSharePlatform.uSmartSocial
                thirdShareDatas.append(communityModel)
            case .whatsApp:
                if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                    
                    let whatsAppModel = YXShareItemModel.init()
                    whatsAppModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeWhatsApp)
                    whatsAppModel.shareImageName = "share-whatsapp"
                    whatsAppModel.sharePlatform = YXSharePlatform.whatsApp
                    thirdShareDatas.append(whatsAppModel)
                }
            case .telegram:
                if YXShareSDKHelper.isClientIntalled(.typeTelegram) {
                    let whatsAppModel = YXShareItemModel.init()
                    whatsAppModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeTelegram)
                    whatsAppModel.shareImageName = "share-telegram"
                    whatsAppModel.sharePlatform = YXSharePlatform.telegram
                    thirdShareDatas.append(whatsAppModel)
                }
            case .line:
                if YXShareSDKHelper.isClientIntalled(.typeLine) {
                    let lineAppModel = YXShareItemModel.init()
                    lineAppModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeLine)
                    lineAppModel.shareImageName = "share-line"
                    lineAppModel.sharePlatform = YXSharePlatform.line
                    thirdShareDatas.append(lineAppModel)
                }
            case .facebook:
                let fbModel = YXShareItemModel.init()
                fbModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeFacebook)
                fbModel.shareImageName = "share-fb"
                fbModel.sharePlatform = YXSharePlatform.facebook
                thirdShareDatas.append(fbModel)
//            case .facebookMessenger://没有
//                if YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger) {
//
//                    let fbMessagerModel = YXShareItemModel.init()
//                    fbMessagerModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeFacebookMessenger)
//                    fbMessagerModel.shareImageName = "share-fb-messenger"
//                    fbMessagerModel.sharePlatform = YXSharePlatform.facebookMessenger
//                    thirdShareDatas.append(fbMessagerModel)
//                }
//            case .wechat://海外不支持
//                if YXShareSDKHelper.isClientIntalled(.typeWechat) {
//
//                    let wechatModel = YXShareItemModel.init()
//                    wechatModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeWechat)
//                    wechatModel.shareImageName = "share-wechat"
//                    wechatModel.sharePlatform = YXSharePlatform.wechat
//                    thirdShareDatas.append(wechatModel)
//
//                    let wechatMomentModel = YXShareItemModel.init()
//                    wechatMomentModel.shareName = YXShareSDKHelper.title(forPlatforms: .subTypeWechatTimeline)
//                    wechatMomentModel.shareImageName = "share-moments"
//                    wechatMomentModel.sharePlatform = YXSharePlatform.wechatFriend
//                    thirdShareDatas.append(wechatMomentModel)
//
//                }
            case .twitter:
                let twitterModel = YXShareItemModel.init()
                twitterModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeTwitter)
                twitterModel.shareImageName = "share-twitter"
                twitterModel.sharePlatform = YXSharePlatform.twitter
                thirdShareDatas.append(twitterModel)
            case .instagram:
                if YXShareSDKHelper.isClientIntalled(.typeInstagram) && shareType != .link{//不支持链接文字分享
                    let twitterModel = YXShareItemModel.init()
                    twitterModel.shareName = YXShareSDKHelper.title(forPlatforms: .typeInstagram)
                    twitterModel.shareImageName = "share-Instagram"
                    twitterModel.sharePlatform = YXSharePlatform.instagram
                    thirdShareDatas.append(twitterModel)
                }
//            case .sms:
//                let twitterModel = YXShareItemModel.init()
//                twitterModel.shareName = YXLanguageUtility.kLang(key: "share_message")
//                twitterModel.shareImageName = "share-message"
//                twitterModel.sharePlatform = YXSharePlatform.sms
//                thirdShareDatas.append(twitterModel)
            default:
                print("未知平台")
            }
        }
        
        
        for (i,item) in thirdShareDatas.enumerated() {
            item.shareTag = 1000+i
        }
        return thirdShareDatas
    }
    
    //传入nil，取默认
    class func getToolShareItems(_ sharePlatforms:[YXSharePlatform]?) -> [YXShareItemModel] {
        
        
        var defaultPlatforms:[YXSharePlatform] = [.more]
        if let platforms = sharePlatforms {
            defaultPlatforms = platforms
        }
        
        var toolsShareDatas:[YXShareItemModel] = []

        for platform in defaultPlatforms {
            switch platform {
            case .save:
                let saveImageModel = YXShareItemModel.init()
                saveImageModel.shareName = YXLanguageUtility.kLang(key: "share_save_pic")
                saveImageModel.shareImageName = "share-save"
                saveImageModel.sharePlatform = YXSharePlatform.save
                toolsShareDatas.append(saveImageModel)
            case .copy:
                let copyModel = YXShareItemModel.init()
                copyModel.shareName = YXLanguageUtility.kLang(key: "share_copy_url")
                copyModel.shareImageName = "share-copyurl"
                copyModel.sharePlatform = YXSharePlatform.copy
                toolsShareDatas.append(copyModel)
            case .more:
                let moreModel = YXShareItemModel.init()
                moreModel.shareName = YXLanguageUtility.kLang(key: "share_more")
                moreModel.shareImageName = "share-more"
                moreModel.sharePlatform = YXSharePlatform.more
                toolsShareDatas.append(moreModel)
            default:
                print("未知平台")
            }
        }

        for (i,item) in toolsShareDatas.enumerated() {
            item.shareTag = 100+i
        }
       
        return toolsShareDatas
    }
}


//MARK: - 分享方法
extension YXShareManager {
    
    // MARK: - 注意事项
    /**
     telegram: 只支持纯图片 或 链接（图片分享时，如果telegram没有登录，就会弹出登录提示，所以使用more)
     Instagram: 不支持链接文字分享
     line平台分享链接时，如果传了图片，就只有图片了
     
     图片 + 文案：微博、Twitter
     只能图片的：Line、Instagram、Facebook、Messenger、微信、朋友圈、qq、空间、企业微信、WhatsApp
    注意：twitter传图文时，给text, 给title不行。 微博，两个都可以
     
     // FB链接分享，需要隐藏弹窗，不然会报 SFSafariViewController's parent view controller was dismissed（因为会调用APP内部网页FB登录界面）
     */
    @objc func isShareImageWithTitle(_ platform: YXSharePlatform) -> Bool {
        //platform == .telegram
        if platform == .twitter || platform == .sinaweibo {
            return true
        }
        return false
    }
    
    @objc func isShareImageWithTitleSSDKType(_ platform: SSDKPlatformType) -> Bool {
        if platform == .typeTwitter || platform == .typeSinaWeibo {
            return true
        }
        return false
    }
    
    // 点击分享，判断对应的是否要先隐藏弹窗
    @objc class func isNeedHiddeModalPresent(_ platform: YXSharePlatform) -> Bool {
        // FB链接分享，需要隐藏弹窗，不然会报 SFSafariViewController's parent view controller was dismissed（因为会调用APP内部网页FB登录界面）
        if platform == .more || platform == .sms || platform == .uSmartSocial  || platform == .facebook {
            return true
        }
        return false
    }
    
    @objc class func showShareResultMessage(sharePlatform:YXSharePlatform, success:Bool) {
        
        if let window = UIApplication.shared.keyWindow {
            switch sharePlatform {
            case .copy:
                if success {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "copy_success"),in: window)
                }
            case .save:
                if success {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "user_saveSucceed"),in: window)
                }else {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "user_saveFailed"),in: window)
                }
                break
            case .more,.telegram:
                print("more 不分享")
                break
            default:
                if success {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "share_succeed"), in: window)

                } else {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "share_failed"), in: window)

                }
            }
        }
    }
    
    @objc class func shareToUsmartCommunity(_ image: UIImage?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !YXUserManager.isLogin() {
                YXToolUtility.handleBusinessWithLogin {

                }
                return
            }

            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let navigator = root.navigator
                let viewModel = YXReportViewModel.init(services: navigator, params: nil)
                if let image = image {
                    viewModel.images = [image]
                }
                navigator.push(viewModel, animated: true)
            }
        }
    }
    
    // 主分享截图 带默认文案
    @objc func shareImage(to platform: YXSharePlatform, shareImage: UIImage?, shareResultBlock: ResultBlock? = nil) {
        
        guard let image = shareImage else {
            return
        }
        
        var shareAppText = ""
        if isShareImageWithTitle(platform) {
            shareAppText = YXLanguageUtility.kLang(key: "share_image_recommend_text")
        }

        YXShareSDKHelper.shareInstance()?.share(platform.SSDKPlatform, text: shareAppText, images: [image], url: nil, title: "", type: .image, withCallback: { (success, userInfo, _) in
            shareResultBlock?(platform, success)
        })
    
    }
    
    // 主分享文案， url 图片icon、图片链接
    @objc func shareTextImage(to platform: YXSharePlatform, text: String?, images: Any?, url: URL?, title: String?, contentType: SSDKContentType = .auto, shareResultBlock: ResultBlock? = nil) {
        
        YXShareSDKHelper.shareInstance()?.share(platform.SSDKPlatform, text: (text ?? ""), images: images, url:  nil, title: (title ?? ""), type: contentType){ (success, userInfo, _) in
            shareResultBlock?(platform, success)
        }
    }
    
    
    @objc func shareLink(to platform: YXSharePlatform, config: YXShareConfig, shareResultBlock: ResultBlock?) {

        if platform == .unKnown || platform == .sinaweibo || platform == .QQ {
            shareResultBlock?(platform, false)
            return
        }

        var images: Any?
        if let url = config.thumbUrl, !url.isEmpty {
            images = url
        } else {
            images = UIImage(named: "icon")
        }

        if config.wechatDescription.isEmpty {
            config.wechatDescription = config.desc
        }

        var sharingImage = YXToolUtility.conventToImage(withBase64String: config.imageData)
        if let subImage = config.subImage, sharingImage == nil {
            sharingImage = subImage
        }
        
        if platform == .copy {
            //复制链接
            let pab = UIPasteboard.general

            var shareString = config.title

            if !config.desc.isEmpty {
                shareString += ("\n\n" + config.desc)
            }

            shareString += ("\n" + (config.shortUrl.isEmpty ? config.pageUrl : config.shortUrl))

            pab.string = shareString

            //YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "copy_success"))
            shareResultBlock?(platform, true)

        } else if platform == .more || (platform == .telegram && sharingImage != nil)  {//telegram 图片分享暂时用more功能,(telgram用长链)
        
            //block回调 present
            let presentBlock:((_ image:UIImage?) -> Void) = { [weak self] (image) in
                guard let `self` = self else { return }

                var items: [Any] = []
        
                var shareString = config.title
                if !config.desc.isEmpty {
                    if shareString.count > 0 {
                        shareString += "\n\n"
                    }
                    shareString += config.desc
                }

                if !shareString.isEmpty {
                    items.append(shareString)
                }

                if let img = image {
                    items.append(img)
                }

                if let shortURL = URL(string: config.shortUrl) {
                    items.append(shortURL)
                } else if let pageUrl = URL(string: config.pageUrl) {
                    items.append(pageUrl)
                }
                if platform == .telegram,let img = image {// telegram 只分享图片 后续调试带文案的
                    items = [img]
                }
                
                if items.count > 0 {
                    self.shareToMore(activityItems: items, shareResultBlock: shareResultBlock)
                    
                }
                
            }
            if let shareImage = sharingImage {
                presentBlock(shareImage)
            } else {
                //下载图片
                if let tempThumbUrl = config.thumbUrl, tempThumbUrl.isEmpty == false, let temp = URL(string: tempThumbUrl) {
                    let progressHUD = YXProgressHUD.showLoading("", in: UIApplication.shared.keyWindow)

                    SDWebImageManager.shared.loadImage(with: temp, options: .retryFailed, progress: nil) { image, data, error, cacheType, finished, imageURL in
                        progressHUD.hide(animated: true)
                        presentBlock(image)
                    }
                } else {
                    presentBlock(nil)
                }
            }
            
        } else if platform == .wxMiniProgram {

            if let pageURL = URL(string: config.pageUrl), YXShareSDKHelper.isClientIntalled(.typeWechat) {
                YXShareSDKHelper.shareInstance()?.shareMiniProgram(by: .typeWechat, title: config.title, description: config.desc, webpageUrl: pageURL, path: config.wxPath, thumbImage: images, hdThumbImage: images, userName: config.wxUserName, withShareTicket: config.withShareTicket, miniProgramType: config.miniProgramType, forPlatformSubType: .subTypeWechatSession, callback: { (success, userInfo, _) in
                    shareResultBlock?(platform, success)
                })
            } else {
                shareResultBlock?(platform, false)
            }

        } else if platform == .sms {
            var desc: String? = config.title + "\n" + config.shortUrl
            if config.subImage != nil {
                desc = nil
            }
            self.shareToMessage(content: desc, sharingImage: sharingImage, imageUrlString: config.thumbUrl) { result in
                shareResultBlock?(platform, result)
            }
        } else {

            if platform == .wechat || platform == .wechatFriend {
                if !YXShareSDKHelper.isClientIntalled(.typeWechat) {
                    shareResultBlock?(platform, false)
                    return;
                }
            } else if platform == .whatsApp {
                if !YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                    shareResultBlock?(platform, false)
                    return;
                }
            } else if platform == .facebookMessenger {
                if !YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger) {
                    shareResultBlock?(platform, false)
                    return;
                }
            }

            if let shareImage = sharingImage {
                YXShareManager.shared.shareImage(to: platform, shareImage: shareImage, shareResultBlock: { platform, result in
                    shareResultBlock?(platform, result)
                })
                
            } else {
                var url: URL?
                var contentType: SSDKContentType = .auto
                url = URL(string: config.pageUrl)
                if config.longUrl == config.pageUrl && !config.shortUrl.isEmpty && platform != .facebook && platform != .telegram{
                    //longUrl 和 pageUrl相同时， shortUrl为longUrl转变的短链
                    url = URL(string: config.shortUrl)
                }

                var desc: String = config.desc
                if platform == .wechat, !config.wechatDescription.isEmpty {
                    desc = config.wechatDescription
                }
                
                if platform == .facebook {
                    if let overseaUrl = config.overseaPageUrl, !overseaUrl.isEmpty {
                        url = URL(string: overseaUrl)
                    }
                    if YXShareSDKHelper.isClientIntalled(.typeFacebook) { // facebook 只支持网络图片
                        images = config.thumbUrl
                    } else {
                        images = nil
                    }
                } else if platform == .facebookMessenger {
                    if let overseaUrl = config.overseaPageUrl, !overseaUrl.isEmpty {
                        url = URL(string: overseaUrl)
                    }
                    images = config.thumbUrl
                } else if platform == .twitter {
                    if let overseaUrl = config.overseaPageUrl, !overseaUrl.isEmpty {
                        url = URL(string: overseaUrl)
                    }
                    if let shortURL = URL(string: config.shortUrl) { //分享链接
                        url = shortURL
                        images = nil
                        contentType = .webPage
                        config.title = ""
                    }
                } else if platform == .whatsApp {
                    desc = config.title
                    if !config.desc.isEmpty {
                        if desc.count > 0 {
                            desc += "\n\n"
                        }
                        desc += config.desc
                    }
                    if !config.shortUrl.isEmpty {
                        desc += "\n\(config.shortUrl)"
                    }
                    images = nil
                    url = nil
                    config.title = ""
                }
                
                //line平台分享链接时，如果传了图片，就只有图片了
                if platform == .line || platform == .telegram {
                    images = nil
                }

                if config.subPlatform == .wxMiniProgram, platform == .wechat {
                    
//                    var miniProgramType: UInt = 0
//                    if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
//                        miniProgramType = 0
//                    } else {
//                        miniProgramType = 2
//                    }
                    
//                    if let miniProgramImage = config.miniProgramImage {
//                        images = miniProgramImage
//                    }
               
                    //TODO:屏蔽分享功能
//                    YXShareSDKHelper.shareInstance()?.shareMiniProgram(by: .typeWechat, title: config.title, description: config.desc, webpageUrl: url, path: config.wxPath, thumbImage: images, hdThumbImage: images, userName: WXMiniProgramUserName, withShareTicket: false, miniProgramType: miniProgramType, forPlatformSubType: .subTypeWechatSession, callback: { (success, userInfo, _) in
//                        shareResultBlock?(platform, success)
//                    })
                } else {
                    
                    YXShareManager.shared.shareTextImage(to: platform, text: desc, images: images, url: url, title: config.title, contentType: contentType) { platform, result in
                        shareResultBlock?(platform, result)
                    }
                    
                }


            }

        }
    }
    
    
    // more分享不给提示
    func shareToMore(activityItems: [Any], shareResultBlock: ResultBlock?) {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        let completeBlock: UIActivityViewController.CompletionWithItemsHandler = { [weak vc] (activityType, completed, items, error) in
            guard let strongVC = vc else { return }
            if let shareBlock = shareResultBlock {
                shareBlock(.more, completed)
            }
            if completed {
                log(.verbose, tag: kModuleViewController, content: "information: send success")
            } else {
                log(.verbose, tag: kModuleViewController, content: "information: send failed")
            }
            strongVC.dismiss(animated: true, completion: nil)
        }
        vc.completionWithItemsHandler = completeBlock
        UIViewController.current().present(vc, animated: true, completion: nil)
    }
    
    //MARK: 1.分享到短信
    func shareToMessage(content: String?, sharingImage: UIImage?, imageUrlString: String?, shareResultBlock: ((Bool) -> Void)?) {
        // 分享短信
        // 1.判断能不能发短信
        if MFMessageComposeViewController.canSendText() {
            // 开始转菊花，进行图片下载
            
            let c = MFMessageComposeViewController()
            c.shareResultBlock = shareResultBlock
            c.body = content
            c.messageComposeDelegate = self
            let presentBlock: (_ image:UIImage?) -> Void = {[weak c] (image) in
                guard let strongC = c else {return}
                if let data = image?.pngData(), data.count > 0 {
                    strongC.addAttachmentData(data, typeIdentifier: "public.png", filename: "icon.png")
                    UIViewController.current().present(strongC, animated: true, completion: nil)
                }
                else if let data = image?.jpegData(compressionQuality: 1), data.count > 0 {
                    strongC.addAttachmentData(data, typeIdentifier: "public.jpeg", filename: "icon.png")
                    UIViewController.current().present(strongC, animated: true, completion: nil)
                }
                else {
                    UIViewController.current().present(strongC, animated: true, completion: nil)
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
                            let hud = YXProgressHUD.showLoading("")
                            let temp = URL(string: imageUrlString)!
                            SDWebImageManager.shared.loadImage(with: temp, options: SDWebImageOptions.retryFailed, progress: { (_, _, _) in
                                
                            }) { (image, data, error, cacheType, finished, imageURL) in
                                hud.hide(animated: true)
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
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "share_not_support_message"), in: UIApplication.shared.keyWindow, hideAfterDelay: 2.0)
        }
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension YXShareManager: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        UIViewController.current().dismiss(animated: true, completion: nil)
        switch result {
        case .sent:
            controller.shareResultBlock!(true)
            print("webview: send message success")
        case .failed:
            controller.shareResultBlock!(false)
            print("webview: send message failed")
        default:
            controller.shareResultBlock!(false)
            print("webview: default")
        }
    }
}

public extension MFMessageComposeViewController {
    private struct AssociatedKey {
        static var shareResultBlock: String = "shareResultBlock"
    }
    var shareResultBlock: ((Bool) -> Void)? {
        get {
            (objc_getAssociatedObject(self, &AssociatedKey.shareResultBlock) as! (Bool) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.shareResultBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}


extension YXShareManager {
    @objc class func shareLinkConfig(with paramsJsonValue: Dictionary<String, Any>?) -> YXShareConfig {
        let config = YXShareConfig()
        config.showMore = true
        config.showCopy = true
        config.showSMS = true
        if paramsJsonValue != nil {
            //config.shareType = (paramsJsonValue?["shareType"] as? String) ?? ""
            config.title = (paramsJsonValue?["title"] as? String) ?? ""
            config.desc = (paramsJsonValue?["description"] as? String) ?? ""
            config.pageUrl = (paramsJsonValue?["pageUrl"] as? String) ?? ""
            config.shortUrl = (paramsJsonValue?["shortUrl"] as? String) ?? ""
            config.longUrl = (paramsJsonValue?["longUrl"] as? String) ?? ""
            //如果shortUrl没有值，那就用pageUrl
            if config.shortUrl.isEmpty {
                config.shortUrl = config.pageUrl
            }
            config.overseaPageUrl = paramsJsonValue?["overseaPageUrl"] as? String  //页面url
            config.thumbUrl = paramsJsonValue?["thumbUrl"] as? String

            config.wxUserName = paramsJsonValue?["wxUserName"] as? String
            config.wxPath = paramsJsonValue?["wxPath"] as? String
            if let value = paramsJsonValue?["withShareTicket"] as? Bool {
                config.withShareTicket = value
            }
            
            if let value = paramsJsonValue?["miniProgramType"] as? UInt {
                config.miniProgramType = value
            }
            
            if let value = paramsJsonValue?["isDialogBgNone"] as? Bool {
                config.isDialogBgNone = value
            }
            
            if let value = paramsJsonValue?["subPlatform"] as? NSNumber, let platform = YXSharePlatform(rawValue: value.uintValue) {
                config.subPlatform = platform
            }
            
            config.imageData = paramsJsonValue?["imageData"]
        }
        
        return config
    }
    
    @objc class func sharePlatform(_ str: String?) -> YXSharePlatform  {
        
        let typeStr = str ?? ""
        if typeStr == "wx_mini_program" {
            return .wxMiniProgram
        } else if typeStr == "copy_link" {
            return .copy
        } else if typeStr == "wechat_friends_circle" {
            return .wechatFriend
        } else if typeStr == "more" {
            return .more
        } else if typeStr == "wechat_friend" {
            return .wechat
        } else if typeStr == "alipay" {
            return .aliSocial
        } else if typeStr == "dingtalk" {
            return .dingTalk
        } else if typeStr == "whatsapp" {
            return .whatsApp
        } else if typeStr == "save" {
            return .save
        } else if typeStr == "facebook" {
            return .facebook
        } else if typeStr == "twitter" {
            return .twitter
        } else if typeStr == "messenger" {
            return .facebookMessenger
        } else if typeStr == "qq" {
            return .QQ
        } else if typeStr == "weibo" {
            return .sinaweibo
        } else if typeStr == "sms" {
            return .sms
        } else if typeStr == "telegram" {
            return .telegram
        } else if typeStr == "uSmartSocial" {
            return .uSmartSocial
        } else if typeStr == "instagram" {
            return .instagram
        } else if typeStr == "line" {
            return .line
        }
        
        return .unKnown
    }
}
