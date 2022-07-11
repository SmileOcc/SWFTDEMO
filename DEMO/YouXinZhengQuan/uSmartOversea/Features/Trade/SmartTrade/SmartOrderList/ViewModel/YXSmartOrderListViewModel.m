//
//  YXSmartOrderListViewModel.m
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXSmartOrderListViewModel.h"

#import "NSDate+YYAdd.h"
//#import "YXOrderDetailViewModel.h"
//#import "YXSmartOrderGuideViewModel.h"

#import "uSmartOversea-Swift.h"

@interface YXSmartOrderListViewModel ()

@property (nonatomic, strong, readwrite) RACCommand *didClickQuote;
@property (nonatomic, strong, readwrite) RACCommand *didClickChange;
@property (nonatomic, strong, readwrite) RACCommand *didClickStop;

@property (nonatomic, strong, readwrite) RACCommand *didClickSmartOneMore;   //再来一单
@property (nonatomic, strong, readwrite) RACCommand *didClickSmartDetail;    //查看触发订单
@property (nonatomic, strong, readwrite) RACCommand *changeSmartOneMore;

@property (nonatomic, strong, readwrite) NSMutableArray *tradingOrders;
@property (nonatomic, strong, readwrite) NSMutableArray *doneOrders;

@property (nonatomic, strong) YXRequest *request;

@end

@implementation YXSmartOrderListViewModel

