//
//  OSSVHomeGoodsListModel.m
// OSSVHomeGoodsListModel
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeGoodsListModel.h"

@implementation OSSVHomeGoodsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"cutOffRate"               : @"cutoff",
             @"goodsId"                  : @"goods_id",
             @"goods_sn"                 : @"goods_sn",
             @"goodsImageUrl"            : @"goods_img",
             @"goods_img_w"              : @"goods_img_w",
             @"goods_img_h"              : @"goods_img_h",
             @"warehouseCode"            : @"warehouse_code",
             @"wid"                      : @"wid",
             @"show_discount_icon"       : @"show_discount_icon",
             @"isDailyDeal"              : @"is_dailyDeal",
             @"leftTime"                 : @"leftTime",
             @"goodsTitle"               : @"goods_title",
             @"cat_id"                    : @"cat_id",
             @"cat_name"                  : @"cat_name",
             @"markImgUrl"               : @"mark_img",
             @"activePrice"              : @"active_price",
             @"activeId"                 : @"active_id",
             @"discount"                 : @"discount",
             @"tips_reduction"           : @"tips_reduction",
             @"is_collect"               : @"is_collect"
             };
}


@end
