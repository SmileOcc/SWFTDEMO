//
//  YXStareDetailViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/17.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareDetailViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXStareDetailViewModel ()

@property (nonatomic, assign) long seqNum;

@property (nonatomic, strong) NSArray *optionList;

@end

@implementation YXStareDetailViewModel

- (void)initialize {
    
    self.seqNum = 0;
    @weakify(self);
    
    self.type = [self.params yx_intValueForKey:@"type"];
    
    self.loadDownRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadDataWithIsDown: YES];
    }];
    
    self.loadUpRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadDataWithIsDown: NO];
    }];
    
    self.loadPollingRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadPollingData];
    }];
    
    self.loadPushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString *marketSymbol) {
        @strongify(self);
        return [self loadPushSettingData];
    }];
    self.updatePushSettingListRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *para) {
        @strongify(self);
        return [self updatePushSettingWithPara: para];
    }];
    YXSecuGroup *group = [[YXSecuGroupManager shareInstance] allSecuGroup];
    
    QuoteLevel level = [[YXUserManager shared] getLevelWith:kYXMarketHK];
    NSMutableArray *arrM = [NSMutableArray array];
    for (YXSecuID *sec in group.list) {
        if (level == QuoteLevelBmp && [sec.market isEqualToString:kYXMarketHK]) {
        } else {
            [arrM addObject:sec.ID];
        }
    }
    self.optionList = arrM;
}


//加载数据
- (RACSignal *)loadDataWithIsDown:(BOOL)isDown {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        if (isDown) {
            self.seqNum = 0;
        }
        
        YXStareRequestModel *requestModel = [[YXStareRequestModel alloc] init];
        requestModel.type = self.type;
        requestModel.leafIndentifer = [self getRequestBkCode];
        requestModel.subType = [self getRequestSubTab];
        requestModel.count = 20;
        requestModel.seqNum = self.seqNum;
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        requestModel.unixTime = time * 1000;
        
        YXStareType type = [YXStareUtility getStareTypeWithType:self.type andSubType:self.subTab];
        if (type == YXStareTypeOptional) {
            // 自选
            requestModel.stockList = self.optionList;
        }
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (isDown) {
                 [self.list removeAllObjects];
            }
            if (responseModel.code == YXResponseStatusCodeSuccess){
                NSDictionary *dataDic = responseModel.data;
                NSArray *list = [dataDic yx_arrayValueForKey:@"list"];
                NSArray *modelList = [NSArray yy_modelArrayWithClass:[YXStareSignalModel class] json:list];
                if (modelList.count > 0) {
                    YXStareSignalModel *model = modelList.lastObject;
                    self.seqNum = model.seqNum;
                    if (isDown) {
                        [self.list removeAllObjects];
                        [self.list addObjectsFromArray:modelList];
                    } else {
                        [self.list addObjectsFromArray:modelList];
                    }
                }

                [subscriber sendNext:modelList];
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
- (RACSignal *)loadPollingData {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
        YXStareRequestModel *requestModel = [[YXStareRequestModel alloc] init];
        requestModel.type = self.type;
        requestModel.leafIndentifer = [self getRequestBkCode];
        requestModel.subType = [self getRequestSubTab];
        requestModel.count = 20;
        requestModel.seqNum = 0;
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        requestModel.unixTime = time * 1000;
        
        YXStareType type = [YXStareUtility getStareTypeWithType:self.type andSubType:self.subTab];
        if (type == YXStareTypeOptional) {
            // 自选
            requestModel.stockList = self.optionList;
        }
        
        YXRequest *dataRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        [dataRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {

            if (responseModel.code == YXResponseStatusCodeSuccess){
                NSDictionary *dataDic = responseModel.data;
                NSArray *list = [dataDic yx_arrayValueForKey:@"list"];
                NSArray *modelList = [NSArray yy_modelArrayWithClass:[YXStareSignalModel class] json:list];

                [subscriber sendNext:modelList];
                [subscriber sendCompleted];
                
            }else{
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            
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
//                NSDictionary *dataDic = responseModel.data;
                
                [subscriber sendNext:@(YES)];
                [subscriber sendCompleted];
                
            } else if (responseModel.code == 808018) {
                [QMUITips showInfo:[YXLanguageUtility kLangWithKey:@"monitor_push_industry_limit"]];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
            
//            808018
            
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
            
        }];
        
        return nil;
    }];
    
}



- (NSMutableArray<YXStareSignalModel *> *)list {
    if (_list == nil) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}


- (NSInteger)getRequestSubTab {
    NSInteger tab = 0;
    YXStareType type = [YXStareUtility getStareTypeWithType:self.type andSubType:self.subTab];
    switch (type) {
        case YXStareTypeAll:
            tab = 0;
            break;
        case YXStareTypeNewStock:
            tab = 2;
            break;
        case YXStareTypeIndustry:
            tab = 1;
            break;
        case YXStareTypeIndex:
            tab = 3;
            break;
        case YXStareTypeOptional:
            tab = 5;
            break;
        case YXStareTypeHold:
            tab = 4;
            break;
        default:
            break;
    }
    
    return tab;
}

- (NSString *)getRequestBkCode {
    
    NSString *code = @"";
    
    YXStareType type = [YXStareUtility getStareTypeWithType:self.type andSubType:self.subTab];
    if (type == YXStareTypeIndustry) {
        code = self.bkCode;
    } else if (type == YXStareTypeIndex) {
        code = self.indexCode;
    } else {
        if (self.type == 0) {
            code = @"hk";
        } else  if (self.type == 1) {
            code = @"us";
        } else  if (self.type == 2) {
            code = @"hs";
        } else {
            // 自选持仓
            code = @"";
        }
    }

    return code;
}

@end
