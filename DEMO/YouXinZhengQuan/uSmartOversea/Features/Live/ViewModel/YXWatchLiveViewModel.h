//
//  YXWatchLiveViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXLiveDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXWatchLiveViewModel : YXViewModel

@property (nonatomic, copy) void(^nextPlayBlock)(BOOL isPlay);

@property (nonatomic, strong) RACCommand *getLiveDetail;

@property (nonatomic, strong) YXLiveDetailModel *liveModel;

@property (nonatomic, strong) RACCommand *getwatchCountCommand;

@property (nonatomic, strong) RACCommand *getUserRightCommand;
@property (nonatomic, strong) RACCommand * gotoLiveChatLandscapeCommand;

@property (nonatomic, assign) BOOL isPlaying; //是否正在播放

@property (nonatomic, assign) BOOL has_right;
// -1:全部可见 1:proV1 2:proV2 4:PI (目前返回1和4，2为预留)"
@property (nonatomic, assign) int require_right;

@end

NS_ASSUME_NONNULL_END
