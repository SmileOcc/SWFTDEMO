//
//  ZFLiveBaseView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "UIView+ZFViewCategorySet.h"

#import "ZFVideoLiveOperateView.h"

#import "ZFGoodsModel.h"
@protocol ZFLiveBaseViewDelegate;


typedef NS_ENUM(NSInteger,PlayerState) {
    
    PlayerStateUnStarted,/**  play video unstart,maybe videosource has error      */
    PlayerStateEnded,/**  play video end  **/
    
    PlayerStatePlaying,/**   video is playing **/
    
    PlayerStatePaused,/**   pause playing video **/
    
    PlayerStateBuffering,/**    video is buffering  **/
    
    PlayerStateEmbed/**    video embed   **/
};

@interface ZFLiveBaseView : UIView<ZFVideoLiveOperateDelegate>


- (instancetype)initWithFrame:(CGRect)frame webView:(WKWebView *)webView;

@property (nonatomic, weak) id<ZFLiveBaseViewDelegate> delegate;

@property (nonatomic,strong) WKWebView                   *webView;

/// 视频web播放的容器视图
@property (nonatomic, strong) UIView                     *webVideoConterView;
/// 视频web播放的容器上的按钮
@property (nonatomic, strong) UIButton                   *closeButton;
/// 视频web播放的容器上的按钮
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
@property (nonatomic, copy) NSString                     *liveVideoID;
/// 视频详情ID
@property (nonatomic, copy) NSString                     *videoDetailID;


/// 当前播放状态
@property (nonatomic, assign) PlayerState                currentPlayerState;

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
@property (nonatomic, assign) BOOL                       hideTopBottomLayerView;
@property (nonatomic, assign) BOOL                       hideAllAlertTipView;

#pragma mark - action

/// 开始播放
- (BOOL)basePlayVideoWithVideoID:(NSString *)liveVideoID;
/// 快进到播放时间
- (void)baseSeekToSecondsPlayVideo:(float)seconds;



- (void)startVideo;

- (void)pauseVideo;

- (void)stopVideo;

/// 全屏显示控制
- (void)fullScreen:(BOOL)isFull;

/// 在window上显示
- (void)showToWindow:(CGSize)size;
- (void)dissmissFromWindow;

/// 显示推荐弹窗商品
- (void)showGoodsAlertView:(ZFCommunityVideoLiveGoodsModel *)goodsModel;
- (void)dissmissGoodsAlertView;

/// 显示推荐弹窗优惠券
- (void)showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel;
- (void)dissmissCouponAlertView;

- (void)removePlyerViewFromSuperView;

@end


@protocol ZFLiveBaseViewDelegate <NSObject>

@optional
- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapBlack:(BOOL)tap;

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapGoods:(ZFGoodsModel *)tapGoods;

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView similarGoods:(ZFGoodsModel *)tapGoods;

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapScreenFull:(BOOL)isFullScreen;

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapCart:(BOOL)tap;

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView tapAlertCart:(ZFGoodsModel *)goodsModel;

///playerStatus = true 播放
- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView player:(BOOL)playerStatus;

@end
