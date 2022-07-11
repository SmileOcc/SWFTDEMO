//
//  YXStockDetailBrokerHoldingVModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/2/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailBrokerHoldingVModel.h"
#import "NSDictionary+Category.h"
#import "uSmartOversea-Swift.h"
#import <YXKit/YXKit.h>

@interface YXStockDetailBrokerHoldingVModel()


@end

@implementation YXStockDetailBrokerHoldingVModel

- (void)initialize {

    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
    self.name = self.params[@"name"];
    self.pClose = self.params[@"pClose"];

    self.selectIndex = [self.params yx_intValueForKey:@"tabIndex" defaultValue:0];

    self.level = (int)[self getLevel];

    self.ratioVModel = [[YXStockDetailBrokerRatioVModel alloc] initWithServices:self.services params:self.params];
    self.tradeVModel = [[YXStockDetailBrokerTradeVModel alloc] initWithServices:self.services params:self.params];

    self.selectIndex = [self.params yx_intValueForKey:@"tabIndex" defaultValue:0];

    self.secu = [[Secu alloc] initWithMarket:self.market symbol:self.symbol];

    self.loadBasicQuotaDataSubject = [RACSubject subject];

    @weakify(self);
    //加载quota盘面数据
    self.loadBasicQuotaDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *idsArr) {
        @strongify(self);
        [self.quoteRequset cancel];
        self.quoteRequset = [[YXQuoteManager sharedInstance] subRtFullQuoteWithSecu:self.secu level:[self getLevel] handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
            @strongify(self);

            YXV2Quote *quoteModel = list.firstObject;

            self.quotaModel = quoteModel;
            [self.loadBasicQuotaDataSubject sendNext:nil];
        } failed:^{
            [self.loadBasicQuotaDataSubject sendNext:nil];
        }];

        return [RACSignal empty];
    }];

}


- (QuoteLevel)getLevel {
    if (self.quotaModel && self.quotaModel.greyFlag.value > 0) {
        return QuoteLevelLevel2;
    }

    return [[YXUserManager shared] getLevelWith:self.market];
}


- (void)cancelRequest {
    [self.quoteRequset cancel];
    self.quoteRequset = nil;
}

@end
