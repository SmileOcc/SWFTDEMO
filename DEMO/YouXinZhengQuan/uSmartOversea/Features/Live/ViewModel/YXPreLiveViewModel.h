//
//  YXPreLiveViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXLiveDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXPreLiveViewModel : YXViewModel

@property (nonatomic, strong) RACCommand *getLiveDetail;

@property (nonatomic, strong) YXLiveDetailModel *liveModel;

@property (nonatomic, strong) RACCommand *getLiveCountCommand;

@property (nonatomic, strong) RACCommand *getwatchCountCommand;

@property (nonatomic, strong) RACCommand *closeLiveCommand;

@end

NS_ASSUME_NONNULL_END
