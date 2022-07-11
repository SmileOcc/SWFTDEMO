//
//  YXTodayGreyStockViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTodayGreyStockViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXTodayGreyStockViewModel ()

@property (nonatomic, strong) YXRequest *request;

@property (nonatomic, strong) YXQuoteRequest *quoteRequest;

@property (nonatomic, strong) NSArray *listArr;

@end



@implementation YXTodayGreyStockViewModel

- (void)initialize{
    [super initialize];
    @weakify(self)
    [self.didDisappearSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.quoteRequest cancel];
    }];
    
    self.loadGreyDataSubject = [[RACSubject alloc] init];
    
}

- (RACSignal *)requestWithOffset:(NSInteger)page {

    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        YXGreyStockListRequestModel *requestModel = [[YXGreyStockListRequestModel alloc] init];
        
        if (self.request) {
            [self.request stop];
            self.request = nil;
        }
        self.request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *list = [responseModel.data yx_arrayValueForKey:@"greyIpoInfoDTOS"];
                if (list.count > 0) {
                    NSMutableArray *arrM = [NSMutableArray array];
                    for (NSDictionary *dic in list) {
                        Secu *secu = [[Secu alloc] initWithMarket:@"hk" symbol:[dic yx_stringValueForKey:@"stockCode"]];
                        [arrM addObject:secu];
                    }
                    @weakify(self);
                    [self.quoteRequest cancel];
                    self.quoteRequest = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:arrM level:QuoteLevelLevel2 handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
                        @strongify(self);

                        if (list.count > 0) {
                            if (scheme == SchemeHttp) {
                                self.listArr = list;
                                self.dataSource = @[list];
                            } else if (scheme == SchemeTcp) {
                                for (YXV2Quote *quote in self.listArr) {
                                    for (YXV2Quote *tcpQuote in list) {
                                        if ([quote.symbol isEqualToString:tcpQuote.symbol]) {
                                            quote.latestPrice = tcpQuote.latestPrice;
                                            quote.netchng = tcpQuote.netchng;
                                            quote.pctchng = tcpQuote.pctchng;
                                        }
                                    }
                                }
                                self.dataSource = @[self.listArr];
                            }
                            [subscriber sendNext:responseModel.data];
                        }
                    } failed:^{
                            
                       }];
                }
                [self.loadGreyDataSubject sendNext:responseModel.data];
                [subscriber sendNext:responseModel.data];
//                [subscriber sendCompleted];
                
            } else {
                [subscriber sendCompleted];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
            [subscriber sendError:request.error];
        }];

        return nil;
    }];

}

- (NSArray *)listArr {
    if (_listArr == nil) {
        _listArr = [[NSArray alloc] init];
    }
    return _listArr;
}


@end
