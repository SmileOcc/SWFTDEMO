//
//  OSSVTrackeDetaileModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTrackeDetaileModel.h"

@implementation OSSVTrackeDetaileModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"trackStatus"      : @"track_status",
             @"trackText"        : @"track_text",
             @"originTime"       : @"origin_time",
             @"address"          : @"address",
             @"trackStatusLang"  : @"track_status_lang"
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"trackStatus",
              @"trackText",
              @"originTime",
              @"address",
              @"trackStatusLang"
    ];
}

@end
