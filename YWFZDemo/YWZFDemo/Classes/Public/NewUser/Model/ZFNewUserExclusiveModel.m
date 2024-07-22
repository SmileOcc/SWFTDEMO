//
//  ZFNewUserExclusiveModel.m
//  ZZZZZ
//
//  Created by mac on 2019/1/8.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserExclusiveModel.h"

@implementation ZFNewUserExclusiveModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"specialMemo"         : @"special_memo",
             @"specialName"         : @"special_name",
             @"specialKeyword"      : @"special_keyword",
             @"specialUrl"          : @"special_url",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list"     : [ZFNewUserExclusiveListModel class],
             };
}

@end


@implementation ZFNewUserExclusiveListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsList"     : @"goods_list",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsList"     : [ZFNewUserExclusiveGoodsListModel class],
             };
}

@end


@implementation ZFNewUserExclusiveGoodsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"nsSaleStartTime"         : @"ns_sale_start_time",
             @"marketPrice"             : @"market_price",
             @"nsSaleEndTime"           : @"ns_sale_end_time",
             @"goodsGrid"               : @"goods_grid",
             @"positionName"            : @"position_name",
             @"catId"                   : @"cat_id",
             @"shopPrice"               : @"shop_price",
             @"positionId"              : @"position_id",
             @"attrSize"                : @"attr_size",
             @"userPrice"               : @"new_user_price",
             @"goodsImg"                : @"goods_img",
             @"urlTitle"                : @"url_title",
             @"goodsTitle"              : @"goods_title",
             @"goodsId"                 : @"goods_id",
             @"attrColor"               : @"attr_color",
             @"goodsSn"                 : @"goods_sn",
             @"goodsThumb"              : @"goods_thumb",
             };
}


@end
