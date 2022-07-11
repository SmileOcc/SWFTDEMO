//
//  OSSVNewChannelViewController+Analyse.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/16.
//  Copyright © 2021 starlink. All rights reserved.
//


///埋点
extension NSObject{
    
    func bannerViewed(attr_node_2:String,attr_node_3:String = "") {
        let sensorsDic = [
            "page_name": "OSSVNewChannelViewController",
            "attr_node_1": "new_arrival",
            "attr_node_2": attr_node_2,
            "attr_node_3": attr_node_3
        ]
        OSSVAnalyticsTool.analyticsSensorsEvent(withName: "BannerImpression", parameters: sensorsDic)
    }
    
    func bannerClicked(attr_node_2:String,attr_node_3:String = "",pageName:String = "NewChannelViewController",attr_node_1:String = "new_arrival") {
        let sensorsDic = [
            "page_name": pageName,
            "attr_node_1": "new_arrival",
            "attr_node_2": attr_node_2,
            "attr_node_3": attr_node_3
        ]
        OSSVAnalyticsTool.analyticsSensorsEvent(withName: "BannerClick", parameters: sensorsDic)
    }
    
    func goodsImpression(action:String = "new",goods: GoodsItem){
        let sensorsDic = [
            "action":action,
            "goods_sn": goods.goods_sn ?? "",
            "currency": "USD",
            "cat_id": goods.cat_id ?? ""
        ]
        OSSVAnalyticsTool.analyticsSensorsEvent(withName: "GoodsImpression", parameters: sensorsDic)
    }
}



