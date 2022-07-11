//
//  OSSVSearchingModel.m
// OSSVSearchingModel
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchingModel.h"
#import "OSSVHomeGoodsListModel.h"

@implementation OSSVSearchingModel


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"pageSize"    : @"page_size",
             @"pageCount"   : @"pageCount",
             @"goodList"    : [OSSVHomeGoodsListModel class],
             @"btm_apikey"  : @"btm_apikey",
             @"btm_index"   : @"btm_index",
             @"btm_sid"     : @"btm_sid",
             @"search_engine": @"search_engine",
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"goodList",
             @"pageCount",
             @"pageSize",
             @"page",
             @"btm_apikey",
             @"btm_index",
             @"btm_sid",
             @"search_engine",
             ];
}

@end
