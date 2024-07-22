//
//  CategoryListPageModel.m
//  ListPageViewController
//
//  Created by YW on 24/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryListPageModel.h"
#import "CategoryPriceListModel.h"
#import "CategoryNewModel.h"

@implementation CategoryListPageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"virtualCategorys"   : @"category" };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goods_list"          : [ZFGoodsModel class] ,
             @"virtualCategorys"    : [CategoryNewModel class] ,
             @"price_list"          : [CategoryPriceListModel class],
             @"af_params"           : [AFparams class],
             @"af_params_color"     : [AFparams class]
            };
}

-(NSArray<ZFBTSModel *> *)gainDataSetBTSModelList
{
    NSMutableArray *btsModelList = [[NSMutableArray alloc] init];
    if (self.af_params) {
        [btsModelList addObject:[self.af_params exChangeBTSModel]];
    }
    if (self.af_params_color) {
        [btsModelList addObject:[self.af_params_color exChangeBTSModel]];
    }
    return btsModelList.copy;
}

@end
