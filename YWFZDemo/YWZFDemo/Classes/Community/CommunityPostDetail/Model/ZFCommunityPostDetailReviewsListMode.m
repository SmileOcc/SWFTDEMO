//
//  ZFCommunityPostDetailReviewsListMode.m
//  Yoshop
//
//  Created by YW on 16/7/15.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFCommunityPostDetailReviewsListMode.h"

@implementation ZFCommunityPostDetailReviewsListMode

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"userId",
             @"content",
             @"avatar",
             @"nickname",
             @"reviewId",
             @"isSecondFloorReply",
             @"replyId",
             @"replyAvatar",
             @"replyUserId",
             @"replyNickName",
             @"identify_type",
             @"identify_icon",
             ];
}

@end
