//
//  ZFVideoLiveZegoCoverStateView.m
//  ZZZZZ
//
//  Created by YW on 2019/8/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVideoLiveZegoCoverStateView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@implementation ZFVideoLiveZegoCoverStateView

- (void)dealloc {
    YWLog(@"---------%@ 释放啊 ",NSStringFromClass(self.class));
    [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopTimer {
    [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFC0x666666();
        [self addSubview:self.messageLabel];
        [self addSubview:self.backButton];
        [self addSubview:self.refreshControl];
        [self addSubview:self.timeView];
        
        [self.refreshControl addSubview:self.refreshImagView];
        [self.refreshControl addSubview:self.refreshLabel];
        
        [self.timeView addSubview:self.descLabel];
        [self.timeView addSubview:self.imageView];
        [self.timeView addSubview:self.timeDownView];
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(26);
            make.trailing.mas_equalTo(-26);
            make.bottom.mas_equalTo(self.mas_centerY).offset(-5);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.mas_centerY).offset(5);
            make.height.mas_equalTo(32);
        }];
        
        [self.refreshControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.mas_centerY).offset(5);
            make.height.mas_equalTo(32);
        }];
        
        [self.refreshImagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.refreshControl.mas_leading).offset(12);
            make.centerY.mas_equalTo(self.refreshControl.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.refreshImagView.mas_trailing).offset(4);
            make.centerY.mas_equalTo(self.refreshControl.mas_centerY);
            make.trailing.mas_equalTo(self.refreshControl.mas_trailing).offset(-10);
        }];
        
        
        // time
        
        [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.timeView.mas_top);
            make.leading.mas_equalTo(self.timeView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.timeView.mas_trailing).offset(-12);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.descLabel.mas_top).offset(-10);
            make.centerX.mas_equalTo(self.timeView.mas_centerX);
        }];
        
        CGFloat tempHeight = [self.timeDownView heightTimerLump];
        [self.timeDownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.descLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(tempHeight);
            make.centerX.mas_equalTo(self.timeView.mas_centerX);
            make.bottom.mas_equalTo(self.timeView.mas_bottom);
        }];
    }
    return self;
}

