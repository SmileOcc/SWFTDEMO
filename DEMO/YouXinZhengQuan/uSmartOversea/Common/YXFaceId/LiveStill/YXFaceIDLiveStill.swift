//
//  YXFaceIDLiveStill.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import ReactiveSwift
import MGFaceIDLiveDetect
import QCloudCOSXML

class YXFaceIDLiveStill: NSObject {
    
    //comparisonType 0: 无源比对，1: 有源比对
    @objc public class func kApiKey(with comparisonType: Int = 1) -> String {
        if comparisonType == 1 {
            #if PRD || PRD_HK
            return "ebX2Ic4o3JY3iB-pnFq0f4k8y-cXVSL9"
            #else
            return "NTxCzMBx97n4xQRVbxjiUyXzAk_Ufil6"
            #endif
        } else if comparisonType == 0 {
            #if PRD || PRD_HK
            return "32wPQ4E7-olyL9bki08AZu3hCLnfJAtZ" //无源-生产
            #else
            return "kRGBQOqnVmtx62A1fv06sYJypounmvuW" //无源-测试开发
            #endif
        }
        return ""
    }
    
    @objc public class func kApiSecret(with comparisonType: Int = 1) -> String {
        if comparisonType == 1 {
            #if PRD || PRD_HK
            return "omXo8L7I5-woQEwrr54JCb-qm50__oby"
            #else
            return "XGfvtuJFSpAC4Rm_QBNYuNcsIWMNUBfg"
            #endif
        } else if comparisonType == 0 {
            #if PRD || PRD_HK
            return "Y43b_dzCUzqGQIGJ2A_yrluku8Nav2rh" //无源-生产
            #else
            return "r0OlAWg3f7Z2n49veY-xubIJxHeDrbXu" //无源-测试开发
            #endif
        }
        return ""
    }
    
    var sign: String?
    
    var sign_version: String?
    
    var isDetecting = false
    
    var videoFilePath: String?
    
    @objc public static var comparisonType: Int = 1 //为“有源比对”或“无源比对”。取值只为“1”或“0”
    
