//
//  YXNormalTradeViewModel.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/3/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNormalTradeViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXNormalTradeViewModel()

@property (nonatomic, strong, readwrite) YXHomeHoldViewModel *holdViewModel;
@property (nonatomic, strong, readwrite) YXTodayOrderViewModel *todayOrderViewModel;
@property (nonatomic, strong, readwrite) YXPosStatisticsViewModel *statisticsViewModel;

@property (nonatomic, strong) YXQuoteRequest *quoteRequest;
@property (nonatomic, strong) YXQuoteRequest *singleBmpQuoteRequest;
@property (nonatomic, strong, readwrite, nullable) YXV2Quote *quote;
@property (nonatomic, strong, readwrite) TradeModel *tradeModel;

@property (nonatomic, strong) NSDictionary *brokerDic; //经纪商席位

@property (nonatomic, strong) YXQuoteRequest *greyListRequest;
@property (nonatomic, strong) NSArray *greyList;
@end

@implementation YXNormalTradeViewModel

- (void)dealloc {
    [self.greyListRequest cancel];
    [self.singleBmpQuoteRequest cancel];
    [self.quoteRequest cancel];
}

- (void)initialize {
    self.tradeModel = [self.params[@"tradeModel"] yy_modelCopy];
    if (self.tradeModel == nil) {
        self.tradeModel = [[TradeModel alloc] init];
    }
    
    NSNumber *isFractional = self.params[@"isFractional"];
    if (isFractional.boolValue) {
        self.tradeModel.tradeType = TradeTypeFractional;
    }
    
    if (self.tradeModel.symbol.length > 0 && self.tradeModel.market.length > 0) {
        if (self.tradeModel.tradeStatus != TradeStatusChange) {
            self.needSingleUpdate = YES;
        }
        self.needPosStatisticsUpdate = YES;
    }
    
    @weakify(self);
    self.queryGreySignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        YXGreyStockListRequestModel *requestModel = [[YXGreyStockListRequestModel alloc] init];
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *list = [responseModel.data yx_arrayValueForKey:@"greyIpoInfoDTOS"];
                if (list.count > 0) {
                    NSMutableArray *arrM = [NSMutableArray array];
                    for (NSDictionary *dic in list) {
                        Secu *secu = [[Secu alloc] initWithMarket:@"hk" symbol:[dic yx_stringValueForKey:@"stockCode"]];
                        [arrM addObject:secu];
                    }
                    [self.greyListRequest cancel];
                    self.greyListRequest = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:arrM level:QuoteLevelLevel2 handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
                           if (list.count > 0) {
                               if (scheme == SchemeHttp) {
                                   self.greyList = list;
                               } else if (scheme == SchemeTcp) {
                                   for (YXV2Quote *quote in self.greyList) {
                                       for (YXV2Quote *tcpQuote in list) {
                                           if ([quote.symbol isEqualToString:tcpQuote.symbol]) {
                                               quote.latestPrice = tcpQuote.latestPrice;
                                               quote.netchng = tcpQuote.netchng;
                                               quote.pctchng = tcpQuote.pctchng;
                                           }
                                       }
                                   }
                               }
                               [subscriber sendNext:self.greyList];
                           }
                       } failed:^{
                            [subscriber sendNext:nil];
                       }];
                } else {
                    [subscriber sendNext:nil];
                }
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendError:nil];
        }];
        return nil;
    }];

    [self.didAppearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (self.tradeModel.symbol.length > 0 && self.tradeModel.market.length > 0) {
            [self subRtFull];
            [self refreshPowerAndCanBuySell];
        }

        [self requestSubViewModels];
    }];

    [self.didDisappearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.greyListRequest cancel];
        [self unSub];
    }];
    
    self.loadOptionAggravateDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self loadOptionAggravateSignal];
    }];
}

- (RACSignal *)loadOptionAggravateSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXOptionAggravateRequestModel *requestModel = [[YXOptionAggravateRequestModel alloc] init];
        requestModel.market = self.tradeModel.market;
        requestModel.code = self.tradeModel.symbol;

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSDictionary *dic = [responseModel.data yx_dictionaryValueForKey:@"options"];
                NSInteger total = [dic yx_intValueForKey:@"total" defaultValue:0];
                [subscriber sendNext: @(total)];
                [subscriber sendCompleted];
            } else {
                [subscriber sendCompleted];
            }

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

