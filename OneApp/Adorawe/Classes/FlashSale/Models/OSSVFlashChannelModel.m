//
//  OSSVFlashChannelModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashChannelModel.h"

@implementation OSSVFlashChannelModel


+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"activeId"       : @"active_id",
             @"expireTime"     : @"expire_time",
             @"title"          : @"title",
             @"label"          : @"label",
             @"timeLabel"      : @"time_label",
             @"status"         : @"status"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"activeId",
             @"expireTime",
             @"title",
             @"label",
             @"timeLabel",
             @"status",
             @"start_time",
             @"date_label",
             @"calendar_tips",
             @"calendar_link",
             ];
}
@end
