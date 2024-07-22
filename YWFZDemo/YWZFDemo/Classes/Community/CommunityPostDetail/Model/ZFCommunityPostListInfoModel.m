//
//  ZFCommunityPostListInfoModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostListInfoModel.h"
#import "ZFCommunityPictureModel.h"

@implementation ZFCommunityPostListInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewPic" : [ZFCommunityPictureModel class]
             };
}

@end
