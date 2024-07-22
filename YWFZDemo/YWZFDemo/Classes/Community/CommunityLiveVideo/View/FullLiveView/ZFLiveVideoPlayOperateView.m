//
//  ZFLiveVideoPlayOperateView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveVideoPlayOperateView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"

@implementation ZFLiveVideoPlayOperateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isFull = NO;
        self.isPlay = YES;
        [self addSubview:self.playButton];
        [self addSubview:self.fullPlayButton];
        [self addSubview:self.startTimeLabel];
        [self addSubview:self.endTimeLabel];
        [self addSubview:self.progressSlider];
                
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(2);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.fullPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-2);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.playButton.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.fullPlayButton.mas_leading).offset(-2);
        }];
        
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.startTimeLabel.mas_trailing).offset(5);
            make.trailing.mas_equalTo(self.endTimeLabel.mas_leading).offset(-5);
            make.height.mas_equalTo(10);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [self.startTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.startTimeLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.endTimeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.endTimeLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CAGradientLayer *bottomLayer = [CAGradientLayer new];
    bottomLayer.colors=@[(__bridge id)ColorHex_Alpha(0x000000, 0.0).CGColor,(__bridge id)ColorHex_Alpha(0x000000, 0.4).CGColor];
    bottomLayer.startPoint = CGPointMake(0.5, 0);
    bottomLayer.endPoint = CGPointMake(0.5, 1);
    bottomLayer.frame = CGRectMake(0, 0, KScreenHeight, 44);
    [self.layer insertSublayer:bottomLayer atIndex:0];
}


- (void)startTime:(NSString *)startTime endTime:(NSString *)endTime isEnd:(BOOL)isEnd {
    
    bool touch = self.progressSlider.touchInside;
    if (isEnd) {
        if (!touch) {
            self.startTimeLabel.text = self.endTimeLabel.text;
            self.progressSlider.value = self.progressSlider.maximumValue;
        }
    } else {
        if (!ZFIsEmptyString(startTime)) {
            if (!touch) {
                self.startTimeLabel.text = [self fromartTime:startTime];
                self.progressSlider.value = [startTime floatValue] + 1.0f;
                //设置播放时，自动隐藏滑块栏
                [self autoHideOperateView];
            }
        }
        if (!ZFIsEmptyString(endTime)) {
            self.endTimeLabel.text = [self fromartTime:endTime];
            self.progressSlider.maximumValue = [endTime floatValue];
        }
    }
}

//设置播放时，自动隐藏滑块栏
- (void)autoHideOperateView {
    
    if (!self.isHidden) {
        self.autoHideBottomViewCount++;
        // FB的时间不是以S间隔
        NSInteger count = 5;
        if (self.autoHideBottomViewCount >= count) {
            YWLog(@"---------- 自动隐藏滑块栏 %li",(long)self.autoHideBottomViewCount);
            self.hidden = YES;
            self.autoHideBottomViewCount = 0;
            if (self.autoHideBlock) {
                self.autoHideBlock();
            }
        }
    }
}


- (void)showFullButton:(BOOL)show {
    self.fullPlayButton.hidden = !show;
    
    if (show) {
        [self.fullPlayButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-2);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
    } else {
        [self.fullPlayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-2);
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }];
    }
}


- (void)setIsFull:(BOOL)isFull {
    if (_isFull != isFull) {
        _isFull = isFull;
        
        if (isFull) {
            [self.fullPlayButton setImage:[UIImage imageNamed:@"live_full_small"] forState:UIControlStateNormal];
        } else {
            [self.fullPlayButton setImage:[UIImage imageNamed:@"live_full_expand"] forState:UIControlStateNormal];
        }
    }
}

- (void)setIsPlay:(BOOL)isPlay {
    if (_isPlay != isPlay) {
        _isPlay = isPlay;
        if (isPlay) {
            [self.playButton setImage:[UIImage imageNamed:@"live_stop"] forState:UIControlStateNormal];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"live_play"] forState:UIControlStateNormal];
        }
    }
}


- (void)actionPlay:(UIButton *)sender {
    self.isPlay = !self.isPlay;
    if (self.playStateBlock) {
        self.playStateBlock(self.isPlay);
    }
}

- (void)actionFullScreen:(UIButton *)sender {
    self.isFull = !self.isFull;
    if (self.fullPlayBlock) {
        self.fullPlayBlock(self.isFull);
    }
}

- (void)actionSliderValurChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    self.startTimeLabel.text = [self fromartTime:[NSString stringWithFormat:@"%f",slider.value]];
    if (self.sliderValueBlock) {
        self.sliderValueBlock(slider.value);
    }
}

- (UILabel *)startTimeLabel {
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _startTimeLabel.text = @"00:00";
        _startTimeLabel.textColor = ZFC0xFFFFFF();
        _startTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _startTimeLabel;
}

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _progressSlider.maximumTrackTintColor = ZFC0xFFFFFF();
        _progressSlider.minimumTrackTintColor = ZFC0xFE5269();
        [_progressSlider setThumbImage:[UIImage imageNamed:@"slider_tap"] forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(actionSliderValurChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

- (UILabel *)endTimeLabel {
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _endTimeLabel.text = @"00:00";
        _endTimeLabel.textColor = ZFC0xFFFFFF();
        _endTimeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _endTimeLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_playButton setImage:[UIImage imageNamed:@"live_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)fullPlayButton {
    if (!_fullPlayButton) {
        _fullPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_fullPlayButton setImage:[UIImage imageNamed:@"live_full_expand"] forState:UIControlStateNormal];
        [_fullPlayButton addTarget:self action:@selector(actionFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullPlayButton;
}

- (NSString *)fromartTime:(NSString *)timeStr {
    
    NSInteger time = [ZFToString(timeStr) integerValue];
    //重新计算 时/分/秒
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",time/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(time%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",time%60];
    
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    if ([str_hour isEqualToString:@"00"]) {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    return format_time;
}
@end
