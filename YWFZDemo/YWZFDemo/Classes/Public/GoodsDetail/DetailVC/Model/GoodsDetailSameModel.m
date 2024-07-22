//
//  GoodsDetailSameModel.m
//  ZZZZZ
//
//  Created by ZJ1620 on 16/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoodsDetailSameModel.h"

@implementation GoodsDetailSameModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cat_level_column = [[NSDictionary alloc] init];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goods_id"           : @"goods_id",
             @"goods_number"       : @"goods_number",
             @"is_on_sale"         : @"is_on_sale",
             @"is_collect"         : @"is_collect",
             @"cat_id"             : @"cat_id",
             @"goods_title"        : @"goods_title",
             //@"short_name"         : @"short_name",
             //@"goods_thumb"        : @"goods_thumb",
             //@"goods_grid"         : @"goods_grid",
             @"shop_price"         : @"shop_price",
             //@"url_title"          : @"url_title",
             @"market_price"       : @"market_price",
             //@"promote_price"      : @"promote_price",
             //@"promote_zhekou"     : @"promote_zhekou",
             //@"odr"                : @"odr",
             //@"is_promote"         : @"is_promote",
             //@"is_mobile_price"    : @"is_mobile_price",
             @"wp_image"           : @"wp_image",
             @"goods_img"          : @"goods_img",
             //@"is_cod"             : @"is_cod",
             @"goods_sn"           : @"goods_sn"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"goods_id",
             @"goods_number",
             @"is_on_sale",
             @"cat_id",
             @"goods_title",
             //@"short_name",
             //@"goods_thumb",
             //@"goods_grid",
             @"shop_price",
             //@"url_title",
             @"market_price",
             //@"promote_price",
             //@"promote_zhekou",
             //@"odr",
             //@"is_promote",
             //@"is_mobile_price",
             @"wp_image",
             @"goods_img",
             @"is_collect",
             //@"is_cod",
             @"goods_sn",
             @"price_type"
             ];
}

- (BOOL)showMarketPrice {
    if (self.price_type == 1 || self.price_type == 2 || self.price_type == 3 || self.price_type == 4 || self.price_type == 5) {
        return YES;
    }
    return NO;
}

@end