    //有源比对
    func startDetect(idCardName: String, idCardNumber: String, bizToken: String?, currentVC: UIViewController, compelete: @escaping (_ dictionary: Dictionary<String, Any>?, _ error: YXFaceIdDetectError?) -> Void) -> Void {
        
        YXFaceIDLiveStill.comparisonType = 1
        
        let helper = YXFaceIdSignHelper()
        self.sign = helper.getFaceIDSignStr()
        self.sign_version = helper.getFaceIDSignVersionStr()
        
        if let bizToken = bizToken, !bizToken.isEmpty {
            self.startMGFaceIDLiveDetect(bizToken, currentVC: currentVC, compelete: compelete)
        } else {
            /**
             get_liveness_video: 0 1 2 3
              0:不保存视频图片
              1：保存视频图片
              2：保存视频
              3：保存图片
             */
            
            let isSaveVideoPhoto = "1"
            let config: [String: String] = [
                "sign" : self.sign!,
                "sign_version": self.sign_version!,
                "security_level" : "2",
                "comparison_type": "\(YXFaceIDLiveStill.comparisonType)",
                "idcard_name" : idCardName,
                "idcard_number" : idCardNumber,
                "get_liveness_video" : isSaveVideoPhoto
            ]
            
            getBizToken(liveConfig: config) { [weak self] (responseModel, error) in
                guard let `self` = self else { return }
                if let responseModel = responseModel,
                    let bizToken = responseModel.bizToken, !bizToken.isEmpty {
                    self.startMGFaceIDLiveDetect(bizToken, currentVC: currentVC, compelete: compelete)
                } else {
                    compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: "BizToken无效"))
                }
            }
        }
    }
    
    //无源比对
    func startPassiveDetect(with image: UIImage, bizToken: String?, currentVC: UIViewController, compelete: @escaping (_ dictionary: Dictionary<String, Any>?, _ error: YXFaceIdDetectError?) -> Void) -> Void {
        
        YXFaceIDLiveStill.comparisonType = 0
        
        let helper = YXFaceIdSignHelper()
        self.sign = helper.getFaceIDSignStr()
        self.sign_version = helper.getFaceIDSignVersionStr()
        
        if let bizToken = bizToken, bizToken.count > 0 {
            self.startMGFaceIDLiveDetect(bizToken, currentVC: currentVC, compelete: compelete)
        } else {
            let isSaveVideoPhoto = "1"
            let config: [String: String] = [
                "sign" : self.sign!,
                "sign_version": self.sign_version!,
                "security_level" : "2",
                "comparison_type": "\(YXFaceIDLiveStill.comparisonType)",
                "uuid": "\(YXUserManager.userUUID())",
                "get_liveness_video" : isSaveVideoPhoto
            ]

            getBizToken(liveConfig: config, image: image) { [weak self] (responseModel, error) in
                guard let `self` = self else { return }
                if let responseModel = responseModel,
                    let bizToken = responseModel.bizToken, !bizToken.isEmpty {
                    
                    self.startMGFaceIDLiveDetect(bizToken, currentVC: currentVC, compelete: compelete)
                } else {
                    compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: "BizToken无效"))
                }
            }
        }

    }
    
    fileprivate func startMGFaceIDLiveDetect(_ bizToken: String, currentVC: UIViewController, compelete: @escaping (_ dictionary: Dictionary<String, Any>?, _ error: YXFaceIdDetectError?) -> Void) {
        #if targetEnvironment(simulator)
        #else
        //防止重复调用
        if isDetecting { return }
        
        var error: MGFaceIDLiveDetectError?
        
        var lang = MGFaceIDLiveDetectLanguageEn
        switch YXUserManager.curLanguage() {
        case .CN, .HK:
            lang = MGFaceIDLiveDetectLanguageCh
        default:
            break
        }
        var bundleFilePath = ""
        if let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            bundleFilePath = documentPath + "/MGFaceIDLiveCustomDetect.bundle"
        }
        _ = MGFaceIDLiveDetectManager.designationMGFaceIDLiveDetectFilePath(bundleFilePath)
        let detectManager = MGFaceIDLiveDetectManager.init(mgFaceIDLiveDetectManagerWithBizToken: bizToken, language: lang, networkHost: "https://api-sgp.megvii.com", extraData: nil, error: &error)
        if error != nil {
            // 初始化失败
            compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: YXLanguageUtility.kLang(key: "common_unknown_error")))
            return
        }
        
        /**
         Printing description of extraOutDataDict:
         ▿ Optional<Dictionary<AnyHashable, Any>>
           ▿ some : 1 element
             ▿ 0 : 2 elements
               ▿ key : AnyHashable("videoPath")
                 - value : "videoPath"
               - value : /private/var/mobile/Containers/Data/Application/DFE4293E-7853-4B7D-862B-51DC5CEBC6AF/tmp/MegviiUserActionLive.data
         */
        //  可选方法-当前使用默认值
        if let detectManager = detectManager {
            let properties = [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE:"Open Account_Face verification",
                              YXSensorAnalyticsPropsConstant.PROP_VIEW_ACTION:"showed",
                              YXSensorAnalyticsPropsConstant.PROP_PAGE_MEDIA:"app"]
            YXSensorAnalyticsTrack.track(withEvent: .viewEvent, properties: properties)
            let customConfigItem = MGFaceIDLiveDetectCustomConfigItem()
            detectManager.setMGFaceIDLiveDetectCustomUIConfig(customConfigItem)
            detectManager.setMGFaceIDLiveDetectPhoneVertical(MGFaceIDLiveDetectPhoneVerticalFront)
            isDetecting = true
            detectManager.startMGFaceIDLiveDetect(withCurrentController: currentVC) { [weak self] (error, deltaData, bizTokenStr, extraOutDataDict) in
                guard let `self` = self else { return }
                self.isDetecting = false
                log(.debug, tag: kOther, content: "MGFaceID Live Detect errorType: \(String(describing: error?.errorType)), errorMessageStr: \(String(describing: error?.errorMessageStr))")
                
       
                 // 视频路径数据，需要后台verify校验接口返回解密key(活体校验成功就有key)
                 if let extraDic = extraOutDataDict, let videoPath = extraDic["videoPath"] as? String {
                     self.videoFilePath = videoPath
                 }
               
                
                if let error = error {
                    if error.errorType == MGFaceIDLiveDetectErrorNone {
                        var jsData = Dictionary<String, Any>()
                        jsData["sign"] = self.sign
                        jsData["sign_version"] = self.sign_version
                        jsData["biz_token"] = bizTokenStr
                        jsData["meglive_data"] = deltaData?.base64EncodedString()
                        compelete(jsData, nil)
                    } else {
                        compelete(nil, YXFaceIdDetectError.init(error.errorType, errorMessageStr: error.errorMessageStr as String))
                    }
                } else {
                    // 初始化失败
                    compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: YXLanguageUtility.kLang(key: "common_unknown_error")))
                }
            }
        } else {
            isDetecting = false
            // 初始化失败
            compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: YXLanguageUtility.kLang(key: "common_unknown_error")))
        }
        #endif
    }

    fileprivate func getBizToken(liveConfig: Dictionary<String, String>?, image: UIImage? = nil, compelete: @escaping (_ responseModel: YXFaceIDBizTokenResponseModel?, _ error: YXFaceIdDetectError?) -> Void) -> Void {
        faceIdProvider.request(.bizToken("meglive", liveConfig, image)) { (result) in
            switch result {
            case let .success(moyaResponse):
                do {
                    let json = try moyaResponse.mapString()
                    let jsonData = Data(json.utf8)
                    let decoder = JSONDecoder()
                    let model = try decoder.decode(YXFaceIDBizTokenResponseModel.self, from: jsonData)
                    compelete(model, nil)
                } catch {
                    compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: "获取BizToken失败"))
                }
            case .failure(_):
                compelete(nil, YXFaceIdDetectError.init(MGFaceIDLiveDetectErrorUnknown, errorMessageStr: "获取BizToken失败"))
            }
        }
    }

    func decryVideoPath(decryptKey: String) {
        #if targetEnvironment(simulator)
        #else
            if let videoPath = self.videoFilePath {
                
                // 视频路径数据，需要后台verify校验接口返回解密key(活体校验成功就有key)
                let result: MGFaceIDLivenessFileResult = MGFaceIDLiveDetectManager.decryptVideoPath(videoPath, key: decryptKey)
                if result.resultCode == MGFaceIDLivenessResultCodeSucceed {
                    
                    for files in result.files {
                        if files.fileType == "video" {
                            uploadVideoTXY(url: files.path)
                            return
                        }
                    }
                }
            }
        #endif
    }

    func uploadVideoTXY(url: String) {

        var region = YXQCloudService.keyQCloudHongKong
        if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            region = YXQCloudService.keyQCloudSingapore
        } else {
            region = YXQCloudService.keyQCloudGuangZhou
        }

        let fileName = String(format: "video/ios_video_%llu_%ld.mov", YXUserManager.userUUID(), Int(Date().timeIntervalSince1970 * 1000))

        YXUserManager.updateToken(fileName: fileName, region: region, bucket: YXUrlRouterConstant.headerImageBucket()) {

            let url = URL(fileURLWithPath: url)
            let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
            put.object = fileName
            put.bucket =  YXUrlRouterConstant.headerImageBucket()
            put.body = url as AnyObject
            put.customHeaders.setObject("www.yxzq.com", forKey: "Referer" as NSCopying)

            put.sendProcessBlock = { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                print("upload \(bytesSent) totalSend \(totalBytesSent) aim \(totalBytesExpectedToSend)")
            }

            put.finishBlock = { outputObject, error in

                if error != nil {
                    print("上传结果 失败======\n\n")

                } else {
                    if let objetResutl = outputObject as? QCloudUploadObjectResult {
                        let txVideoPath = objetResutl.location
                        print("视频路径：" + txVideoPath)
                        facelIDAPPProvider.request(.saveVideoUrl(txVideoPath)) { result in
                            print(result)
                            print("上传结果======\n\n")
                        }
                    }
                }

            };

            QCloudCOSTransferMangerService.costransfermangerService(forKey: region).uploadObject(put)

        } failed: { (msg) in
            print(msg)
        }

    }
}
