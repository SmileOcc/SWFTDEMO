//
//  OSSVAccountMysWishsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountMysWishsModel.h"
#import "OSSVDetailNowAttributeModel.h"

@implementation OSSVAccountMysWishsModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"goodsThumb": @"good_thumb",
             @"goodsTitle" : @"goods_title",
             @"goodsMarketPrice" : @"market_price",
             @"shop_price" : @"shop_price",
             @"goodsAttr" : @"GoodsAttr",
             @"store" : @"store",
             @"cat_name" : @"cat_name",
             @"goodsId" : @"goods_id",
             @"goodsNowAttr" : @"now_attr",
             @"collectId" : @"collect_id",
             @"warehouseCode" : @"warehouse_code",
             @"warehouseName" : @"warehouse_name",
             @"isOnSale" : @"is_on_sale",
             @"goodsNum" : @"goods_number",
             @"tips_reduction" : @"tips_reduction"
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"GoodsDetailsNowAttributeModel" : [OSSVDetailNowAttributeModel class]};
}
@end
