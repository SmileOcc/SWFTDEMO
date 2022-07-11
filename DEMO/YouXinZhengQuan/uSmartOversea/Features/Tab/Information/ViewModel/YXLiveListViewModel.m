//
//  YXLiveListViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveListViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXLiveModel.h"
#import "NSDictionary+Category.h"
#import "YXLiveDetailModel.h"

@interface YXLiveListViewModel ()

@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, strong) YXRequest *liveRequest;

@property (nonatomic, strong) YXRequest *replayRequest;

@end

@implementation YXLiveListViewModel

- (void)initialize {
    
    self.offset = 0;
    self.replayList = [NSMutableArray array];
    @weakify(self);
    self.refreshLiveCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self refreshLiveListRequest];
    }];
    
    self.refreshReplayCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [self refreshReplayList];
    }];
    
    self.getPauseLiveListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *input) {
        @strongify(self)
        return [self getPauseLiveListRequest];
    }];
    
    self.refreshRecommendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *_Nullable input) {
        @strongify(self)
        return [self refreshHomeData];
    }];
    
    self.refreshCourseCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *_Nullable input) {
        @strongify(self)
        return [self refreshAllVideoDataWithIsDown:input.boolValue];
    }];
    
}


- (RACSignal *)refreshLiveListRequest {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [self.liveRequest stop];
        self.liveRequest = nil;
        YXLiveHotListRequesetModel *requestModel = [[YXLiveHotListRequesetModel alloc] init];
        requestModel.limit = 100;
        self.liveRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.liveRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *arr = [responseModel.data yx_arrayValueForKey:@"show_list"];
                self.liveList = [NSArray yy_modelArrayWithClass:[YXLiveModel class] json:arr];
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

- (RACSignal *)refreshReplayList {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        [self.replayRequest stop];
        self.replayRequest = nil;
        YXLiveReplayListRequesetModel *requestModel = [[YXLiveReplayListRequesetModel alloc] init];
        requestModel.offset = 0;
        self.replayRequest = [[YXRequest alloc] initWithRequestModel:requestModel];
        [self.replayRequest startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                        
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSMutableArray *arrM = [NSMutableArray array];
                NSArray *arr = [responseModel.data yx_arrayValueForKey:@"category_list"];
                for (NSDictionary *dic in arr) {
                    NSArray *showList = [dic yx_arrayValueForKey:@"show_list"];
                    if (showList.count > 0) {
                        YXLiveCategoryModel *model = [YXLiveCategoryModel yy_modelWithJSON:dic];
                        
                        if (model) {
                            [arrM addObject:model];
                        }
                    }
                }
                self.replayList = arrM;
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

//YXPauseLiveListRequestModel
- (RACSignal *)getPauseLiveListRequest {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXPauseLiveListRequestModel *requestModel = [[YXPauseLiveListRequestModel alloc] init];
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            NSArray *pauseList = nil;
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *arr = [responseModel.data yx_arrayValueForKey:@"show_list"];
                pauseList = [NSArray yy_modelArrayWithClass:[YXLiveDetailModel class] json:arr];
            }
            
            [subscriber sendNext:pauseList];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

- (RACSignal *)refreshHomeData {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        YXNewCourseRecommedListRequestModel *requestModel = [[YXNewCourseRecommedListRequestModel alloc] init];
        requestModel.limit = @"3";
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            NSArray *recommendList = [responseModel.data yx_arrayValueForKey:@"List"];
            if (recommendList.count > 0) {
                YXNewCourseHomeManagerModel *model = [[YXNewCourseHomeManagerModel alloc] init];
                model.isRecommend = YES;
                YXNewCourseTitleModel *titleModel = [[YXNewCourseTitleModel alloc] init];
                titleModel.show = [YXLanguageUtility kLangWithKey:@"news_hot_recommend"];
                YXNewCourseTopicDetailModel *topicDetailModel = [[YXNewCourseTopicDetailModel alloc] init];
                topicDetailModel.title = titleModel;
                model.special_topic_video_info = topicDetailModel;
                NSArray *tempList = [NSArray yy_modelArrayWithClass:[YXNewCourseVideoInfoSubModel class] json:recommendList];
                NSMutableArray *tempArrM = [NSMutableArray array];
                for (YXNewCourseVideoInfoSubModel *model in tempList) {
                    YXNewCourseVideoInfoModel *infoModel = [[YXNewCourseVideoInfoModel alloc] init];
                    infoModel.video_info = model;
                    infoModel.type = 1;
                    [tempArrM addObject:infoModel];
                }
                model.special_topic_video_json_info = tempArrM;
                self.recommendModel = model;
            } else {
                self.recommendModel = [[YXNewCourseHomeManagerModel alloc] init];
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

// 所有课程
- (RACSignal *)refreshAllVideoDataWithIsDown:(BOOL)isDown {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        if (isDown) {
            self.offset = 0;
        } else {
            self.offset += 5;
        }
        YXTopicCategoryListRequestModel *requestModel = [[YXTopicCategoryListRequestModel alloc] init];
        requestModel.page = @{
            @"offset": @(self.offset),
            @"limit": @(5)
        };
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *list = [responseModel.data yx_arrayValueForKey:@"list"];
                BOOL canLoadMore = YES;
                
                if (list.count > 0) {
                    
                    if (list.count < 5) {
                        canLoadMore = NO;
                    }
                    NSMutableArray *ids = [NSMutableArray array];
                    for (NSDictionary *dic in list) {
                        NSDictionary *subDic = @{@"id": [dic yx_stringValueForKey:@"special_topic_id" defaultValue:@""]};
                        [ids addObject:subDic];
                    }
                    YXTopicCategoryListDetailRequestModel *requestModel = [[YXTopicCategoryListDetailRequestModel alloc] init];
                    requestModel.special_topic_ids = ids;
                    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
                    [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
                        NSArray *list = [responseModel.data yx_arrayValueForKey:@"list"];
                        
                        NSArray *modelList = [NSArray yy_modelArrayWithClass:[YXNewCourseHomeManagerModel class] json:list];
                        if (isDown) {
                            [self.courseList removeAllObjects];
                        }
                        if (modelList.count > 0) {
                            [self.courseList addObjectsFromArray:modelList];
                        }
                        [subscriber sendNext: @(canLoadMore)];
                        [subscriber sendCompleted];
                    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                        NSLog(@"");
                        self.offset --;
                        [subscriber sendNext:@(canLoadMore)];
                        [subscriber sendCompleted];
                    }];
                    
                } else {
                    [subscriber sendNext:@(NO)];
                    [subscriber sendCompleted];
                }
            } else {
                [subscriber sendNext:@(YES)];
                [subscriber sendCompleted];
            }

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:@(YES)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (NSMutableArray<YXNewCourseHomeManagerModel *> *)courseList {
    if (_courseList == nil) {
        _courseList = [[NSMutableArray alloc] init];
    }
    return _courseList;
}



@end
