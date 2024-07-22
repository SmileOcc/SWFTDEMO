//
//  ZFZegoPlayerLiveVideoView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

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

#import "ZFZegoBasePlayerView.h"

#import "ZFZegoLiveConstants.h"

@protocol ZFzegoPlayerLiveVideoDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoPlayerLiveVideoView : UIView


@property (nonatomic, weak) id<ZFzegoPlayerLiveVideoDelegate> delegate;

@property (nonatomic, assign) LiveZegoCoverState coverState;

@property (nonatomic, assign) BOOL isFull;


/// 用于直播第三方流的
@property (nonatomic, strong) ZegoAPIStreamExtraPlayInfo *streamExtraPlayInfo;

/// 视频播放的容器视图
@property (nonatomic, strong) UIView                     *videoConterView;

/// 来源父视图
@property (nonatomic, weak) UIView                       *sourceView;

/// 播放浏览数
@property (nonatomic, copy) NSString                     *lookNums;

@property (nonatomic, assign) ZegoBasePlayerType        playerType;

/** 播放的房间ID*/
@property (nonatomic, copy) NSString                         *roomID;
/** 播放的流*/
@property (nonatomic, copy) NSString                         *streamID;

/// 视频来源地址
@property (nonatomic, copy) NSString                     *sourceVideoAddress;

/// 视频详情ID
@property (nonatomic, copy) NSString                     *videoDetailID;

/// 第三方拉流code_ID
@property (nonatomic,strong) NSString                    *thirdStreamID;

/** 是否登录成功*/
@property (nonatomic, assign) BOOL                           loginRoomSuccess;

@property (nonatomic, strong) NSMutableDictionary            *viewContainersDict;
/** 直播流集合，播放的是最后一个*/
@property (nonatomic, strong) NSMutableArray<ZegoStream *>   *streamList;


/** 开始推流播放（包括成功、失败)*/
@property (nonatomic, copy) void (^livePlayingBlock)(BOOL playing);

/** 配置是直播、录播、第三方流*/
- (void)configurationLiveType:(ZegoBasePlayerType)playerType firstStart:(BOOL)firstStart isFull:(BOOL)isFull;
/** 直播*/
- (void)startZegoLive;
/** 录播*/
- (void)startVideoPlay;
/** 退出清楚设置*/
- (void)clearAllStream;
/** 重新登录*/
- (void)reLoginRoom;


- (void)startVideo;

- (void)pauseVideo;

- (void)stopVideo;

- (void)baseSeekToSecondsPlayVideo:(float)seconds;

@end


@protocol ZFzegoPlayerLiveVideoDelegate <NSObject>

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView tapBlack:(BOOL)tap;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView liveCoverStateBlack:(LiveZegoCoverState )state;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView tapGoods:(ZFGoodsModel *)tapGoods;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView similarGoods:(ZFGoodsModel *)tapGoods;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView tapScreenFull:(BOOL)isFullScreen;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView tapCart:(BOOL)tap;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView tapAlertCart:(ZFGoodsModel *)goodsModel;


///////
- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)operateView showRecommendGoods:(ZFCommunityVideoLiveGoodsModel *)goodsModel;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)operateView showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView startPlayingStream:(BOOL )state;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView updateLiveCoverState:(LiveZegoCoverState )coverState;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView isPlaying:(BOOL)isPlaying;

- (void)zfZegoLiveVideoPlayer:(ZFZegoPlayerLiveVideoView *)playerView videoProgress:(NSString *)current max:(NSString *)max isEnd:(BOOL)isEnd;


@end
NS_ASSUME_NONNULL_END
