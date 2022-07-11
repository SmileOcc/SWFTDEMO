//
//  YXStockDetailBrokerRatioVModel.h
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXStockAnalyzeBrokerListModel.h"

@class Secu;
@class YXV2Quote;
@class YXQuoteRequest;
@interface YXStockDetailBrokerRatioVModel : YXViewModel

//symbol + market + name
@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, copy, readonly) NSString *market;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *pClose;

@property (nonatomic, strong) Secu *secu;
//行情model
@property (nonatomic, strong) YXV2Quote *quotaModel;

@property (nonatomic, strong) NSDictionary *brokerDic;

@property (nonatomic, strong) YXStockAnalyzeBrokerListModel *dataSource;

@property (nonatomic, strong) NSArray<YXStockAnalyzeBrokerStockInfo *> *brokerNamesArray;

@property (nonatomic, assign) long long maxValue;


@property (nonatomic, strong) RACCommand *pushToBrokerDetailCommand;

@property (nonatomic, strong) RACCommand *brokerShareHoldingDataCommand;

@end
