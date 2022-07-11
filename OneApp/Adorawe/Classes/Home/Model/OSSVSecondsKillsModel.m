//
//  OSSVSecondsKillsModel.m
// OSSVSecondsKillsModel
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSecondsKillsModel.h"

@implementation OSSVSecondsKillsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"banner"          : @"banner",
             @"goods_list"      : @"goods_list",
             @"timing"          : @"timing",
             @"goodsList"       : @"goodsList",
             @"endStr"          : @"label",
             @"timeCount"       : @"expire_time"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{
             @"banner"      : [OSSVAdvsEventsModel class],
             @"goods_list"  : [OSSVHomeGoodsListModel class],
             @"goodsList"   : [OSSVHomeGoodsListModel class]
             };
}


@end
