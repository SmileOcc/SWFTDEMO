//
//  YXSmartTradeGuideViewModel.m
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXSmartTradeGuideViewModel.h"

//#import "YXSmartTradeViewModel.h"

#import "YXRequest.h"
#import "NSDictionary+Category.h"

#import "uSmartOversea-Swift.h"

#import "YXBannerActivityModel.h"
#import "YXSmartTradeViewModel.h"

@interface YXSmartTradeGuideViewModel()


@property (nonatomic, strong) YXRequest *advertiseRequest; //顶部图片
@property (nonatomic, strong) YXRequest *kindlyReminderRequest; //风险提示

@end


@implementation YXSmartTradeGuideViewModel

- (void)initialize {
    
    self.tradeModel = self.params[@"tradeModel"];

    if (self.tradeModel == nil) {
        NSInteger exchangeType = (NSInteger)[self.params yx_intValueForKey:@"exchangeType"];
        TradeModel *tradeModel = [[TradeModel alloc] init];
        tradeModel.market = [NSString marketWithExchangeType:exchangeType];
        self.tradeModel = tradeModel;
    }

    //MARK: command实现
    //风险提示
    @weakify(self)
    self.advertiseCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable x) {
        
        @strongify(self)
        
        return [self sendOtherAdvertiseRequest];
    }];
    
    //风险提示
    self.kindlyReminderCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable x) {
        
        @strongify(self)
        
        return [self sendKindlyReminderSelectRequest];
    }];
}

//APP查询温馨提示
- (RACSignal *)sendOtherAdvertiseRequest {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        
        YXBannerAdvertisementRequestModel *requestModel = [[YXBannerAdvertisementRequestModel alloc] init];
        
        requestModel.show_page = 108;
        self.advertiseRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        @weakify(self)
        [self.advertiseRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            @strongify(self)
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXBannerActivityModel *model = [YXBannerActivityModel yy_modelWithDictionary:responseModel.data];
                
                NSMutableArray *activityArr = [[NSMutableArray alloc] init];
                if (model.bannerList.count > 0) {
                    [activityArr addObjectsFromArray:model.bannerList];
                    self.bannerList = model.bannerList;
                }
                [subscriber sendNext:activityArr];
            }else {
                NSError *error = [NSError errorWithDomain:YXViewModel.defaultErrorDomain code:responseModel.code userInfo:@{NSLocalizedDescriptionKey: responseModel.msg}];
                [self.requestShowErrorSignal sendNext:error];
            }
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"network_timeout"] in:[UIViewController currentViewController].view];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

//APP查询温馨提示
- (RACSignal *)sendKindlyReminderSelectRequest {

    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        
        YXKindlyReminderSelectRequestModel *requestModel = [[YXKindlyReminderSelectRequestModel alloc] init];
        
        requestModel.sceneType = 1;
        self.kindlyReminderRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.kindlyReminderRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            if (responseModel.code == YXResponseStatusCodeSuccess) {

                [subscriber sendNext:responseModel.data];
            }else {
                NSError *error = [NSError errorWithDomain:YXViewModel.defaultErrorDomain code:responseModel.code userInfo:@{NSLocalizedDescriptionKey: responseModel.msg}];
                [self.requestShowErrorSignal sendNext:error];
            }
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"network_timeout"] in:[UIViewController currentViewController].view];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

//MARK: 私有方法
- (void)pushToSmartOrderWith:(NSInteger)type {
    SmartOrderType smartOrderType = type;

    TradeModel *tradeModel = [[TradeModel alloc] init];
    tradeModel.tradeOrderType = TradeOrderTypeSmart;
    tradeModel.condition.smartOrderType = smartOrderType;
    tradeModel.market = self.tradeModel.market;
    tradeModel.symbol = self.tradeModel.symbol;
    tradeModel.name = self.tradeModel.name;
    if (smartOrderType == SmartOrderTypeStopLossSell ||
        smartOrderType == SmartOrderTypeStopLossSellOption ||
        smartOrderType == SmartOrderTypeHighPriceSell ||
        smartOrderType == SmartOrderTypeStopProfitSell ||
        smartOrderType == SmartOrderTypeStopProfitSellOption ||
        smartOrderType == SmartOrderTypeBreakSell ||
        smartOrderType == SmartOrderTypeTralingStop) {
        tradeModel.direction = TradeDirectionSell;
    }
    YXTradeViewModel *viewModel = [[YXTradeViewModel alloc] initWithServices:self.services
                                                                      params:@{
                                                                          @"tradeModel": tradeModel,
                                                                      }];
    [self.services pushViewModel:viewModel animated:YES];
}

