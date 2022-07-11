//
//  YXLiveShareTool.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/15.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveShareTool: NSObject {

    @objc static func share(liveModel: YXLiveDetailModel?, viewController: UIViewController?) {
        guard let model = liveModel else { return }
        let inviteCode = YXUserManager.shared().curLoginUser?.invitationCode ?? ""
        let pageUrl = YXH5Urls.playInviteCodeLiveUrl(with: model.id ?? "", inviteCode: inviteCode)
        let shareType: String = "freedom"
        let title = model.title ?? ""
        let shortUrl = pageUrl
        let thumbUrl = (model.cover_images?.image.first as? String) ?? ""
        var desStr = ""
        if let des = model.detail, let data = des.data(using: .utf8), let att = NSAttributedString.init(htmlData: data, documentAttributes: nil) {
            desStr = att.string
        }
        var wetchatDes = ""
        if let anchorName = model.anchor?.nick_name, anchorName.count > 0 {
            wetchatDes = YXLanguageUtility.kLang(key: "live_instructor") + ": " + anchorName
        } else {
            wetchatDes = desStr
        }
        let image: Any = (thumbUrl.isEmpty) ? UIImage(named: "icon")! : thumbUrl
        
        if let pageURL = URL(string: pageUrl) {
            
            if shareType == "freedom" {
                // 資訊的不支持freedom
                var section0_items: [QMUIMoreOperationItemView] = []
                // 1.Whats app
                if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {
                    let whatsapp = QMUIMoreOperationItemView(image: UIImage(named: "share-whats"), title: YXShareSDKHelper.title(forPlatforms: .typeWhatsApp)) { (controller, itemView) in
                        
                        // 点击后执行的block
                        controller.hideToBottom()
                        
                        let shareText = "\(title)\n\(shortUrl)"
                        YXShareSDKHelper.shareInstance()?.share(.typeWhatsApp, text: shareText, images: nil, url: nil, title: nil, type: .auto, withCallback: { (success, userInfo, _) in
                        })
                    }
                    section0_items.append(whatsapp)
                }
                // 2.facebook
                let fb = QMUIMoreOperationItemView(image: UIImage(named: "share-fb"), title: YXShareSDKHelper.title(forPlatforms: .typeFacebook)) { (controller, itemView) in
                    // 点击后执行的block
                    controller.hideToBottom()
                    
                    if YXShareSDKHelper.isClientIntalled(.typeFacebook) {
                        YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: desStr, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                            
                        })
                    } else {
                        YXShareSDKHelper.shareInstance()?.share(.typeFacebook, text: desStr, images: nil, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
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
                        
                        YXShareSDKHelper.shareInstance()?.share(.typeFacebookMessenger, text: desStr, images: thumbUrl, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
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
                        
                        YXShareSDKHelper.shareInstance()?.share(.typeWechat, text: wetchatDes, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        })
                    }
                    
                    let moment = QMUIMoreOperationItemView(image: UIImage(named: "share-moments"), title: YXShareSDKHelper.title(forPlatforms: .subTypeWechatTimeline)) { (controller, itemView) in
                        // 点击后执行的block
                        controller.hideToBottom()
                        YXShareSDKHelper.shareInstance()?.share(.subTypeWechatTimeline, text: desStr, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        })
                    }
                    
                    section0_items.append(wechat)
                    
                    section0_items.append(moment)
                }
                
                // 5.twitter
                let twitter = QMUIMoreOperationItemView(image: UIImage(named: "share-twitter"), title: YXShareSDKHelper.title(forPlatforms: .typeTwitter)) { (controller, itemView) in
                    // 点击后执行的block
                    controller.hideToBottom()
                    if let shortURL = URL(string: shortUrl) {
                        YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: desStr, images: nil, url: shortURL, title: nil, type: .webPage, withCallback: { (success, userInfo, _) in
                        })
                    } else {
                        YXShareSDKHelper.shareInstance()?.share(.typeTwitter, text: desStr, images: image, url: pageURL, title: title, type: .auto, withCallback: { (success, userInfo, _) in
                        })
                    }
                }
                section0_items.append(twitter)
                
                
                // 7.更多
                let more = QMUIMoreOperationItemView(image: UIImage(named: "share-more"), title: YXLanguageUtility.kLang(key: "share_info_more")) { controller, itemView in
//                    guard let `self` = self else { return }
                    
                    // 点击后执行的block
                    controller.hideToBottom()
                    
                    let image = UIImage(named: "icon")!
                    if let shortURL = URL(string: shortUrl) {
                        let vc = UIActivityViewController(activityItems: [title, image, shortURL], applicationActivities: nil)
                        let completeBlock: UIActivityViewController.CompletionWithItemsHandler = { activityType, completed, items, error in
                            
                            if completed {
 
                            } else {
                                log(.verbose, tag: kModuleViewController, content: "information: send failed")
                            }
                            vc.dismiss(animated: true, completion: nil)
                        }
                        vc.completionWithItemsHandler = completeBlock
                        viewController?.present(vc, animated: true, completion: nil)
                    }
                }
                

                let section1_items: [QMUIMoreOperationItemView] = [more]
                
                
                let vc = YXMoreOperationViewController()
                vc.contentEdgeInsets = UIEdgeInsets(top: 0, left: uniHorLength(10), bottom: YXConstant.deviceScaleEqualToXStyle() ? 0 : 34, right: uniHorLength(10))
                vc.items = [section0_items, section1_items]
                vc.showFromBottom(withBackgroundClear: false)
            }
            
        }
    }
    
    @objc static func shareComment(contentDic:[String:String], viewController: UIViewController? , completion:((_ isSuccess: Bool) -> Void)? ) {
       
        let config = YXShareManager.shareLinkConfig(with: contentDic)
        config.isDefaultShowMessage = true
        if let _ = URL(string: config.pageUrl) {
            config.showCopy = true
            config.showSMS = false
           
            YXShareManager.shared.showLink(config, configBlock: { platform in
               
                if platform == .more {
                    let newConfig = YXShareManager.shareLinkConfig(with: contentDic)
                    newConfig.subImage = UIImage(named: "icon")
                    newConfig.title = "" //  源代码无title, let titleString:String = desStr + " " + shortUrl

                    return newConfig
                }
                return nil
                
            }, itemViewBlock: nil, shareResultBlock: {
                (platform, success) in
                completion?(success)
            })
        }
    }
}
