//
//  ZFZegoBasePlayerView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFZegoHelper.h"
#import "ZFZegoLiveConstants.h"

#import "UIView+ZFViewCategorySet.h"

#import "ZFVideoLiveOperateView.h"

#import "ZFGoodsModel.h"

@protocol ZFZegoBasePlayerViewDelegate;


@interface ZFZegoBasePlayerView : UIView

@property (nonatomic, weak) id<ZFZegoBasePlayerViewDelegate> delegate;


@property (nonatomic, assign) ZegoBasePlayerType        playerType;

/// 用于直播第三方流的
@property (nonatomic, strong) ZegoAPIStreamExtraPlayInfo *streamExtraPlayInfo;

/// 视频播放的容器视图
@property (nonatomic, strong) UIView                     *videoConterView;
/// 预览图片
@property (nonatomic, strong) UIImageView                *previewImageView;

/// 视频播放的容器上的按钮
@property (nonatomic, strong) UIButton                   *closeButton;
/// 视频播放的容器上的按钮
@property (nonatomic, strong) UIProgressView             *progressView;
/// 来源父视图
@property (nonatomic, weak) UIView                       *sourceView;
/// 原始大小
@property (nonatomic, assign) CGRect                     sourceFrame;


/// 操作视图
@property (nonatomic, strong) ZFVideoLiveOperateView     *operateView;

/// 播放浏览数
@property (nonatomic, copy) NSString                     *lookNums;

/// 视频来源地址
@property (nonatomic, copy) NSString                     *sourceVideoAddress;
/// 开始播放视频ID
@property (nonatomic,strong) NSString                    *liveVideoID;
/// 视频详情ID
@property (nonatomic, copy) NSString                     *videoDetailID;

/// 第三方拉流code_ID
@property (nonatomic,strong) NSString                    *thirdStreamID;

/// 当前播放状态
@property (nonatomic, assign) NSInteger                 currentPlayerState;

/// 全屏状态
@property (nonatomic, assign) BOOL                       isFullScreen;

/// 视频推荐商品
@property (nonatomic, strong) NSArray                    *recommendGoods;

/// 平移手势
@property (nonatomic, strong) UIPanGestureRecognizer     *pan;
/// 点击手势
@property (nonatomic, strong) UITapGestureRecognizer     *tap;
/// 用于手势平移
@property (nonatomic, assign) BOOL                       isAnimating;

/// 基础隐藏配置
@property (nonatomic, assign) BOOL                       hideTopOperateView;
@property (nonatomic, assign) BOOL                       hideEyesNumsView;
@property (nonatomic, assign) BOOL                       hideFullScreenView;

/// 小菊花
@property (nonatomic, strong) UIActivityIndicatorView           *activityView;


- (void)startVideo;

- (void)pauseVideo;

- (void)stopVideo;

///点击播放、暂停
- (void)basePlayVideoWithVideoID:(NSString *)videoID;
///滑块进度值
- (void)baseSeekToSecondsPlayVideo:(float)seconds;
    


///显示预览图片
- (void)showPreviewView:(UIImage *)image;
- (void)hidePreviewView;

/// 全屏显示控制
- (void)fullScreen:(BOOL)isFull;

/// 在window上显示
- (void)showToWindow:(CGSize)size;
- (void)dissmissFromWindow;

/// 显示推荐弹窗商品
- (void)showGoodsAlertView:(ZFCommunityVideoLiveGoodsModel *)goodsModel;
- (void)dissmissGoodsAlertView;

/// 显示推荐弹窗商品
- (void)showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel;
- (void)dissmissCouponAlertView;

- (void)removePlyerViewFromSuperView;


- (void)updateLayout:(NSArray<ZegoRoomMessage *> *)messageList;

- (NSString *)addStaticsInfo:(BOOL)publish stream:(NSString *)streamID fps:(double)fps kbs:(double)kbs akbs:(double)akbs rtt:(int)rtt pktLostRate:(int)pktLostRate;

- (void)updateQuality:(int)quality detail:(NSString *)detail onView:(UIView *)playerView;

- (NSDictionary *)decodeJSONToDictionary:(NSString *)json;

// getRoomList 时获取到的 streamId
@property (nonatomic, copy) NSArray *streamIdList;

- (void)addLogString:(NSString *)log;



@end

@protocol ZFZegoBasePlayerViewDelegate <NSObject>

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapBlack:(BOOL)tap;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView liveCoverStateBlack:(LiveZegoCoverState )state;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapGoods:(ZFGoodsModel *)tapGoods;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView similarGoods:(ZFGoodsModel *)tapGoods;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapScreenFull:(BOOL)isFullScreen;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapCart:(BOOL)tap;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)playerView tapAlertCart:(ZFGoodsModel *)goodsModel;

- (void)zfZegoBasePlayer:(ZFZegoBasePlayerView *)operateView showRecommendGoods:(BOOL)isShow;

@end
