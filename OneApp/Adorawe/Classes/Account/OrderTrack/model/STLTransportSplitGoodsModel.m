//
//  OSSVTransporteSpliteGoodsModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransporteSpliteGoodsModel.h"

@implementation OSSVTransporteSpliteGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodPrice"               : @"goods_price",
             @"goodDiscountPrice"       : @"goods_discount_price",
             @"goodName"                : @"goods_name",
             @"goodAttr"                : @"goods_attr",
             @"wid"                     : @"wid",
             @"goodImgUrl"              : @"goods_thumb",
             @"goodId"                  : @"goods_id",
             @"goodSn"                  : @"goods_sn",
             @"goodNumber"              : @"goods_number",
             @"isReview"                : @"is_review",
             @"warehouseName"           : @"warehouse_name",
             @"formated_goods_price"    : @"formated_goods_price",
             @"formated_subtotal"       : @"formated_subtotal",
             @"subtotal"                : @"subtotal",
             @"cat_id"                   : @"cat_id",
             @"cat_name"                 : @"cat_name",
             @"show_in_goods_list"      : @"show_in_goods_list",
             @"isDelete"                : @"is_delete"

             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"goodPrice",
              @"goodDiscountPrice",
              @"goodName",
              @"goodAttr",
              @"wid",
              @"goodImgUrl",
              @"goodId",
              @"goodSn",
              @"goodNumber",
              @"isReview",
              @"warehouseName",
              @"formated_goods_price",
              @"formated_subtotal",
              @"subtotal",
              @"cat_id",
              @"cat_name",
              @"show_in_goods_list",
              @"isDelete"
    ];
}

@end
