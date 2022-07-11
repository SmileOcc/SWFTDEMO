//
//  YXShortUrlRequestModel.swift
//  YouXinZhengQuan
//
//  Created by provswin on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXShortUrlRequestModel: YXHZBaseRequestModel {
    @objc var long : String = ""
//    @objc var type = 0
    
    override func yx_requestUrl() -> String {
        return "/news-shorturl/api/v1/geturl"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:];
    }
    
    @objc class func startRequest(longUrl: String, callback: (@escaping (_ qrcodeUrlString: String)->Void)) {
        let requestModel = YXShortUrlRequestModel()
        requestModel.long = longUrl
//        requestModel.type = 0
        
        let request = YXRequest(request: requestModel)
        request.startWithBlock { responseModel in
            if responseModel.code == .success, let data = responseModel.data as? [String : Any], let url = data["url"] as? String, !url.isEmpty {
                let result = "\(YXUrlRouterConstant.staticResourceBaseUrl())/\(url)"
                callback(result)
            } else {
                callback(longUrl)
            }
        } failure: { request in
            callback(longUrl)
        }
    }
}

class YXShareConfigRequestModel: YXJYBaseRequestModel {
    @objc var sceneKey : String = ""
    @objc var ICode : String?
    
    override func yx_requestUrl() -> String {
        return "/customer-relationship-server/web/get-app-sharing-config-by-key-app/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }
    
    @objc class func startRequest(type: YXShareSceneKey, callback: (@escaping (_ model: YXShareSceneModel?)->Void)) {
        let requestModel = YXShareConfigRequestModel()
        requestModel.sceneKey = type.sceneKey
        if YXUserManager.isLogin(), let code = YXUserManager.shared().curLoginUser?.invitationCode, !code.isEmpty {
            requestModel.ICode = code
        }
        let request = YXRequest(request: requestModel)
        request.startWithBlock { responseModel in
            if responseModel.code == .success, let data = responseModel.data as? [String : Any], let configModel = YXShareSceneModel.yy_model(with: data) {
                if let url = URL(string: configModel.registerPageLink), url.scheme != nil {
                    
                } else {
                    configModel.registerPageLink = "\(YXUrlRouterConstant.staticResourceBaseUrl())/\(configModel.registerPageLink)"
                }
                
                callback(configModel)
            } else {
                callback(nil)
            }
        } failure: { request in
            callback(nil)
        }
    }
}


class YXShareSceneModel: YXModel {
    @objc var id: Int = 0
    @objc var guideCopywriting: String = "" //"引导文案xxx",
    @objc var registerPageLink: String = ""
    @objc var sharingLinkIcon: String = ""
    @objc var sceneName: String = ""
    @objc var sceneKey: String = ""
    @objc var username: String = ""
    
    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return ["username" : "operator"]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [:]
    }
}

