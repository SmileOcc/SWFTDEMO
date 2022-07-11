//
//  YXCouponBannerReq.swift
//  uSmartOversea
//
//  Created by usmart on 2022/5/24.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXCouponBannerReq: YXJYBaseRequestModel {
    override func yx_requestUrl() -> String {
//        return "/activity-server/api/get-intraday-stock-infos/v1"
        return "activity-server-sg/api/get-coupon-banner/v1"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXCouponBannerResModel.self
    }
}

class YXCouponBannerResModel: YXResponseModel {
    @objc var list : [YXCouponBannerListModel] = []
    @objc var text : String = ""
    @objc var coupon_banner : String = "coupon_banner"
    @objc var couponbanner_id : Int = 0
    @objc var customer_status : Int = 0

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return ["list": YXCouponBannerListModel.self]
    }
    
    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "list": "data.list",
            "text": "data.text",
            "couponbanner_id": "data.id",
            "coupon_banner": "data.type",
            "customer_status": "data.status"
        ]
    }
    
}

class YXCouponBannerListModel: NSObject {
    @objc var imgurl : String?

}