#pragma mark - ViewModel

- (YXHomeHoldViewModel *)holdViewModel {
    if (_holdViewModel == nil) {
        _holdViewModel = [[YXHomeHoldViewModel alloc] initWithServices:self.services params:@{@"exchangeType": @(self.tradeModel.market.exchangeType)}];
        _holdViewModel.isOrder = YES;
        
        @weakify(self)
        [_holdViewModel.changeTrade.executionSignals.switchToLatest subscribeNext:^(YXJYHoldStockModel*  _Nullable m) {
            [self changeStock:[m.market lowercaseString] symbol:m.stockCode name:m.stockName];
        }];
        
        [_holdViewModel.changeTradeBuy.executionSignals.switchToLatest subscribeNext:^(YXAccountAssetHoldListItem*  _Nullable m) {
            @strongify(self)
            YXTradeViewController *currentViewController = (YXTradeViewController *)[UIViewController currentViewController];
            if ([currentViewController isKindOfClass:[YXTradeViewController class]]) {
                BOOL isFraction = m.accountBusinessType == YXAccountBusinessTypeUsFraction;
                BOOL isCurrentFraction = currentViewController.tradeMenuType == TradeMenuTypeFractional;
                BOOL needReset = isFraction != isCurrentFraction;
                if (needReset) {
                    self.tradeModel.market = m.market;
                    self.tradeModel.symbol = m.stockCode;
                    self.tradeModel.name = m.stockName;
                    self.tradeModel.tradeStatus = TradeStatusLimit;
                    self.tradeModel.direction = TradeDirectionBuy;
                    self.tradeModel.tradeType = isFraction ? TradeTypeFractional : TradeTypeNormal;
                    [currentViewController resetNormalTrade];
                    return;
                }
            }
            
            [self changeStock:m.market symbol:m.stockCode name:m.stockName tradeStatus:TradeStatusLimit direction:TradeDirectionBuy];
        }];
        
        [_holdViewModel.changeTradeSell.executionSignals.switchToLatest subscribeNext:^(YXAccountAssetHoldListItem*  _Nullable m) {
            @strongify(self)
            YXTradeViewController *currentViewController = (YXTradeViewController *)[UIViewController currentViewController];
            if ([currentViewController isKindOfClass:[YXTradeViewController class]]) {
                BOOL isFraction = m.accountBusinessType == YXAccountBusinessTypeUsFraction;
                BOOL isCurrentFraction = currentViewController.tradeMenuType == TradeMenuTypeFractional;
                BOOL needReset = isFraction != isCurrentFraction;
                if (needReset) {
                    self.tradeModel.market = m.market;
                    self.tradeModel.symbol = m.stockCode;
                    self.tradeModel.name = m.stockName;
                    self.tradeModel.tradeStatus = TradeStatusLimit;
                    self.tradeModel.direction = TradeDirectionSell;
                    self.tradeModel.tradeType = isFraction ? TradeTypeFractional : TradeTypeNormal;
                    [currentViewController resetNormalTrade];
                    return;
                }
            }
         
            [self changeStock:m.market symbol:m.stockCode name:m.stockName tradeStatus:TradeStatusLimit direction:TradeDirectionSell];
        }];
        
        //「智能下单」
        [self.holdViewModel.changeSmartTrade.executionSignals.switchToLatest subscribeNext:^(YXAccountAssetHoldListItem*  _Nullable m) {
            @strongify(self)
            YXTradeViewController *currentViewController = (YXTradeViewController *)[UIViewController currentViewController];
            if ([currentViewController isKindOfClass:[YXTradeViewController class]]) {
                self.tradeModel.market = m.market;
                self.tradeModel.symbol = m.stockCode;
                self.tradeModel.name = m.stockName;
                currentViewController.tradeMenuType = TradeMenuTypeSmart;
            }
        }];
    }
    return _holdViewModel;
}

