//
//  YXUserBanner.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
struct YXUserBanner: Codable {
    let dataList: [BannerList]?
    
    enum CodingKeys: String, CodingKey {
        case dataList = "dataList"
    }
}


//struct YXUserBanner: Codable {
//    let adName: String?
//    let bannerList: [BannerList]
//    let guide: String?
//    enum CodingKeys: String, CodingKey {
//        case adName = "ad_name"
//        case bannerList = "banner_list"
//        case guide
//    }
//}
//
//struct BannerList: Codable {
//    let bannerID, adType, adPos: Int?
//    let pictureURL: String?
//    var jumpURL: String? {
//        get {
//            if self.newsJumpType == .Normal || self.newsJumpType == .Recommend {
//                return self.newsID
//            }
//            return self.originJumpURL
//        }
//    }
//    let originJumpURL, newsID, bannerTitle, tag: String?
//    var newsJumpType: YXInfomationType = .Unknown
//    enum CodingKeys: String, CodingKey {
//        case bannerID = "banner_id"
//        case adType = "ad_type"
//        case adPos = "ad_pos"
//        case pictureURL = "picture_url"
//        case originJumpURL = "jump_url"
//        case newsID = "news_id"
//        case bannerTitle = "banner_title"
//        case tag
//        case newsJumpType = "news_jump_type"
//    }
//}


//struct YXUserBanner2: Codable {
//
//    var bannerList: [BannerList2]?
//    enum CodingKeys: String, CodingKey {
//        case bannerList
//    }
//
//    init(from decoder: Decoder) throws {
//        if var arrayContainer = try? decoder.unkeyedContainer() {
//
//            var arr: [BannerList2] = []
//            while !arrayContainer.isAtEnd {
//                let value = try arrayContainer.decode(BannerList2.self)
//                arr.append(value)
//            }
//            bannerList = arr
//        } else if var container = try? decoder.container(keyedBy:CodingKeys.self) {
//            bannerList = nil
//        }else {
//            bannerList =  nil
//        }
//    }
//
//}

struct BannerList: Decodable,Encodable {
    

        let bannerID: Int?
        let adType: Int?
        let adPos: Int?
        let pictureURL: String?
      //  var invalidTime: String?
       let originJumpURL, newsID, bannerTitle, tag: String?
       var jumpType: String?  // NATIVE = "1"; H5 = "2";
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
        enum CodingKeys: String, CodingKey {
            case bannerID = "id"
            case adType = "type"
            case bannerTitle = "bannerName"
            case adPos = "priority"
            case pictureURL = "img"
            case originJumpURL = "redirectPosition"
            case jumpType = "redirectMethod"
         //   case invalidTime = "endDate"
            case newsID,tag
        }
    
//    let pageNum,pageSize,createBy,id,status,type,updateBy:Int?
//    let attributes,bannerName,createByName,createTime,endDate:String?
//    let failReason,finalVerifyPerson,fromDate,img,pageId,redirectMethod:String?
//    let redirectPosition,updateByName,updateTime,verifyPerson,version:String
    
    
}


//struct YXUserBanner:Codable {
//    var bannerList : [BannerList]
//    init(from decoder: Decoder) throws {
//        if var arrayContainer = try? decoder.unkeyedContainer() {
//            var arr: [BannerList] = []
//            while !arrayContainer.isAtEnd {
//                let value = try arrayContainer.decode(BannerList.self)
//                arr.append(value)
//            }
//            bannerList = arr
//        }else {
//            bannerList =  [BannerList]()
//        }
//    }
//}
