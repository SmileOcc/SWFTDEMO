//
//  ZFBannerPageModel.m
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNativeBannerPageModel.h"

@implementation ZFNativeBannerPageModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"plateID"        :@"navId",
             @"plateTitle"     :@"navName"
             };
}

@end
