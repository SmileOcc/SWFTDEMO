//
//  OSSVFlashMainModel.m
// XStarlinkProject
//
//  Created by odd on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFlashMainModel.h"

@implementation OSSVFlashMainModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"activeTabs"      : [OSSVFlashChannelModel class],
             @"bannerInfo"      : [OSSVAdvsEventsModel class],
             };
}

@end
