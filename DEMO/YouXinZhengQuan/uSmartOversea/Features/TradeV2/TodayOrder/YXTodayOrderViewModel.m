//
//  YXTodayOrderViewModel.m
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTodayOrderViewModel.h"
#import "YXRequest.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "uSmartOversea-Swift.h"
//#import "YXTradeViewModel.h"


@interface YXTodayOrderViewModel ()

@property (nonatomic, strong, readwrite) RACCommand *didClickQuote;
@property (nonatomic, strong, readwrite) RACCommand *didClickTrade;
@property (nonatomic, strong, readwrite) RACCommand *didClickChange;
@property (nonatomic, strong, readwrite) RACCommand *didClickRecall;
@property (nonatomic, strong, readwrite) RACCommand *didClickOrderDetail;    //订单详情
@property (nonatomic, strong, readwrite) RACCommand *bondCancel;

@property (nonatomic, strong) RACCommand *didChange; //更改了订单
@property (nonatomic, strong, readwrite) RACCommand *pwdSucceedForUndoEntrust; //对撤单，密码输入成功

@property (nonatomic, strong, readwrite) NSMutableArray *tradingOrders;
@property (nonatomic, strong, readwrite) NSMutableArray *doneOrders;

@property (nonatomic, strong, readwrite) NSMutableArray *stockTradingOrders;
@property (nonatomic, strong, readwrite) NSMutableArray *stockDoneOrders;

@property (nonatomic, strong, readwrite) NSMutableArray *bondTradingOrders;
@property (nonatomic, strong, readwrite) NSMutableArray *bondDoneOrders;


@property (nonatomic, strong) YXRequest *request;
@property (nonatomic, strong) YXRequest *undoEntrustRequest;
@property (nonatomic, strong) YXRequest *undoBrokenEntrustRequest;

//@property (nonatomic, assign, readwrite) NSInteger exchangeType;

@property (nonatomic, assign) YXTimerFlag timerFlag; //定时器

@end

@implementation YXTodayOrderViewModel

- (instancetype)initWithServices:(id<YXViewModelServices>)services params:(NSDictionary *)params {
    
    if (self = [super initWithServices:services params:params]) {

    }
    
    return self;
}

