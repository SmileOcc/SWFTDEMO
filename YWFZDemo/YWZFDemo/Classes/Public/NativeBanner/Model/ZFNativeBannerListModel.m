//
//  ZFNativeBannerListModel.m
//  ZZZZZ
//
//  Created by YW on 13/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeBannerListModel.h"
#import "ZFNativeBannerModel.h"
#import "ZFGoodsModel.h"

@implementation ZFNativeBannerListModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"bannerID"   : @"positionId",
             @"bannerName" : @"positionName",
             @"bannerType" : @"positionType",
             @"bannerList" : @"banners",
             @"skuArrays"  : @"goodsList"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"bannerList" : [ZFNativeBannerModel class],
             @"skuArrays"  : [ZFGoodsModel class]
             };
}

@end
