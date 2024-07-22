//
//  ZFZegoPlayerView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoBasePlayerView.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFVideoLiveOperateView.h"

#import "ZFZegoHelper.h"
#import "ZFZegoMediaPlayerHelper.h"
#import "ZFGoodsModel.h"

@interface ZFZegoPlayerView : ZFZegoBasePlayerView


/** 倒计时信息*/
@property (nonatomic, strong) ZFVideoLiveZegoCoverWaitInfor  *inforModel;

/** 播放的房间ID*/
@property (nonatomic, copy) NSString                         *roomID;
/** 播放的流*/
@property (nonatomic, copy) NSString                         *streamID;
/** 是否登录成功*/
@property (nonatomic, assign) BOOL                           loginRoomSuccess;

@property (nonatomic, strong) NSMutableDictionary            *viewContainersDict;
/** 直播流集合，播放的是最后一个*/
@property (nonatomic, strong) NSMutableArray<ZegoStream *>   *streamList;


/** 开始推流播放（包括成功、失败)*/
@property (nonatomic, copy) void (^livePlayingBlock)(BOOL playing);

/** 配置是直播、录播、第三方流*/
- (void)configurationLiveType:(ZegoBasePlayerType)playerType firstStart:(BOOL)firstStart;
/** 直播*/
- (void)startZegoLive;
/** 录播*/
- (void)startVideoPlay;
/** 退出清楚设置*/
- (void)clearAllStream;
/** 重新登录*/
- (void)reLoginRoom;
@end
