//
//  YXHomeHoldViewModel.m
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXHomeHoldViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXRequest.h"

//#import "YXSmartTradeGuideViewModel.h"
//#import "YXWarrantsMainViewModel.h"

@interface YXHomeHoldViewModel ()

@property (nonatomic, strong, readwrite) RACCommand *didClickQuote;
@property (nonatomic, strong, readwrite) RACCommand *didClickTrade;
@property (nonatomic, strong, readwrite) RACCommand *didClickBuy;
@property (nonatomic, strong, readwrite) RACCommand *didClickSell;

@property (nonatomic, strong) YXRequest *request;

@property (nonatomic, assign) YXSortState currentSortState;
@property (nonatomic, assign) YXMobileBrief1Type currentMobileBrief1Type;

@property (nonatomic, strong) YXSubscribeQuotesManager *quoteTool;
@property (nonatomic, assign) BOOL didAppear;

@end

@implementation YXHomeHoldViewModel

- (void)dealloc
{
    [self.quoteTool invalidate];
    self.quoteTool = nil;
}

- (instancetype)initWithServices:(id<YXViewModelServices>)services params:(NSDictionary *)params {
    
    if (self = [super initWithServices:services params:params]) {
        
    }
    
    return self;
}

- (void)initialize {
    [super initialize];
    
    self.needShowEmptyImage = YES;

    self.isAssetPage = [((NSNumber *)self.params[@"isAssetPage"]) boolValue];
    
    self.sortState = YXSortStateNormal;
    self.currentSortState = YXSortStateNormal;
    
    @weakify(self)
    self.didClickQuote = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXAccountAssetHoldListItem * _Nullable model) {
        @strongify(self)

        NSString *name = model.stockName;
        NSString *symbol = model.stockCode;
        NSString *market = model.market;

        YXStockInputModel *input = [[YXStockInputModel alloc] init];
        input.market = market;
        input.symbol = symbol;
        input.name = name;
        [self.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
             
        return [RACSignal empty];
    }];
    
    self.didClickTrade = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXAccountAssetHoldListItem * _Nullable m) {
        @strongify(self)
        if (self.isOrder) {
            [self.changeTrade execute:m];
        } else {
            TradeModel *model = [[TradeModel alloc] init];
            model.name = m.stockName;
            model.symbol = m.stockCode;
            model.market = model.market;
            if ([model.market isEqualToString:kYXMarketHK]) {
                model.tradeOrderType = TradeOrderTypeLimitEnhanced;
            } else {
                model.tradeOrderType = TradeOrderTypeLimit;
            }
            
            if (m.accountBusinessType == YXAccountBusinessTypeUsFraction) {
                model.tradeType = TradeTypeFractional;
            }
            
            YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
            [self.services pushViewModel:viewModel animated:YES];
        }
        return [RACSignal empty];
    }];
    //点击「买入」
    self.didClickBuy = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXAccountAssetHoldListItem * _Nullable m) {
        @strongify(self)
        if (self.isOrder) {
            [self.changeTradeBuy execute:m];
        } else {
            TradeModel *model = [[TradeModel alloc] init];
            model.name = m.stockName;
            model.symbol = m.stockCode;
            model.market = m.market;
            model.tradeStatus = TradeStatusLimit;
            if ([model.market isEqualToString:kYXMarketHK]) {
                model.tradeOrderType = TradeOrderTypeLimitEnhanced;
            } else {
                model.tradeOrderType = TradeOrderTypeLimit;
            }
            
            if (m.accountBusinessType == YXAccountBusinessTypeUsFraction) {
                model.tradeType = TradeTypeFractional;
            }
            
            [YXTradeManager getOrderTypeWithMarket:model.market complete:^(enum TradeOrderType tradeOrderType) {
                model.tradeOrderType = tradeOrderType;
                YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
                [self.services pushViewModel:viewModel animated:YES];
            }];
        }
        return [RACSignal empty];
    }];
    
    //点击「卖出」
    self.didClickSell = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXAccountAssetHoldListItem * _Nullable m) {
        @strongify(self)
        if (self.isOrder) {
            [self.changeTradeSell execute:m];
        }else {
            TradeModel *model = [[TradeModel alloc] init];
            model.name = m.stockName;
            model.symbol = m.stockCode;
            model.market = m.market;
            model.direction = TradeDirectionSell;
            model.tradeStatus = TradeStatusLimit;
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.positiveFormat = @"###,##0";
            numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
            model.entrustQuantity = [numberFormatter stringFromNumber:@(m.currentAmount.integerValue)];
            
            if (m.accountBusinessType == YXAccountBusinessTypeUsFraction) {
                model.tradeType = TradeTypeFractional;
            }
            
            [YXTradeManager getOrderTypeWithMarket:model.market complete:^(enum TradeOrderType tradeOrderType) {
                model.tradeOrderType = tradeOrderType;
                YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.services params:@{@"tradeModel":model}];
                [self.services pushViewModel:viewModel animated:YES];
            }];
        }
        return [RACSignal empty];
    }];

    
    self.changeTrade = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    //「买入」
    self.changeTradeBuy = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    //「卖出」
    self.changeTradeSell = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];

    self.changeSmartTrade = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    self.didClickSortCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        @strongify(self)
        YXAccountArea area = [input.firstObject integerValue];
        YXSortState state = [input[1] integerValue];
        YXMobileBrief1Type type = [input.lastObject integerValue];
        
        LOG_VERBOSE(kOther, @"%zd--%zd",state, type);
        self.currentMobileBrief1Type = type;
        self.currentSortState = state;


        NSMutableArray *tempDataSource = [NSMutableArray arrayWithArray:self.dataSource];

        for (NSArray *holdList in tempDataSource) {
            if (holdList.count == 0) {
                continue;
            }

            YXAccountAssetHoldListItem *item = holdList.firstObject;

            NSString *market = item.exchangeType.lowercaseString;

            if (([market isEqualToString:kYXMarketHK] && area == YXAccountAreaHk)
                || ([market isEqualToString:kYXMarketUS] && area == YXAccountAreaUs)
                || ([market isEqualToString:kYXMarketUsOption] && area == YXAccountAreaUsoptions)
                || ([market isEqualToString:kYXMarketSG] && area == YXAccountAreaSg)) {

                NSInteger index = [tempDataSource indexOfObject:holdList];
                tempDataSource[index] = [self list:holdList withSortState:self.currentSortState mobileBrief1Type:self.currentMobileBrief1Type];

                break;
            }
        }

        self.dataSource = [tempDataSource copy];
        
        return [RACSignal empty];
    }];
    
    self.didClickWarrant = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXAccountAssetHoldListItem * _Nullable model) {
        @strongify(self)
        //FIXME: 涡轮的跳转
        [self.services pushPath:YXModulePathsWarrantsAndStreet context:@{@"name": model.stockName, @"symbol": model.stockCode, @"market": model.market} animated:YES];
        return [RACSignal empty];
    }];
    
    [self.didAppearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)

        self.didAppear = YES;

        if (self.isAssetPage) { // 如果是在资产页，那么持仓更新依赖于资产页的数据即可
            return;
        }

        [self.requestRemoteDataCommand execute:@(1)];
    }];
    
    [self.didDisappearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self)

        self.didAppear = NO;

        if (self.isAssetPage) { // 如果是在资产页，那么持仓更新依赖于资产页的数据即可
            return;
        }

        [self.quoteTool invalidate];
    }];
}

