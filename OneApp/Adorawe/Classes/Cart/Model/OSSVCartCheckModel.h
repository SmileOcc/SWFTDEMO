//
//  OSSVCartCheckModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateModel.h"
#import "OSSVCartWareHouseModel.h"
#import "OSSVPointsModel.h"
#import "OSSVAddresseBookeModel.h"
#import "OSSVCouponModel.h"
#import "STLBaseModelErrorMessageProtocol.h"
#import "OSSVCodInforModel.h"
#import "OSSVShipFreeInfoModel.h"
#import "OSSVCoinInforModel.h"

@class CartCheckFreeDataModel;
@class AddressGoodsShieldInfoModel;
@interface CurrencyList : NSObject

@property (nonatomic, strong) RateModel *currency_cod;
@property (nonatomic, strong) RateModel *currency_check;

@end

#pragma mark - OSSVCartCheckModel

@interface OSSVCartCheckModel : NSObject

@property (nonatomic, strong) OSSVAddresseBookeModel *address;                ///<地址模型
@property (nonatomic, strong) NSArray          *goodList;               ///<废弃，分仓
@property (nonatomic, strong) NSArray          *wareHouseList;          ///<仓库->商品列表
@property (nonatomic, strong) NSArray          *paymentList;            ///<支付方式列表
@property (nonatomic, strong) NSArray          *shippingList;           ///<物流方式列表
@property (nonatomic, copy)   NSString         *insurance;                ///<物流保险
@property (nonatomic, copy)   NSString         *usableCouponNum;                ///<可以使用的优惠券
@property (nonatomic, strong) OSSVCouponModel      *coupon;                 ///<用户选择的优惠券券码
@property (nonatomic, strong) OSSVPointsModel      *points;                 ///<用户可以使用的积分模型
@property (nonatomic, strong) RateModel        *currencyInfo;           ///<汇率相关model
@property (nonatomic, strong) CartCheckFreeDataModel        *fee_data;           ///<金额相关model

@property (nonatomic, strong) AddressGoodsShieldInfoModel   *goods_shield_info;
@property (nonatomic, assign) NSInteger        flag;                    ///<错误码
@property (nonatomic, assign) NSInteger        statusCode;              ///<错误码
@property (nonatomic, copy) NSString          *message;                 ///<错误message

@property (nonatomic, strong) CurrencyList *currency_list;

@property (nonatomic, copy) NSString *cod_black_list_tip;               ///<cod黑名单提示，如果长度大于0，则在提交订单的时候弹出窗口提示
@property (nonatomic, copy)   NSString *couponMsg; //优惠券的文案
@property (nonatomic, copy)   NSString *rebate_activity_info; //返现的文案

@property (nonatomic, strong) OSSVCodInforModel      *cod_discount_info;
@property (nonatomic, strong) OSSVCoinInforModel     *coin_discount_info;
@property (nonatomic, strong) OSSVShipFreeInfoModel  *ship_free_info;
//是否启用运费险
@property (nonatomic, copy)   NSString        *shippingInsurance;

-(void)modalErrorMessage:(UIViewController *)viewController errorManager:(id<STLBaseModelErrorMessageProtocol>)model;
@end


@interface CartCheckFreeDataModel : NSObject
@property (nonatomic, copy) NSString          *coupon_save;
@property (nonatomic, copy) NSString          *shipping;
@property (nonatomic, copy) NSString          *product;
@property (nonatomic, copy) NSString          *total;
@property (nonatomic, copy) NSString          *active_save;
@property (nonatomic, copy) NSString          *cod;
@property (nonatomic, copy) NSString          *pay_discount_save;

@property (nonatomic, copy) NSString          *product_converted;
@property (nonatomic, copy) NSString          *pay_discount_save_converted; //在线支付优惠金额
@property (nonatomic, copy) NSString          *coupon_save_converted;
@property (nonatomic, copy) NSString          *total_converted;
@property (nonatomic, copy) NSString          *shipping_converted;
@property (nonatomic, copy) NSString          *cod_converted;
@property (nonatomic, copy) NSString          *active_save_converted;

@property (nonatomic, copy) NSString          *cod_discount;
@property (nonatomic, copy) NSString          *cod_discount_converted;

@property (nonatomic, copy) NSString          *cod_discount_before;
@property (nonatomic, copy) NSString          *cod_discount_before_converted;
////自定义 积分
@property (nonatomic, copy) NSString          *point_save;
@property (nonatomic, copy) NSString          *point_save_converted;
@property (nonatomic, copy) NSString          *insurance;
@property (nonatomic, copy) NSString          *insurance_converted;
//金币相关的
@property (nonatomic, copy)   NSString *coin; //可以使用金币数量
@property (nonatomic, copy)   NSString *coin_save; //使用金币省的金额
@property (nonatomic, copy)   NSString *coin_save_converted_symbol; //金币兑换的 金额（带货币符号）
@property (nonatomic, copy)   NSString *coin_save_converted; //金币兑换的 金额（不带货币符号）
@property (nonatomic, copy)   NSString *free_converted; //带货币符号的免费金额 ---货币符号 ----暂无用
@property (nonatomic, copy)   NSString *coin_save_converted_origin;

//1.4.4
///价格模块cod原价
@property (nonatomic, copy)   NSString *cod_regular;
///价格模块cod原价String显示文本
@property (nonatomic, copy)   NSString *cod_regular_converted;
///价格模块shipping原价
@property (nonatomic, copy)   NSString *shipping_regular;
///价格模块shipping原价String显示文本
@property (nonatomic, copy)   NSString *shipping_regular_converted;
//运费险金额
@property (nonatomic, copy) NSString *shipping_insurance_converted_origin;
//运费险---美金 不带货币符号
@property (nonatomic, copy) NSString *shipping_insurance;
@end



@interface AddressGoodsShieldInfoModel : NSObject

@property (nonatomic, copy) NSString *has_shield;
@property (nonatomic, copy) NSString *shield_tips;

@end
