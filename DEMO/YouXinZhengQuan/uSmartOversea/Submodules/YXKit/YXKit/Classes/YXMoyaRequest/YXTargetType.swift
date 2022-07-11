//
//  YXMoyaRequest.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya
import MMKV

@objc public enum YXRequestType: Int {
    case hzRequest
    case jyRequest
    case wjRequest
    case zxRequest
}

public extension YXTargetType {
    var yx_headers: [String: String] {
        
        var headers = YXHeaders.httpHeaders()

        if let contentType = contentType {
            headers["Content-Type"] = contentType
        }
        
        switch self.requestType {
        case .hzRequest:
            if YXGlobalConfigManager.configURL(type: .hzCenter) != self.baseURL.absoluteString {
                headers["Host"] = YXUrlRouterConstant.hzBaseUrlWithoutScheme()
            }
        case .jyRequest:
            if YXGlobalConfigManager.configURL(type: .jyCenter) != self.baseURL.absoluteString {
                headers["Host"] = YXUrlRouterConstant.jyBaseUrlWithoutScheme()
            }
        case .wjRequest:
            if YXGlobalConfigManager.configURL(type: .wjCenter) != self.baseURL.absoluteString {
                headers["Host"] = YXUrlRouterConstant.wjBaseUrlWithoutScheme()
            }
        case .zxRequest:
            if YXGlobalConfigManager.configURL(type: .zxCenter) != self.baseURL.absoluteString {
                headers["Host"] = YXUrlRouterConstant.zxBaseUrlWithoutScheme()
            }
        }
        
        return headers
    }
}

public protocol YXTargetType: TargetType {
    
    var servicePath: String { get }
    var contentType: String? { get }
    var requestType: YXRequestType { get }
}

@objc public class YXHeaders: NSObject {
    @objc public class func httpHeaders() -> [String: String] {
        let xTransId = NSUUID().uuidString
        let xTime = "\(Int64(Date().timeIntervalSince1970 * 1000))"
        let xDt = "t2" //t2代表苹果
        let xDevId = YXConstant.deviceUUID
        let xUid = "\(YXUserHelper.currentUUID())"
        let xLang = "\(YXUserHelper.currentLanguage())" //语言 1-简体  2-繁体  3-英文
        let xType = YXConstant.appType  //app类型 1-大陆版  2-港版
        let xVer = YXConstant.appVersion ?? ""
        let xToken = YXKitUtil.xTokenGenerate(withXTransId: xTransId, xTime: xTime, xDt: xDt, xDevId: xDevId, xUid: xUid, xLang: xLang, xType: xType, xVer: xVer)

        // downloadCid：下载渠道id,默认为AppStore
        let downloadCid = "AppStore"

        // registerCt：注册渠道类型
        let registerCt = YXConstant.launchChannel?.isEmpty ?? true ? "1" : "ecp"

        // registerCid：注册渠道id, 如果没有YXConstant.launchChannel，则使用downloadCid作为registerCid
        let registerCid: String = YXConstant.launchChannel ?? downloadCid
        
        let xRegion = MMKV.default().int32(forKey: YXConstant.berichRegionKey, defaultValue: 2)
        
        // registerICode：注册邀请码
        let registerICode: String = YXConstant.registerICode ?? ""
        
        let xRe = "{\"register-ct\":\"\(registerCt)\",\"download-cid\":\"\(downloadCid)\",\"register-cid\":\"\(registerCid)\",\"ICode\":\"\(registerICode)\"}"
        
        var headers: [String: String] = ["Authorization": YXUserHelper.currentToken(),
                                        "X-Ver"        : xVer,
                                        "X-Dt"         : xDt,
                                        "X-Time"       : xTime,
                                        "X-Trans-Id"   : xTransId,
                                        "X-Net-Type"   : YXNetworkUtil.sharedInstance().networkType(),
                                        "X-Uid"        : xUid,
                                        "X-Dev-Info"   : YXConstant.deviceInfo(),                                                  //设备信息
                                        "X-Idfa"       : YXIDFAHelper.getIDFA() ?? "",
                                        "X-Request-Id" : "\(YXConstant.flakeId())",  //交易用请求id
                                        "X-Lang"       : xLang,
                                        "X-Type"       : xType,
                                        "X-Dev-Id"     : xDevId,
                                        "X-Re"         : xRe,
                                        "Referer"      : "www.yxzq.com",
                                        "X-Token"      : xToken,
                                        /*"X-Region"     : String(xRegion),
                                        "X-BrokerNo"   : YXUserHelper.currentBroker(),
                                        "BrokerAuthorization":YXUserHelper.currentBrokerToken()*/
                                        ]
        
        if YXConstant.appTypeValue == .EDUCATION {
            headers["X-Region"] = String(xRegion)
        }else if YXConstant.appTypeValue == .OVERSEA_SG {
            headers["X-BrokerNo"] = "sg"
            // headers["BrokerAuthorization"] = YXUserHelper.currentBrokerToken()
            headers["X-Region"] = String(3)
        }else {
            headers["X-Region"] = nil
            headers["X-BrokerNo"] = nil
            headers["BrokerAuthorization"] = nil
        }
        // 这个字段用于控制是否开启双向证书校验,在生产环境下,默认是开启双向校验的
        if headers["X-Challenge"] == nil {
            if YXGlobalConfigManager.isCertificateCheckOn() == false {
                headers["X-Challenge"] = "Cancel"
            }
        }
    
        return headers
    }
}
