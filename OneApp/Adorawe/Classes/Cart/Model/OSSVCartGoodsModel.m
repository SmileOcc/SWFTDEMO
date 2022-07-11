//
//  OSSVCartGoodsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartGoodsModel.h"

@implementation OSSVCartGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodsId"     : @"goods_id",
             @"goodsSn"     : @"goods_sn",
             @"goodsAttr"     : @"goods_attr",
             @"goodsName" : @"goods_name",
             @"goodsPrice"     : @"goods_price",
             @"goodsThumb"     : @"goods_thumb",
             @"cat_name"   : @"cat_name",
             @"goodsNumber" : @"goods_number",
             @"warehouseName" : @"warehouse_name",
             @"flashSaleId"   : @"flash_sale_active_id",
             @"isFlashSale"   : @"is_flash_sale",
             @"exchange_label" : @"exchange_label",
             @"is_exchange":@"is_exchange",
             };
}

@end
