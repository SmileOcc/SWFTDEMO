//
//  OSSVCheckUpdatesModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckUpdatesModel.h"
#import "OSSVUpdatesContentsModel.h"

@implementation OSSVCheckUpdatesModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"isNeedUpdate"            : @"status",
             @"updateContent"           : @"data"
             };
}


+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"isNeedUpdate",
              @"updateContent"
              ];
}

@end
