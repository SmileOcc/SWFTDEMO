//
//  OSSVTransporteSpliteTotalModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransporteSpliteTotalModel.h"

@implementation OSSVTransporteSpliteTotalModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
//             @"order_sn"           : @"order_sn",
//             @"flow_num"           : @"flow_num",
//             @"track_at"           : @"track_at",
//             @"trackId"            : @"track_id",
//             @"trackDetail"        : @"track_detail",
//             @"goodsList"          : @"goods_list",
             @"track_text"         : @"track_text",
             @"trackList"          : @"list"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
//             @"goodsList"        : [OSSVTransporteSpliteGoodsModel class],
//             @"trackDetail"      : [OSSVTrackeDetaileModel class],
             @"trackList"        : [OSSVTrackeListeMode class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
//              @"order_sn",
//              @"flow_num",
//              @"track_at",
//              @"trackId",
//              @"trackDetail",
//              @"goodsList",
              @"track_text",
              @"trackList"
    ];
}

@end