- (void)initialize {
    [super initialize];

    self.orderType = @"";
    self.beginDate = @"";
    self.endDate = @"";
    self.stockCode = @"";

    // 是否在下单页
    if (self.params[@"isOrder"]) {
        self.isOrder = [((NSNumber *)self.params[@"isOrder"]) boolValue];
    }

    if (self.isOrder) { // 下单页
        self.orderStatus = @""; // 默认全部
        self.transactionTime = @"1"; // 默认今天
    } else {
        self.orderStatus = @"0"; // 默认 Active
        self.transactionTime = @"4"; // 默认近三个月
    }

    if (self.params[@"exchangeType"]) {
        NSInteger exchangeType = [((NSNumber *)self.params[@"exchangeType"]) integerValue];

        // TODO: SG
        if (exchangeType == 5) {
            self.marketType = YXMarketFilterTypeUs;
        } else if (exchangeType == 0) {
            self.marketType = YXMarketFilterTypeHk;
        } else {
            self.marketType = YXMarketFilterTypeAll;
        }
    }

    @weakify(self)
    //行情
    self.didClickQuote = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXConditionOrderModel * _Nullable model) {
        YXStockInputModel *input = [[YXStockInputModel alloc] init];
        input.market = model.market.lowercaseString;
        input.symbol = model.stockCode;
        input.name = model.stockName;
        [self.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
     
        return [RACSignal empty];
    }];
    
    //修改
    self.didClickChange = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXConditionOrderModel * _Nullable orderModel) {
        @strongify(self)
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        numberFormatter.groupingSize = 3;
        numberFormatter.groupingSeparator = @",";
        numberFormatter.maximumFractionDigits = 4;

        NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
        priceFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        priceFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        priceFormatter.maximumFractionDigits = 4;
        priceFormatter.groupingSeparator = @"";

        TradeModel *model = [[TradeModel alloc] init];
        model.name = orderModel.stockName;
        model.symbol = orderModel.stockCode;
        model.market = orderModel.market.lowercaseString;
        model.tradeOrderType = TradeOrderTypeSmart;
        model.tradeStatus = TradeStatusChange;
        model.entrustId = orderModel.conId;
        if ([orderModel.tradePeriod isEqualToString:@"AB"] || [orderModel.tradePeriod isEqualToString:@"B"] || [orderModel.tradePeriod isEqualToString:@"A"]) {
            model.tradePeriod = TradePeriodPreAfter;
        }
        
        model.entrustPrice = [priceFormatter stringFromNumber:orderModel.entrustPrice];
        model.entrustQuantity = [numberFormatter stringFromNumber:@(orderModel.entrustAmount)];
        model.condition.conditionPrice = [priceFormatter stringFromNumber:orderModel.conditionPrice];
        model.condition.strategyEnddateDesc = orderModel.strategyEnddateDesc;
        
        model.condition.amountIncrease = orderModel.amountIncrease;
        
        SmartOrderType smartOrderType = orderModel.smartOrderType;
        if (smartOrderType == SmartOrderTypeBreakSell
            || smartOrderType == SmartOrderTypeHighPriceSell
            || smartOrderType == SmartOrderTypeStopProfitSell
            || smartOrderType == SmartOrderTypeStopLossSell
            || smartOrderType == SmartOrderTypeTralingStop) {
            model.direction = TradeDirectionSell;
        }
        model.condition.smartOrderType = smartOrderType;
        if (smartOrderType == SmartOrderTypePriceHandicap) {
            model.condition.conditionExtendDTO = [orderModel.conditionExtendDTO yy_modelCopy];
        }
        model.condition.conditionOrderType = orderModel.entrustProp.tradeOrderType;
        model.condition.releationStockMarket = orderModel.relatedStockMarket;
        model.condition.releationStockCode = orderModel.releationStockCode;
        model.condition.releationStockName = orderModel.releationStockName;
        model.condition.dropPrice = [priceFormatter stringFromNumber:orderModel.dropPrice];

        if (orderModel.entrustGear == nil) {
            model.condition.entrustGear = GearTypeEntrust;
        } else {
            model.condition.entrustGear = orderModel.entrustGear.integerValue;
        }

        if ([orderModel.currency isEqualToString:@"HKD"]) {
            model.currency = [YXLanguageUtility kLangWithKey:@"common_hk_dollar"];
        } else if ([orderModel.currency isEqualToString:@"USD"]) {
            model.currency = [YXLanguageUtility kLangWithKey:@"common_us_dollar"];
        } else if ([orderModel.currency isEqualToString:@"SGD"]) {
            model.currency = [YXLanguageUtility kLangWithKey:@"common_sg_dollar"];
        }
        
        if (model.condition.smartOrderType == SmartOrderTypeTralingStop) {
            YXQueryCondinfoRequestModel *requestModel = [[YXQueryCondinfoRequestModel alloc] init];
            requestModel.syncIdList = @[orderModel.quoteCondId];
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXQueryCondinfoResponseModel * _Nonnull responseModel) {
                YXCondInfo *info = responseModel.list.firstObject;
                model.condition.highestPrice = [priceFormatter stringFromNumber:@(info.highestPrice.doubleValue / 1000)];

                YXSmartTradeViewModel *viewModel = [[YXSmartTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
                [self.services pushViewModel:viewModel animated:YES];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                
            }];
        } else {
            YXSmartTradeViewModel *viewModel = [[YXSmartTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
            [self.services pushViewModel:viewModel animated:YES];
        }


        return [RACSignal empty];
    }];

    
    //再来一单
    self.didClickSmartOneMore = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXConditionOrderModel * _Nullable orderModel) {
        @strongify(self)
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        numberFormatter.groupingSize = 3;
        numberFormatter.groupingSeparator = @",";
        numberFormatter.maximumFractionDigits = 4;

        NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
        priceFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        priceFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        priceFormatter.maximumFractionDigits = 4;
        priceFormatter.groupingSeparator = @"";

        TradeModel *model = [[TradeModel alloc] init];
        model.name = orderModel.stockName;
        model.symbol = orderModel.stockCode;
        model.market = orderModel.market.lowercaseString;
        model.tradeOrderType = TradeOrderTypeSmart;
        
        SmartOrderType smartOrderType = orderModel.smartOrderType;
        if (smartOrderType == SmartOrderTypeBreakSell
            || smartOrderType == SmartOrderTypeHighPriceSell
            || smartOrderType == SmartOrderTypeStopProfitSell
            || smartOrderType == SmartOrderTypeStopLossSell
            || smartOrderType == SmartOrderTypeTralingStop) {
            model.direction = TradeDirectionSell;
        }

        model.condition.smartOrderType = smartOrderType;
        if (smartOrderType == SmartOrderTypePriceHandicap) {
            if ([orderModel.conditionExtendDTO.quotationSource isKindOfClass:[NSNumber class]]) {
                ConditionExtendDTO *dto = [[ConditionExtendDTO alloc] init];
                dto.quotationSource = @(orderModel.conditionExtendDTO.quotationSource.integerValue);
                model.condition.conditionExtendDTO = dto;
                
                if (orderModel.conditionExtendDTO.quotationSource.integerValue == 1) {
                    model.condition.releationStockMarket = orderModel.relatedStockMarket;
                    model.condition.releationStockCode = orderModel.releationStockCode;
                }
            }
        } else if (smartOrderType == SmartOrderTypeStockHandicap) {
            model.condition.releationStockMarket = orderModel.relatedStockMarket;
            model.condition.releationStockCode = orderModel.releationStockCode;
            model.condition.releationStockName = orderModel.releationStockName;
        }
        model.condition.conditionPrice = [priceFormatter stringFromNumber:orderModel.conditionPrice];
        model.condition.amountIncrease = orderModel.amountIncrease;
        model.condition.dropPrice = [priceFormatter stringFromNumber:orderModel.dropPrice];

        if ([orderModel.currency isEqualToString:@"HKD"]) {
            model.currency = [YXLanguageUtility kLangWithKey:@"common_hk_dollar"];
        } else if ([orderModel.currency isEqualToString:@"USD"]) {
            model.currency = [YXLanguageUtility kLangWithKey:@"common_us_dollar"];
        } else if ([orderModel.currency isEqualToString:@"SGD"]) {
            model.currency = [YXLanguageUtility kLangWithKey:@"common_sg_dollar"];
        }

        if (self.isOrder) {
            [self.changeSmartOneMore execute:model];
        } else {
            YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
            
            [self.services pushViewModel:viewModel animated:YES];
        }
        
        return [RACSignal empty];
    }];
    
    //智能交易页的「再来一单」
    self.changeSmartOneMore = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];

    //查看触发订单
    self.didClickSmartDetail = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXConditionOrderModel * _Nullable orderModel) {
        @strongify(self);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            YXOrderDetailViewModel *viewModel = [[YXOrderDetailViewModel alloc] initWithMarket:orderModel.market.lowercaseString
                                                                                        symbol:orderModel.stockCode
                                                                                     entrustId:orderModel.orderId
                                                                                          name:orderModel.stockName
                                                                                  allOrderType:YXAllOrderTypeNormal];
            [self.services pushPath:YXModulePathsOrderDetail context:viewModel animated:YES];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
                return nil;
        }];
    }];
    
    //终止
    self.didClickStop = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXConditionOrderModel * _Nullable model) {
        @strongify(self)
        return [self requestUndoConditionRequestModelWithModel:model];
    }];
    
    self.validatePwd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        if (self.request) {
            [self.request stop];
            self.request = nil;
        }

        YXHoldSmartOrderRequestModel *requestModel = [[YXHoldSmartOrderRequestModel alloc] init];
        requestModel.isQueryTodayConditionOrder = self.isOrder;

        if (!self.isOrder) {
            YXSmartOrderQuery *query = [[YXSmartOrderQuery alloc] init];
            query.securityType = self.securityType;
            query.transactionTime = self.transactionTime;
            query.transactionTimeStart = self.beginDate;
            query.transactionTimeEnd = self.endDate;
            query.conditionType = self.orderType;
            query.orderStatus = self.orderStatus;
            query.market = [self fetchMarketWith:self.marketType];
            query.stockCode = self.stockCode;

            requestModel.query = query;
        }

        if (self.isAll) {
            requestModel.pageNum = page;
        }
        self.request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.request startWithBlockWithSuccess:^(YXConditionOrderResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                if (self.isAll) {
                    if (page == 1) {
                        self.dataSource = @[responseModel.list];
                    } else {
                        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.dataSource[0]];
                        [array addObjectsFromArray:responseModel.list];
                        self.dataSource = @[array];
                    }
                    if ([self.dataSource[0] count] < responseModel.total && [responseModel.list count] != 0) {
                        self.loadNoMore = NO;
                    } else {
                        self.loadNoMore = YES;
                    }
                } else {
                    self.tradingOrders = [[NSMutableArray alloc] init];
                    self.doneOrders = [[NSMutableArray alloc] init];

                    [responseModel.list enumerateObjectsUsingBlock:^(YXConditionOrderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.status != 0) {
                            [self.doneOrders addObject:obj];
                        } else {
                            [self.tradingOrders addObject:obj];
                        }
                    }];
                    if ([responseModel.list count] < 1) {
                        self.dataSource = @[@[[YXModel new]]];
                    } else {
                        if ([self.doneOrders count] < 1) {
                            self.dataSource = @[self.tradingOrders];
                        } else if ([self.tradingOrders count] < 1){
                            self.dataSource = @[@[[YXModel new]], @[[YXModel new]], self.doneOrders];
                        } else {
                            self.dataSource = @[self.tradingOrders, @[[YXModel new]], self.doneOrders];
                        }
                    }
                }

                [subscriber sendNext:responseModel];
            }
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            self.dataSource = nil;
            [subscriber sendError:nil];
        }];

        return nil;
    }];
}

