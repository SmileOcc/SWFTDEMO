//
//  ZFCommunityVideoDetailInfoModel.m
//  ZZZZZ
//
//  Created by YW on 16/11/30.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoDetailInfoModel.h"

@implementation ZFCommunityVideoDetailInfoModel

+ (NSDictionary *)modelCustomPropertyMapper
{
    return @{
                 @"videoId" : @"id",
                 @"viewNum" : @"view_num",
                 @"videoUrl" : @"video_url",
                 @"videoDescription" : @"video_description",
                 @"likeNum" : @"like_num"
                 };
}

+ (NSArray *)modelPropertyWhitelist
{
    return @[
                 @"videoId",
                 @"viewNum",
                 @"videoUrl",
                 @"videoDescription",
                 @"likeNum",
                 @"isLike"
                 ];
}

@end
