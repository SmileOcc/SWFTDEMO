//
//  YXActivityDetailModel.m
//  YouXinZhengQuan
//
//  Created by 井超 on 2019/12/31.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXBannerActivityDetailModel.h"

@implementation YXBannerActivityDetailModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{
             @"adPos": @"ad_pos",
             @"adType": @"ad_type",
             @"bannerId": @"banner_id",
             @"bannerTitle": @"banner_title",
             @"effectiveTime": @"effective_time",
             @"jumpUrl": @"jump_url",
             @"newsId": @"news_id",
             @"newsJumpType": @"news_jump_type",
             @"pictureUrl":@"picture_url",
             @"tag":@"tag",
             };
}

@end
