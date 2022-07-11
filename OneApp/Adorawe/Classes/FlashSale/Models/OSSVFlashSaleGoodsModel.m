//
//  OSSVFlashSaleGoodsModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleGoodsModel.h"
@implementation OSSVFlashSaleGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodId"       : @"goods_id",
             @"wid"          : @"wid",
             @"goodsImgUrl"  : @"goods_img",
             @"activeId"     : @"active_id",
             @"activeStock"  : @"active_stock",
             @"soldNum"      : @"sold_num",
             @"goodsTitle"   : @"goods_title",
             @"activePrice"  : @"active_price",
             @"marketPrice"  : @"market_price",
             @"discount"     : @"discount",
             @"soldOut"      : @"sold_out",
             @"userWant"     : @"user_want",
             @"activeStatus" : @"active_status",
             @"isCollect"    : @"is_collect",
             @"followNum"    : @"follow_num",
             @"followId"     : @"id",
             @"isFollow"    : @"is_follow",
             };
}


@end

@implementation STLFlashTotalModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsList"      : [OSSVFlashSaleGoodsModel class],
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodsList"    : @"goodsList",
             @"totalCount"   : @"totalCount",
             @"pageCount"    : @"pageCount"

             };
}

+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"goodsList",
             @"totalCount",
             @"pageCount"
             ];
}

@end
