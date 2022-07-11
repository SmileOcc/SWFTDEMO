//
//  YXOrgAccountViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXOrgAccountListViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXOrgAccountModel.h"
#import "NSDictionary+Category.h"

@interface YXOrgAccountListViewModel()



@end

@implementation YXOrgAccountListViewModel


- (void)initialize {
    [super initialize];
    
    self.statusChangeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(YXOrgAccountModel *input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
            YXOrgSwitchUserTraderInfoRequestModel *requestModel = [[YXOrgSwitchUserTraderInfoRequestModel alloc] init];
            requestModel.traderStatus = @(!input.traderStatus).stringValue;
            requestModel.traderId = input.id;
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
               [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
                if (responseModel.code == YXResponseCodeSuccess) {
                    [subscriber sendNext:@(YES)];
                } else {
                    NSError *error = [NSError errorWithDomain:YXViewModel.defaultErrorDomain code:responseModel.code userInfo:@{NSLocalizedDescriptionKey: responseModel.msg}];
                    [self.requestShowErrorSignal sendNext:error];
                    [subscriber sendNext:@(NO)];
                }                
                [subscriber sendCompleted];
                
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
                [self.requestShowErrorSignal sendNext:nil];
                [subscriber sendNext:@(NO)];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
}

- (RACSignal *)requestWithOffset:(NSInteger)offset{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXOrgAccountListRequestModel *requestModel = [[YXOrgAccountListRequestModel alloc] init];
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseCodeSuccess) {
                NSArray *list = [responseModel.data yx_arrayValueForKey:@"orgTraderInfoVOList"];
                NSArray *modelList = [NSArray yy_modelArrayWithClass:[YXOrgAccountModel class] json:list];

                if (modelList) {
                    NSMutableArray *arrM = [NSMutableArray array];
                    for (YXOrgAccountModel *model in modelList) {
                        if (model) {
                            [arrM addObject:@[model]];
                        }
                    }
                    self.dataSource = arrM;
                }
            }
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}


@end
