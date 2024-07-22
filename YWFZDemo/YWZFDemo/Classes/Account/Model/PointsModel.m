//
//  PointsModel.m
//  Dezzal
//
//  Created by YW on 18/8/11.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "PointsModel.h"

@implementation PointsModel

+ (NSDictionary *)modelCustomPropertyMapper {

    return @{
             @"adddate" : @"adddate",
             @"income"  : @"income",
             @"outgo"   : @"outgo",
             @"balance" : @"balance",
             @"note"    : @"note",
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return  @[@"adddate",
              @"income",
              @"outgo",
              @"balance",
              @"note" ];
}
@end
