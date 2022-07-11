//
//  GATools.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/9/9.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import ObjectMapper

@objcMembers class GATools: NSObject {
    static func logEvent(name:String,screenGroup:String,action:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: name, parameters: [
            "screen_group":screenGroup,
            "action":action
        ])
    }
    
    ///地址列表页事件
    static func logAddressBookEvent(action:String){
        logEvent(name: "personal_action", screenGroup: "AddressBook", action: action)
    }
    ///添加/修改页地址
    static func logAddEditAddressEvent(action:String){
        logEvent(name: "personal_action", screenGroup: "AddNewAddress", action: action)
    }
    
    ///优惠券页面
    static func logCouponPageEvent(action:String){
        logEvent(name: "coupons_action", screenGroup: "Coupons", action: action)
    }
    
    ///登录注册动作
    static func logSignInSignUpAction(eventName:String, action:String){
        logEvent(name: eventName, screenGroup: "Login/Register", action: action)
    }
    
    ///登录注册结果
    static func logSignInSignUp(eventName:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group": "Login/Register"
        ])
    }
    
    ///修改个人信息
    static func logEditProfile(action:String,screenGroup:String){
        logEvent(name: "personal_action", screenGroup: screenGroup, action: action)
    }
    
    ///评论
    static func logReviews(action:String,content:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "reviews_action", parameters: [
            "screen_group":"MyReviews",
            "action":action,
            "content":content
        ])
    }
}


///新品
extension GATools{
    static func logNewInTopBanner(promotionId:String,promotionName:String,creativeName:String,creativeSlot:String,items:[GAEventItems],isclick:Bool = false){
        let eventName = isclick ? "click_promotion" : "view_promotion"
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group":"New",
            "position":"New",
            "promotion_id":promotionId,
            "promotion_name":promotionName,
            "creative_name":creativeName,
            "creative_slot":creativeSlot,
            "items": itemsJson,
        ])
    }
    
    
    //pop出产品详情弹窗
    static func popGoodDetailView(goodTitle:String) {
        OSSVAnalyticsTool.analyticsGAEvent(withName:"item_pop_ups", parameters: [
            "screen_group" : "New",
            "position" : "New Bestsellers List",
            "content" : goodTitle])
    }

    static func logNewTimenavigate(navigation:String,isclick:Bool = false){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "new_product_navigation", parameters: [
            "screen_group": "New",
            "navigaition": navigation,
            "position": "New"
        ])
    }
    
    static func logNewInListImpression(itemListId:String,itemListName:String,items:[GAEventItems],isclick:Bool = false){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        let eventName = isclick ? "select_item" : "view_item_list"
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group": "New",
            "position": "New_NewArrivals List",
            "item_list_id": itemListId,
            "item_list_name":itemListName,
            "items": itemsJson,
        ])
    }
    
    static func logNewInloadMore(){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "unfold_new_productList", parameters: [
            "screen_group": "New",
            "button_name": "view_more",
        ])
    }
    
    static func logNewInHotSale(itemListId:String,itemListName:String,items:[GAEventItems],isclick:Bool = false){
        let eventName = isclick ? "select_item" : "view_item_list"
        
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group": "New",
            "position": "New_Bestsellers List",
            "item_list_id": itemListId,
            "item_list_name":itemListName,
            "items": itemsJson,
        ])
    }
    
    static func logNewInAddCart(value:String,items:[GAEventItems]){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "add_to_cart", parameters: [
            "screen_group": "New",
            "position": "New_Bestsellers List",
            "currency": "USD",
            "items": itemsJson,
            "value":value,
        ])
    }
}

///结算流程
extension GATools{
    static func logOrderInfomation(eventName:String,action:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group":"Order_Information",
            "action":action
        ])
    }
    
    static func logOrderInfomationPlaceOrder(value:Float,coupon:String,shippingMethod:String,items:[GAEventItems]){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "add_shipping_info", parameters: [
            "screen_group":"Order_Information",
            "currency":"USD",
            "value":value,
            "coupon":coupon,
            "shipping_tier":shippingMethod,
            "items": itemsJson
        ])
    }
    
    static func logFillInPaymentInfo(){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "payment", parameters: [
            "screen_group":"Payment",
            "action":"Add_Payment",
        ])
    }
    
    static func logAddpaymentInfo(value:Float,coupon:String,paymentType:String,items:[GAEventItems]){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "add_payment_info", parameters: [
            "screen_group":"Payment",
            "currency":"USD",
            "value":value,
            "coupon":coupon,
            "payment_type":paymentType,
            "items": itemsJson
        ])
    }
    
    static func logOrderCancelAlert(action:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "cancel_payment", parameters: [
            "screen_group":"Payment",
            "action":action
        ])
    }
}

