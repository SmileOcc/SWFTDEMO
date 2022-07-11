//
//  YXSmartTradeViewModel.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXSmartTradeViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXSmartTradeViewModel ()

@property (nonatomic, strong, readwrite) YXHomeHoldViewModel *holdViewModel;
@property (nonatomic, strong, readwrite) YXTodayOrderViewModel *todayOrderViewModel;
@property (nonatomic, strong, readwrite) YXSmartOrderListViewModel *smartOrderViewModel;
@property (nonatomic, strong, readwrite) YXPosStatisticsViewModel *statisticsViewModel;


@property (nonatomic, strong) YXQuoteRequest *quoteRequest;
@property (nonatomic, strong) YXQuoteRequest *followQuoteRequest;
@property (nonatomic, strong) YXQuoteRequest *singleBmpQuoteRequest;
@property (nonatomic, strong) YXQuoteRequest *singleBmpFollowQuoteRequest;
@property (nonatomic, strong, readwrite, nullable) YXV2Quote *quote;
@property (nonatomic, strong, readwrite, nullable) YXV2Quote *followQuote;
@property (nonatomic, strong, readwrite) TradeModel *tradeModel;

@property (nonatomic, strong) NSDictionary *brokerDic; //经纪商席位

@end

@implementation YXSmartTradeViewModel

- (void)dealloc {
    [self.singleBmpQuoteRequest cancel];
    [self.singleBmpFollowQuoteRequest cancel];
    [self.followQuoteRequest cancel];
    [self.quoteRequest cancel];
}

- (void)initialize {
    self.tradeModel = [self.params[@"tradeModel"] yy_modelCopy];

    if (self.tradeModel == nil) {
        self.tradeModel = [[TradeModel alloc] init];
    }
    self.tradeModel.tradeType = TradeTypeNormal;
    
    SmartOrderType smartOrderType = self.tradeModel.condition.smartOrderType;
    if ([self.tradeModel.market isEqualToString:kYXMarketUsOption]) {
        if (smartOrderType == SmartOrderTypeStopLossSell) {
            smartOrderType = SmartOrderTypeStopLossSellOption;
        } else if (smartOrderType == SmartOrderTypeStopProfitSell) {
            smartOrderType = SmartOrderTypeStopProfitSellOption;
        }
    } else {
        if (smartOrderType == SmartOrderTypeStopLossSellOption) {
            smartOrderType = SmartOrderTypeStopLossSell;
        } else if (smartOrderType == SmartOrderTypeStopProfitSellOption) {
            smartOrderType = SmartOrderTypeStopProfitSell;
        }
    }
    
    self.tradeModel.condition.smartOrderType = smartOrderType;
    
    if (self.tradeModel.symbol.length > 0 && self.tradeModel.market.length > 0) {
        if (self.tradeModel.tradeStatus != TradeStatusChange) {
            self.needSingleUpdate = YES;
        }
        self.needPosStatisticsUpdate = YES;
    }
    
    @weakify(self);
    [self.didAppearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (self.tradeModel.symbol.length > 0 && self.tradeModel.market.length > 0) {
            [self subRtFull];
            [self refreshPowerAndCanBuySell];
        }
        
//        [self subFollowRtSimple];
        
        if (self.tradeModel.tradeStatus != TradeStatusChange) {
            [self requestSubViewModels];
        }
    }];

    [self.didDisappearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
//        if (![self.tradeModel.market isEqualToString:kYXMarketUsOption]) {
////            [self.holdViewModel invalidate];
//        }
        [self unSub];
        [self unSubFollow];
    }];
    
}

#pragma mark - ViewModel

- (YXPosStatisticsViewModel *)statisticsViewModel {
    if (_statisticsViewModel == nil) {
        _statisticsViewModel = [[YXPosStatisticsViewModel alloc] initWithServices:self.services params:@{}];
    }
    return _statisticsViewModel;
}

