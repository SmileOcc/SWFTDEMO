//
//  YXLiveAuthorViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
@class YXLiveDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveAuthorViewModel : YXViewModel

@property (nonatomic, strong) YXLiveDetailModel *liveModel;

@property (nonatomic, strong) RACCommand *getFollowStatusCommand;
@property (nonatomic, strong) RACCommand *updateFollowStatusCommand;

@property (nonatomic, assign) BOOL isFollow;

@end

NS_ASSUME_NONNULL_END
