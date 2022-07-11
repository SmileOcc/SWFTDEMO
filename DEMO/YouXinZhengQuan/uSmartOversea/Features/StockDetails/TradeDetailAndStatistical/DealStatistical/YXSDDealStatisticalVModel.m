//
//  YXSDDealStatisticalVModel.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDDealStatisticalVModel.h"

#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXSDDealStatisticalVModel()

//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pClose;

// 刷新间隔
@property (nonatomic, assign) double refreshTime;

@end

@implementation YXSDDealStatisticalVModel

- (void)initialize {
    
    //market + symbol
    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
    self.name = self.params[@"name"];
    self.pClose = self.params[@"pClose"];
            
    self.secu = [[Secu alloc] initWithMarket:self.market symbol:self.symbol];
    
    self.timeShareType = [self.params yx_intValueForKey:@"timeShareType"];
    self.loadBasicQuotaDataSubject = [RACSubject subject];
    
    [self loadDataSetting];
}


- (void)loadDataSetting {
    
    
    double limitTimer = [YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeStockRealquoteRefreshFreq] / 1000.0;
    @weakify(self);
    //加载quota盘面数据
    self.loadBasicQuotaDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *idsArr) {
        @strongify(self);
        [self.quoteRequset cancel];

        self.quoteRequset = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:@[self.secu] level:[self getLevel] handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
            @strongify(self);
            
            if (scheme == SchemeTcp) {
                // 推送的数据过来, 限制3毫秒内不能刷新
                double time = CFAbsoluteTimeGetCurrent();
                if ((time - self.refreshTime) < limitTimer) {
                    return;
                }
                self.refreshTime = time;
            }

            YXV2Quote *quoteModel = list.firstObject;
            
            
            // 更新股票类型
            if (self.quotaModel == nil) {
                self.quotaModel = quoteModel;
            } else {
                self.quotaModel = quoteModel;
            }
            [self.loadBasicQuotaDataSubject sendNext:nil];
        } failed:^{
            [self.loadBasicQuotaDataSubject sendNext:nil];
        }];
        
        return [RACSignal empty];
    }];

    self.loadTradeDateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *lastTickDic) {
        @strongify(self)
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            YXDealStatisticalDateRequestModel *requesetModel = [[YXDealStatisticalDateRequestModel alloc] init];
            requesetModel.market = self.market;
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requesetModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                NSArray *list = [responseModel.data yx_arrayValueForKey:@"list"];
                if (list.count > 0) {
                    [subscriber sendNext:list];
                }
                [subscriber sendCompleted];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
    }];
}

- (QuoteLevel)getLevel {
    if (self.quotaModel && self.quotaModel.greyFlag.value > 0) {
        return QuoteLevelLevel2;
    }

    return [[YXUserManager shared] getLevelWith:self.market];
}


@end