- (YXHomeHoldViewModel *)holdViewModel {
    if (_holdViewModel == nil) {
        _holdViewModel = [[YXHomeHoldViewModel alloc] initWithServices:self.services params:@{@"exchangeType": @(self.tradeModel.market.exchangeType)}];
        _holdViewModel.isOrder = YES;
        
        @weakify(self)
//        [_holdViewModel.changeTrade.executionSignals.switchToLatest subscribeNext:^(TradeModel*  _Nullable model) {
//            @strongify(self)
//            if ([self.tradeModel.market isEqualToString:kYXMarketUsOption]) {
//                YXNormalTradeViewModel *vm = [[YXNormalTradeViewModel alloc] initWithServices:self.services params: @{@"tradeModel": model}];
//                [self.services pushViewModel:vm animated:true];
//            } else {
//                [YXTradeManager getOrderTypeWithMarket:model.market complete:^(enum TradeOrderType type) {
//                    model.tradeOrderType = type;
//                    YXNormalTradeViewModel *vm = [[YXNormalTradeViewModel alloc] initWithServices:self.services params: @{@"tradeModel": model}];
//                    [self.services pushViewModel:vm animated:true];
//                }];
//            }
//        }];
//
        [_holdViewModel.changeTradeBuy.executionSignals.switchToLatest subscribeNext:^(YXAccountAssetHoldListItem*  _Nullable m) {
            @strongify(self)
            YXTradeViewController *currentViewController = (YXTradeViewController *)[UIViewController currentViewController];
            if ([currentViewController isKindOfClass:[YXTradeViewController class]]) {
                BOOL isFraction = m.accountBusinessType == YXAccountBusinessTypeUsFraction;
                    
                self.tradeModel.market = m.market;
                self.tradeModel.symbol = m.stockCode;
                self.tradeModel.name = m.stockName;
                TradeType tradeType = isFraction ? TradeTypeFractional : TradeTypeNormal;
                [currentViewController changeToNormalTradeWithTradeType:tradeType direction:TradeDirectionBuy];
            }
        }];
        
        [_holdViewModel.changeTradeSell.executionSignals.switchToLatest subscribeNext:^(YXAccountAssetHoldListItem*  _Nullable m) {
            @strongify(self)
            YXTradeViewController *currentViewController = (YXTradeViewController *)[UIViewController currentViewController];
            if ([currentViewController isKindOfClass:[YXTradeViewController class]]) {
                BOOL isFraction = m.accountBusinessType == YXAccountBusinessTypeUsFraction;
                
                self.tradeModel.market = m.market;
                self.tradeModel.symbol = m.stockCode;
                self.tradeModel.name = m.stockName;
                TradeType tradeType = isFraction ? TradeTypeFractional : TradeTypeNormal;
                [currentViewController changeToNormalTradeWithTradeType:tradeType direction:TradeDirectionSell];
            }
        }];
        
        [_holdViewModel.changeSmartTrade.executionSignals.switchToLatest subscribeNext:^(YXAccountAssetHoldListItem*  _Nullable m) {
            @strongify(self)
            TradeModel *tradeModel = [[TradeModel alloc] init];
            tradeModel.market = m.market;
            tradeModel.symbol = m.stockCode;
            tradeModel.name = m.stockName;
            tradeModel.condition.smartOrderType = self.tradeModel.condition.smartOrderType;
            [self changeTradeModel:tradeModel];
        }];
    }
    return _holdViewModel;
}


- (YXTodayOrderViewModel *)todayOrderViewModel {
    if (_todayOrderViewModel == nil) {
        _todayOrderViewModel = [[YXTodayOrderViewModel alloc] initWithServices:self.services params:@{@"exchangeType": @(self.tradeModel.market.exchangeType)}];
        _todayOrderViewModel.isOrder = YES;
        @weakify(self)
        [_todayOrderViewModel.changeTrade.executionSignals.switchToLatest subscribeNext:^(TradeModel*  _Nullable model) {
            @strongify(self)
            model.condition.smartOrderType = self.tradeModel.condition.smartOrderType;
            [self changeTradeModel:model];
        }];
        
        //「撤销」的回调
        [_todayOrderViewModel.didClickRecall.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            [self refreshPowerAndCanBuySell];
        }];
    }
    return _todayOrderViewModel;
}

- (YXSmartOrderListViewModel *)smartOrderViewModel {
    if (_smartOrderViewModel == nil) {
        _smartOrderViewModel = [[YXSmartOrderListViewModel alloc] initWithServices:self.services params:@{@"isOrder" : @(YES)}];
        _smartOrderViewModel.isOrder = YES;
        
        @weakify(self)
        [_smartOrderViewModel.changeSmartOneMore.executionSignals.switchToLatest subscribeNext:^(TradeModel*  _Nullable model) {
            @strongify(self)
            [self changeTradeModel:model];
        }];
    }
    return _smartOrderViewModel;
}

