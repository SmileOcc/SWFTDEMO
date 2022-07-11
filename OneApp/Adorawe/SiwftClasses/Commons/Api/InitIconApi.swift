//
//  InitIconApi.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/8.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RxSwift

class InitIconApi:OSSVBasesRequests{
    override func requestPath() -> String! {
        OSSVNSStringTool.buildRequestPath(.InitIconApiPath)
    }
    
    override func requestSerializerType() -> STLRequestSerializerType {
        .JSON
    }
    
    override func requestMethod() -> STLRequestMethod {
        .POST
    }
    
    
    @objc static func getAppIconInfo(){
        STLNetworkStateManager.shared().networkState {
            let api = InitIconApi()
            api.start { req in
                if let reqJson = OSSVNSStringTool.desEncrypt(req) as? [String:Any],
                   let statusCode =  reqJson[String.kStatusCode] as? Int,
                   let resultMap = reqJson[String.kResult] as? [String:Any],
                   let resultList = resultMap[String.kResultData]
                {
                    if statusCode == 200{
                        let result:[ConfigedIconModel] = NSArray.yy_modelArray(with: ConfigedIconModel.self, json: resultList) as? [ConfigedIconModel] ?? []
                        let userDefault = UserDefaults.standard
                        userDefault.set(resultList, forKey: .kConfigIconData)
                        userDefault.synchronize()
                        result.forEach { item in
                            if let iconSelected = item.icon_src_check,
                               let iconNormarl = item.icon_src_nocheck{
                                cacheDataWith(urlStr: iconSelected)
                                cacheDataWith(urlStr: iconNormarl)
                            }
                        }
                    }
                }
                
            } failure: { _, _ in
            }
        } exception: {
            
        }
    }
    
    static func cacheDataWith(urlStr:String){
        guard let url = URL(string: urlStr) else { return  }
        YYWebImageManager.shared().requestImage(with: url, options: .allowBackgroundTask, progress: nil, transform: nil) { img, url, type, state, err in
            if let img = img {
                YYWebImageManager.shared().cache?.setImage(img, forKey: urlStr)
            }
        }
    }
}

extension String{
    static let kResultData = "data"
    
    static let kConfigIconData = "kConfigIconData"
}




