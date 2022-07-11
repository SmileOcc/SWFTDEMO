//
//  OSSVCategoriyDetailsGoodListsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoriyDetailsGoodListsModel.h"

@implementation OSSVCategoriyDetailsGoodListsModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    
    return @{
             @"count"                    : @"count",
             @"cutOffRate"               : @"cutoff",
             @"goodsId"                  : @"goods_id",
             @"goodsImageUrl"            : @"goods_img",
             @"goods_img_w"              : @"goods_img_w",
             @"goods_img_h"              : @"goods_img_h",
             @"groupBy"                  : @"groupby",
             @"originalMarketPrice"      : @"market_price",
             @"shop_price"           : @"shop_price",
             @"warehouseCode"            : @"warehouse_code",
             @"wid"                      : @"wid",
             @"show_discount_icon"       : @"show_discount_icon",
             @"isDailyDeal"              : @"is_dailyDeal",
             @"leftTime"                 : @"leftTime",
             @"goodsTitle"               : @"goods_title",
             @"cat_id"                    : @"cat_id",
             @"cat_name"                  : @"cat_name",
             @"markImgUrl"               : @"mark_img",
             @"tips_reduction"           : @"tips_reduction",
             @"is_collect"               : @"is_collect"
             };
}

@end
