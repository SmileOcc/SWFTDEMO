//
//  YXStareSettingViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareSettingViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXStareSignalModel.h"
#import "NSDictionary+Category.h"

@interface YXStareSettingViewModel ()


@end

@implementation YXStareSettingViewModel

- (void)initialize {
    @weakify(self);
    self.loadSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadSettingData];
    }];
    
    self.updateSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self updateSignalSetting];
    }];
    
    self.loadPushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadPushSettingData];
    }];
    self.updatePushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self updatePushSettingWithPara: para];
    }];
}

//加载数据
- (RACSignal *)loadSettingData{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXStareSettinglistRequestModel *requestModel = [[YXStareSettinglistRequestModel alloc] init];
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                NSDictionary *dataDic = responseModel.data;
                NSDictionary *listDic = [dataDic yx_dictionaryValueForKey:@"list"];
                NSArray *groupList = [listDic yx_arrayValueForKey:@"group"];
                NSDictionary *signalDic = groupList.firstObject;
                NSArray *modelList = [signalDic yx_arrayValueForKey:@"signal"];

                NSArray *listArray = [NSArray yy_modelArrayWithClass:[YXStareSignalSettingModel class] json:modelList];
                NSMutableArray *signalMutArr = [NSMutableArray array];
                for (YXStareSignalSettingModel *model in listArray) {
                    if (model.SignalId == 10 || model.SignalId == 13) {
                        //过滤开盘价提醒和收盘价提醒
                    } else {
                        [signalMutArr addObject:model];
                    }
                }
                self.signalList = signalMutArr;

                [subscriber sendNext:self.signalList];
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

// 更新信号
- (RACSignal *)updateSignalSetting {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXStareUpdateSettingListtRequestModel *requestModel = [[YXStareUpdateSettingListtRequestModel alloc] init];
        
        NSMutableArray *arr = [NSMutableArray array];
        for (YXStareSignalSettingModel *model in self.signalList) {
            if (model.Defult == 1) {
                [arr addObject:@(model.SignalId)];
            }
        }
        NSDictionary *dic = @{
            @"groupId": @(0),
            @"signalId": arr,
        };
        requestModel.list = @[dic];
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                //NSDictionary *dataDic = responseModel.data;

                
                [subscriber sendNext:@(YES)];
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


//加载数据
- (RACSignal *)loadPushSettingData{
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXStarePsuhSettinglistRequestModel *requestModel = [[YXStarePsuhSettinglistRequestModel alloc] init];
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                NSDictionary *dataDic = responseModel.data;
                NSArray *modelList = [dataDic yx_arrayValueForKey:@"list"];
                self.pushList = [NSArray yy_modelArrayWithClass:[YXStarePushSettingModel class] json:modelList];
                
                [subscriber sendNext:self.pushList];
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

- (RACSignal *)updatePushSettingWithPara:(NSDictionary *)para {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXStareUpdatePsuhSettinglistRequestModel *requestModel = [[YXStareUpdatePsuhSettinglistRequestModel alloc] init];
        
        NSInteger type = [para yx_intValueForKey:@"type"];
        NSArray *list = [para yx_arrayValueForKey:@"list"];
        
        requestModel.type = type;
        requestModel.list = list?:@[];
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess){
                //NSDictionary *dataDic = responseModel.data;

                
                [subscriber sendNext:@(YES)];
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
