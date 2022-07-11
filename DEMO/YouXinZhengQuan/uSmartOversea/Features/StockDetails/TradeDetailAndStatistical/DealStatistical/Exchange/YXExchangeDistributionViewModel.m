//
//  YXExchangeDistributionViewModel.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXExchangeDistributionViewModel.h"
#import "uSmartOversea-Swift.h"


@interface YXExchangeDistributionViewModel()
//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pClose;
@end

@implementation YXExchangeDistributionViewModel

- (void)initialize {
    //market + symbol
    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
        
    self.requestModel = [[YXSDDealStatistalModel alloc] init];
    self.requestModel.market = self.market;
    self.requestModel.symbol = self.symbol;
    self.requestModel.type = 2;
    self.requestModel.bidOrAskType = 0;
    self.requestModel.marketTimeType = 3;
    self.requestModel.tradeDay = @"0";
    self.loadExchangeDataSubject = [RACSubject subject];
    
    [self loadDataSetting];
}

- (void)loadDataSetting {
    @weakify(self);
    //MARK: statisticRequset
    self.loadExchangeDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *lastTickDic) {
        @strongify(self);
        
        YXDealStatisticalExchangeRequestModel *requestModel = [[YXDealStatisticalExchangeRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        requestModel.type = self.requestModel.type;
        requestModel.bidOrAskType = self.requestModel.bidOrAskType;
        requestModel.marketTimeType = self.requestModel.marketTimeType;
        requestModel.tradeDay = [self.requestModel.tradeDay longLongValue];
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel * _Nonnull responseModel) {
            if (responseModel.code == YXResponseCodeSuccess) {
                self.exchangeListModel = [YXExchangeStatisticalModel yy_modelWithDictionary:responseModel.data];
            }
            [self.loadExchangeDataSubject sendNext:nil];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [self.loadExchangeDataSubject sendNext:nil];
        }];
        
        return [RACSignal empty];
    }];
    

}

@end
