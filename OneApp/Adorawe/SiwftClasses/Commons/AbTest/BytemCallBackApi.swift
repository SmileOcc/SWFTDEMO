//
//  BytemCallBack.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RangersAppLog

class BytemCallBackApi:NSObject{
    
    /// 向bytem发送回调
    /// - Parameters:
    ///   - apiKey: 搜索apikey
    ///   - index: 对应搜索行为发生的索引
    ///   - sid: 对应搜索的search_id
    ///   - pid: 对应商品的id
    ///   - skuid: 对应sku的id
    ///   - action: 0为点击，1为加购，2为购买
    @objc static func sendCallBack(apiKey:String,index:String,sid:String,pid:String,skuid:String,action:Int, searchEngine:String){
        
        ///APP站点区分使用 只A站使用
        if app_type == 1 { //只A站使用
            
            guard searchEngine == "btm" else { return }
            let params = ["apikey":apiKey as Any,
                          "index":index,
                          "sid":sid,
                          "pid":pid,
                          "skuid":skuid,
                          "action":action
            ]
            if let req = try? AFJSONRequestSerializer().request(withMethod: "POST", urlString: OSSVLocaslHosstManager.appSearchBytem(), parameters: params){
                URLSession.shared.dataTask(with: req as URLRequest).resume()
            }
        }
    }
}

//TODO bytem 回调
