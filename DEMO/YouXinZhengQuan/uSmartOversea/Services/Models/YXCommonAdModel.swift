//
//  YXCommonAdModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/8/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
struct YXCommonAdModel: Decodable ,Encodable{
    /*
     http://jy-uat.usmartnz.com/crm-server-dolphin/doc/doc.html
     */
//    let pageNum,pageSize,createBy,id,status,type,updateBy:Int?
//    let attributes,bannerName,createByName,createTime,endDate:String?
//    let failReason,finalVerifyPerson,fromDate,img,pageId,redirectMethod:String?
//    let redirectPosition,updateByName,updateTime,verifyPerson,version:String
    
    /*
     {
         "code": 0,
         "data": [
             {
                 "adType": 1, 类型 1:弹窗广告 2：自选广告

                 "advertiseName": "广告位测试01",广告名称

                 "id": 1,主键Id

                 "img": "example.png",图片地址

                 "params": "xxx",参数

                 "priority": 1,优先级

                 "recommendMsg": "xxx",自选推荐

                 "redirectMethod": "H5",跳转方式 1:native 2:h5

                 "redirectPosition": "www.baidu.com"跳转地址

             }
         ],
         "msg": ""
     }
     */
    
    let bannerID: Int?
    let adType: Int?
    let adName: String?
    let adPos: Int?
    let pictureURL: String?
    let jumpURL: String?
    let jumpType: String?
    let invalidTime: String?
    var priority : Int?
    var recommendMsg : [RecommendStockModel]?
    let params: String?

    enum CodingKeys: String, CodingKey {
        case bannerID = "id"
        case adType = "adType"
        case adName = "advertiseName"
        case adPos
        case pictureURL = "img"
        case jumpURL = "redirectPosition"
        case jumpType = "redirectMethod"     //NATIVE = 1 // H5 = "2"
        case invalidTime = "endDate"
        case priority = "priority"
        case recommendMsg = "recommendMsg"
        case params = "params"

    }
    
}


//struct YXPopAdModel:Codable {
//    var popList : [YXCommonAdModel]
//    init(from decoder: Decoder) throws {
//        if var arrayContainer = try? decoder.unkeyedContainer() {
//            var arr: [YXCommonAdModel] = []
//            while !arrayContainer.isAtEnd {
//                let value = try arrayContainer.decode(YXCommonAdModel.self)
//                arr.append(value)
//            }
//            popList = arr
//        }else {
//            popList =  [YXCommonAdModel]()
//        }
//    }
//}

struct YXPopAdModel:Codable {
    let dataList: [YXCommonAdModel]?
    
    enum CodingKeys: String, CodingKey {
        case dataList = "dataList"
    }
}


class RecommendStockModel: Codable {
    let symbol: String?
    let stockName: String?
    let secu_code: String?
    let market: String?
    let title: String?
    let desc: String?

    let introductionCn: String?
    let introductionTc: String?
    let introductionEn: String?
    var isSelect = true
    var quote: YXV2Quote?
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case stockName = "secu_name"
        case secu_code
        case market
        case title
        case desc
        case introductionCn
        case introductionTc
        case introductionEn
    }
}
