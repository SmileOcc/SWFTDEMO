//
//  YXPreLiveViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXPreLiveViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@implementation YXPreLiveViewModel

- (void)initialize {
    [super initialize];
    
    NSString *liveId = self.params[@"liveId"];
    @weakify(self);
    self.getLiveDetail = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            YXLiveDetailRequestModel *requestModel = [[YXLiveDetailRequestModel alloc] init];
            requestModel.id = liveId;
            
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                NSLog(@"");
                if (responseModel.code == YXResponseCodeSuccess) {
                    self.liveModel = [YXLiveDetailModel yy_modelWithJSON: [responseModel.data yx_dictionaryValueForKey:@"show"]];
                }
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
    }];
    
    
    self.getLiveCountCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self);
        return [self likeCountData];
    }];
    
    self.getwatchCountCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [self watchCountData];
    }];
    
    self.closeLiveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [self closeLiveData];
    }];
}



- (RACSignal *)likeCountData {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        YXLiveLikeCountRequestModel *requestModel = [[YXLiveLikeCountRequestModel alloc] init];
        NSArray *list = @[@{@"bizId" : self.liveModel.post_id?:@"", @"bizPreFix": @"live::chat"}];
        requestModel.list = list;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {

            NSDictionary *dic = [responseModel.data yx_dictionaryValueForKey:@"data"];
            NSDictionary *valueDic = dic.allValues.firstObject;
            NSInteger count = [valueDic yx_intValueForKey:@"count"];
            self.liveModel.likeCount = count;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}


- (RACSignal *)watchCountData {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        YXLiveBriefDetailRequestModel *requestModel = [[YXLiveBriefDetailRequestModel alloc] init];
        requestModel.id = self.liveModel.id?:@"";
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            NSLog(@"");
            if (responseModel.code == YXResponseCodeSuccess) {
                YXLiveDetailModel *model = [YXLiveDetailModel yy_modelWithJSON: [responseModel.data yx_dictionaryValueForKey:@"show"]];
                self.liveModel.watch_user_count = model.watch_user_count;
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


- (RACSignal *)closeLiveData {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        YXLiveUpdateStatusRequestModel *requestModel = [[YXLiveUpdateStatusRequestModel alloc] init];
        requestModel.id = self.liveModel.id.intValue;
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
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
