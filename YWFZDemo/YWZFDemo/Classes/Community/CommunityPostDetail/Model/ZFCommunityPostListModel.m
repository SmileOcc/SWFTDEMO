//
//  ZFCommunityPostListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostListModel.h"
#import "ZFCommunityPictureModel.h"

@implementation ZFCommunityPostListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewPic" : [ZFCommunityPictureModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"reviewId"    :   @"reviewId",
             @"userId"       :   @"userId",
             @"avatar"       :   @"avatar",
             @"nickname"     :   @"nickname",
             @"addTime"      :   @[@"add_time",@"addTime"],
             @"isFollow"     :   @"isFollow",
             @"content"      :   @"content",
             @"reviewPic"    :   @"reviewPic",
             @"likeCount"    :   @"likeCount",
             @"isLiked"      :   @"isLiked",
             @"topicList"    :   @"topicList",
             @"replyCount"   :   @"replyCount",
             @"identify_type":   @"identify_type",
             @"identify_icon":   @"identify_icon",
             };
}


@end
