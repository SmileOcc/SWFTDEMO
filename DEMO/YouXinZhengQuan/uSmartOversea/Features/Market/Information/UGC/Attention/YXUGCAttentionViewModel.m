//
//  YXUGCAttentionViewModel.m
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXUGCAttentionViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXBannerActivityModel.h"

@interface YXUGCAttentionViewModel()

@end

@implementation YXUGCAttentionViewModel

-(void)initialize {
    
 
}

-(YXUGCNoAttensionUserModel *)noAttensionModel {
    if (!_noAttensionModel) {
        _noAttensionModel = [[YXUGCNoAttensionUserModel alloc] init];
        _noAttensionModel.title = @"还没有关注的人呢";
        
    }
    return _noAttensionModel;
}

@end


@interface YXNewHotMainViewModel ()
@property (nonatomic, copy) NSString *commendUser_token;
@end

@implementation YXNewHotMainViewModel

- (void)initialize {
    @weakify(self)
    
    self.loadMoreHotFeedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(RACTuple *input) {
        @strongify(self);
        return [self reqHotFeedDataSignal];
    }];
    
    self.zipDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self);
        return [RACSignal zip:@[[self requesteBannerSignal],[self reqHotFeedDataSignal],[self requestecommendUserListSignal]]];
    }];
}

-(RACSignal* )reqHotFeedDataSignal {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        YXNewHotReqModel * resModel = [[YXNewHotReqModel alloc] init];
        if (self.query_token.length >0 ) {
            resModel.query_token = self.query_token;
        }
        
        YXRequest* resquest = [[YXRequest alloc] initWithRequestModel:resModel];
        [resquest startWithBlockWithSuccess:^(__kindof YXUGCFeedAttentionPostListModel * _Nonnull responseModel) {
            self.query_token = responseModel.query_token;
            self.attentionModel = responseModel;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

-(RACSignal*)requestecommendUserListSignal {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXQueryRecommendUserListReqHK *recommendUserListReqModel = [[YXQueryRecommendUserListReqHK alloc] init];
        recommendUserListReqModel.limit = 12;
        if (self.commendUser_token.length > 0 ) {
            recommendUserListReqModel.query_token = self.commendUser_token;
        }
        YXRequest* resquest = [[YXRequest alloc] initWithRequestModel:recommendUserListReqModel];
        [resquest startWithBlockWithSuccess:^(__kindof YXUGCRecommandUserListModel * _Nonnull responseModel) {
            if( responseModel.code == YXResponseStatusCodeSuccess ) {
                self.recommendUserListResModel = responseModel;
                self.commendUser_token = responseModel.query_token;
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.recommendUserListResModel.list];
                [array enumerateObjectsUsingBlock:^(YXUGCRecommandUserModel*  obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.follow_status == 1 || obj.follow_status == 2) {
                        [array removeObject:obj];
                    }
                }];
                self.recommendUserListResModel.list = array;
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

-(RACSignal*)requesteBannerSignal {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXBannerAdvertisementRequestModel* requestModel = [[YXBannerAdvertisementRequestModel alloc] init];
        requestModel.show_page = 33;
        YXRequest* request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel * _Nonnull responseModel) {
            if( responseModel.code == YXResponseStatusCodeSuccess ) {
                self.recommendBannerResModel = [YXBannerActivityModel yy_modelWithJSON:responseModel.data];
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
