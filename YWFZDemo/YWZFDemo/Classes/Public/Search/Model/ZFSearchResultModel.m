//
//  ZFSearchResultModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultModel.h"
#import "ZFGoodsModel.h"

@implementation ZFSearchResultModel

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.goodsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodsArray" : @"goods_list",
             @"result_num" : @"result_num",
             @"total_page" : @"total_page",
             @"cur_page"   : @"cur_page"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodsArray" : [ZFGoodsModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"goodsArray",
             @"result_num",
             @"total_page",
             @"cur_page",
             @"guideWords",
             @"spellKeywords",
             @"af_params_color",
             @"af_params_search"
             ];
}

@end
