//
//  YXSmartTradeViewModel.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXHomeHoldViewModel.h"
#import "YXTodayOrderViewModel.h"
#import "YXSmartOrderListViewModel.h"

NS_ASSUME_NONNULL_BEGIN


@class TradeModel;
@class YXV2Quote;
@class YXPosStatisticsViewModel;

@interface YXSmartTradeViewModel : YXViewModel

@property (nonatomic, strong, readonly) YXHomeHoldViewModel *holdViewModel;
@property (nonatomic, strong, readonly) YXTodayOrderViewModel *todayOrderViewModel;
@property (nonatomic, strong, readonly) YXSmartOrderListViewModel *smartOrderViewModel;
@property (nonatomic, strong, readonly) YXPosStatisticsViewModel *statisticsViewModel;

@property (nonatomic, strong, readonly) TradeModel *tradeModel;
@property (nonatomic, strong, readonly, nullable) YXV2Quote *quote;
@property (nonatomic, strong, readonly, nullable) YXV2Quote *followQuote;


@property (nonatomic, assign) BOOL needSingleUpdate;
@property (nonatomic, assign) BOOL needPosStatisticsUpdate;

- (void)changeStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)symbol;
- (void)subRtFull;
- (void)unSub;
- (void)singleBmpSubRtFull;

- (void)subFollowRtSimple;
- (void)unSubFollow;
- (void)singleBmpSubFollowRtSimple;

- (void)requestSubViewModels;
- (void)requestTodayViewModel;
- (void)requestSmartViewModel;


- (void)refreshPowerAndCanBuySell;

@end

NS_ASSUME_NONNULL_END
