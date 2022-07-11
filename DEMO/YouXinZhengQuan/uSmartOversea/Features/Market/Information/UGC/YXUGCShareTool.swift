//
//  YXUGCShareTool.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import MessageUI


class YXUGCShareConfigModel: NSObject {
    
    @objc var isHasFavorite = false
    @objc var isFavorite = false
    
    @objc var isHasFont = false
    @objc var isBig = false
    
    @objc var isHasTranslate = false
    @objc var isCn = true
    
    @objc var cid: String = ""
    @objc var contentType: YXUGCShareContentType = .news
}

@objc enum YXUGCShareActionType: Int {
    case share = 0
    case favorite = 1
    case font = 2
    case translate = 3
}

@objc enum YXUGCShareContentType: Int {
    case news = 0
    case article = 1
    case video = 2
}

class YXUGCShareTool: NSObject {
    
    
    var configModel: YXUGCShareConfigModel?
    
    @objc static let shareInstance = YXUGCShareTool.init()
        
    @objc var clickCallBack: ((_ action: YXUGCShareActionType, _ configModel: YXUGCShareConfigModel?) -> ())?
    
    @objc static func showShare(with configModel: YXUGCShareConfigModel?, shareDic: Dictionary<String, Any>?) {
        
        let tool = YXUGCShareTool.shareInstance
        
        tool.configModel = configModel
        
        guard let paramsJsonValue = shareDic else {
            return
        }
        
        let config = YXShareManager.shareLinkConfig(with: paramsJsonValue)
        let  vc =  UIViewController.current()
        config.miniProgramImage = UIImage.qmui_image(with: vc.view)
        config.showCopy = false
        config.isMoreTop = true
        config.isDefaultShowMessage = true
        if let _ = URL(string: config.pageUrl) {
        
            YXShareManager.shared.showLink(config) { platform in
                if platform == .more {
                    let newConfig = YXShareManager.shareLinkConfig(with: paramsJsonValue)
                    newConfig.subImage = UIImage(named: "icon")
                    newConfig.desc = ""
                    return newConfig
                }
                
                return nil
            } itemViewBlock: {  
                var section1_items: [QMUIMoreOperationItemView] = []
                
                if let configModel = configModel {
                    if configModel.isHasFavorite {
                        // 收藏
                        tool.favorite.setTitle(YXLanguageUtility.kLang(key: "news_favorite"), for: .normal)
                        tool.favorite.setTitle(YXLanguageUtility.kLang(key: "news_unfavorite"), for: .selected)
                        tool.favorite.removeTarget(nil, action: nil, for: .allEvents)
                        section1_items.append(tool.favorite)
                        tool.favorite.isSelected = configModel.isFavorite
                        tool.getCollectionStatus()
                        // 获取状态
                    }
                    if configModel.isHasFont {
                        // 字体设置
                        tool.font.setTitle(YXLanguageUtility.kLang(key: "news_set_font"), for: .normal)
                        tool.font.setTitle(YXLanguageUtility.kLang(key: "news_set_font"), for: .selected)
                        tool.font.removeTarget(nil, action: nil, for: .allEvents)
                        section1_items.append(tool.font)
                        tool.font.isSelected = configModel.isBig
                    }
                    
                    if configModel.isHasTranslate {
                        // 翻译设置
                        tool.translate.setTitle(YXLanguageUtility.kLang(key: "news_share_translate"), for: .normal)
                        tool.translate.setTitle(YXLanguageUtility.kLang(key: "news_share_translate"), for: .selected)
                        tool.translate.removeTarget(nil, action: nil, for: .allEvents)
                        section1_items.append(tool.translate)
                        tool.translate.isSelected = !configModel.isCn
                    }
                }
                
                return section1_items
            } shareResultBlock: { platform, success in
                 
            }

        }
        
    }
    
    func getCollectionStatus() {
        
        guard YXUserManager.isLogin() else {
            return
        }
        guard let configModel = self.configModel else { return }
        
        if configModel.contentType == .news {
            let model = YXIsCollectRequestModel.init()
            model.newsid = configModel.cid
            let request = YXRequest.init(request: model)
            request.startWithBlock { responseModel in
                if responseModel.code == .success {
                    if let isFavorite = responseModel.data?["collected"] as? Bool {
                        self.configModel?.isFavorite = isFavorite
                        self.favorite.isSelected = isFavorite
                    }
                    
                } else {
                    YXProgressHUD.showError(responseModel.msg)
                }
                
            } failure: { request in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }

        } else if configModel.contentType == .article {
            let model = YXArticleIsCollectRequestModel.init()
            model.cid = [configModel.cid]
            let request = YXRequest.init(request: model)
            request.startWithBlock { responseModel in
                
                var isFavorite = false
                if responseModel.code == .success {
                    if let list = responseModel.data?["cid"] as? [Int64] {
                        if list.contains(Int64(configModel.cid) ?? 0) {
                            isFavorite = true
                        }
                    }
                    
                } else {
                    YXProgressHUD.showError(responseModel.msg)
                }
                self.configModel?.isFavorite = isFavorite
                self.favorite.isSelected = isFavorite
            } failure: { request in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }
        } else {
            let model = YXVideoIsCollectRequestModel.init()
            model.id = configModel.cid
            let request = YXRequest.init(request: model)
            request.startWithBlock { responseModel in
                if responseModel.code == .success {
                    if let isFavorite = responseModel.data?["has_collected"] as? Bool {
                        self.configModel?.isFavorite = isFavorite
                        self.favorite.isSelected = isFavorite
                    }
                    
                } else {
                    YXProgressHUD.showError(responseModel.msg)
                }
                
            } failure: { request in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }

        }
    }
    
