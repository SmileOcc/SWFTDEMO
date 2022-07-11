//
//  YXVSSearchViewModel.m
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXVSSearchViewModel.h"
#import "YXVSSearchViewController.h"
#import "NSDictionary+Category.h"
#import "uSmartOversea-Swift.h"

@implementation YXVSSearchViewModel

- (void)initialize {
    [super initialize];

    NSString *market = self.params[@"market"];
    NSString *symbol = self.params[@"symbol"];
    NSString *name = self.params[@"name"];
    NSNumber *from = self.params[@"isFromStockDetail"];
    int type1 = [self.params yx_intValueForKey:@"type1"];
    self.isFromStockDetail = from.boolValue;

    if (symbol && market) {
        YXVSSearchModel *vsModel = [[YXVSSearchModel alloc] init];
        YXSecu *secu = [[YXSecu alloc] init];
        secu.name = name;
        secu.market = market;
        secu.symbol = symbol;
        secu.type1 = (OBJECT_SECUSecuType1)type1;
        vsModel.secu = secu;
        YXKlineVSTool.shared.selectList = @[vsModel];
    }

    @weakify(self)
    self.searchRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *word) {
        @strongify(self)
        return [[self searchRequestSignalWithWord:word] takeUntil:self.rac_willDeallocSignal];
    }];

}

- (void)dealloc
{
    [self.searchRequest stop];
    self.searchRequest.yx_delegate = nil;
    self.searchRequest = nil;
}

- (RACSignal *)searchRequestSignalWithWord:(NSString *)word {
    @weakify(self, word)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self, word)
        YXSearchRequestModel *requestModel = [[YXSearchRequestModel alloc] init];
        requestModel.word = word;
        requestModel.mkts = [NSString stringWithFormat:@"%@,%@,%@",kYXMarketUS,kYXMarketHK,kYXMarketSG];
        //requestModel.type1 = @"1";

        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [subscriber sendNext:responseModel];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendError:request.error];
        }];
        self.searchRequest = request;
        return nil;
    }];

    return signal;
}




@end
