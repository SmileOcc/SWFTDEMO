//
//  ZFCommunityMessageModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessageModel.h"

@implementation ZFCommunityMessageModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"review_data"        : [ZFCommunityPostDetailReviewsListMode class]
             };
}

@end
