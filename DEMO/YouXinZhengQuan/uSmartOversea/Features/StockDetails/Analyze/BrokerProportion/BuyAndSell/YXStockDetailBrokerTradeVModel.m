//
//  YXStockDetailBrokerTradeVModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerTradeVModel.h"
#import "uSmartOversea-Swift.h"
#import "YXBrokerDetailModel.h"
#import "YXBrokerDetailViewModel.h"
#import <YXKit/YXKit.h>
#import "YXBrokerDetailVC.h"

@interface YXStockDetailBrokerTradeVModel ()
//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pClose;

// 刷新间隔
@property (nonatomic, assign) double refreshTime;

@property (nonatomic, assign) YXTimerFlag brokerTimerFlag;

@end

@implementation YXStockDetailBrokerTradeVModel

- (void)initialize {

    //market + symbol
    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
    self.name = self.params[@"name"];
    self.pClose = self.params[@"pClose"];
    self.brokerType = [self.params[@"timeIndex"] intValue];
    self.brokerDic = self.params[@"brokerDic"];

    self.level = (int)[self getLevel];

    self.secu = [[Secu alloc] initWithMarket:self.market symbol:self.symbol];

    if (self.level == QuoteLevelLevel2) {
        self.brokerTimerSubject = [RACSubject subject];
    }

    @weakify(self)
    self.brokerListDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self brokerListData];
    }];

    //跳转到经纪商持股详情
    self.pushToBrokerDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *input) {
        @strongify(self);
        NSMutableDictionary *param = @{@"symbol" : self.symbol,
                                       @"market" : self.market,
                                       @"name" : self.name}.mutableCopy;
        [param addEntriesFromDictionary:input];
        YXBrokerDetailViewModel *viewModel = [[YXBrokerDetailViewModel alloc] initWithServices:self.services params:param];
        [self.services pushViewModel:viewModel animated:YES];
        return [RACSignal empty];
    }];
}

- (QuoteLevel)getLevel {

    return [[YXUserManager shared] getLevelWith:self.market];
}

- (RACSignal *)brokerListData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeBrokerListRequestModel *requestModel = [[YXStockAnalyzeBrokerListRequestModel alloc] init];
        requestModel.symbol = self.symbol;
        requestModel.market = self.market;
        if (self.level != QuoteLevelLevel2) {
            //经纪商持股非level2，从1日开始
            requestModel.type = self.brokerType + 1;
        } else {
            requestModel.type = self.brokerType;
        }

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXStockAnalyzeBrokerListModel *model = [YXStockAnalyzeBrokerListModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:model];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
        }];
        return nil;
    }];
}

- (void)openTimer {
    @weakify(self)
    self.brokerTimerFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self)
        if (self.brokerTimerSubject) {
            [self.brokerTimerSubject sendNext:nil];
        }
    } timeInterval:60 repeatTimes:NSIntegerMax atOnce:NO];
}

- (void)closeTimer {
    [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.brokerTimerFlag];
}

@end