- (NSArray *)list:(NSArray *)list withSortState:(YXSortState)sortState mobileBrief1Type:(YXMobileBrief1Type)mobileBrief1Type {
    if (list != nil) {
        NSArray *array = [list copy];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(YXAccountAssetHoldListItem *  _Nonnull obj1, YXAccountAssetHoldListItem *  _Nonnull obj2) {
            double value1 = 0;
            double value2 = 0;
            switch (mobileBrief1Type) {
//                case YXMobileBrief1TypeDailyBalance:
//                {
//                    value1 = [obj1.dailyBalance doubleValue];
//                    value2 = [obj2.dailyBalance doubleValue];
//                }
//                    break;
                case YXMobileBrief1TypeHoldingBalance:
                {
                    value1 = [obj1.holdingBalance doubleValue];
                    value2 = [obj2.holdingBalance doubleValue];
                }
                    break;
                case YXMobileBrief1TypeMarketValueAndNumber:
                {
                    value1 = [obj1.marketValue doubleValue];
                    value2 = [obj2.marketValue doubleValue];
                }
                    break;
                case YXMobileBrief1TypeLastAndCostPrice:
                {
                    value1 = [obj1.lastPrice doubleValue];
                    value2 = [obj2.lastPrice doubleValue];
                }
                    break;
                default:
                    break;
            }
            if (sortState == YXSortStateAscending) {
                if (value1 < value2) {
                    return NSOrderedAscending;
                } else if (value1 > value2) {
                    return NSOrderedDescending;
                } else {
                    return [obj1.stockName compare:obj2.stockName];
                }
            } else if (sortState == YXSortStateDescending) {
                if (value1 > value2) {
                    return NSOrderedAscending;
                } else if (value1 < value2) {
                    return NSOrderedDescending;
                } else {
                    return [obj2.stockName compare:obj1.stockName];
                }
            }
            return NSOrderedSame;
        }];
        return array;
    }
    return @[];
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    
    if (![YXUserManager isLogin]) {
        return [RACSignal empty];
    }
    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        if (self.request) {
            [self.request stop];
            self.request = nil;
        }
        
        YXAccountAssetReqModel *requestModel = [[YXAccountAssetReqModel alloc] init];
        requestModel.userId = [NSString stringWithFormat:@"%llu", YXUserManager.userUUID];
        requestModel.accountBusinessType = 100;
        
        self.request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXAccountAssetResModel *model = [YXAccountAssetResModel yy_modelWithJSON:responseModel.data];
                [model calculate];
                self.assetModel = model;
                [self reloadDataSource];
                [self subAllMarketsQuote:model];
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

