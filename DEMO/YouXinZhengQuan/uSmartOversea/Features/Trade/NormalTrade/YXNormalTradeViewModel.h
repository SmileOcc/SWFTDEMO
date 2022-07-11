//
//  YXNormalTradeViewModel.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

#import "YXHomeHoldViewModel.h"
#import "YXTodayOrderViewModel.h"

#import "YXMarketDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TradeModel;
@class YXV2Quote;
@class YXPosStatisticsViewModel;
@interface YXNormalTradeViewModel : YXViewModel

@property (nonatomic, strong, readonly) YXHomeHoldViewModel *holdViewModel;
@property (nonatomic, strong, readonly) YXTodayOrderViewModel *todayOrderViewModel;
@property (nonatomic, strong, readonly) YXPosStatisticsViewModel *statisticsViewModel;

@property (nonatomic, strong, readonly) TradeModel *tradeModel;
@property (nonatomic, strong, readonly, nullable) YXV2Quote *quote;

@property (nonatomic, assign) BOOL needSingleUpdate;
@property (nonatomic, assign) BOOL needPosStatisticsUpdate;

@property (nonatomic, strong) RACSignal *queryGreySignal;
@property (nonatomic, strong) RACCommand *loadOptionAggravateDataCommand;

- (void)changeStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)symbol;
- (void)reset;

- (void)subRtFull;
- (void)unSub;
- (void)singleBmpSubRtFull;

- (void)requestSubViewModels;
- (void)requestTodayViewModel;

- (void)refreshPowerAndCanBuySell;

@end

NS_ASSUME_NONNULL_END
