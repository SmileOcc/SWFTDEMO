//
//  ZFCommunityPostDetailModel.m
//  Yoshop
//
//  Created by YW on 16/7/14.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFCommunityPostDetailModel.h"

#import "ZFCommunityGoodsInfosModel.h"
#import "ZFCommunityPostDetailLikeUserModel.h"
#import "ZFCommunityPictureModel.h"

@implementation ZFCommunityPostDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
                 @"reviewPic" : [ZFCommunityPictureModel class],
                 @"goodsInfos" : [ZFCommunityGoodsInfosModel class],
                 @"likeUsers" : [ZFCommunityPostDetailLikeUserModel class]
                 };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
                 @"avatar",
                 @"userId",
                 @"nickname",
                 @"addTime",
                 @"isFollow",
                 @"content",
                 @"reviewPic",
                 @"likeUsers",
                 @"likeCount",
                 @"isLiked",
                 @"replyCount",
                 @"goodsInfos",
                 @"type",
                 @"reviewsId",
                 @"labelInfo",
                 @"sort",
                 @"viewNum",
                 @"reviewTotal",
                 @"beLikedTotal",
                 @"reviewType",
                 @"title",
                 @"nextReviewIds",
                 @"deeplinkUrl",
                 @"deeplinkTitle",
                 @"identify_type",
                 @"identify_icon",
                 @"identify_content",
                 @"collectCount",
                 @"isCollected",
                 ];
}

@end