- (void)requestSubViewModels {
    [self.todayOrderViewModel updateWithExchangeType: self.tradeModel.market.exchangeType];
    [self.smartOrderViewModel.requestRemoteDataCommand execute:@(1)];
    [self.holdViewModel.requestRemoteDataCommand execute:@(1)];
}

- (void)requestTodayViewModel {
    [self.todayOrderViewModel updateWithExchangeType: self.tradeModel.market.exchangeType];
}

- (void)requestSmartViewModel {
    [self.smartOrderViewModel.requestRemoteDataCommand execute:@(1)];
}

#pragma mark - 修改股票

- (void)changeStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)name {
    NSInteger direction = TradeDirectionBuy;
    if (self.tradeModel.condition.smartOrderType == SmartOrderTypeHighPriceSell
        || self.tradeModel.condition.smartOrderType == SmartOrderTypeBreakSell
        || self.tradeModel.condition.smartOrderType == SmartOrderTypeStopProfitSell
        || self.tradeModel.condition.smartOrderType == SmartOrderTypeStopLossSell
        || self.tradeModel.condition.smartOrderType == SmartOrderTypeTralingStop) {
        direction = TradeDirectionSell;
    }
    
    if (self.tradeModel.condition.smartOrderType == SmartOrderTypePriceHandicap
        || self.tradeModel.condition.smartOrderType == SmartOrderTypeStockHandicap) {
        direction = self.tradeModel.direction;
    }
    [self changeStock:market symbol:symbol name:name tradeStatus:TradeStatusNormal direction:direction];
}

- (void)changeStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)name tradeStatus:(TradeStatus)tradeStatus direction:(TradeDirection)direction {
    TradeModel *tradeModel = [[TradeModel alloc] init];
    tradeModel.market = market;
    tradeModel.symbol = symbol;
    tradeModel.name = name;
    tradeModel.tradeStatus = tradeStatus;
    tradeModel.direction = direction;
    
    tradeModel.condition.smartOrderType = self.tradeModel.condition.smartOrderType;
    [self changeTradeModel:tradeModel];
}

- (void)changeTradeModel:(TradeModel *)tradeModel {
    tradeModel.tradeOrderType = TradeOrderTypeSmart;
    if ([tradeModel.market isEqualToString: kYXMarketHK]) {
        tradeModel.condition.conditionOrderType = TradeOrderTypeLimitEnhanced;
    } else {
        tradeModel.condition.conditionOrderType = TradeOrderTypeLimit;
    }
    
    SmartOrderType smartOrderType = tradeModel.condition.smartOrderType;
    if ([self.tradeModel.market isEqualToString:kYXMarketUsOption]) {
        if (smartOrderType == SmartOrderTypeStopLossSell) {
            smartOrderType = SmartOrderTypeStopLossSellOption;
        } else if (smartOrderType == SmartOrderTypeStopProfitSell) {
            smartOrderType = SmartOrderTypeStopProfitSellOption;
        }
    } else {
        if (smartOrderType == SmartOrderTypeStopLossSellOption) {
            smartOrderType = SmartOrderTypeStopLossSell;
        } else if (smartOrderType == SmartOrderTypeStopProfitSellOption) {
            smartOrderType = SmartOrderTypeStopProfitSell;
        }
    }
    tradeModel.condition.smartOrderType = smartOrderType;
    tradeModel.condition.entrustGear = GearTypeEntrust;
    if (smartOrderType == SmartOrderTypeTralingStop) {
        tradeModel.condition.entrustGear = GearTypeLatest;
    }
    
    if ([tradeModel.market isEqualToString:self.tradeModel.market]) {
        tradeModel.condition.strategyEnddateDesc = self.tradeModel.condition.strategyEnddateDesc;
        tradeModel.condition.strategyEnddateTitle = self.tradeModel.condition.strategyEnddateTitle;
        tradeModel.condition.strategyEnddateYearMsg = self.tradeModel.condition.strategyEnddateYearMsg;
    }

    self.needSingleUpdate = YES;
    self.needPosStatisticsUpdate = YES;
    self.tradeModel = tradeModel;
    
    [self subRtFull];
}