///商品详情
extension GATools{
    static func logGoodsViewItem(screenGroup:String,value:String,items:[GAEventItems]){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "view_item", parameters: [
            "screen_group":screenGroup,
            "currency":"USD",
            "value":value,
            "items":itemsJson,
        ])
    }
    
    ///跳转到购物车
    static func logJumpToBag(screenGroup:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "go_to_bag", parameters: [
            "screen_group":screenGroup,
        ])
    }
    
    ///收藏
    static func logAddToWishList(screenGroup:String,value:String,items:[GAEventItems]){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "add_to_wishlist", parameters: [
            "screen_group":screenGroup,
            "position":"ProductDetail",
            "currency":"USD",
            "value":value,
            "items":itemsJson,
        ])
    }
    
    static func logGoodsDetailSimpleEvent(eventName:String,screenGroup:String,buttonName:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group":screenGroup,
            "button_name":buttonName,
        ])
    }
    
    ///广告图点击
    static func logGoodsBannerImg(itemListName:String,screenGroup:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "item_list_entrance", parameters: [
            "screen_group": screenGroup,
            "item_list_name": itemListName,
        ])
    }
    
    ///改变颜色
    static func logGoodsChangeColor(color:String,screenGroup:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "select_ProductColor", parameters: [
            "screen_group": screenGroup,
            "color": color,
        ])
    }
    
    ///改变尺码
    static func logGoodsChangeSize(size:String,screenGroup:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "select_ProductColor", parameters: [
            "screen_group": screenGroup,
            "size": size,
        ])
    }
    
    ///活动
    static func logGoodsActivityAction(eventName:String,action:String,screenGroup:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "eventName", parameters: [
            "screen_group": screenGroup,
            "action": action,
        ])
    }
    
    ///导航到某个商品列表
    static func logListNavigation(navigation:String,screenGroup:String,position:String){
        OSSVAnalyticsTool.analyticsGAEvent(withName: "product_navigation", parameters: [
            "screen_group": screenGroup,
            "navigaition": navigation,
            "position": position
        ])
    }
    
    ///收藏  加购 等
    static func logEventWithGoodsList(eventName:String,screenGroup:String,position:String,value:String,items:[GAEventItems]){
        let itemsJson = items.map { item in
            item.toJSON()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: eventName, parameters: [
            "screen_group":screenGroup,
            "position":position,
            "currency":"USD",
            "value":value,
            "items":itemsJson,
        ])
    }

}

@objcMembers class GAEventItems:NSObject,Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        item_id <- map["item_id"]
        item_name <- map["item_name"]
        item_brand <- map["item_brand"]
        item_category <- map["item_category"]
        item_variant <- map["item_variant"]
        price <- map["price"]
        quantity <- map["quantity"]
        currency <- map["currency"]
        index <- map["index"]
    }
    
    init(item_id: String? = nil, item_name: String? = nil, item_brand: String? = nil, item_category: String? = nil, item_variant: String? = OSSVLocaslHosstManager.appName(), price: String? = nil,quantity: NSNumber? = nil, currency: String? = nil,index: NSNumber? = nil) {
        self.item_id = item_id
        self.item_name = item_name
        self.item_brand = item_brand
        self.item_category = item_category
        self.item_variant = item_variant
        self.price = price
        self.quantity = quantity
        self.currency = currency
        self.index = index
    }
    
    var item_id:String?
    var item_name: String?
    var item_brand: String?
    var item_category: String?
    var item_variant: String?
    var price: String?
    var quantity: NSNumber?
    var currency: String?
    var index:NSNumber?
    
    
    func ado_toJSONData() -> [String : Any]{
        return self.toJSON()
    }
    
}
