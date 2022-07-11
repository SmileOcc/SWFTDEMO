//
//  NewChannelModels.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import ObjectMapper
import IGListKit


class OSSVNewChannelRespModel:Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        result <- map["result"]
        statusCode <- map["statusCode"]
        message <- map["message"]
    }
    
    var result:OSSVNewChannelResult?
    var statusCode:Int?
    var message:String?
}

class OSSVNewChannelResult: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        mutiProtogene <- map["mutiProtogene"]
        color <- map["color"]
        id <- map["id"]
    }
    
    var mutiProtogene:[OSSVProtoGene]?
    var color:String?
    var id:String?
}

class OSSVProtoGene:Mappable,ListDiffable{
    
    let idStr = UUID().uuidString as NSString
    
    func diffIdentifier() -> NSObjectProtocol {
        idStr
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? OSSVProtoGene else{
            return false
        }
        return obj.idStr == idStr
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        bg_color <- map["bg_color"]
        sort <- map["sort"]
        type <- map["type"]
        modeImg <- map["modeImg"]
        imgType <- map["imgType"]
        colour <- map["colour"]
        ranking <- map["ranking"]
        total <- map["total"]
        date <- map["date"]
        goodsList <- map["goodsList"]
    }
    
    var bg_color:String?
    var sort:String?
    var type:String?
    var modeImg:[ModeImg]?
    var imgType:Int?
    var date:DateItem?
    var colour:String?
    var ranking:Int?
    var total:Int?
    
    ///UI 状态变量
    var isLast:Bool = false
    var hasMore:Bool = true
    
    var goodsList:[GoodsItem]?
}


class GoodsItem:Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        goods_original <- map["goods_original"]
        spu <- map["spu"]
        show_discount_icon <- map["show_discount_icon"]
        market_price <- map["market_price"]
        goods_img_w <- map["goods_img_w"]
        shop_price <- map["shop_price"]
        dangerous_type <- map["dangerous_type"]
        cat_id <- map["cat_id"]
        collect_count <- map["collect_count"]
        sale_num <- map["sale_num"]
        discount <- map["discount"]
        goods_img <- map["goods_img"]
        group_goods_id <- map["group_goods_id"]
        tips_reduction <- map["tips_reduction"]
        goods_title <- map["goods_title"]
        goods_img_h <- map["goods_img_h"]
                        
        url_title <- map["url_title"]
        shop_price_converted <- map["shop_price_converted"]
        goods_number <- map["goods_number"]
        goods_id <- map["goods_id"]
        wid <- map["wid"]
        mark_img <- map["mark_img"]
        market_price_converted <- map["market_price_converted"]
        goods_sn <- map["goods_sn"]
        is_on_sale <- map["is_on_sale"]
        is_collect <- map["is_collect"]
        
                        
        if let flashDict = map.JSON["flash_sale"] as? [String:Any]{
            flashSale = STLFlashSaleModel.yy_model(with: flashDict)
        }
    }
    
    var goods_original: String?
    var spu: String?
    var flashSale: STLFlashSaleModel?
    var show_discount_icon: String?
    var market_price, goods_img_w, shop_price, dangerous_type: String?
    var cat_id: String?
    var collect_count: Int?
    var sale_num: Int?
    var discount: Int?
    var goods_img: String?
    var group_goods_id, tips_reduction, goods_title, goods_img_h: String?
    var url_title, shop_price_converted, goods_number, goods_id: String?
    var wid, mark_img, market_price_converted, goods_sn: String?
    var is_on_sale: String?
    var is_collect:Int?
    
    var isImpressioned:Bool = false
}

class DateItem:Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        colour <- map["colour"]
        sort <- map["sort"]
        days <- map["days"]
        is_show_goods_num <- map["is_show_goods_num"]
        sectionType <- map["sectionType"]
        goods_num <- map["goods_num"]
        new_in_day <- map["new_in_day"]
    }
    
    var colour:String?
    var sort:String?
    var days:Int?
    var is_show_goods_num:String?
    var sectionType:String?
    var new_in_day:[TimeRangeModel]?
    var goods_num:String?
}

class TimeRangeModel:Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        goodsList <- map["goodsList"]
        name <- map["name"]
        total <- map["total"]
        date <- map["date"]
    }
    
    var goodsList:[GoodsItem]?
    var name:String?
    var total:Int?
    var date:String?
}

class ModeImg:Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        arHasRule <- map["arHasRule"]
        shareImg <- map["shareImg"]
        hasRule <- map["hasRule"]
        url <- map["url"]
        isShare <- map["isShare"]
        coupon <- map["coupon"]
        shareTitle <- map["shareTitle"]
        pageType <- map["pageType"]
        shareUrl <- map["shareUrl"]
        images <- map["images"]
        shareDoc <- map["shareDoc"]
        imagesHeight <- map["imagesHeight"]
        imagesWidth <- map["imagesWidth"]
        name <- map["name"]
    }
    
    var arHasRule:Bool?
    var shareImg:Int?
    var hasRule:Bool?
    var url:String?
    var isShare:Int?
    var coupon:String?
    var shareTitle:String?
    var pageType:String?
    var shareUrl:String?
    var images:String?
    var shareDoc:String?
    var imagesHeight:Int?
    var imagesWidth:Int?
    var name:String?
}

enum ChannelDataType:String{
    ///双列商品广告
    case TwoColumAds = "1"
    ///三列商品广告
    case ThreeColumAds = "14"
    ///单行图片
    case OneRowImg = "2"
    ///双列图片
    case TwoColumImg = "3"
    ///三列图片
    case ThreeColumImg = "4"
    ///四列图片
    case FourColumImg = "5"
    ///滑动商品
    case ScrollProduct = "6"
    ///商品导航
    case GoodsNavigate = "7"
    ///商品分类导航
    case GoodsCategoryNavigate = "10"
    ///单列Coupon
    case OneColumCoupon = "15"
    ///双列Coupon
    case TwoColumCoupon = "8"
    ///三列Coupon
    case ThreeColumCoupon = "9"
    ///滑动礼品
    case ScrollGift = "11"
    ///0元换购商品
    case ZeroExchangeBuy = "12"
    ///优惠券一键领取按钮
    case FastGetCoupon = "13"
    ///单列分页商品
    case OneColumnPagedGoods = "17"
    ///双列分页商品
    case TowColumnPagedGoods = "18"
    ///滚动焦点图
    case ScrollFocusedImg = "21"
    ///2行滑动0元礼
    case TwoRowZeroGift = "19"
    ///2行滑动0元礼
    case ScrollCoupon = "20"
    ///时间导航'
    case TimeNavigate = "22"
}


enum OneRowImgChildColumn:Int{
    ///单张图片
    case OneColumn = 1
    ///三图片
    case ThreeColumn = 3
    ///四图片
    case FourColumn = 4
}

