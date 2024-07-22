//
//  ZFFullLiveStateCoverView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveStateCoverView.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFCountDownView.h"
#import "ZFThemeManager.h"
#import "ZFTimerManager.h"
#import "YWCFunctionTool.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFPushManager.h"
#import "AppDelegate+ZFNotification.h"
#import "YSAlertView.h"

#import "ZFAnalytics.h"
#import "ZFAppsflyerAnalytics.h"

@interface ZFFullLiveStateCoverView()

@property (nonatomic, strong) UIView                *stateView;
@property (nonatomic, strong) UILabel               *descLabel;
@property (nonatomic, strong) YYAnimatedImageView   *imageView;

@property (nonatomic, strong) UIView                *timeView;
@property (nonatomic, strong) UILabel               *timeDescLabel;
@property (nonatomic, strong) UIView                *timeBgView;
@property (nonatomic, strong) ZFCountDownView       *timeDownView;
@property (nonatomic, strong) UIButton              *remindButton;
@property (nonatomic, strong) UIButton              *backButton;
@property (nonatomic, strong) UILabel               *tipSuccessLabel;


@property (nonatomic, assign) BOOL isNeedRemind;



@end

@implementation ZFFullLiveStateCoverView

- (void)dealloc {
    YWLog(@"---------%@ 释放啊 ",NSStringFromClass(self.class));
    [[ZFTimerManager shareInstance] stopTimer:_inforModel.startTimerKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
                
        self.backgroundColor = ZFCClearColor();
        [self addSubview:self.stateView];
        [self.stateView addSubview:self.imageView];
        [self.stateView addSubview:self.descLabel];
        [self.stateView addSubview:self.backButton];
        
        [self addSubview:self.timeView];
        [self addSubview:self.timeBgView];
        [self.timeBgView addSubview:self.timeDescLabel];
        [self.timeBgView addSubview:self.timeDownView];
        [self.timeView addSubview:self.remindButton];
        [self.timeView addSubview:self.tipSuccessLabel];
        
        [self.stateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.stateView.mas_leading);
            make.trailing.mas_equalTo(self.stateView.mas_trailing);
            make.width.mas_greaterThanOrEqualTo(150);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.descLabel.mas_top).offset(-15);
            make.centerX.mas_equalTo(self.stateView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(159, 96));
            make.top.mas_equalTo(self.stateView.mas_top);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.stateView.mas_centerX);
            make.top.mas_equalTo(self.descLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(36);
            make.width.mas_lessThanOrEqualTo(180);
            make.width.mas_greaterThanOrEqualTo(120);
            make.bottom.mas_equalTo(self.stateView.mas_bottom);
        }];
        
        [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.remindButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.mas_centerY).offset(5);
            make.height.mas_equalTo(36);
        }];
        
        [self.timeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.remindButton.mas_top).offset(-10);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
        }];
        
        [self.timeDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.timeBgView.mas_leading);
            make.trailing.mas_equalTo(self.timeBgView.mas_trailing);
            make.top.mas_equalTo(self.timeBgView.mas_top);
        }];
        
        CGFloat tempHeight = [self.timeDownView heightTimerLump];
        [self.timeDownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tempHeight);
            make.top.mas_equalTo(self.timeDescLabel.mas_bottom).offset(20);
            make.centerX.mas_equalTo(self.timeBgView.mas_centerX);
            make.bottom.mas_equalTo(self.timeBgView.mas_bottom);
        }];
        
        [self.tipSuccessLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.timeBgView.mas_leading);
            make.trailing.mas_equalTo(self.timeBgView.mas_trailing);
            make.top.mas_equalTo(self.mas_centerY).offset(5);
            make.height.mas_equalTo(36);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInform:) name:kAppDidBecomeActiveNotification object:nil];
    }
    return self;
}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    if (CGRectContainsPoint(self.commentView.frame, point)) {
//        return self.commentView;
//    }
//    return [super hitTest:point withEvent:event];
//}

- (void)stopTimer {
    [[ZFTimerManager shareInstance] stopTimer:_inforModel.startTimerKey];
}

- (void)actionBack:(UIButton *)sender {
    if (self.backBlock) {
        self.backBlock();
    }
}

- (void)actionRemind:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });

    self.isNeedRemind = YES;
    //< ------- 第一种，不弹窗直接进入设置界面 ------- >
    // 注册远程推送通知
    BOOL isPopAlert = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    if (isPopAlert) {
        
        @weakify(self)
        [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
            @strongify(self)
            
            if (isRegister) {
                [self openReminPush];
            } else {
                //如果已经弹出过，就直接进入到系统推送页面
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }
            
        }];
        

    }else{

        [ZFPushManager saveShowAlertTimestamp];
        [ZFAppsflyerAnalytics analyticsPushEvent:@"Setting" remoteType:ZFOperateRemotePush_guide_yes];
        [AppDelegate registerZFRemoteNotification:^(NSInteger openFlag){
            /**
             * ⚠️⚠️⚠️⚠️⚠️
             * 需要在这里回调，从系统设置再次进入app时，
             * 1、先触发重新活动的通知触发的方法，通知更新的信息方法，不是最新状态，自己获取的状态可能是错的
             * 2、在重新更新状态
             */
            if (openFlag) {
                [self openReminPush];
            }
//            [ZFAnalytics appsFlyerTrackEvent:@"af_subscribe" withValues:@{}];
//            
//            // 统计推送点击量
//            ZFOperateRemotePushType remoteType = ZFOperateRemotePush_sys_unKonw;
//            if (openFlag == 1) {
//                remoteType = ZFOperateRemotePush_sys_yes;
//            } else if (openFlag == 0) {
//                remoteType = ZFOperateRemotePush_sys_no;
//            }
//            [ZFAppsflyerAnalytics analyticsPushEvent:@"Setting" remoteType:remoteType];
        }];
        
    }
}