    func collectionRequest() {
        guard let configModel = self.configModel else { return }
        
        if configModel.contentType == .news {
            let model = YXCollectRequestModel.init()
            model.newsids = configModel.cid
            model.collectflag = !configModel.isFavorite
            let request = YXRequest.init(request: model)
            request.startWithBlock { responseModel in
                if responseModel.code == .success {
                    configModel.isFavorite = !configModel.isFavorite
                    if configModel.isFavorite {
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "collection_success"))
                    } else {
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "collection_cancel"))
                    }
                } else {
                    YXProgressHUD.showError(responseModel.msg)
                }
                
            } failure: { request in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }
        } else if configModel.contentType == .article {
            let model = YXAritckcCollectRequestModel.init()
            model.cid = [configModel.cid]
            model.collect_type = configModel.isFavorite ? 2 : 1
            let request = YXRequest.init(request: model)
            request.startWithBlock { responseModel in
                if responseModel.code == .success {
                    configModel.isFavorite = !configModel.isFavorite
                    if configModel.isFavorite {
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "collection_success"))
                    } else {
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "collection_cancel"))
                    }
                } else {
                    YXProgressHUD.showError(responseModel.msg)
                }
                
            } failure: { request in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }
        } else {
            
            var request: YXRequest!
            if configModel.isFavorite {
                let a = YXVideoCancelCollectRequestModel.init()
                a.id = configModel.cid
                request = YXRequest.init(request: a)
            } else {
                let b = YXVideoAddCollectRequestModel.init()
                b.id = configModel.cid
                request = YXRequest.init(request: b)
            }
                                                
            request.startWithBlock { responseModel in
                if responseModel.code == .success {
                    configModel.isFavorite = !configModel.isFavorite
                    if configModel.isFavorite {
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "collection_success"))
                    } else {
                        YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "collection_cancel"))
                    }
                } else {
                    YXProgressHUD.showError(responseModel.msg)
                }
                
            } failure: { request in
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "common_net_error"))
            }
        }
    }
    
    
    lazy var favorite: QMUIMoreOperationItemView = {
        let favorite = QMUIMoreOperationItemView(image: UIImage(named: "share-unfavorite"), selectedImage: UIImage(named: "share-favorite"), title: YXLanguageUtility.kLang(key: "news_favorite"), selectedTitle: YXLanguageUtility.kLang(key: "news_unfavorite")) { [weak self] (controller, itemView) in
            guard let `self` = self else { return }
            
            // 点击后执行的block
//            controller.hideToBottom()
            
            if let finalVc = controller as? YXMoreOperationViewController {
                finalVc.hide {
                    if YXUserManager.isLogin() {
                        self.collectionRequest()
                    } else {
                        (YXNavigationMap.navigator as? NavigatorServices)?.pushToLoginVC(callBack: nil)
                    }
                }
            }
            
        }
        return favorite
    }()
    
    lazy var font: QMUIMoreOperationItemView = {
        let font = QMUIMoreOperationItemView(image: UIImage(named: "share-small-font"), selectedImage: UIImage(named: "share-large-font"), title: YXLanguageUtility.kLang(key: "news_set_font"), selectedTitle: YXLanguageUtility.kLang(key: "news_set_font")) { [weak self] (controller, itemView) in
            guard let `self` = self else { return }
            
            // 点击后执行的block
            controller.hideToBottom()
            self.clickCallBack?(.font, self.configModel)
        }
        return font
    }()
    
    lazy var translate: QMUIMoreOperationItemView = {
        let font = QMUIMoreOperationItemView(image: UIImage(named: "news_traslate"), selectedImage: UIImage(named: "news_traslate_select"), title: YXLanguageUtility.kLang(key: "news_share_translate"), selectedTitle: YXLanguageUtility.kLang(key: "news_share_translate")) { [weak self] (controller, itemView) in
            guard let `self` = self else { return }
            
            // 点击后执行的block
            controller.hideToBottom()
            self.clickCallBack?(.translate, self.configModel)
        }
        return font
    }()
}
