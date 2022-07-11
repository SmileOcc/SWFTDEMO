//
//  YXStockDetailRequestHelper.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailRequestHelper: NSObject {

    //static let shared = YXStockDetailRequestHelper()

    class func checkIndustryUpdate(_ completion: (() -> Void)? = nil) {

        let version_a = 0
        let version_hk = 0
        let version_us = 0

        //        if let data = MMKV.default().data(forKey: brokerListPath) {
        //            let dic = try? JSONSerialization.jsonObject(with: data, options: [])
        //            if let finalDic = dic as? [String: Any] {
        //                if let str = finalDic["version"] as? Int, let arr = finalDic["broker_list"] as? [String: Any], arr.count > 0 {
        //                    version = str
        //                }
        //            }
        //        }

        let requestModel = YXStockStareIndustryRequestModel()
        requestModel.version_a = version_a
        requestModel.version_hk = version_hk
        requestModel.version_us = version_us
        let request = YXRequest.init(request: requestModel)

        request.startWithBlock(success: { (responseModel) in    
            if responseModel.code == .success {
                //                if let dic = responseModel.data as? [String: Any], let nowVer = dic["version"] as? Int64 {
                //                    if nowVer != version {
                //                        if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                //                            MMKV.default().set(data, forKey: brokerListPath)
                //                        }
                //                    }

                //                }

                if let dic = responseModel.data as? [String: Any] {
                    if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                        MMKV.default().set(data, forKey: industryListPath)
                        completion?()
                    }
                }
            }
        }, failure: { (request) in

        })
    }

}
