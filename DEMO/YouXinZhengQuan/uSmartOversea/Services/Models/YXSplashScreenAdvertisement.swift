//
//  YXSplashScreenAdvertisement.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation


// MARK: - DataClass
struct YXSplashScreenList: Codable {
    let dataList: [SplashscreenList]?
    
    enum CodingKeys: String, CodingKey {
        case dataList = "dataList"
    }
}
// MARK: - SplashscreenList
struct SplashscreenList: Codable {
    /*
     http://jy-uat.usmartnz.com/crm-server-dolphin/doc/doc.html
     */
//    let pageNum,pageSize,createBy,id,status,type,updateBy:Int?
//    let attributes,bannerName,createByName,createTime,endDate:String?
//    let failReason,finalVerifyPerson,fromDate,img,pageId,redirectMethod:String?
//    let redirectPosition,updateByName,updateTime,verifyPerson,version:String
    
    
    let bannerID: Int?
    let adType: Int?
    let adName: String?
    let adPos: Int?
    let pictureURL: String?
  //  let jumpURL: String?
    var jumpType: String?
    let invalidTime: String?
    
    var jumpURL: String? {
        get {
            if self.newsJumpType == .Normal || self.newsJumpType == .Recommend {
                return self.newsID
            }
            return self.originJumpURL
        }
    }
    var newsJumpType: YXInfomationType {
        get {
            if self.jumpType == "1" {
                return .Native
            } else if jumpType == "2"{
                return .Internal
            }else {
                return .Unknown
            }
        }
        
        set{
            if newValue == .Native{
               jumpType = "1"
            } else if newValue == .Internal{
                jumpType = "2"
            }
        }
    }
    let originJumpURL, newsID, tag: String?

    enum CodingKeys: String, CodingKey {
        case bannerID = "id"
        case adType = "type"
        case adName = "advertiseName"
        case adPos = "priority"
        case pictureURL = "img"
        case jumpType = "redirectMethod"
        case invalidTime = "endDate"
        case originJumpURL = "redirectPosition"
        case newsID,tag
    }
}