- (void)updateInform:(NSNotification *)notify {
    //进入【设置】修改通知后，在回到界面时，判断处理通知变化
    if (self.isNeedRemind) {
        @weakify(self)
        [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
            @strongify(self)
            if (isRegister) {
                [self openReminPush];
            }
        }];
    }
}

- (void)openReminPush {
    
    if (self.isNeedRemind) {
        self.isNeedRemind = NO;
        NSString *message = ZFLocalizedString(@"Live_permission_grant_to_push_",nil);
        NSString *noTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_Cancel",nil);
        NSString *yesTitle = ZFLocalizedString(@"Community_LivesVideo_No_Wifi_Play_OK",nil);
        
        ShowAlertView(nil, message, @[yesTitle], ^(NSInteger buttonIndex, id buttonTitle) {
            if (self.remindBlock) {
                self.remindBlock();
            }
        }, noTitle, ^(id cancelTitle) {
        });
    }
}


#pragma mark - Property Method

- (void)setIsRemind:(BOOL)isRemind {
    _isRemind = isRemind;
    if (isRemind) {
        self.remindButton.backgroundColor = ZFC0xCCCCCC();
        self.remindButton.enabled = NO;
        [self.remindButton setTitle:ZFLocalizedString(@"Live_remind_watched", nil) forState:UIControlStateNormal];
        self.remindButton.hidden = YES;
        self.tipSuccessLabel.hidden = NO;
    } else {
        self.remindButton.backgroundColor = ZFC0xFE5269();
        self.remindButton.enabled = YES;
        [self.remindButton setTitle:ZFLocalizedString(@"Live_remind_watch", nil) forState:UIControlStateNormal];
        self.remindButton.hidden = NO;
        self.tipSuccessLabel.hidden = YES;
    }
    if (self.isThirdStream) {
        self.remindButton.hidden = YES;
    }
}
- (void)setInforModel:(ZFCommunityLiveWaitInfor *)inforModel {
    _inforModel = inforModel;
    
    self.descLabel.text = ZFToString(inforModel.content);
    self.timeDescLabel.text = ZFToString(inforModel.content);
    [[ZFTimerManager shareInstance] startTimer:inforModel.startTimerKey];
    [self.timeDownView startTimerWithStamp:inforModel.time timerKey:inforModel.startTimerKey];
}

- (void)updateLiveCoverState:(LiveZegoCoverState)coverState {
        
    if (self.inforModel && coverState == LiveZegoCoverStateWillStart) {
        
        if ([ZFToString(self.inforModel.time) integerValue]  <= 0) {
            coverState = LiveZegoCoverStateJustLive;
            [self handleOtherState:coverState];
        } else {
            
            if (self.waitTimeBlock) {
                self.waitTimeBlock(YES);
            }
            
            self.hidden = NO;
            self.imageView.hidden = YES;
            self.descLabel.hidden = YES;
            self.timeBgView.hidden = NO;
            self.timeView.hidden = NO;
            
            if (self.isRemind) {
                self.remindButton.backgroundColor = ZFC0xCCCCCC();
                self.remindButton.enabled = NO;
            } else {
                self.remindButton.backgroundColor = ZFC0xFE5269();
                self.remindButton.enabled = YES;
            }
        }
        
    } else if(coverState == LiveZegoCoverStateLiving) {
        self.hidden = YES;
    } else {
        [self handleOtherState:coverState];
    }
    
    self.coverState = coverState;
    
    // 第三方不显示
    if (self.isThirdStream) {
        self.remindButton.hidden = YES;
    }
}

