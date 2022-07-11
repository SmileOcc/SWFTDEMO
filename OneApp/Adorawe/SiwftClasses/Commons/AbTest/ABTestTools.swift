//
//  ABTestTools.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/30.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import RangersAppLog
import RxSwift
import RxCocoa


@objcMembers class ABTestTools:NSObject{
    
    static let shared = ABTestTools()
    private let disposebag = DisposeBag()
    
    private override init() {}
    
    public func setupSDK(launchOptions:[UIApplication.LaunchOptionsKey : Any]?) {
        
        ///APP站点区分使用
        if app_type == 1 {//A 站才使用
            
            let config = BDAutoTrackConfig(appID: OSSVLocaslHosstManager.abTestAppId(), launchOptions: launchOptions)
            
            config.appName = OSSVLocaslHosstManager.abTestAppName()
            config.channel = "App Store"
            config.abEnable = true
            config.logNeedEncrypt = false
            config.clearABCacheOnUserChange = true //默认切换用户重新获取A/B配置信息，如果要关闭则把clearABCacheOnUserChange配置项置为NO
            config.serviceVendor = BDAutoTrackServiceVendor.private
            
            BDAutoTrack.setRequestHostBlock { verder, urlType in
                return OSSVLocaslHosstManager.appABSnssdkUrl()
            }
            
            BDAutoTrack.start(with: config)
            
            
            
            NotificationCenter.default.rx.notification(Notification.Name(BDAutoTrackNotificationABTestSuccess), object: nil)
                .subscribe(onNext:{ _ in
                    print("BDAutoTrackNotificationABTestSuccess")
                    
                }).disposed(by: disposebag)
            
            ///初始化成功才能拿到
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                
                let ab_Params = BDAutoTrack.abTestConfigValue(forKey: "ab_params", defaultValue: "default_value")
                print("ABTest Params:\(ab_Params ?? 0)")
                
                print("ABtest ssid:\(BDAutoTrack.ssID ?? "")")
                //            self.uploadEvent(eventName: "play_vidios", params: ["vidoname":"Mr Bean"])
            })
        }
        
    }
    
    
    public func uploadEvent(eventName:String,params:[AnyHashable : Any]?){
//        BDAutoTrack.eventV3("event_name", params: ["eventKey":"eventValue"])
        
        ///APP站点区分使用
        if app_type == 1 {//A 站才使用
            BDAutoTrack.eventV3(eventName, params: params)
        }
    }
    
    
    /// 发起搜索：点击搜索页面触发搜索事件
    /// - Parameters:
    ///   - keyWord: 关键词
    ///   - keyWordsType: 关键词类型 - history：历史记录 - recommend：推荐搜索词 - custom：输入搜索词 -associate：联想词 -default：默认词
    public func searchInit(keyWord:String, keyWordsType:String){
        uploadEvent(eventName: "SearchInitiate", params: ["key_word":keyWord,"key_word_type":keyWordsType])
    }
    
    
    /// 搜索返回结果: 收到搜索请求返回的结果触发
    /// - Parameters:
    ///   - keyWord: 关键词
    ///   - keyWordsType: 关键词类型 - history：历史记录 - recommend：推荐搜索词 - custom：输入搜索词 -associate：联想词 -default：默认词
    ///   - resultNumber: 搜索结果数量
    public func searchRequest(keyWord:String, keyWordsType:String, resultNumber:Int){
        uploadEvent(eventName: "SearchRequest", params: ["key_word":keyWord,"key_word_type":keyWordsType,"result_number":resultNumber])
    }
    
    
    
    /// 商品曝光: 用户在搜索场景的商品列表滑动时，该商品被曝光时返回
    /// - Parameters:
    ///   - keyWord: 关键词
    ///   - keyWordsType: 关键词类型 - history：历史记录 - recommend：推荐搜索词 - custom：输入搜索词 -associate：联想词 -default：默认词
    ///   - positionNum: 位置序号: 从 1 开始计算的位置（按照从左往右再从上往下的顺序）
    ///   - goodsSn: 商品编码
    ///   - goodsName: 商品名称
    ///   - catId: 分类 id
    ///   - catName: 分类名称
    public func goodsImpression(keyWord:String, keyWordsType:String,positionNum:Int,goodsSn:String,goodsName:String,catId:String,catName:String){
        uploadEvent(eventName: "GoodsImpression",
                    params: ["key_word":keyWord,
                             "key_word_type":keyWordsType,
                             "position_number":positionNum,
                             "goods_sn":goodsSn,
                             "goods_name":goodsName,
                             "cat_id":catId,
                             "cat_name":catName
                            ])
    }
    
    
    /// 点击搜索结果: 点击搜索结果触发
    /// - Parameters:
    ///   - keyWord: 关键词
    ///   - keyWordsType: 关键词类型 - history：历史记录 - recommend：推荐搜索词 - custom：输入搜索词 -associate：联想词 -default：默认词
    ///   - positionNum: 位置序号: 从 1 开始计算的位置（按照从左往右再从上往下的顺序）
    ///   - goodsSn: 商品编码
    ///   - goodsName: 商品名称
    ///   - catId: 分类 id
    ///   - catName: 分类名称
    public func searchResultClick(keyWord:String, keyWordsType:String,positionNum:Int,goodsSn:String,goodsName:String,catId:String,catName:String){
        uploadEvent(eventName: "SearchResultClick",
                    params: ["key_word":keyWord,
                             "key_word_type":keyWordsType,
                             "position_number":positionNum,
                             "goods_sn":goodsSn,
                             "goods_name":goodsName,
                             "cat_id":catId,
                             "cat_name":catName
                            ])
    }
    
    
    
    /// 浏览商品详情页:浏览商品时触发
    /// - Parameters:
    ///   - keyWord: 关键词
    ///   - positionNum: 位置序号: 从 1 开始计算的位置（按照从左往右再从上往下的顺序）
    ///   - goodsSn: 商品编码
    ///   - goodsName: 商品名称
    ///   - catId: 分类 id
    ///   - catName: 分类名称
    ///   - originPrice: 商品划线价
    ///   - presentPrice: 商品现价
    public func goodsDetail(keyWord:String,positionNum:Int,goodsSn:String,goodsName:String,catId:String,catName:String,originPrice:Float,presentPrice:Float){
        uploadEvent(eventName: "GoodsDetail",
                    params: ["key_word":keyWord,
                             "position_number":positionNum,
                             "goods_sn":goodsSn,
                             "goods_name":goodsName,
                             "cat_id":catId,
                             "cat_name":catName,
                             "original_price":originPrice,
                             "present_price":presentPrice
                            ])
    }
    
    
    /// 加入购物车:加入购物车成功时触发
    /// - Parameters:
    ///   - keyWord: 关键词
    ///   - positionNum: 位置序号: 从 1 开始计算的位置（按照从左往右再从上往下的顺序）
    ///   - goodsSn: 商品编码
    ///   - goodsName: 商品名称
    ///   - catId: 分类 id
    ///   - catName: 分类名称
    ///   - originPrice: 商品划线价
    ///   - presentPrice: 商品现价
    public func addToCart(keyWord:String,positionNum:Int,goodsSn:String,goodsName:String,catId:String,catName:String,originPrice:Float,presentPrice:Float){
        uploadEvent(eventName: "AddToCart",
                    params: ["key_word":keyWord,
                             "position_number":positionNum,
                             "goods_sn":goodsSn,
                             "goods_name":goodsName,
                             "cat_id":catId,
                             "cat_name":catName,
                             "original_price":originPrice,
                             "present_price":presentPrice
                            ])
    }

    
    /// 下单:下单成功时触发
    /// - Parameters:
    ///   - orderSn: 订单号
    ///   - orderActureAmount: 订单实付金额
    ///   - totalPriceOfGoods: 商品总价
    ///   - goodsSnCount: 商品数: 一个sku，无论购买多少，数量均视为1
    ///   - paymentMethod: 支付方式: pay_code - cod; - paypal; - checkout; - pacypay
    ///   - isUseDiscount: 是否使用优惠券:1-是；0-否
    public func submitOrder(orderSn:String,orderActureAmount:Float,totalPriceOfGoods:Float,goodsSnCount:Int,paymentMethod:String,isUseDiscount:String){
        uploadEvent(eventName: "SubmitOrder",
                    params: ["order_sn":orderSn,
                             "order_actual_amount":orderActureAmount,
                             "total_price_of_goods":totalPriceOfGoods,
                             "goods_sn_count":goodsSnCount,
                             "payment_method":paymentMethod,
                             "is_use_discount":isUseDiscount
                            ])
    }
    
    
    /// 线上支付订单:线上支付订单成功时触发
    /// - Parameters:
    ///   - orderSn: 订单号
    ///   - orderActureAmount: 订单实付金额
    ///   - totalPriceOfGoods: 商品总价
    ///   - goodsSnCount: 商品数: 一个sku，无论购买多少，数量均视为1
    ///   - paymentMethod: 支付方式: pay_code - cod; - paypal; - checkout; - pacypay
    ///   - isUseDiscount: 是否使用优惠券:1-是；0-否
    public func onlinePayOrder(orderSn:String,orderActureAmount:Float,totalPriceOfGoods:Float,goodsSnCount:Int,paymentMethod:String,isUseDiscount:String){
        uploadEvent(eventName: "OnlinePayOrder",
                    params: ["order_sn":orderSn,
                             "order_actual_amount":orderActureAmount,
                             "total_price_of_goods":totalPriceOfGoods,
                             "goods_sn_count":goodsSnCount,
                             "payment_method":paymentMethod,
                             "is_use_discount":isUseDiscount
                            ])
    }
    
    
    
    /// COD确认订单:COD确认订单成功时触发
    /// - Parameters:
    ///   - orderSn: 订单号
    ///   - orderActureAmount: 订单实付金额
    ///   - totalPriceOfGoods: 商品总价
    ///   - goodsSnCount: 商品数: 一个sku，无论购买多少，数量均视为1
    ///   - paymentMethod: 支付方式: pay_code - cod; - paypal; - checkout; - pacypay
    ///   - isUseDiscount: 是否使用优惠券:1-是；0-否
    public func confirmCod(orderSn:String,orderActureAmount:Float,totalPriceOfGoods:Float,goodsSnCount:Int,paymentMethod:String,isUseDiscount:String,confirmMethod:String?){
        var paramms = ["order_sn":orderSn,
                       "order_actual_amount":orderActureAmount,
                       "total_price_of_goods":totalPriceOfGoods,
                       "goods_sn_count":goodsSnCount,
                       "payment_method":paymentMethod,
                       "is_use_discount":isUseDiscount,
        ] as [String : Any]
        
        if confirmMethod != nil{
            paramms["confirm_method"] = confirmMethod
        }
        uploadEvent(eventName: "ConfirmCod",
                    params: paramms)
    }
    
    /// COD短信验证曝光:COD订单弹窗展示时触发
    /// - Parameters:
    ///   - orderSn: 订单号
    public func codPaymentPopup(orderSn:String){
        uploadEvent(eventName: "CodPaymentPopup",
                    params: ["order_sn":orderSn])
    }
    
    /// COD短信验证修改手机号:用户修改手机号成功后触发
    public func changePhoneNum(){
        uploadEvent(eventName: "ChangePhoneNum",
                    params: [:])
    }
    
    ///推荐AB 分流
    public static func Recommand_ab(requestId:String?)->String {
        if let requestId = requestId,
           !requestId.isEmpty{
            return "HS-\(requestId)"
        }
        ///没有返回starlink
        return "starlink"
    }
    
}


