//
//  ZFCommunityPostDetailLikeUserModel.m
//  Yoshop
//
//  Created by YW on 16/7/21.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFCommunityPostDetailLikeUserModel.h"

@implementation ZFCommunityPostDetailLikeUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"userId"       : @"user_id"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"avatar",
             @"userId"
             ];
}

@end
