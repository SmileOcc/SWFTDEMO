//
//  YXBannerActivityModel.m
//  YouXinZhengQuan
//
//  Created by 井超 on 2019/12/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXBannerActivityModel.h"

@implementation YXBannerActivityModel
+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"bannerList": @"banner_list"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"bannerList": [YXBannerActivityDetailModel class]};
}



@end
