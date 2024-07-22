//
//  ZFCommunityMoreHotVideoModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMoreHotVideoModel.h"

@implementation ZFCommunityMoreHotVideoModel
+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
             @"videoId" : @"id",
             @"videoTitle" : @"video_title",
             @"viewNum" : @"view_num",
             @"videoUrl" : @"video_url",
             @"videoDesc" : @"duration"
             };
}

+ (NSArray *)modelPropertyWhitelist
{
    return @[
             @"videoId",
             @"videoTitle",
             @"viewNum",
             @"videoUrl",
             @"videoDesc"
             ];
}
@end