#pragma mark - 行情
- (void)subRtFull {
    [self unSub];
    if (self.tradeModel.market.length < 1 || self.tradeModel.symbol.length < 1) {
        return;
    }
    Secu *secu = [[Secu alloc] initWithMarket:self.tradeModel.market symbol:self.tradeModel.symbol];
    QuoteLevel quoteLevel = [[YXUserManager shared] getLevelWith:self.tradeModel.market];
    @weakify(self)
    self.quoteRequest = [[YXQuoteManager sharedInstance] subRtFullQuoteWithSecu:secu level:quoteLevel isAdr:NO handler:^(NSArray<YXV2Quote *> * _Nonnull list , enum Scheme scheme) {
        @strongify(self)
        self.quote = list.firstObject;
        
    } failed:^{
    }];
}

- (void)unSub {
    [self.quoteRequest cancel];
}

- (void)subFollowRtSimple {
    [self unSubFollow];
    
    if (self.tradeModel.condition.releationStockCode.length > 0 &&
        self.tradeModel.condition.releationStockMarket.length > 0 &&
        (self.tradeModel.condition.smartOrderType == SmartOrderTypePriceHandicap
        || self.tradeModel.condition.smartOrderType == SmartOrderTypeStockHandicap)) {
        Secu *secu = [[Secu alloc] initWithMarket:self.tradeModel.condition.releationStockMarket symbol:self.tradeModel.condition.releationStockCode];
        QuoteLevel quoteLevel = [[YXUserManager shared] getLevelWith:self.tradeModel.condition.releationStockMarket];
        @weakify(self)
        self.followQuoteRequest = [[YXQuoteManager sharedInstance] subRtFullQuoteWithSecu:secu level:quoteLevel isAdr:NO handler:^(NSArray<YXV2Quote *> * _Nonnull list , enum Scheme scheme) {
            @strongify(self)
            self.followQuote = [list.firstObject yy_modelCopy];
        } failed:^{
        }];
    }
}

- (void)unSubFollow {
    _followQuote = nil;
    [self.followQuoteRequest cancel];
}

- (void)singleBmpSubFollowRtSimple {
    if ([[YXUserManager shared] getLevelWith:self.tradeModel.condition.releationStockMarket] == QuoteLevelBmp) {
        Secu *secu = [[Secu alloc] initWithMarket:self.tradeModel.condition.releationStockMarket symbol:self.tradeModel.condition.releationStockCode];
        
        @weakify(self)
        self.singleBmpFollowQuoteRequest = [[YXQuoteManager sharedInstance] subRtFullQuoteWithSecu:secu level:QuoteLevelBmp isAdr:NO handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
            @strongify(self);
            if (scheme == SchemeHttp) {
                self.followQuote = list.firstObject;
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"trading_refresh_success"]];
            }
        } failed:^{
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"network_failed"]];
        }];
    }
}

- (void)singleBmpSubRtFull {
    if ([[YXUserManager shared] getLevelWith:self.tradeModel.market] == QuoteLevelBmp) {
        Secu *secu = [[Secu alloc] initWithMarket:self.tradeModel.market symbol:self.tradeModel.symbol];
        
        @weakify(self)
        self.singleBmpQuoteRequest = [[YXQuoteManager sharedInstance] subRtFullQuoteWithSecu:secu level:QuoteLevelBmp isAdr:NO handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
            @strongify(self);
            if (scheme == SchemeHttp) {
                self.quote = list.firstObject;
                [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"trading_refresh_success"]];
            }
        } failed:^{
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"network_failed"]];
        }];
    }
}

//泰语、马来语先用英文
- (NSString *)p_fetchAbbName {
    switch ([YXUserManager curLanguage]) {
        case YXLanguageTypeHK:
            return @"traditional_abb_name";
            break;
        case YXLanguageTypeEN:
            return @"english_abb_name";
            break;
        case YXLanguageTypeCN:
            return @"simplified_abb_name";
            break;
            
        case YXLanguageTypeML:
            return @"english_abb_name";
            break;
        case YXLanguageTypeTH:
            return @"english_abb_name";
            break;
        default:
            return @"traditional_abb_name";
            break;
    }
}

#pragma mark - Empty Method
- (void)refreshPowerAndCanBuySell {
    
}


@end
