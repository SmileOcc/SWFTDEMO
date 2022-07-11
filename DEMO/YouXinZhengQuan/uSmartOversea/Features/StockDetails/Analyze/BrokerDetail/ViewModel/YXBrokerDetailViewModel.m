//
//  YXBrokerDetailViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/25.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerDetailViewModel.h"
#import "YXBrokerDetailModel.h"
#import "NSDictionary+Category.h"
#import "uSmartOversea-Swift.h"
#import "YXStockAnalyzeBrokerListModel.h"

@interface YXBrokerDetailViewModel()

@end

@implementation YXBrokerDetailViewModel

- (void)initialize {
    
    self.market = [self.params yx_stringValueForKey:@"market"];
    self.symbol = [self.params yx_stringValueForKey:@"symbol"];
    self.selecIndex = [self.params yx_intValueForKey:@"index"];
    self.brokerList = [self.params yx_arrayValueForKey:@"brokerInfo"];
    
    @weakify(self)
    self.loadCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadData];
    }];
    
    self.loadMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self loadMoreData];
    }];
}


//加载数据
- (RACSignal *)loadData{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXBrokerHoldDetailRequestModel *requestModel = [[YXBrokerHoldDetailRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        YXStockAnalyzeBrokerStockInfo *model = self.brokerList[self.selecIndex];
        requestModel.brokerCode = model.code;
        requestModel.direction = @"0";
        requestModel.size = @"60";
        requestModel.nextPageRef = nil;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
//        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                self.model = [YXBrokerDetailModel yy_modelWithJSON:responseModel.data];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            
//            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            
//            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
            
        }];
        
        return nil;
    }];
    
}

//加载数据
- (RACSignal *)loadMoreData{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXBrokerHoldDetailRequestModel *requestModel = [[YXBrokerHoldDetailRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.symbol = self.symbol;
        YXStockAnalyzeBrokerStockInfo *model = self.brokerList[self.selecIndex];
        requestModel.brokerCode = model.code;
        requestModel.direction = @"0";
        requestModel.size = @"60";
        requestModel.nextPageRef = self.model.nextPageRef;
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                YXBrokerDetailModel *model = [YXBrokerDetailModel yy_modelWithJSON:responseModel.data];
                NSMutableArray *arrM;
                if (self.model.list.count > 0) {
                    arrM = [NSMutableArray arrayWithArray:self.model.list];
                } else {
                    arrM = [NSMutableArray array];
                }
                if (model.list.count > 0) {
                    [arrM addObjectsFromArray:model.list];
                }
                model.list = arrM;
                self.model = model;
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                
            }else{
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
