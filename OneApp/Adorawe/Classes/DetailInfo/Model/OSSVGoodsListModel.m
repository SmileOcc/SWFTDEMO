//
//  OSSVGoodsListModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVGoodsListModel.h"

@implementation OSSVGoodsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsId"        : @"goods_id",
             @"wid"            : @"wid",
             @"warehouseCode"  : @"warehouse_code",
             @"goodsImg"       : @"goods_img",
             @"goods_img_w"    : @"goods_img_w",
             @"goods_img_h"    : @"goods_img_h",
             @"shop_price"     : @"shop_price",
             @"goodsMarketPrice" : @"market_price",
             @"goodsCount"       : @"count",
             @"cutOffRate"       : @"cutoff",
             @"imageSize"        : @"image_size",
             @"goodsTitle"       : @"goods_title",
             @"cat_id"           : @"cat_id",
             @"cat_name"         : @"cat_name",
             @"markImgUrlString" : @"mark_img",
             @"discount"         : @"discount",
             @"tips_reduction"   : @"tips_reduction",
             @"isCollect"        : @"is_Collect"
             };
}
@end