- (void)initialize {
    [super initialize];
    
    self.exchangeType = YXExchangeTypeUs;
    self.categoryStatus = @"0";
    self.market = @"";
    
    if (self.params[@"exchangeType"]) {
        self.exchangeType = [((NSNumber *)self.params[@"exchangeType"]) integerValue];
    }

    self.isAssetPage = [((NSNumber *)self.params[@"isAssetPage"]) boolValue];
    
    self.needShowEmptyImage = YES;
    
    @weakify(self)
    self.didClickQuote = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXOrderModel *orderModel) {
        @strongify(self)
        NSString *name = orderModel.symbolName;
        NSString *symbol = orderModel.symbol;
        NSString *market = [orderModel realMarket];
//        if (orderModel.exchangeType == 5) {
//            symbol = orderModel.symbol;
////            market = kYXMarketUS;
//        } else if (orderModel.exchangeType == 6) {
//            symbol = orderModel.symbol;
////            market = kYXMarketChinaSH;
//        } else if (orderModel.exchangeType == 7) {
//            symbol = orderModel.symbol;
////            market = kYXMarketChinaSZ;
//        } else if (orderModel.exchangeType == 51) {
//            symbol = orderModel.symbol;
////            market = kYXMarketUsOption;
//            
//            if ([[YXUserManager shared] getOptionLevel] == QuoteLevelDelay) {
//                [YXToolUtility goBuyOptionOnlineAlert];
//                return [RACSignal empty];
//            }
//        } else {
//            // 港股
//            symbol = [NSString stringWithFormat:@"%05d", [orderModel.symbol intValue]];
//        }
        
        YXStockInputModel *input = [[YXStockInputModel alloc] init];
        input.market = market;
        input.symbol = symbol;
        input.name = name;
        [self.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
     
        return [RACSignal empty];
    }];
    
    self.didClickTrade = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXOrderModel * _Nullable orderModel) {
        @strongify(self)
        TradeModel *model = [[TradeModel alloc] init];
        model.name = orderModel.symbolName;
        model.symbol = orderModel.symbol;
        model.market = [orderModel realMarket];
        
        if (self.isShortSell) {
            model.tradeType = TradeTypeShortSell;
        }

        if (self.isOrder) {
            [self.changeTrade execute:model];
        } else {
            if (self.isShortSell) {

            } else {
                [YXTradeManager getOrderTypeWithMarket:model.market complete:^(enum TradeOrderType tradeOrderType) {
                    @strongify(self)
                    model.tradeType = TradeTypeNormal;
                    model.tradeOrderType = tradeOrderType;
                    YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
                    [self.services pushViewModel:viewModel animated:YES];
                }];
            }
        }
        return [RACSignal empty];
    }];
    
    self.didClickChange = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXOrderModel * _Nullable orderModel) {
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
        model.name = orderModel.symbolName;
        model.symbol = orderModel.symbol;
        model.market = [orderModel realMarket];
        model.entrustId = orderModel.entrustId;
        model.entrustPrice = [priceFormatter stringFromNumber:orderModel.entrustPrice];
        model.entrustQuantity = [numberFormatter stringFromNumber:orderModel.entrustQty];
        model.tradeStatus = TradeStatusChange;
        
        if ([orderModel.tradePeriod isEqualToString:@"AB"] || [orderModel.tradePeriod isEqualToString:@"B"] || [orderModel.tradePeriod isEqualToString:@"A"]) {
            model.tradePeriod = TradePeriodPreAfter;
        }
        
        if ([orderModel.entrustSide isEqualToString:@"B"]) {
            model.direction = TradeDirectionBuy;
        }else {
            model.direction = TradeDirectionSell;
        }

        model.tradeOrderType = orderModel.entrustProp.tradeOrderType;
        
        if (self.isShortSell) {
            model.tradeType = TradeTypeShortSell;
        }
        
        switch (orderModel.symbolType) {
            case 2:
                model.tradeType = TradeTypeFractional;
                if (orderModel.oddTradeType == 1) {
                    model.fractionalTradeType = FractionalTradeTypeShares;
                } else {
                    model.fractionalTradeType = FractionalTradeTypeAmount;
                }
                numberFormatter.minimumFractionDigits = 2;
                model.fractionalAmount = [NSString stringWithFormat:@"%.2f", orderModel.entrustAmount.doubleValue];
                model.fractionalQuantity = [numberFormatter stringFromNumber:orderModel.entrustQty];
                break;
            case 4:
                model.tradeOrderType = TradeOrderTypeLimit;
                break;
            default:
                break;
        }

        YXNormalTradeViewModel *viewModel = [[YXNormalTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
        [self.services pushViewModel:viewModel animated:YES];
        
        return [RACSignal empty];
    }];
    
    self.didClickRecall = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXOrderModel * _Nullable orderModel) {
        @strongify(self)
        orderModel = [orderModel yy_modelCopy];

        if (orderModel.symbolType == 4) { // 期权
            return [self requestOptionUndoEntrustRequestWithModel:orderModel];
        }

        if (orderModel.symbolType == 2) { // 碎股
            return [self requestFractionUndoEntrustRequestWithModel:orderModel];
        }

        return [self requestUndoEntrustRequestWithModel:orderModel];
    }];
    
    //「订单详情」
    self.didClickOrderDetail = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXOrderModel * _Nullable orderModel) {
        @strongify(self)
        
        NSString *market = orderModel.market;
        YXAllOrderType orderType = YXAllOrderTypeNormal;
        NSString *entrustId = orderModel.entrustId;
        if (self.isIntraday) {
            orderType = YXAllOrderTypeDayMargin;
            entrustId = orderModel.dayMarginId;
        } else if (orderModel.symbolType == 4) {
            orderType = YXAllOrderTypeOption;
        } else if (self.isShortSell) {
            orderType = YXAllOrderTypeShortSell;
        }
        YXOrderDetailViewModel *viewModel = [[YXOrderDetailViewModel alloc] initWithMarket:market symbol:orderModel.symbol entrustId:entrustId name:orderModel.symbolName allOrderType:orderType];
        [self.services pushPath:YXModulePathsOrderDetail context:viewModel animated:YES];
        
        return [RACSignal empty];
    }];
    
    self.changeTrade = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {

        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    self.pwdSucceedForUndoEntrust = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {

        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    self.validatePwd = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    self.didChange = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    [self.didAppearSignal subscribeNext:^(id  _Nullable x) {
        
        @strongify(self)
        if (self.isShortcut) {
            if (self.timerFlag > 0) {
                [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.timerFlag];
                self.timerFlag = 0;
            }
            @weakify(self)
            self.timerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
                @strongify(self)
                QuoteLevel level = [[YXUserManager shared] getLevelWith:[self getMarketStrWithExchangeType:self.exchangeType]];
                if (level != QuoteLevelBmp) {
                    [self.requestRemoteDataCommand execute:@(1)];
                }

            } timeInterval:[YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeHoldingFreq] repeatTimes:NSIntegerMax atOnce:NO];
        } else {
            [self.requestRemoteDataCommand execute:@(1)];
        }
    }];
    
    [self.didDisappearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.isShortcut) {
            if (self.timerFlag > 0) {
                [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.timerFlag];
                self.timerFlag = 0;
            }
        }
    }];
    
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    
    return [self stockTodayOrderSingal];
    
}

