//
//  YXLiveChatLandscapeViewModel.m
//  uSmartOversea
//
//  Created by suntao on 2021/2/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXLiveChatLandscapeViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"
#import "YXLiveDetailModel.h"

@implementation YXLiveChatLandscapeViewModel

-(void)initialize
{
    @weakify(self)
    self.getwatchCountCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [self watchCountData];
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

-(void)isPlayingFlag
{
    if (self.playBlock) {
        self.playBlock(self.isPlaying);
    }
}


@end
