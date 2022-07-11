//
//  YXLiveReplayListViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveReplayListViewModel.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXLiveReplayListViewModel()

@property (nonatomic, strong) YXRequest *request;

@end

@implementation YXLiveReplayListViewModel

- (void)initialize {
    [super initialize];
    self.page = 1;
    self.perPage = 10;
    self.shouldPullToRefresh = YES;
    self.shouldInfiniteScrolling = YES;
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        if (self.request) {
            [self.request stop];
        }
        YXAnchorDemandShowListRequestModel *requestModel = [[YXAnchorDemandShowListRequestModel alloc] init];
        requestModel.anchor_id = self.anchorId.integerValue;
        requestModel.limit = self.perPage;
        requestModel.offset = (self.page - 1) * self.perPage;
        self.request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseCodeSuccess) {
                NSArray *list = [NSArray yy_modelArrayWithClass:[YXLiveDetailModel class] json:[responseModel.data yx_arrayValueForKey:@"show_list"]];
                if (self.page == 1) {
                    // 下拉
                    [self.list removeAllObjects];
                    [self.list addObjectsFromArray:list];
                } else {
                    [self.list addObjectsFromArray:list];
                }
                if (list.count < self.perPage) {
                    self.loadNoMore = YES;
                } else {
                    self.loadNoMore = NO;
                }
                self.dataSource = @[self.list];
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

- (NSMutableArray<YXLiveDetailModel *> *)list {
    if (_list == nil) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

@end
