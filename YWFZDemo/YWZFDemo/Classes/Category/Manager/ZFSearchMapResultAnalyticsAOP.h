//
//  ZFSearchMapResultAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2018/10/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  搜索统计代码AOP
//  适用于 SearchResultViewController ZFSearchMapResultViewController

#import <Foundation/Foundation.h>
#import "ZFAnalyticsInjectProtocol.h"
#import "ZFAppsflyerAnalytics.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZFSearchMapResultAnalyticsDatasource <NSObject>

///获取数据源
- (NSArray *)ZFSearchMapResultAnalyticsDataList;

///获取当前正在搜索的key
- (NSString *)ZFSearchMapResultAnalyticsSearchKey;

@end

@interface ZFSearchMapResultAnalyticsAOP : NSObject
<                                                                                                                                                        
    ZFAnalyticsInjectProtocol
>

-(instancetype)init;

///搜索结果总条数
@property (nonatomic, assign) NSInteger totalCount;
///搜索类型，包括文字搜索和图片搜索
@property (nonatomic, copy) NSString *searchType;
///搜索排序
@property (nonatomic, copy) NSString *sort;
///当前搜集的页面
@property (nonatomic, copy) NSString *page;

@property (nonatomic, weak) id<ZFSearchMapResultAnalyticsDatasource>datasource;
// 统计参数
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

@end

NS_ASSUME_NONNULL_END
