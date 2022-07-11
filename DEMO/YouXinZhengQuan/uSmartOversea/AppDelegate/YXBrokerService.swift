//
//  YXBrokerService.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate


let brokerListPath = "hk_brokerListPath"
let industryListPath = "industryListPath"
let indexListPath = "indexListPath"

class YXBrokerService: NSObject, ApplicationService{
    
    func checkUpdate() {
        var version = 0
        if let data = MMKV.default().data(forKey: brokerListPath) {
            let dic = try? JSONSerialization.jsonObject(with: data, options: [])
            if let finalDic = dic as? [String: Any] {

                if let arr = finalDic["broker_list"] as? [Any], arr.count > 0 {
                    if let str = finalDic["version"] as? Int {
                        version = str
                    }
                }
            }
        }
        let sevice = YXQuotesDataService.init()
        
        sevice.request(.getBrokerList(version: version), response: { (response) in

            switch response {
            case .success(let result, let code):
                if let code = code, code == .success {
                    
                    if let dic = result.data?.value as? [String: Any] {
                        if let nowVer = dic["version"] as? Int64 {
                            if nowVer != version {
                                if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                                    MMKV.default().set(data, forKey: brokerListPath)
                                }
                            }
                        }
                    }
                }
            case .failed( _):
                print("")
            }
        } as YXResultResponse<JSONAny>).disposed(by: YXUserManager.shared().disposeBag)
    }

    

    func checkIndexUpdate() {

        let version = 0

        let requestModel = YXStockStareIndexRequestModel()
        requestModel.version = version

        let request = YXRequest.init(request: requestModel)

        request.startWithBlock(success: { (responseModel) in
//            guard let code = responseModel?.code else { return }
            if responseModel.code == .success {
                if let dic = responseModel.data as? [String: Any] {
                    if let data = try? JSONSerialization.data(withJSONObject: dic, options: []) {
                        MMKV.default().set(data, forKey: indexListPath)
                    }
                }
            }
        }, failure: { (request) in

        })
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        checkUpdate()
//        YXStockDetailRequestHelper.checkIndustryUpdate()
//        checkIndexUpdate()
        return true
    }

}
