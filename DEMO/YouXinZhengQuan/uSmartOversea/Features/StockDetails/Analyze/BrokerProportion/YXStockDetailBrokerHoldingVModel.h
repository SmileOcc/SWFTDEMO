//
//  YXStockDetailBrokerHoldingVModel.h
//  uSmartOversea
//
//  Created by youxin on 2020/2/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
#import "YXStockDetailBrokerRatioVModel.h"
#import "YXStockDetailBrokerTradeVModel.h"

NS_ASSUME_NONNULL_BEGIN
@class Secu;
@class YXV2Quote;
@class YXQuoteRequest;
@interface YXStockDetailBrokerHoldingVModel : YXTableViewModel

@property (nonatomic, assign) NSInteger selectIndex;

//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pClose;
@property (nonatomic, strong) Secu *secu;
//行情model
@property (nonatomic, strong) YXV2Quote *quotaModel;

@property (nonatomic, assign) int level;

//加载基本盘面数据
@property (nonatomic, strong) RACCommand *loadBasicQuotaDataCommand;
@property (nonatomic, strong) RACSubject *loadBasicQuotaDataSubject;

@property (nonatomic, strong, nullable) YXQuoteRequest *quoteRequset;

@property (nonatomic, strong) YXStockDetailBrokerRatioVModel *ratioVModel;
@property (nonatomic, strong) YXStockDetailBrokerTradeVModel *tradeVModel;


- (void)cancelRequest;

- (void)loadQuoteData;

@end

NS_ASSUME_NONNULL_END
