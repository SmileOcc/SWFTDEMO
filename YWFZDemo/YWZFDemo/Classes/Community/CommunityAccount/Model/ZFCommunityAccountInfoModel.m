
//
//  ZFCommunityAccountInfoModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountInfoModel.h"

@implementation ZFCommunityAccountInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"nickName"       : @"nick_name"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"state",
             @"avatar",
             @"nickName",
             @"followingCount",
             @"followersCount",
             @"userId",
             @"likeCount",
             @"isFollow",
             @"affiliate_id",
             @"identify_type",
             @"identify_icon",
             @"identify_content",
             ];
}
@end
