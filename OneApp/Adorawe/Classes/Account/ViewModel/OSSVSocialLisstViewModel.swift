//
//  OSSVSocialLisstViewModel.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/12.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import ObjectMapper

class OSSVSocialLisstViewModel: BaseViewModel {

    override func requestNetwork(_ parmaters: Any!, completion: ((Any?) -> Void)!, failure: ((Any?) -> Void)!) {
        let api = OSSVSociaslListsAip.init()
        api.start { req in
            
            var results:NSArray?
//            if let reqDic = OSSVNSStringTool.desEncrypt(req) as? [String:Any]{
//                if reqDic[kStatusCode] as? Int32 == kStatusCode_200 {
//                    results = NSArray.yy_modelArray(with: OSSVSocialsPlatformsModel.self, json: reqDic[kResult] ?? []) as NSArray?
//                }
//            }
            
            if let reqDic = OSSVNSStringTool.desEncrypt(req) as? [String:Any]{
                if reqDic[kStatusCode] as? Int32 == kStatusCode_200 {
                    results = Mapper<OSSVSocialsPlatformsModel>().mapArray(JSONObject: reqDic[kResult]) as NSArray?
                }
            }
            
            if (completion != nil) {
                completion(results)
            }
        } failure: { req, err in
            if (failure != nil) {
                failure(nil)
            }
        }

    }
}