- (RACSignal *)stockTodayOrderSingal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        if (self.request) {
            [self.request stop];
            self.request = nil;
        }
        
        YXTodayHoldOrderRequestModel *requestModel = [[YXTodayHoldOrderRequestModel alloc] init];
//        requestModel.market = self.exchangeType;
        requestModel.market = self.market;
        requestModel.categoryStatus = self.categoryStatus.intValue;
        if ([[YXUserManager shared] curBroker] == YXBrokersBitTypeNz) {
            requestModel.market = @"";
        }
        self.request = [[YXRequest alloc] initWithRequestModel:requestModel];
        @weakify(self);
        [self.request startWithBlockWithSuccess:^(YXOrderResponseModel *responseModel) {
            @strongify(self)
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                self.orderCount = responseModel.allCount;
                self.todayOrderResModel = responseModel;
                if (responseModel.list.count > 0) {
                    // 今日订单列表里的订单，需要把已结束的订单排在后面, 结束的订单有：下单失败、废单、已撤单、全部成交、收市撤单
                    NSArray *sortedList = [responseModel.list sortedArrayUsingComparator:^NSComparisonResult(YXOrderModel *obj1, YXOrderModel *obj2) {
                        if (obj1.isFinished > obj2.isFinished) {
                            return NSOrderedDescending;
                        } else if (obj1.isFinished > obj2.isFinished) {
                            return NSOrderedAscending;
                        }
                        return NSOrderedSame;
                    }];
                    self.dataSource = @[sortedList];
                }else {
                    self.dataSource = @[@[]];
                }
                    
                [subscriber sendNext:responseModel];
                
            } else {
                self.dataSource = @[@[]];
                [subscriber sendNext:responseModel];
            }
            
            [subscriber sendCompleted];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            self.dataSource = nil;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

// 期权订单撤单
- (RACSignal *)requestOptionUndoEntrustRequestWithModel:(YXOrderModel *)model {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXOptionCancelOrderRequestModel *requestModel = [[YXOptionCancelOrderRequestModel alloc] init];
        requestModel.orderId = model.entrustId;
        self.undoEntrustRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
        [self.undoEntrustRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                [subscriber sendNext:nil];
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"newStock_cancel_success"]];

            } else if (responseModel.code == YXResponseStatusCodeTradePwdInvalid
                       || responseModel.code == YXResponseStatusCodeTradePwdInvalid1
                       || responseModel.code == YXResponseStatusCodeOptionTradePwdInvalid) {

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

// 碎股订单撤单
- (RACSignal *)requestFractionUndoEntrustRequestWithModel:(YXOrderModel *)model {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXFractionalCancelOrderRequestModel *requestModel = [[YXFractionalCancelOrderRequestModel alloc] init];
        requestModel.orderId = model.entrustId;
        self.undoEntrustRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
        [self.undoEntrustRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                [subscriber sendNext:nil];
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"newStock_cancel_success"]];

            } else if (responseModel.code == YXResponseStatusCodeTradePwdInvalid
                       || responseModel.code == YXResponseStatusCodeTradePwdInvalid1
                       || responseModel.code == YXResponseStatusCodeOptionTradePwdInvalid) {

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

//普通订单撤单
- (RACSignal *)requestUndoEntrustRequestWithModel:(YXOrderModel *)model {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXUndoEntrustRequestModel2 *requestModel = [[YXUndoEntrustRequestModel2 alloc] init];
        requestModel.orderId = model.entrustId;
        self.undoEntrustRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
        
        [self.undoEntrustRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            @strongify(self)
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {

                [subscriber sendNext:nil];
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"newStock_cancel_success"]];
                
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
            @strongify(self)
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            [self.requestShowErrorSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//碎股订单撤单
- (RACSignal *)requestUndoBrokenEntrustRequestWithModel:(YXOrderModel *)model {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXUndoBrokenOrderRequestModel *requestModel = [[YXUndoBrokenOrderRequestModel alloc] init];
        requestModel.oddId = model.conId;
        self.undoBrokenEntrustRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
        [self.undoBrokenEntrustRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            @strongify(self)
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {

                [subscriber sendNext:nil];
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"newStock_cancel_success"]];
                
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
            @strongify(self)
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            [self.requestShowErrorSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//债券订单撤单
- (RACSignal *)requestUndoBondEntrustWithParams:(NSDictionary *)params {
    NSString *token = params[@"token"];
    YXBondOrderModel2 *model = params[@"bondModel"];
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXBondCancelOrderRequestModel *requestModel = [[YXBondCancelOrderRequestModel alloc] init];
        requestModel.orderNo = model.orderNo;
        requestModel.tradeToken = token;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            @strongify(self)
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                
                [subscriber sendNext:nil];
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"newStock_cancel_success"]];
                
            }else if (responseModel.code == YXResponseStatusCodeTradePwdInvalid || responseModel.code ==  YXResponseStatusCodeTradePwdInvalid1) {
                
                if (self.validatePwd) {
                    [self.validatePwd execute:nil];
                }
                
            }else {
                
                NSError *error = [NSError errorWithDomain:YXViewModel.defaultErrorDomain code:responseModel.code userInfo:@{NSLocalizedDescriptionKey: responseModel.msg, YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
                [self.requestShowErrorSignal sendNext:error];
            }
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            @strongify(self)
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInWindow)}];
            [self.requestShowErrorSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInWindow)}];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//今日订单 ---正在交易订单数
- (NSInteger)tradingOrderCount {
    return self.stockTradingOrders.count + self.bondTradingOrders.count;
}
//今日订单 ---已成交订单数
- (NSInteger)doneOrderCount {
    return self.stockDoneOrders.count + self.bondDoneOrders.count;
}

- (void)updateWithExchangeType:(NSInteger)exchangeType {
    self.exchangeType = exchangeType;
    [self.requestRemoteDataCommand execute:@(1)];
}

- (NSString *)getMarketStrWithExchangeType: (NSInteger)exchangeType {
    NSString *market = kYXMarketHK;
    switch (exchangeType) {
        case 0:
            market = kYXMarketHK;
            break;
        case 5:
            market = kYXMarketUS;
            break;
        case 6:
            market = kYXMarketChinaSH;
            break;
        case 7:
            market = kYXMarketChinaSZ;
            break;
        case 51:
            market = kYXMarketUsOption;
            break;
        default:
            market = kYXMarketChina;
            break;
    }
    
    return market;
}

@end
