//
//  OSSVAccounteMyeOrdersListeModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyeOrdersListeModel.h"
#import "OSSVAccounteMyOrderseGoodseModel.h"

@implementation OSSVAccounteMyeOrdersListeModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"orderId" : @"order_id",
              @"payCode" : @"pay_code",
              @"orderSn" : @"order_sn",
              @"orderStatus" : @"order_status",
              @"orderAmount" : @"order_amount",
              @"orderStatusValue" : @"order_status_value",
              @"ordersGoodsList" : @"goods_list",
              @"expiresTime" : @"expires_time",
              @"isAccord" : @"is_accord",
              @"order_amount_new" : @"new_order_amount",
              @"order_remark" : @"order_remark",
              @"add_time":@"add_time",
              @"formated_goods_amount":@"formated_goods_amount",
              @"goods_amount_origin":@"goods_amount_origin",
              @"isSplit" : @"is_split",
              @"formated_shipping_fee_new":@"new_formated_shipping_fee",
              @"coupon_code":@"coupon_code",
              @"coupon_save":@"coupon_save",
              @"formated_coupon_save_new":@"new_formated_coupon_save",

              };
}

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"ordersGoodsList" : [OSSVAccounteMyOrderseGoodseModel class],
             @"receiver_info" : [OrderReceiverInfo class],
             @"money_info" : [OSSVOrdereMoneyeInfoModel class],
    };
    
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"orderId",
             @"payCode",
             @"orderSn",
             @"orderStatus",
             @"orderAmount",
             @"orderStatusValue",
             @"ordersGoodsList",
             @"expiresTime",
             @"isAccord",
             @"order_amount_new",
             @"order_remark",
             @"add_time",
             @"formated_goods_amount",
             @"isSplit",
             @"formated_shipping_fee_new",
             @"coupon_code",
             @"order_amount_origin",
             @"shipping_fee",
             @"province",
             @"city",
             @"district",
             @"goods_amount_origin",
             @"coupon_save",
             @"formated_coupon_save_new",
             @"receiver_info",
             @"money_info",
             @"is_retrieve",
             @"retrieve_tips",
            ];
}
@end



@implementation OrderReceiverInfo


@end
