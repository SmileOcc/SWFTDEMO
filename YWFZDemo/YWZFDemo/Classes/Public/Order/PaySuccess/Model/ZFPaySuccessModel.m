
//
//  ZFPaySuccessModel.m
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaySuccessModel.h"
#import "ZFBannerModel.h"

@implementation ZFPaySuccessModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"banners" : [ZFBannerModel class]
             };
}

@end