- (NSInteger)holdSecurityCount {
    NSInteger count = 0;
    for (NSArray *holdList in self.dataSource) {
        count += holdList.count;
    }
    return count;
}

- (void)reloadDataSource {
    NSMutableArray *dataSource = [NSMutableArray array];

    for (YXAccountAssetData *assetData in self.assetModel.assetSingleInfoRespVOS) {
        NSString *market = assetData.exchangeType.lowercaseString;
        if ([market isEqualToString:kYXMarketHK]) {
            NSArray *holdingList = [self list:assetData.holdInfos withSortState:self.hkstate mobileBrief1Type:self.hktype];
            [dataSource addObject:holdingList];
        } else if ([market isEqualToString:kYXMarketUS]) {
            switch (assetData.accountBusinessType) {
                case YXAccountBusinessTypeNormal: {
                    NSArray *holdingList = [self list:assetData.holdInfos withSortState:self.usstate mobileBrief1Type:self.ustype];
                    [dataSource addObject:holdingList];
                }
                    break;
                case YXAccountBusinessTypeUsFraction: {
                    NSArray *holdingList = [self list:assetData.holdInfos withSortState:self.usFractionState mobileBrief1Type:self.usFractionType];
                    [dataSource addObject:holdingList];
                }
                    break;
                case YXAccountBusinessTypeUsOption: {
                    NSArray *holdingList = [self list:assetData.holdInfos withSortState:self.usOptionState mobileBrief1Type:self.usOptionType];
                    [dataSource addObject:holdingList];
                }
                    break;
            }
        } else if ([market isEqualToString:kYXMarketSG]) {
            NSArray *holdingList = [self list:assetData.holdInfos withSortState:self.sgstate mobileBrief1Type:self.sgtype];
            [dataSource addObject:holdingList];
        }
    }

    self.dataSource = [dataSource copy];
}

#pragma mark - 行情订阅

- (YXSubscribeQuotesManager *)quoteTool {
    if (!_quoteTool) {
        _quoteTool = [[YXSubscribeQuotesManager alloc] init];
    }
    return _quoteTool;
}

- (void)subAllMarketsQuote:(YXAccountAssetResModel *)assetModel {
    if (self.isAssetPage) { // 如果是在资产页，那么持仓更新依赖于资产页的数据即可
        return;
    }

    if (!self.didAppear) {
        return;
    }

    if (!assetModel.totalData) {
        return;
    }

    @weakify(self)
    [self.quoteTool subAllMarketQuotes:assetModel callBack:^(YXAccountAssetResModel *model) {
        @strongify(self)
        [self reloadDataSource];
    }];
}

@end
