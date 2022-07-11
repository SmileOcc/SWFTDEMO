//
//  OSSVTrackineAddresseModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTrackineAddresseModel.h"

@implementation OSSVTrackineAddresseModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"district"                  : @"district",
             @"country"                   : @"country",
             @"street"                    : @"street",
             @"province"                  : @"province",
             @"street_more"               : @"street_more",
             @"city"                      : @"city"
             };
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"district",
              @"country",
              @"street",
              @"province",
              @"street_more",
              @"city"
              ];
}
@end
