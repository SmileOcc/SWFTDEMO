//
//  YXOptionalBannerResponseModel.m
//  uSmartOversea
//
//  Created by youxin on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXOptionalBannerResponseModel.h"

@implementation YXOptionalBannerResponseModel
+ (NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{@"bannerList": [Banner class]};
}

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"bannerList": @"data.banner_list",
             };
}
@end

@implementation Banner

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"title": @"banner_title",
             @"adName": @"ad_name",
             @"adPos": @"ad_pos",
             @"newsId": @"news_id",
             @"newsJumpType": @"news_jump_type",
             @"jumpUrl": @"jump_url",
             @"pictureUrl": @"picture_url",
             @"adType": @"ad_type",
             @"bannerID": @"banner_id"
             };
}

@end