- (YXTodayOrderViewModel *)todayOrderViewModel {
    if (_todayOrderViewModel == nil) {
        _todayOrderViewModel = [[YXTodayOrderViewModel alloc] initWithServices:self.services params:@{@"exchangeType": @(self.tradeModel.market.exchangeType)}];
        _todayOrderViewModel.isOrder = YES;
        @weakify(self)
        [_todayOrderViewModel.changeTrade.executionSignals.switchToLatest subscribeNext:^(TradeModel*  _Nullable m) {
            @strongify(self)
//            [self changeStock:[NSString marketWithExchangeType:m.exchangeType] symbol:m.stockCode name:m.stockName];
            [self changeTradeModel:m];
        }];
        
        //「撤销」的回调
        [_todayOrderViewModel.didClickRecall.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
            @strongify(self)

            [self refreshPowerAndCanBuySell];
        }];
    }
    return _todayOrderViewModel;
}

- (YXPosStatisticsViewModel *)statisticsViewModel {
    if (_statisticsViewModel == nil) {
        _statisticsViewModel = [[YXPosStatisticsViewModel alloc] initWithServices:self.services params:@{}];
    }
    return _statisticsViewModel;
}

- (void)requestSubViewModels {
    [self.todayOrderViewModel updateWithExchangeType:self.tradeModel.market.exchangeType];
//    [self.todayOrderViewModel.requestRemoteDataCommand execute:@(1)];
    [self.holdViewModel.requestRemoteDataCommand execute:@(1)];
}

- (void)requestTodayViewModel {
    [self.todayOrderViewModel updateWithExchangeType: self.tradeModel.market.exchangeType];
//    [self.todayOrderViewModel.requestRemoteDataCommand execute:@(1)];
}


#pragma mark - 修改股票
- (void)changeConditionWithStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)name {
    
}

- (void)changeStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)name {
    [self changeStock:market symbol:symbol name:name tradeStatus:TradeStatusNormal direction:TradeDirectionBuy];
}

- (void)reset {
    [self changeStock:self.tradeModel.market symbol:self.tradeModel.symbol name:self.tradeModel.name tradeStatus:self.tradeModel.tradeStatus direction:self.tradeModel.direction];
}

- (void)changeStock:(NSString *)market symbol:(NSString *)symbol name:(NSString *)name tradeStatus:(TradeStatus)tradeStatus direction:(TradeDirection)direction {
    TradeModel *tradeModel = [[TradeModel alloc] init];
    tradeModel.market = market;
    tradeModel.symbol = symbol;
    tradeModel.name = name;
    tradeModel.tradeStatus = tradeStatus;
    tradeModel.direction = direction;
    if (self.tradeModel.tradeOrderType != TradeOrderTypeSmart) {
        tradeModel.tradeOrderType = self.tradeModel.tradeOrderType;
    }
    
    if (self.tradeModel.tradeType == TradeTypeShortSell) {
        tradeModel.market = kYXMarketUS;
        tradeModel.tradeType = TradeTypeShortSell;
    }
    
    if (self.tradeModel.tradeType == TradeTypeFractional) {
        tradeModel.market = kYXMarketUS;
        tradeModel.tradeType = TradeTypeFractional;
    }

    [self changeTradeModel:tradeModel];
}

- (void)changeTradeModel:(TradeModel *)tradeModel {
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


- (NSDictionary *)brokerDic {
    if (_brokerDic == nil) {
        //key与`YXBrokerService.swift`中的brokerListPath一致。
        NSData *data = [[MMKV defaultMMKV] getDataForKey:@"hk_brokerListPath"];
        if (data == nil) {
            _brokerDic = [NSDictionary dictionary];
        } else {
            NSString *abbNameKey = [self p_fetchAbbName];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
            NSArray *arr = [dic yx_arrayValueForKey:@"broker_list"];
            NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            for (NSDictionary *brokerDic in arr) {
                NSString *localId = [brokerDic yx_stringValueForKey:@"broker_code"];
                localId = [localId stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSArray *arr = [localId componentsSeparatedByString:@","];
                NSString *name = [brokerDic yx_stringValueForKey:abbNameKey]?:@"";
                for (NSString *code in arr) {
                    if (code.length > 0) {
                        [dicM setValue:name forKey:code];
                    }
                }
            }
            _brokerDic = dicM;
        }
        
    }
    return _brokerDic;
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
