//
//  STLCartLikeGoodsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLCartLikeGoodsModel.h"

@implementation STLCartLikeGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"title" : @"title",
             @"goods" : @"goods"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"title" : [CartLikeGoodsTitleModel class],
             @"goods" : [CartLikeGoodsItemsModel class],
             };
}


@end


// ==============================  =========================== //
@implementation CartLikeGoodsTitleModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"titleName" : @"title_name",
             @"titleImage" : @"title_image"
             };
}

@end;

// ==============================  =========================== //
@implementation CartLikeGoodsItemsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsTitle" : @"goods_title",
             @"goodsId" : @"goods_id",
             @"wid" : @"wid",
             @"goodsPrice" : @"goods_price",
             @"marketPrice" : @"market_price",
             @"goodsThumb" : @"goods_thumb"
             };
}
@end
