//
//  YXQCloudService.swift
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/8.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import QCloudCOSXML

struct YXQCloudCOSModel: Codable {
    let sessionToken, tmpSecretID, tmpSecretKey, expiredTime: String
    let currentTimestamp: Int

    enum CodingKeys: String, CodingKey {
        case sessionToken
        case tmpSecretID = "tmpSecretId"
        case tmpSecretKey, expiredTime, currentTimestamp
    }
}

class YXQCloudService: NSObject, ApplicationService, QCloudSignatureProvider {
    
    @objc let credentialFenceQueue = QCloudCredentailFenceQueue() //腾讯云线程
    
    @objc static let keyQCloudGuangZhou = "ap-guangzhou"
    
    @objc static let keyQCloudShenZhenFsi = "ap-shenzhen-fsi"
    
    @objc static let keyQCloudHongKong = "ap-hongkong"
    
    @objc static let keyQCloudSingapore = "ap-singapore"
    
    @objc static let AESKey = ")O[NB]6,YF}+efca"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //上传图片初始化
        configureQCloud()
        
        // 关闭腾讯移动分析(mta)的功能
        TACMTAConfig.getInstance()?.statEnable = false
        return true
    }
    
    //腾讯云签名
    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        let credential = QCloudCredential.init();
        // 临时密钥 SecretId
        credential.secretID = YXUserManager.shared().qCloudSecretID;
        // 临时密钥 SecretKey
        credential.secretKey = YXUserManager.shared().qCloudSecretKey;
        // 临时密钥 Token
        credential.token = YXUserManager.shared().qCloudToken;
        /** 强烈建议返回服务器时间作为签名的开始时间, 用来避免由于用户手机本地时间偏差过大导致的签名不正确(参数startTime和expiredTime单位为秒)
        */
        credential.startDate = Date.init(timeIntervalSince1970: TimeInterval(YXUserManager.shared().qCloudCurrentTimestamp / 1000))
        let expiredTime = Int(YXUserManager.shared().qCloudExpiredTime) ?? 0
        credential.experationDate = Date.init(timeIntervalSince1970: TimeInterval(expiredTime))
        let creator = QCloudAuthentationV5Creator.init(credential: credential);
        let signature = creator?.signature(forData: urlRequst);
        continueBlock(signature,nil);
    }
    
    //上传图片初始化
    func configureQCloud() {
        let guangZhouConfiguration = QCloudServiceConfiguration()
        guangZhouConfiguration.appID = "1257884527"
        guangZhouConfiguration.signatureProvider = self
        let guangZhouEndpoint = QCloudCOSXMLEndPoint()
        guangZhouConfiguration.endpoint = guangZhouEndpoint
        guangZhouEndpoint.regionName = YXQCloudService.keyQCloudGuangZhou
        guangZhouEndpoint.useHTTPS = true
        QCloudCOSXMLService.registerCOSXML(with: guangZhouConfiguration, withKey: YXQCloudService.keyQCloudGuangZhou)
        QCloudCOSTransferMangerService.registerCOSTransferManger(with: guangZhouConfiguration, withKey: YXQCloudService.keyQCloudGuangZhou)
        
        let shenZhenConfiguration = QCloudServiceConfiguration()
        shenZhenConfiguration.appID = "1257884527"
        shenZhenConfiguration.signatureProvider = self
        let shenZhenEndpoint = QCloudCOSXMLEndPoint()
        shenZhenConfiguration.endpoint = shenZhenEndpoint
        shenZhenEndpoint.regionName = YXQCloudService.keyQCloudShenZhenFsi
        shenZhenEndpoint.useHTTPS = true
        QCloudCOSXMLService.registerCOSXML(with: shenZhenConfiguration, withKey: YXQCloudService.keyQCloudShenZhenFsi)
        QCloudCOSTransferMangerService.registerCOSTransferManger(with: shenZhenConfiguration, withKey: YXQCloudService.keyQCloudShenZhenFsi)
        
        let hongKongConfiguration = QCloudServiceConfiguration()
        hongKongConfiguration.appID = "1257884527"
        hongKongConfiguration.signatureProvider = self
        let hongKongEndpoint = QCloudCOSXMLEndPoint()
        hongKongConfiguration.endpoint = hongKongEndpoint
        hongKongEndpoint.regionName = YXQCloudService.keyQCloudHongKong
        hongKongEndpoint.useHTTPS = true
        QCloudCOSXMLService.registerCOSXML(with: hongKongConfiguration, withKey: YXQCloudService.keyQCloudHongKong)
        QCloudCOSTransferMangerService.registerCOSTransferManger(with: hongKongConfiguration, withKey: YXQCloudService.keyQCloudHongKong)
        
        let singaporeConfiguration = QCloudServiceConfiguration()
        singaporeConfiguration.appID = "1257884527"
        singaporeConfiguration.signatureProvider = self
        let singaporeEndpoint = QCloudCOSXMLEndPoint()
        singaporeConfiguration.endpoint = singaporeEndpoint
        singaporeEndpoint.regionName = YXQCloudService.keyQCloudSingapore
        singaporeEndpoint.useHTTPS = true
        QCloudCOSXMLService.registerCOSXML(with: singaporeConfiguration, withKey: YXQCloudService.keyQCloudSingapore)
        QCloudCOSTransferMangerService.registerCOSTransferManger(with: singaporeConfiguration, withKey: YXQCloudService.keyQCloudSingapore)
    }
}
