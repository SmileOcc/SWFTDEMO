//
//  YXExchangeDistributionViewModel.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXSDDealStatistalModel.h"
#import "YXExchangeStatisticalModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface YXExchangeDistributionViewModel : YXViewModel


//symbol + market + name
@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, copy, readonly) NSString *market;

@property (nonatomic, strong) RACSubject *loadExchangeDataSubject;

@property (nonatomic, strong) YXSDDealStatistalModel *requestModel;

@property (nonatomic, assign) CGPoint contentOffset;

//加载Statistic数据
@property (nonatomic, strong) RACCommand *loadExchangeDataCommand;

@property (nonatomic, strong) YXExchangeStatisticalModel *exchangeListModel;



@end

NS_ASSUME_NONNULL_END
