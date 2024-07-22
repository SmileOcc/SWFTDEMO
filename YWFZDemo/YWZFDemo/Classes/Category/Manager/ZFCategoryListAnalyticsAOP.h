//
//  ZFCategoryListAnalyticsManager.h
//  ZZZZZ
//
//  Created by YW on 2018/10/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  分类列表统计代码AOP
//  适用于 CategoryListPageViewModel

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"
#import "GoodsDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCategoryListAnalyticsAOP : NSObject
<
    ZFAnalyticsInjectProtocol
>

@property (nonatomic, copy) NSString *cateName;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, strong) AFparams *afParams;

///重置统计筛选数据源
- (void)refreshDataSource;

@end

NS_ASSUME_NONNULL_END
