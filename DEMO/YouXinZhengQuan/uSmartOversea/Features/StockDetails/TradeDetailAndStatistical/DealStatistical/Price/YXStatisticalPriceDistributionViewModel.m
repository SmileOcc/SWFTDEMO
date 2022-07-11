//
//  YXStatisticalPriceDistributionViewModel.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXStatisticalPriceDistributionViewModel.h"
#import "uSmartOversea-Swift.h"

@interface YXStatisticalPriceDistributionViewModel()
//symbol + market + name
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pClose;
@end

@implementation YXStatisticalPriceDistributionViewModel

- (void)initialize {
    //market + symbol
    self.symbol = self.params[@"symbol"];
    self.market = self.params[@"market"];
    self.name = self.params[@"name"];
    self.pClose = self.params[@"pClose"];
    
    self.requestModel = [[YXSDDealStatistalModel alloc] init];
    self.requestModel.market = self.market;
    self.requestModel.symbol = self.symbol;
    self.requestModel.type = 0;
    self.requestModel.bidOrAskType = 0;
    self.requestModel.marketTimeType = 3;
    self.requestModel.sortType = 0;
    self.requestModel.sortMode = 0;
    
    self.requestModel.tradeDay = @"0";
    self.loadStatisticSubject = [RACSubject subject];
    
    [self loadDataSetting];
}

- (void)loadDataSetting {
    @weakify(self);
    //MARK: statisticRequset
    self.loadStatisticDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *lastTickDic) {
        @strongify(self)
        
        [self.statisticRequset cancel];
        
        /* http://szshowdoc.youxin.com/web/#/23?page_id=662 -->
        quotes-analysis(行情分析服务) --> v1 --> 成交统计接口
        quotes-analysis-app/api/v1/statistic
         type: 类型：0：最近20条，1：最近50条，2：全部 */
        Secu *secu = [[Secu alloc] initWithMarket:self.market symbol:self.symbol];
        self.statisticRequset = [[YXQuoteManager sharedInstance] subNewStatisticQuoteWithSecu:secu type:self.requestModel.type bidOrAskType:self.requestModel.bidOrAskType marketTimeType:self.requestModel.marketTimeType tradeDay:self.requestModel.tradeDay sortType:self.requestModel.sortType sortMode:self.requestModel.sortMode handler:^(YXAnalysisStatisticData * _Nonnull sData, enum Scheme scheme) {
            //获取最大成交量
            for (YXAnalysisStatisticPrice *model in sData.priceData) {
                if (self.maxVolume < model.volume.value ) {
                    self.maxVolume = model.volume.value;
                }
            }
            
            [self.loadStatisticSubject sendNext:sData];
        } failed:^{
            @strongify(self)
            [self.loadStatisticSubject sendNext:nil];
        }];
        
        return [RACSignal empty];
    }];
    

}
@end