- (void)endCoverStateRefresh:(LiveZegoCoverState)state {
    [UIView animateWithDuration:2.0f animations:^{
        self.refreshImagView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
}

- (void)updateCoverState:(LiveZegoCoverState)state {
    _state = state;
    
    if (!self.refreshImagView.isHidden) {
        [UIView animateWithDuration:2.0f animations:^{
            self.refreshImagView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    }
    
    if (state == LiveZegoCoverStateEnd) {

        _messageLabel.text = ZFLocalizedString(@"Live_End_Tip", nil);
        self.refreshControl.hidden = YES;
        self.backButton.hidden = NO;
        self.timeView.hidden = YES;
        _messageLabel.hidden = NO;

        
    } else if (state == LiveZegoCoverStateJustLive) {
        _messageLabel.text = ZFLocalizedString(@"Live_Pause", nil);
        self.refreshControl.hidden = YES;
        self.backButton.hidden = NO;
        self.timeView.hidden = YES;
        _messageLabel.hidden = NO;
        
    } else if (state == LiveZegoCoverStateNetworkNrror){
        // 在倒计时时，不处理网络
        if (self.timeView.isHidden) {
            _messageLabel.text = ZFLocalizedString(@"Live_Network_Error", nil);
            self.refreshControl.hidden = NO;
            self.backButton.hidden = YES;
            self.timeView.hidden = YES;
            _messageLabel.hidden = NO;
            _state = LiveZegoCoverStateWillStart;
        }

        
    } else if (state == LiveZegoCoverStateWillStart) {
        // 没有设置倒计时信息
        if (ZFIsEmptyString(self.startTimerKey)
            || [self.inforModel.time doubleValue] <= 0.0) {
            _state = LiveZegoCoverStateJustLive;
            [self updateCoverState:LiveZegoCoverStateJustLive];
        } else {
            
            self.refreshControl.hidden = YES;
            self.backButton.hidden = YES;
            self.timeView.hidden = NO;
            _messageLabel.hidden = YES;
        }
    } else {
        self.refreshControl.hidden = YES;
        self.backButton.hidden = YES;
        self.timeView.hidden = YES;
        self.messageLabel.hidden = YES;
    }
    
    if (self.zegoCoverState) {
        self.zegoCoverState(_state);
    }
}

- (void)setInforModel:(ZFVideoLiveZegoCoverWaitInfor *)inforModel {
    //设置了倒计时，但是数据有问题
    if (ZFIsEmptyString(inforModel.startTimerKey)
        || [inforModel.time doubleValue] <= 0.0) {
        [self updateCoverState:LiveZegoCoverStateJustLive];
        return;
    }
    
    _inforModel = inforModel;
    if (ZFIsEmptyString(self.startTimerKey)) {
        self.startTimerKey = ZFToString(inforModel.startTimerKey);
    } else if(![self.startTimerKey isEqualToString:inforModel.startTimerKey]) {
        [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
        self.startTimerKey = inforModel.startTimerKey;
    }
    
    self.descLabel.text = ZFToString(inforModel.content);
    [[ZFTimerManager shareInstance] startTimer:self.startTimerKey];
    [self.timeDownView startTimerWithStamp:inforModel.time timerKey:self.startTimerKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadActivityTime) name:kTimerManagerUpdate object:nil];
    
    [self updateCoverState:LiveZegoCoverStateWillStart];
}

/**
 活动倒计时结束事件
 */
- (void)reloadActivityTime {
    int timeOut =  [self.inforModel.time doubleValue] - [[ZFTimerManager shareInstance] timeInterval:self.inforModel.startTimerKey];
    
    int leftTimeOut = [[ZFTimerManager shareInstance] timeInterval:self.inforModel.startTimerKey];
    
    YWLog(@"----------- 视频活动倒计时 : %i -- left: %i",timeOut,leftTimeOut);
    
    if(timeOut <= 0 || leftTimeOut <= 0){ //倒计时结束，关闭
        self.inforModel.time = @"";
        [self stopTimer];
        self.timeView.hidden = YES;
        
        if (self.zegoEndDownTimeBlock) {
            self.zegoEndDownTimeBlock(YES);
        }
        
        // 先显示播主还未来
        [self updateCoverState:LiveZegoCoverStateJustLive];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimerManagerUpdate object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLiveZegoCoverStateTimerEnd object:nil];
        
    }
}


- (void)actionBack:(UIButton *)sender {
    if (self.zegoEndBlock) {
        self.zegoEndBlock(LiveZegoCoverStateEnd);
    }
}

- (void)actionRefresh:(UIControl *)sender {
    [UIView animateWithDuration:1.0f animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];
        self.refreshImagView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
    }];
    
    if (self.zegoEndBlock) {
        self.zegoEndBlock(LiveZegoCoverStateNetworkNrror);
    }
}


#pragma mark - Property Method

- (UIControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIControl alloc] init];
        [_refreshControl addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventTouchUpInside];
        _refreshControl.layer.cornerRadius = 2;
        _refreshControl.layer.borderColor = ZFC0xFFFFFF().CGColor;
        _refreshControl.layer.borderWidth = 1.0;
        _refreshControl.hidden = YES;
    }
    return _refreshControl;
}

- (UIImageView *)refreshImagView {
    if (!_refreshImagView) {
        _refreshImagView = [[UIImageView alloc] init];
        _refreshImagView.image = [UIImage imageNamed:@"rotate"];
    }
    return _refreshImagView;
}

- (UILabel *)refreshLabel {
    if (!_refreshLabel) {
        _refreshLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _refreshLabel.text = ZFLocalizedString(@"Live_Network_Refresh", nil);
        _refreshLabel.textColor = ZFC0xFFFFFF();
        _refreshLabel.font = [UIFont systemFontOfSize:14];
    }
    return _refreshLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = ZFC0xFFFFFF();
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 2;
        _messageLabel.text = ZFLocalizedString(@"Live_Pause", nil);
    }
    return _messageLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setTitle:ZFLocalizedString(@"Live_End_Back", nil) forState:UIControlStateNormal];
        _backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        _backButton.layer.cornerRadius = 2;
        _backButton.layer.borderColor = ZFC0xFFFFFF().CGColor;
        _backButton.layer.borderWidth = 1.0;
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
        _imageView = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"community_play_wait_hourglass"]];
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
    }
    return _descLabel;
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

@end



@implementation ZFVideoLiveZegoCoverWaitInfor

@end
