//
//  YXLiveAuthorViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveAuthorViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@implementation YXLiveAuthorViewModel

- (void)initialize {
    @weakify(self);
    self.getFollowStatusCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            YXLiveHasConcernRequestModel *requestModel = [[YXLiveHasConcernRequestModel alloc] init];
            requestModel.target_uid = self.liveModel.anchor_id;
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                if (responseModel.code == YXResponseCodeSuccess) {
                    self.isFollow = [responseModel.data yx_boolValueForKey:@"flag"];
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
    
    self.updateFollowStatusCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            YXLiveConcernRequestModel *requestModel = [[YXLiveConcernRequestModel alloc] init];
            requestModel.target_uid = self.liveModel.anchor_id;
            requestModel.focus_status = input.boolValue ? 1 : 2;
            requestModel.uid = @([YXUserHelper currentUUID]).stringValue;
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                if (responseModel.code == YXResponseCodeSuccess) {
                    [subscriber sendNext:@(YES)];
                    if (input.boolValue) {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_follow_tip"]];
                    } else {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_unfollow_tip"]];
                    }
                } else {
                    [subscriber sendNext:@(NO)];

                }
                
                [subscriber sendCompleted];
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
    }];
}

@end
