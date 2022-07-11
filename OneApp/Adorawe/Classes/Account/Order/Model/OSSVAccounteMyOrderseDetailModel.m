//
//  OSSVAccounteMyOrderseDetailModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyOrderseDetailModel.h"

#import "OSSVAccounteOrdersDetaileGoodsModel.h"

@implementation OSSVAccounteMyOrderseDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"orderId" : @"order_id",
             @"orderSn" : @"order_sn",
             @"orderStatus" : @"order_status",
             @"orderStatusValue" : @"order_status_value",
             @"firstName" : @"first_name",
             @"lastName" : @"last_name",
             @"streetMore" : @"street_more",
             @"goodsList" : @"goods_list",
             @"shippingName" : @"shipping_name",
             @"payName" : @"pay_name",
             @"payCode" : @"pay_code",
             @"orderaddTime":@"orderadd_time",
             @"orderDate" : @"order_date",
             @"addTime" : @"add_time",
             @"pointMoney" : @"point_money",
             @"codFractionsType" : @"cod_fractions_type",
             @"expiresTime" : @"expires_time",
             @"district":@"district",
             @"order_flow_switch":@"order_flow_switch",
             @"order_remark":@"order_remark",
             @"is_split" : @"is_split",
             @"split_text" : @"split_text",
             };
}

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"goodsList" : [OSSVAccounteOrdersDetaileGoodsModel class],
             @"money_info" : [OSSVOrdereMoneyeInfoModel class],
    };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"orderId",
             @"orderSn",
             @"orderStatus",
             @"orderStatusValue",
             @"firstName",
             @"lastName",
             @"street",
             @"streetMore",
             @"country",
             @"province",
             @"city",
             @"phone",
             @"zip",
             @"goodsList",
             @"shippingName",
             @"payName",
             @"payCode",
             @"orderaddTime",
             @"addTime",
             @"orderDate",
             @"wid",
              @"shipping",
             @"paydesc",
             @"pointMoney",
             @"codFractionsType",
             @"expiresTime",
             @"parcel_num",
             @"district",
             @"order_flow_switch",
             @"order_remark",
             @"is_split",
             @"split_text",
             @"money_info",
             @"coupon_code",
             @"is_retrieve",
             @"retrieve_tips",
             ];
}
@end
