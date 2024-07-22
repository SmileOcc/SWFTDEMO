//
//  ZFBannerTimeView.m
//  ZZZZZ
//
//  Created by YW on 24/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBannerTimeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFTimerManager.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"

static CGFloat kZFBannerTimeDayHeight = 20;

@interface ZFBannerTimeView ()<ZFInitViewProtocol>
@property (nonatomic, strong)  UIButton  *dayButton;
@property (nonatomic, strong)  YYLabel   *hourLabel;
@property (nonatomic, strong)  YYLabel   *midDotLabel;
@property (nonatomic, strong)  YYLabel   *minuteLabel;
@property (nonatomic, strong)  YYLabel   *rightDotLabel;
@property (nonatomic, strong)  YYLabel   *secondLabel;
@property (nonatomic, copy) NSString   *countDownStamp;//倒计时总秒数
@property (nonatomic, copy) NSString   *countDownTimerKey;//定时器key
@end

@implementation ZFBannerTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textBgColor = [UIColor blackColor];
        self.textColor = [UIColor whiteColor];
        self.dotColor = [UIColor blackColor];
        self.isShowDay = YES;
        [self zfInitView];
        [self zfAutoLayoutView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTime) name:kTimerManagerUpdate object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CGFloat)minContentViewHeight {
    return kZFBannerTimeDayHeight;
}

- (void)zfInitView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.dayButton];
    [self addSubview:self.hourLabel];
    [self addSubview:self.midDotLabel];
    [self addSubview:self.minuteLabel];
    [self addSubview:self.rightDotLabel];
    [self addSubview:self.secondLabel];
}

- (void)zfAutoLayoutView {
    [self.dayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.height.mas_equalTo(kZFBannerTimeDayHeight);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dayButton.mas_right).offset(8);
        make.size.mas_equalTo(CGSizeMake(kZFBannerTimeDayHeight, kZFBannerTimeDayHeight));
        make.centerY.mas_equalTo(self.dayButton.mas_centerY);
    }];
    
    [self.midDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hourLabel.mas_right);
        make.centerY.mas_equalTo(self.dayButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(8, kZFBannerTimeDayHeight));
    }];
    
    [self.minuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.midDotLabel.mas_right);
        make.centerY.mas_equalTo(self.dayButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kZFBannerTimeDayHeight, kZFBannerTimeDayHeight));
    }];

    [self.rightDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minuteLabel.mas_right);
        make.centerY.mas_equalTo(self.dayButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(8, kZFBannerTimeDayHeight));
    }];
    
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rightDotLabel.mas_right);
        make.right.mas_equalTo(self);
        make.centerY.mas_equalTo(self.dayButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kZFBannerTimeDayHeight, kZFBannerTimeDayHeight));
    }];
    
    [self.dayButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.dayButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];

}

#pragma mark - Setter

/**
 开启倒计时任务
 
 @param timeStamp 倒计时总秒数
 @param timerKey 去全局单利定时器中取相应的定时器key
 */
- (void)startCountDownTimerStamp:(NSString *)timeStamp
                    withTimerKey:(NSString *)timerKey {
    
    _countDownStamp = timeStamp;
    _countDownTimerKey = timerKey;
    
    [self reloadTime];
}

