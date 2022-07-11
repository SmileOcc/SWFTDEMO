//
//  YXStockDetailBrokerRatioVModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerRatioVModel.h"
#import "YXBrokerDetailViewModel.h"
#import <YXKit/YXKit.h>
#import "uSmartOversea-Swift.h"
#import "YXBrokerDetailVC.h"

@interface YXStockDetailBrokerRatioVModel()

//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pClose;

// 刷新间隔
@property (nonatomic, assign) double refreshTime;

@end

@implementation YXStockDetailBrokerRatioVModel
- (void)initialize {

    //market + symbol
    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
    self.name = self.params[@"name"];
    self.pClose = self.params[@"pClose"];
    self.brokerDic = self.params[@"brokerDic"];

    self.secu = [[Secu alloc] initWithMarket:self.market symbol:self.symbol];

    @weakify(self)
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

    self.brokerShareHoldingDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self brokerShareHoldingData];
    }];
}

- (RACSignal *)brokerShareHoldingData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXStockAnalyzeBrokerListRequestModel *requestModel = [[YXStockAnalyzeBrokerListRequestModel alloc] init];
        requestModel.symbol = self.symbol;
        requestModel.market = self.market;
        requestModel.type = 5;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];

        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXStockAnalyzeBrokerListModel *model = [YXStockAnalyzeBrokerListModel yy_modelWithJSON:responseModel.data];
                self.maxValue = model.blist.firstObject.holdRatio;
                self.dataSource = model;
                [subscriber sendNext:model];
                NSMutableArray *tempArray = [NSMutableArray array];
                for (YXStockAnalyzeBrokerListDetailInfo *info in model.blist) {
                    YXStockAnalyzeBrokerStockInfo *nameInfo = [[YXStockAnalyzeBrokerStockInfo alloc] init];
                    if (info.brokerCode.length > 0) {
                        NSString *name = self.brokerDic[info.brokerCode];
                        nameInfo.name = name.length > 0 ? name : @"";
                    } else {
                        nameInfo.name = @"";
                    }
                    nameInfo.code = info.brokerCode;
                    [tempArray addObject:nameInfo];
                }
                self.brokerNamesArray = tempArray;
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

@end
