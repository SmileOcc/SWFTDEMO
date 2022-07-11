//
//  YXWarrantsStreetViewModel.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/11/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXWarrantsStreetViewModel.h"
#import "YXRequest.h"
#import "uSmartOversea-Swift.h"

@implementation YXWarrantsStreetViewModel

- (void)initialize {
    
    [super initialize];
    
    self.market = self.params[@"market"];
    self.code = self.params[@"symbol"];
    self.name = self.params[@"name"];
    self.roc = self.params[@"roc"];
    self.now = self.params[@"now"];
    self.change = self.params[@"change"];
    self.priceBase = self.params[@"priceBase"];
    self.type1 = self.params[@"type1"];
    self.shouldPullToRefresh = YES;
    self.dataSource = @[];
    
    @weakify(self)
    self.rangesCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        @strongify(self)
        return [self requestRanges];
    }];
    
    self.detailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        @strongify(self)
        return [self requestDetail];
    }];
}

- (RACSignal *)requestRanges{
   
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        
        YXRangesRequestModel *requestModel = [[YXRangesRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.code;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        @weakify(self)
        [request startWithBlockWithSuccess:^(__kindof YXRangesResponseModel *responseModel) {
            @strongify(self)
            
            self.range = responseModel.range;
            self.date = responseModel.date;
            
            self.rangeIndex = 0;
            self.dateIndex = 0;
            if (self.range.count > 1) {
                self.rangeIndex = 1;
            }
            
            [self.detailCommand execute:nil];
            
            [subscriber sendNext:responseModel];
            [subscriber sendCompleted];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            self.dataSource = @[];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            [self.requestShowErrorSignal sendNext:nil];
        }];
        
        return nil;
    }];
}

- (RACSignal *)requestDetail{
   
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        if (self.range.count > 0 && self.date.count > 0) {
            YXCbbcDetailRequestModel *requestModel = [[YXCbbcDetailRequestModel alloc] init];
            requestModel.market = self.market;
            requestModel.symbol = self.code;
            requestModel.date = ((NSNumber *)self.date[self.dateIndex]).longLongValue;
            requestModel.range = ((NSNumber *)self.range[self.rangeIndex]).doubleValue/pow(10.0, self.priceBase.doubleValue);
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXCbbcDetailResponseModel *responseModel) {
                
                if (responseModel.code == YXResponseCodeSuccess
                    && (responseModel.bearCell.count != 0 || responseModel.bullCell.count != 0)) {
                    int maxBearOutstand = [[responseModel.bearCell valueForKeyPath:@"@max.outstanding"] intValue];
                    int maxBullOutstand = [[responseModel.bullCell valueForKeyPath:@"@max.outstanding"] intValue];
                    self.maxOutstanding = MAX(maxBearOutstand, maxBullOutstand);
                    self.responseModel = responseModel;
                    self.dataSource = @[responseModel.bearCell, responseModel.bullCell];
                    [subscriber sendNext:responseModel];
                } else {
                    self.responseModel = nil;
                    self.dataSource = @[];
                    [subscriber sendNext:nil];
                                   
                }
                [subscriber sendCompleted];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                self.responseModel = nil;
                self.dataSource = @[];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                [self.requestShowErrorSignal sendNext:nil];
            }];
        } else {
            self.responseModel = nil;
            self.dataSource = @[];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

@end
