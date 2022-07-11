//
//  YXTableViewModel.h
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXModel.h"

@interface YXTableViewModel : YXViewModel


/**
 数据源
 */
@property (nonatomic, copy) NSArray<NSArray *> *dataSource;

@property (nonatomic, copy) NSArray *sectionIndexTitles;

/**
 页码
 */
@property (nonatomic, assign) NSUInteger page;

/**
 每页条数
 */
@property (nonatomic, assign) NSUInteger perPage;


/**
 刷新
 */
@property (nonatomic, assign) BOOL shouldPullToRefresh;


/**
 加载
 */
@property (nonatomic, assign) BOOL shouldInfiniteScrolling;

@property (nonatomic, copy) NSString *keyword;

/**
 选择
 */
@property (nonatomic, strong) RACCommand *didSelectCommand;

/**
 加载数据
 */
@property (nonatomic, strong, readonly) RACCommand *requestRemoteDataCommand;

/**
 根据偏移加载数据
 */
@property (nonatomic, strong, readonly) RACCommand *requestOffsetDataCommand;

/**
 没有更多了
 */
@property (nonatomic, assign) BOOL loadNoMore;

- (id)fetchLocalData;

- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter;

- (NSUInteger)offsetForPage:(NSUInteger)page;

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page;

- (RACSignal *)requestWithOffset:(NSInteger)offset;

// 其他地方需要更新datasource但又不想触发观察方法可以通过此方法修改
- (void)updateDataSourceWithArray:(NSArray<NSArray *> *)arr;

@end
