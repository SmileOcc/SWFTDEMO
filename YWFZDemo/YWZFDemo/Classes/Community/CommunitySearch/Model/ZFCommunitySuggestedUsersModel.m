//
//  ZFCommunitySuggestedUsersModel.m
//  ZZZZZ
//
//  Created by YW on 2017/7/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySuggestedUsersModel.h"

@implementation ZFCommunitySuggestedUsersModel


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"avatar"       : @"avatar",
             @"isFollow"        : @"isFollow",
             @"likes_total"        : @"likes_total",
             @"nickname"        : @"nickname",
             @"review_total"        : @"review_total",
             @"user_id"        : @"user_id",
             @"postlist"          : @"postlist",
             @"identify_type"        : @"identify_type",
             @"identify_icon"          : @"identify_icon"
             };
}
@end

