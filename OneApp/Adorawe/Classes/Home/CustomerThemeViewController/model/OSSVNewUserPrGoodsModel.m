//
//  OSSVNewUserPrGoodsModel.m
// OSSVNewUserPrGoodsModel
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVNewUserPrGoodsModel.h"

@implementation OSSVNewUserPrGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsId" : @"goods_id",
             @"shopPrice" : @"shop_price",
             @"goodsNumber" : @"goods_number",
             @"isOnSale" : @"is_on_sale",
             @"marketPrice":@"market_price",
             @"goodsImg" : @"goods_img",
             @"discount" : @"discount",
             @"wid" : @"wid",
             @"goodsSpecs" : @"GoodsSpecs",
             @"goodsTitle" : @"goods_title",
             @"isCollect"  : @"is_Collect"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsSpecs"          : [OSSVSpecsModel class]
             };
}


@end
