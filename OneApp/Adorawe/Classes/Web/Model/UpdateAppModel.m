//
//  UpdateAppModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "UpdateAppModel.h"

@implementation UpdateAppModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"isUpdate"    : @"is_update",
             @"title"       : @"title",
             @"updateMsg"   : @"updateMsg",
             @"url"         : @"url"
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"isUpdate",
             @"title",
             @"updateMsg",
             @"url"
             ];
}

@end
