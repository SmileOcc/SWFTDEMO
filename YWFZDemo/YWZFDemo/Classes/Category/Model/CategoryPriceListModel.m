//
//  CategoryPriceListModel.m
//  ListPageViewController
//
//  Created by YW on 6/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryPriceListModel.h"

@implementation CategoryPriceListModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"price_max"     : @"max",
             @"price_min"     : @"min",
             @"price_range"   : @"name"
            };
}
@end
