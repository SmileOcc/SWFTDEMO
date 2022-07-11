//
//  YXWatchLiveViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXWatchLiveViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@implementation YXWatchLiveViewModel

- (void)initialize {
    
    @weakify(self);
    self.getLiveDetail = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            YXLiveDetailRequestModel *requestModel = [[YXLiveDetailRequestModel alloc] init];
            requestModel.id = [self.params yx_stringValueForKey:@"liveId"];
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
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
    
    self.getwatchCountCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [self watchCountData];
    }];
    
    self.getUserRightCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            YXLiveGetUserRightRequestModel *requestModel = [[YXLiveGetUserRightRequestModel alloc] init];
            requestModel.id = ([self.params yx_stringValueForKey:@"liveId" defaultValue:@""]).intValue;
            
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                NSLog(@"");
                if (responseModel.code == YXResponseCodeSuccess) {
                    NSDictionary *userRightDic = [responseModel.data yx_dictionaryValueForKey:@"user_right"];
                    self.has_right = [userRightDic yx_boolValueForKey:@"has_right"];
                    self.require_right = [userRightDic yx_intValueForKey:@"require_right"];
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
    
    self.gotoLiveChatLandscapeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        YXLiveChatLandscapeViewModel * landscapeViewmodel = [[YXLiveChatLandscapeViewModel alloc] initWithServices:self.services params:nil];
        landscapeViewmodel.liveModel = self.liveModel;
        landscapeViewmodel.isPrePlaying = self.isPlaying;
        @weakify(self);
        landscapeViewmodel.playBlock = ^(BOOL isPlay) {
            @strongify(self);
            if (self.nextPlayBlock) {
                self.nextPlayBlock(isPlay);
            }
        };

        [self.services pushViewModel:landscapeViewmodel animated:NO];
        
        return [RACSignal empty];
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
                self.liveModel.status = model.status;
                self.liveModel.demand_id = model.demand_id;
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
