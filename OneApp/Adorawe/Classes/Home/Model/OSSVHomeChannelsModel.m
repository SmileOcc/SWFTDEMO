//
//  OSSVHomeChannelsModel.m
// OSSVHomeChannelsModel
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeChannelsModel.h"

@implementation OSSVHomeChannelsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"channelId"       : @"cha_id",
             @"channelCode"     : @"code",
             @"channelName"     : @"name",
             @"channelContent"  : @"content",
             @"channelType"     : @"type",
             @"en_name"         : @"en_name"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"channelId",
             @"channelCode",
             @"channelName",
             @"channelContent",
             @"channelType",
             @"en_name",
             ];
}



@end
