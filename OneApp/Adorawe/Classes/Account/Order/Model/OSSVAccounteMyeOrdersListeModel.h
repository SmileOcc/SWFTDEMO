//
//  OSSVAccounteMyeOrdersListeModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAddresseBookeModel.h"
#import "OSSVAccounteMyOrderseGoodseModel.h"
#import "OSSVOrdereMoneyeInfoModel.h"

@class OrderReceiverInfo;

@interface OSSVAccounteMyeOrdersListeModel : NSObject
@property (nonatomic,copy) NSString *isSplit;    //是否有物流拆单  1:是   0： 否
@property (nonatomic,copy) NSString *orderId;//订单ID
@property (nonatomic,copy) NSString *orderSn;//订单SKU
@property (nonatomic,copy) NSString *payCode;//支付类型
@property (nonatomic,copy) NSString *orderStatus;//订单状态
@property (nonatomic,copy) NSString *orderAmount;//订单总价
@property (nonatomic,copy) NSString *orderStatusValue;//订单状态值
//@property (nonatomic,strong) NSArray *ordersGoodsList;//订单商品列表
@property (nonatomic, copy) NSString *expiresTime;      ///<订单过期时间
@property (nonatomic, assign) BOOL isAddTime;           ///<是否在后台返回的基础上加了当前的时间戳
@property (nonatomic, assign) BOOL isAccord;            ///<是否显示cod订单的提示语
//@property (nonatomic,copy) NSString *order_amount_new;//订单金额，无单位 对应货币的
//@property (nonatomic,copy) NSString *order_amount_origin;//订单金额，无单位 对应美元的

/// order_remark
@property (nonatomic,copy) NSString *order_remark;
@property (nonatomic,copy) NSString *add_time;
//@property (nonatomic, copy) NSString                *formated_goods_amount;//商品总价 对应货币
//@property (nonatomic, copy) NSString                *goods_amount_origin;//商品总价 对应美元


@property (nonatomic, strong) NSArray<OSSVAccounteMyOrderseGoodseModel*>  *ordersGoodsList;

//@property (nonatomic, copy) NSString                *shipping_fee;  //运费金额，无单位 对应美元的
@property (nonatomic, copy) NSString                *coupon_code;

//////?????
//@property (nonatomic, copy) NSString                *formated_shipping_fee_new;  //运费金额，无单位 对应美元
//@property (nonatomic, copy) NSString                *coupon_save;
//@property (nonatomic, copy) NSString                *formated_coupon_save_new;

@property (nonatomic, copy) NSString                *province;
@property (nonatomic, copy) NSString                *city;
@property (nonatomic, copy) NSString                *district;

@property (nonatomic, strong) OrderReceiverInfo   *receiver_info;

@property (nonatomic, strong) OSSVOrdereMoneyeInfoModel *money_info;

///是否为挽回订单 1是 0否
@property (nonatomic, assign) BOOL               is_retrieve;
///订单挽回文案
@property (nonatomic, copy) NSString             *retrieve_tips;

///自定义
@property (nonatomic, strong) OSSVAddresseBookeModel   *selAddressModel;
@property (nonatomic,copy) NSString *order_flow_switch;


@end


@interface OrderReceiverInfo : NSObject

@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *country_name;
@end
