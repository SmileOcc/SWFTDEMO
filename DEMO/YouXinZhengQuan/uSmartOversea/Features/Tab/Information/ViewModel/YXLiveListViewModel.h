//
//  YXLiveListViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
@class YXLiveCategoryModel;
@class YXNewCourseHomeManagerModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveListViewModel : YXViewModel

@property (nonatomic, strong) RACCommand *refreshLiveCommand;
@property (nonatomic, strong) RACCommand *refreshReplayCommand; 
@property (nonatomic, strong) NSArray *liveList;
@property (nonatomic, strong) NSArray <YXLiveCategoryModel *> *replayList;

@property (nonatomic, strong) RACCommand *getPauseLiveListCommand;

@property (nonatomic, strong) RACCommand *refreshRecommendCommand; //刷新

@property (nonatomic, strong) RACCommand *refreshCourseCommand; //刷新

@property (nonatomic, strong) NSMutableArray <YXNewCourseHomeManagerModel *>*courseList;

@property (nonatomic, strong) YXNewCourseHomeManagerModel *recommendModel;

@end

NS_ASSUME_NONNULL_END