- (NSArray *)configs {
    if (_configs == nil) {
//        NSMutableArray *holdItems = [NSMutableArray arrayWithArray:@[
//            @{
//                @"title":[YXLanguageUtility kLangWithKey:@"trading_stop_profit_sell_order"],
//                @"desc":[YXLanguageUtility kLangWithKey:@"stop_profit_sell_desc"],
//                @"image":[UIImage imageNamed:@"trade_smart_profit_sell"],
//                @"smartOrderType":@(SmartOrderTypeStopProfitSell)
//            },
//            @{
//                @"title":[YXLanguageUtility kLangWithKey:@"trading_stop_loss_sell_order"],
//                @"desc":[YXLanguageUtility kLangWithKey:@"stop_loss_sell_desc"],
//                @"image":[UIImage imageNamed:@"trade_smart_loss_sell"],
//                @"smartOrderType":@(SmartOrderTypeStopLossSell)
//            }
//        ]];
//        if (![self.tradeModel.market isEqualToString:kYXMarketUsOption]) {
//            [holdItems addObject:
//             @{
//                 @"title":[YXLanguageUtility kLangWithKey:@"trading_traling_stop"],
//                 @"desc":[YXLanguageUtility kLangWithKey:@"trading_traling_stop_desc"],
//                 @"image":[UIImage imageNamed:@"trade_smart_traling_stop"],
//                 @"smartOrderType":@(SmartOrderTypeTralingStop)
//             }];
//        }
        NSMutableArray *configs = [@[
            @{
                @"title":[YXLanguageUtility kLangWithKey:@"price_conditions"],
                @"desc":[YXLanguageUtility kLangWithKey:@"trading_price_conditions_desc"],
                @"column":@(1),
                @"items":@[
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_break_buy_order"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"break_buy_desc"],
                            @"image":[UIImage imageNamed:@"break_buy"],
                            @"smartOrderType":@(SmartOrderTypeBreakBuy)
                        },
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_low_price_buy_order"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"low_buy_desc"],
                            @"image":[UIImage imageNamed:@"trade_smart_low_buy"],
                            @"smartOrderType":@(SmartOrderTypeLowPriceBuy)
                        },
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_high_price_sell_order"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"high_sell_desc"],
                            @"image":[UIImage imageNamed:@"trade_smart_high_price_sell"],
                            @"smartOrderType":@(SmartOrderTypeHighPriceSell)
                        },
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_break_sell_order"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"break_sell_desc"],
                            @"image":[UIImage imageNamed:@"break_sell"],
                            @"smartOrderType":@(SmartOrderTypeBreakSell)
                        }
                ]
            },
            @{
                @"title":[YXLanguageUtility kLangWithKey:@"trading_stop_profit_stop_loss"],
                @"desc":@"",
                @"column":@(1),
                @"items":@[
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_stop_profit_sell_order"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"take_profit_desc"],
                            @"image":[UIImage imageNamed:@"take_profit"],
                            @"smartOrderType":@(SmartOrderTypeStopProfitSell)
                        },
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_stop_loss_sell_order"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"stop_loss_desc"],
                            @"image":[UIImage imageNamed:@"stop_loss"],
                            @"smartOrderType":@(SmartOrderTypeStopLossSell)
                        },
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trading_traling_stop"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"traling_stop_desc"],
                            @"image":[UIImage imageNamed:@"trailing_stop"],
                            @"smartOrderType":@(SmartOrderTypeTralingStop)
                        },
                ]
            },
            @{
                @"title":[YXLanguageUtility kLangWithKey:@"portfolio_strategy"],
                @"desc":@"",
                @"column":@(1),
                @"items":@[
                        @{
                            @"title":[YXLanguageUtility kLangWithKey:@"trigger_follow_stock"],
                            @"desc":[YXLanguageUtility kLangWithKey:@"trigger_follow_stock_desc"],
                            @"image":[UIImage imageNamed:@"stock_handicap"],
                            @"smartOrderType":@(SmartOrderTypeStockHandicap)
                        },
                ]
            },
        ] mutableCopy];
        
//        [configs addObject:
//         @{
//             @"title": [YXLanguageUtility kLangWithKey:@"hold_stop_win_loss"],
//             @"desc":@"",
//             @"column":@(1),
//             @"items":holdItems,
//         }];
//
//        NSMutableArray *mixItems = [NSMutableArray array];
//        if ([self.tradeModel.market isEqualToString:kYXMarketHK]) {
//            [mixItems addObject:
//             @{
//                 @"title":[YXLanguageUtility kLangWithKey:@"trigger_bid_ask_price"],
//                 @"desc":[YXLanguageUtility kLangWithKey:@"trigger_bid_ask_price_desc"],
//                 @"image":[UIImage imageNamed:@"trade_smart_price_handicap"],
//                 @"smartOrderType":@(SmartOrderTypePriceHandicap)
//             }];
//        }
//        [mixItems addObject:
//         @{
//             @"title":[YXLanguageUtility kLangWithKey:@"trigger_follow_stock"],
//             @"desc":[YXLanguageUtility kLangWithKey:@"trigger_follow_stock_desc"],
//             @"image":[UIImage imageNamed:@"trade_smart_follow_handicap"],
//             @"smartOrderType":@(SmartOrderTypeStockHandicap)
//         }];
//        if ([self.tradeModel.market isEqualToString:kYXMarketHK] || [self.tradeModel.market isEqualToString:kYXMarketUS]) {
//            if ([YXUserManager isGrayWith:YXGrayStatusBitTypeGrid]) {
//                [mixItems addObject:
//                 @{
//                     @"title":[YXLanguageUtility kLangWithKey:@"grid_trade_title"],
//                     @"desc":[YXLanguageUtility kLangWithKey:@"grid_trade_desc"],
//                     @"image":[UIImage imageNamed:@"smart_grid"],
//                     @"smartOrderType":@(SmartOrderTypeGrid)
//                 }];
//            }
//        }
//
//        NSDictionary *mixConfig = @{
//            @"title":[YXLanguageUtility kLangWithKey:@"portfolio_strategy"],
//            @"desc":[YXLanguageUtility kLangWithKey:@"trading_portfolio_strategy_desc"],
//            @"column":@(1),
//            @"items":mixItems
//        };
//        [configs addObject:mixConfig];
        
        _configs = [configs copy];
    }
    return _configs;
}


@end