- (RACSignal *)requestUndoConditionRequestModelWithModel:(YXConditionOrderModel *)model {
    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        
        YXRequest *request;

        YXUndoConditionRequestModel *requestModel = [[YXUndoConditionRequestModel alloc] init];
        requestModel.conId = model.conId;
        request = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                if (self.isAll) {
                    NSMutableArray *array = [self.dataSource[0] mutableCopy];
                    [array enumerateObjectsUsingBlock:^(YXConditionOrderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.conId isEqualToString: model.conId]) {
                            model.status = 3;
                           // model.statusDes = @"已失效";
                            model.statusDes = [YXLanguageUtility kLangWithKey:@"order_list_statusDes"];
                            array[idx] = model;
                            *stop = YES;
                        }
                    }];
                    self.dataSource = @[array];
                } else {
                    [self.tradingOrders enumerateObjectsUsingBlock:^(YXConditionOrderModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.conId isEqualToString: model.conId]) {
                            [self.tradingOrders removeObjectAtIndex:idx];
                            *stop = YES;
                        }
                    }];
                    
                    model.status = 3;
                   // model.statusDes = @"已失效";
                    model.statusDes = [YXLanguageUtility kLangWithKey:@"order_list_statusDes"];
                    [self.doneOrders insertObject:model atIndex:0];
                    if ([self.tradingOrders count] < 1){
                        self.dataSource = @[@[[YXModel new]], @[[YXModel new]], self.doneOrders];
                    } else {
                        self.dataSource = @[self.tradingOrders, @[[YXModel new]], self.doneOrders];
                    }
                }
                [subscriber sendNext:nil];
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"trading_alert_cancel_cond_order_success"]];
            }else if (responseModel.code == YXResponseStatusCodeTradePwdInvalid || responseModel.code ==  YXResponseStatusCodeTradePwdInvalid1) {
                
                if (self.validatePwd) {
                    [self.validatePwd execute:model];
                }
                
            }else {
                NSError *error = [NSError errorWithDomain:YXViewModel.defaultErrorDomain code:responseModel.code userInfo:@{NSLocalizedDescriptionKey: responseModel.msg, YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
                [self.requestShowErrorSignal sendNext:error];
            }
            [subscriber sendCompleted];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            [self.requestShowErrorSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

///获取market字符串
- (NSString *)fetchMarketWith:(YXMarketType)marketType {
    switch (marketType) {
        case YXMarketFilterTypeHk:
            return @"HK";
        case YXMarketFilterTypeUs:
            return @"US";
        case YXMarketFilterTypeSg:
            return @"SG";
        default:
            return @"";
    }
}

@end
