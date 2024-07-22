//
//  ZFVideoLiveOperateView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFCommunityLiveVideoGoodsModel.h"

#import "ZFCommunityVideoLiveGoodsModel.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFVideoLiveGoodsAlertView.h"
#import "ZFVideoLiveCouponAlertView.h"
#import "ZFCommunityLiveRecommendGoodsView.h"
#import "ZFGoodsDetailAttributeSmallView.h"
#import "ZFVideoLiveCommentOperateView.h"
#import "ZFVideoLiveZegoCoverStateView.h"


@protocol ZFVideoLiveOperateDelegate;

typedef NS_ENUM(NSUInteger, ZFVideoType) {
    ZFVideoTypeUnknow,
    ZFVideoTypeYT,
    ZFVideoTypeFB,
    ZFVideoTypeZG,
};

typedef NS_ENUM(NSUInteger, ZFVideoPlayState) {
    ZFVideoPlayStateUnknow,
    ZFVideoPlayStatePlay,
    ZFVideoPlayStatePause,
    ZFVideoPlayStateStop,
};

@interface ZFVideoLiveOperateView : UIView


@property (nonatomic, weak) id<ZFVideoLiveOperateDelegate> delegate;

@property (nonatomic, strong) ZFVideoLiveZegoCoverWaitInfor  *inforModel;

@property (nonatomic, assign) ZFVideoType                  videoType;

@property (nonatomic, assign) BOOL                         isFullScreen;

/// 直播播放地址
@property (nonatomic, copy) NSString                       *liveVideoAddress;

/// 视频详情ID
@property (nonatomic, copy) NSString                       *videoDetailID;


@property (nonatomic, strong) UISlider                     *progressSlider;

@property (nonatomic, strong) NSArray<ZFGoodsModel*>       *recommendGoods;

@property (nonatomic, assign) BOOL                         isNeedComment;

@property (nonatomic, assign) ZFVideoPlayState             playState;

/// 是否可加载Zego直播历史评论数据
@property (nonatomic, assign) BOOL                         isZegoHistoryComment;

/// 基础设置
@property (nonatomic, assign) BOOL                         hideTopOperateView;
@property (nonatomic, assign) BOOL                         hideEyesNumsView;
@property (nonatomic, assign) BOOL                         hideFullScreenView;
@property (nonatomic, assign) BOOL                         hideTopBottomLayerView;
@property (nonatomic, assign) BOOL                         hideAllAlertTipView;



- (void)updateLiveCoverState:(LiveZegoCoverState)coverState;




- (void)lookNumbers:(NSString *)num;

- (void)startTime:(NSString *)startTime endTime:(NSString *)endTime isEnd:(BOOL)isEnd;

/// 播放视图状态
- (void)playViewState:(BOOL)play;

- (void)hiddenGoodsListView:(BOOL)hidden;

/// 弹出商品
- (void)showGoodsAlertView:(ZFCommunityVideoLiveGoodsModel *)goodsModel;
- (void)dissmissGoodsAlertView;

/// 弹出优惠券
- (void)showCouponAlertView:(ZFGoodsDetailCouponModel *)couponModel;
- (void)dissmissCouponAlertView;

- (void)fullScreen:(BOOL)isFull;

- (void)videoIsCanPlay;

//设置播放时，自动隐藏滑块栏
- (void)autoHideOperateView;
- (void)hideBottomOperateView:(BOOL)hide;

/// 释放前清空设置
- (void)clearAllSeting;

@end


@protocol ZFVideoLiveOperateDelegate <NSObject>

/// 操作视图 点击返回按钮
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapBlack:(BOOL)tap;

/// 操作视图 点击封面按钮
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView liveCoverStateBlack:(LiveZegoCoverState )state;

/// 操作视图 点击选择商品
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapGoods:(ZFGoodsModel *)tapGoods;

/// 操作视图 点击选择商品上的相似按钮
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView similarGoods:(ZFGoodsModel *)tapGoods;

/// 操作视图 点击全屏切换
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapScreenFull:(BOOL)isFullScreen;

/// 操作视图 点击购物车按钮事件
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapCart:(BOOL)tap;

/// 操作视图 点击弹出商品加入购物车事件
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapAlertCart:(ZFGoodsModel *)goodsModel;

/// 操作视图 点击播放、暂停按钮事件
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView play:(BOOL)tap;

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView tapScreen:(BOOL)tap;

/// 操作视图 点击播放、暂停按钮事件
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView sliderValue:(float)value;

/// 操作视图 点击领取优惠券，暂无添加事件
- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView receiveCoupon:(ZFGoodsDetailCouponModel *)couponModel;

- (void)videoLiveOperateView:(ZFVideoLiveOperateView *)operateView showRecommendGoods:(BOOL)isShow;


@end
