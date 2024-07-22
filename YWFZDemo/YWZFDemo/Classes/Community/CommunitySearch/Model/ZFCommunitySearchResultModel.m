
//
//  ZFCommunitySearchResultModel.m
//  ZZZZZ
//
//  Created by YW on 2017/7/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchResultModel.h"
@implementation ZFCommunitySearchResultModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"avatar"       : @"avatar",
             @"isFollow"        : @"isFollow",
             @"likes_total"        : @"likes_total",
             @"nick_name"        : @"nick_name",
             @"review_total"        : @"review_total",
             @"user_id"        : @"user_id",
             @"identify_type"  : @"identify_type",
             @"identify_icon"  : @"identify_icon",
             };
}

@end

