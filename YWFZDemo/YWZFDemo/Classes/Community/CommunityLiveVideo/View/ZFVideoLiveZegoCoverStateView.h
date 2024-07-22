//
//  ZFVideoLiveZegoCoverStateView.h
//  ZZZZZ
//
//  Created by YW on 2019/8/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "ZFCountDownView.h"
#import "ZFTimerManager.h"
#import "ZFZegoLiveConstants.h"

@class ZFVideoLiveZegoCoverWaitInfor;


NS_ASSUME_NONNULL_BEGIN

//typedef NS_ENUM(NSInteger,LiveZegoCoverState) {
//    LiveZegoCoverStateUnknow,
//    /** 网络异常*/
//    LiveZegoCoverStateNetworkNrror,
//    /** 结束刷新动画*/
//    LiveZegoCoverStateEndRefresh,
//    /** 将要开始，显示倒计时*/
//    LiveZegoCoverStateWillStart,
//    /** 直播流播放*/
//    LiveZegoCoverStateLiving,
//    /** 主播离开*/
//    LiveZegoCoverStateJustLive,
//    /** 直播结束*/
//    LiveZegoCoverStateEnd,
//    /** 录播播放状态*/
//    LiveZegoCoverStatePlay,
//};
@interface ZFVideoLiveZegoCoverStateView : UIView

@property (nonatomic, strong) ZFVideoLiveZegoCoverWaitInfor  *inforModel;


@property (nonatomic, strong) UILabel                     *messageLabel;
@property (nonatomic, strong) UIButton                    *backButton;
@property (nonatomic, assign) LiveZegoCoverState          state;

@property (nonatomic, strong) UIControl                   *refreshControl;
@property (nonatomic, strong) UIImageView                 *refreshImagView;
@property (nonatomic, strong) UILabel                     *refreshLabel;

@property (nonatomic, strong) UIView                      *timeView;
@property (nonatomic, strong) UILabel                     *descLabel;
@property (nonatomic, strong) YYAnimatedImageView         *imageView;
@property (nonatomic, strong) ZFCountDownView             *timeDownView;
@property (nonatomic, copy) NSString                      *startTimerKey;




@property (nonatomic, copy) void (^zegoEndBlock)(LiveZegoCoverState coverState);
@property (nonatomic, copy) void (^zegoCoverState)(LiveZegoCoverState coverState);

@property (nonatomic, copy) void (^zegoEndDownTimeBlock)(BOOL flag);


- (void)endCoverStateRefresh:(LiveZegoCoverState)state;
- (void)updateCoverState:(LiveZegoCoverState)state;

- (void)stopTimer;

@end


@interface ZFVideoLiveZegoCoverWaitInfor : NSObject

/** 倒计时秒*/
@property (nonatomic, copy) NSString *time;
/** 活动文案*/
@property (nonatomic, copy) NSString *content;
/** 倒计时标识key*/
@property (nonatomic, copy) NSString *startTimerKey;
@end

NS_ASSUME_NONNULL_END
