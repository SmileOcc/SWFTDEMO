//
//  HelpModel.m
//  ZZZZZ
//
//  Created by YW on 18/9/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "HelpModel.h"

@implementation HelpModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"helpId" :@"id",
             @"title"  :@"title",
             @"url"    :@"url"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return  @[@"helpId",
              @"title",
              @"url",];
}
@end