- (void)handleOtherState:(LiveZegoCoverState)coverState {
    
    if (self.waitTimeBlock) {
        self.waitTimeBlock(NO);
    }
    
    self.hidden = NO;
    self.timeBgView.hidden = YES;
    self.timeView.hidden = YES;
    self.imageView.hidden = NO;
    self.descLabel.hidden = NO;

//    if (coverState == LiveZegoCoverStateEnd) {
//        self.descLabel.text = ZFLocalizedString(@"Live_End_Tip", nil);
//    } else if(coverState == LiveZegoCoverStateJustLive) {
//        self.descLabel.text = ZFLocalizedString(@"Live_Pause", nil);
//    } else if(coverState == LiveZegoCoverStateNetworkNrror) {
//        self.descLabel.text = ZFLocalizedString(@"Live_Network_Error", nil);
//    }
    
    if (coverState == LiveZegoCoverStateEnd) {
        self.imageView.hidden = YES;
        self.backButton.hidden = NO;
        self.descLabel.text = ZFLocalizedString(@"Live_End_Tip", nil);
    } else {
        self.backButton.hidden = YES;
        self.descLabel.text = ZFLocalizedString(@"Live_Pause", nil);
    }
    
    if (self.backButton.isHidden) {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(159, 96));
        }];
    } else {
        [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
        }];
    }
}


#pragma mark - Property Method

- (UIView *)stateView {
    if (!_stateView) {
        _stateView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _stateView;
    
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = ZFCClearColor();
        _backButton.layer.cornerRadius = 18.0;
        _backButton.layer.masksToBounds = YES;
        _backButton.layer.borderColor = ZFC0xFFFFFF().CGColor;
        _backButton.layer.borderWidth = 1.0;
        _backButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        [_backButton setTitle:ZFLocalizedString(@"Live_End_Back", nil) forState:UIControlStateNormal];
        [_backButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.hidden =YES;
    }
    return _backButton;
}

- (UIView *)timeView {
    if (!_timeView) {
        _timeView = [[UIView alloc] initWithFrame:CGRectZero];
        _timeView.hidden = YES;
    }
    return _timeView;
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"live_host_leave"]];
        _imageView.hidden = YES;
    }
    return _imageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = ZFC0xFFFFFF();
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 0;
        _descLabel.hidden = YES;
    }
    return _descLabel;
}

- (UIView *)timeBgView {
    if (!_timeBgView) {
        _timeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _timeBgView.hidden = YES;
    }
    return _timeBgView;
}
- (UILabel *)timeDescLabel {
    if (!_timeDescLabel) {
        _timeDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeDescLabel.textColor = ZFC0xFFFFFF();
        _timeDescLabel.font = [UIFont systemFontOfSize:14];
        _timeDescLabel.textAlignment = NSTextAlignmentCenter;
        _timeDescLabel.numberOfLines = 0;
        _timeDescLabel.text = @"Livestream begins in";

    }
    return _timeDescLabel;
}

- (ZFCountDownView *)timeDownView {
    if (!_timeDownView) {
        _timeDownView = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:20 showDay:YES];
        _timeDownView.timerCircleRadius = 4;
        _timeDownView.timerTextBackgroundColor = ZFC0x2D2D2D();
        _timeDownView.timerTextColor = ZFC0xFFFFFF();
        _timeDownView.timerBackgroundColor = ZFCClearColor();
    }
    return _timeDownView;
}

- (UIButton *)remindButton {
    if (!_remindButton) {
        _remindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _remindButton.backgroundColor = ZFC0xFE5269();
        _remindButton.layer.cornerRadius = 18.0;
        _remindButton.layer.masksToBounds = YES;
        _remindButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _remindButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
        [_remindButton setTitle:ZFLocalizedString(@"Live_remind_watch", nil) forState:UIControlStateNormal];
        [_remindButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_remindButton addTarget:self action:@selector(actionRemind:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _remindButton;
}


- (UILabel *)tipSuccessLabel {
    if (!_tipSuccessLabel) {
        _tipSuccessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipSuccessLabel.textColor = ZFC0xFFFFFF();
        _tipSuccessLabel.font = [UIFont systemFontOfSize:14];
        _tipSuccessLabel.textAlignment = NSTextAlignmentCenter;
        _tipSuccessLabel.numberOfLines = 0;
        _tipSuccessLabel.hidden = YES;
        _tipSuccessLabel.text = ZFLocalizedString(@"Live_5minutes_receive_push", nil);
    }
    return _tipSuccessLabel;
}
@end
