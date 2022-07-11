//
//  YXLiveChatLandscapeViewModel.h
//  uSmartOversea
//
//  Created by suntao on 2021/2/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"


@class  YXLiveDetailModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveChatLandscapeViewModel : YXViewModel

@property (nonatomic, assign) BOOL isPrePlaying;  //上一个界面是否正在播放
@property (nonatomic, assign) BOOL isPlaying; //现在是否在播放
@property (nonatomic, copy) void(^playBlock)(BOOL isPlay);

@property (nonatomic, strong) RACCommand *getwatchCountCommand;
@property (nonatomic, strong) YXLiveDetailModel *liveModel;

-(void)isPlayingFlag;

@end

NS_ASSUME_NONNULL_END
