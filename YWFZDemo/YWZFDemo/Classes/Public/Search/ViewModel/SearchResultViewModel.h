//
//  SearchResultViewModel.h
//  Dezzal
//
//  Created by YW on 18/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFAnalytics.h"
#import "CategoryRefineSectionModel.h"

typedef void(^SearchResultReloadDataCompletionHandler)(void);

@interface SearchResultViewModel : BaseViewModel

@property (nonatomic, copy) SearchResultReloadDataCompletionHandler searchResultReloadDataCompletionHandler;

@property (nonatomic, strong) NSString                              *searchTitle;
//统计
@property (nonatomic, strong) ZFAnalyticsProduceImpression          *analyticsProduceImpression;


/// 搜索列表
- (void)requestSearchNetwork:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

/// 搜索筛选
- (void)requestSearchRefineData:(NSDictionary *)params completion:(void (^)(id))completion failure:(void (^)(id))failure;
@end

