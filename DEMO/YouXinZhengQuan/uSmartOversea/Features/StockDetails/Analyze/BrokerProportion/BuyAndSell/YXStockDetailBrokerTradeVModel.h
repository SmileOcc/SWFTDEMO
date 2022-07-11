//
//  YXStockDetailBrokerTradeVModel.h
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class Secu;
@class YXV2Quote;
@class YXQuoteRequest;
@interface YXStockDetailBrokerTradeVModel : YXViewModel

//symbol + market + name
@property (nonatomic, copy, readonly) NSString *symbol;
@property (nonatomic, copy, readonly) NSString *market;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *pClose;

@property (nonatomic, assign) int brokerType;

@property (nonatomic, strong) Secu *secu;

@property (nonatomic, strong) NSDictionary *brokerDic;

@property (nonatomic, assign) int level;

@property (nonatomic, strong) RACCommand *brokerListDataCommand;

@property (nonatomic, strong) RACSubject *brokerTimerSubject;

@property (nonatomic, strong) RACCommand *pushToBrokerDetailCommand;

// 开启定时器
- (void)openTimer;

- (void)closeTimer;

@end

NS_ASSUME_NONNULL_END
