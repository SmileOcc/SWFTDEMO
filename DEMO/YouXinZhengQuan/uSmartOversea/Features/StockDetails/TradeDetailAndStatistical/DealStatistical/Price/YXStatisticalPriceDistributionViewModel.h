//
//  YXStatisticalPriceDistributionViewModel.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXSDDealStatistalModel.h"
@class YXQuoteRequest;

NS_ASSUME_NONNULL_BEGIN

@interface YXStatisticalPriceDistributionViewModel : YXViewModel

//symbol + market + name
@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, copy, readonly) NSString *market;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *pClose;

@property (nonatomic, strong) RACSubject *loadStatisticSubject;

@property (nonatomic, strong) YXQuoteRequest *statisticRequset;

//最大的成交量
@property (nonatomic, assign) uint32_t  maxVolume;

@property (nonatomic, strong) YXSDDealStatistalModel *requestModel;
@property (nonatomic, assign) CGPoint contentOffset;

//加载Statistic数据
@property (nonatomic, strong) RACCommand *loadStatisticDataCommand;



@end

NS_ASSUME_NONNULL_END