- (void)reloadTime {
    int timeOut =  [self.countDownStamp doubleValue] - [[ZFTimerManager shareInstance] timeInterval:self.countDownTimerKey];
    
    if(timeOut <= 0){ //倒计时结束，关闭
        [[ZFTimerManager shareInstance] stopTimer:self.countDownTimerKey];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.dayButton setTitle:[NSString stringWithFormat:@"0%@",ZFLocalizedString(@"CountDownTimer_Day", nil)] forState:UIControlStateNormal];
        self.hourLabel.text   = @"00";
        self.minuteLabel.text = @"00";
        self.secondLabel.text = @"00";
    }else{
        int day = timeOut / 3600 / 24;
        int hours = timeOut / 3600 % 24;
        int minute = timeOut / 60 % 60;
        int second = timeOut % 60;
        
        if (day < 10) {
            [self.dayButton setTitle:[NSString stringWithFormat:@"%d%@",day,ZFLocalizedString(@"CountDownTimer_Day", nil)] forState:UIControlStateNormal];
        }else{
            if (day > 99) day = 99;
            [self.dayButton setTitle:[NSString stringWithFormat:@"%d%@",day,ZFLocalizedString(@"CountDownTimer_Day", nil)] forState:UIControlStateNormal];
        }
        
        if (hours < 10) {
            self.hourLabel.text = [NSString stringWithFormat:@"0%d",hours];
        }else{
            if (hours > 99) hours = 99;
            self.hourLabel.text = [NSString stringWithFormat:@"%d",hours];
        }
        
        if (minute < 10) {
            self.minuteLabel.text = [NSString stringWithFormat:@"0%d",minute];
        }else{
            self.minuteLabel.text = [NSString stringWithFormat:@"%d",minute];
        }
        
        if (second < 10) {
            self.secondLabel.text = [NSString stringWithFormat:@"0%d",second];
        }else{
            self.secondLabel.text = [NSString stringWithFormat:@"%d",second];
        }
    }
    
    if (!self.isShowDay) {
        [self.dayButton setTitle:@"" forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (void)setTextBgColor:(UIColor *)textBgColor
{
    _textBgColor = textBgColor;
    self.dayButton.backgroundColor = _textBgColor;
    self.hourLabel.backgroundColor = _textBgColor;
    self.minuteLabel.backgroundColor = _textBgColor;
    self.secondLabel.backgroundColor = _textBgColor;
}

-(void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    self.midDotLabel.textColor = _dotColor;
    self.rightDotLabel.textColor = _dotColor;
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.hourLabel.textColor = _textColor;
    self.minuteLabel.textColor = _textColor;
    self.secondLabel.textColor = _textColor;
    [self.dayButton setTitleColor:_textColor forState:UIControlStateNormal];
}

- (UIButton *)dayButton {
    if (!_dayButton) {
        _dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dayButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_dayButton setTitleColor:ZFCOLOR(255, 255, 255, 1) forState:UIControlStateNormal];
        _dayButton.userInteractionEnabled = NO;
        _dayButton.backgroundColor = [UIColor blackColor];
        _dayButton.layer.cornerRadius = 4.0f;
        _dayButton.layer.masksToBounds = YES;
        [_dayButton setContentEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
    }
    return _dayButton;
}


- (YYLabel *)hourLabel {
    if (!_hourLabel) {
        _hourLabel = [[YYLabel alloc] init];
        _hourLabel.font = [UIFont systemFontOfSize:14.0f];
        _hourLabel.textColor = ZFCOLOR(255, 255, 255, 1);
        _hourLabel.backgroundColor = [UIColor blackColor];
        _hourLabel.textAlignment = NSTextAlignmentCenter;
        _hourLabel.layer.cornerRadius = 4.0f;
        _hourLabel.layer.masksToBounds = YES;
    }
    return _hourLabel;
}

- (YYLabel *)midDotLabel {
    if (!_midDotLabel) {
        _midDotLabel = [[YYLabel alloc] init];
        _midDotLabel.backgroundColor = [UIColor clearColor];
        _midDotLabel.font = ZFFontBoldSize(14);
        _midDotLabel.text = @":";
        _midDotLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _midDotLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _midDotLabel;
}

- (YYLabel *)rightDotLabel {
    if (!_rightDotLabel) {
        _rightDotLabel = [[YYLabel alloc] init];
        _rightDotLabel.backgroundColor = [UIColor clearColor];
        _rightDotLabel.font = ZFFontBoldSize(14);
        _rightDotLabel.text = @":";
        _rightDotLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _rightDotLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rightDotLabel;
}

- (YYLabel *)minuteLabel {
    if (!_minuteLabel) {
        _minuteLabel = [[YYLabel alloc] init];
        _minuteLabel.font = [UIFont systemFontOfSize:14.0f];
        _minuteLabel.textColor = ZFCOLOR(255, 255, 255, 1);
        _minuteLabel.textAlignment = NSTextAlignmentCenter;
        _minuteLabel.backgroundColor = [UIColor blackColor];
        _minuteLabel.layer.cornerRadius = 4.0f;
        _minuteLabel.layer.masksToBounds = YES;
    }
    return _minuteLabel;
}

- (YYLabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[YYLabel alloc] init];
        _secondLabel.font = [UIFont systemFontOfSize:14.0f];
        _secondLabel.textColor = ZFCOLOR(255, 255, 255, 1);
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = [UIColor blackColor];
        _secondLabel.layer.cornerRadius = 4.0f;
        _secondLabel.layer.masksToBounds = YES;
    }
    return _secondLabel;
}


+ (ZFBannerTimePosition)getBannerTimePosition:(NSString *)position {
    ZFBannerTimePosition timePosition = ZFBannerTimePositionBottomCenter;
    
    if ([position isEqualToString:@"0"]) {
        timePosition = ZFBannerTimePositionTopLeft;
        
    } else if([position isEqualToString:@"1"]) {
        timePosition = ZFBannerTimePositionTopCenter;
        
    } else if([position isEqualToString:@"2"]) {
        timePosition = ZFBannerTimePositionTopRight;
        
    } else if([position isEqualToString:@"3"]) {
        timePosition = ZFBannerTimePositionCenterLeft;
        
    } else if([position isEqualToString:@"4"]) {
        timePosition = ZFBannerTimePositionCenter;
        
    } else if([position isEqualToString:@"5"]) {
        timePosition = ZFBannerTimePositionCenterRight;
        
    } else if([position isEqualToString:@"6"]) {
        timePosition = ZFBannerTimePositionBottomLeft;
        
    } else if([position isEqualToString:@"7"]) {
        timePosition = ZFBannerTimePositionBottomCenter;
        
    } else if([position isEqualToString:@"8"]) {
        timePosition = ZFBannerTimePositionBottomRight;
    }
    
    return timePosition;
}

@end
