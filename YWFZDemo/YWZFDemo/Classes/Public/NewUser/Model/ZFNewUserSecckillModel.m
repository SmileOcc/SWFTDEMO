//
//  ZFNewUserSecckillModel.m
//  ZZZZZ
//
//  Created by mac on 2019/1/10.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserSecckillModel.h"

@implementation ZFNewUserSecckillModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"specialName"         : @"special_name",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list"     : [ZFNewUserSecckillListModel class],
             };
}

@end

@implementation ZFNewUserSecckillListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"endTime"             : @"end_time",
             @"sekillStartDesc"     : @"sekill_start_desc",
             @"startTime"           : @"start_time",
             @"serviceTime"         : @"service_time",
             @"sekillStartTime"     : @"sekill_start_time",
             @"goodsList"           : @"goods_list",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsList"     : [ZFNewUserSecckillGoodsListModel class],
             };
}

@end

@implementation ZFNewUserSecckillGoodsListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"marketPrice"         : @"market_price",
             @"isShow"              : @"is_show",
             @"goodsGrid"           : @"goods_grid",
             @"positionId"          : @"position_id",
             @"goodsImg"            : @"goods_img",
             @"leftPercent"         : @"left_percent",
             @"goodsTitle"          : @"goods_title",
             @"addTime"             : @"add_time",
             @"urlTitle"            : @"url_title",
             @"goodsNumber"         : @"goods_number",
             @"goodsId"             : @"goods_id",
             @"seckillStatus"       : @"seckill_status",
             @"startTime"           : @"start_time",
             @"goodsLeftDesc"       : @"goods_left_desc",
             @"endTime"             : @"end_time",
             @"goodsSn"             : @"goods_sn",
             @"goodsThumb"          : @"goods_thumb",
             };
}

@end
