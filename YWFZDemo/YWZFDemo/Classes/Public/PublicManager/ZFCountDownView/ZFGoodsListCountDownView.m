//
//  ZFGoodsListCountDownView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsListCountDownView.h"
#import "ZFInitViewProtocol.h"
#import "ZFTimerManager.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"

@interface ZFGoodsListCountDownView () <ZFInitViewProtocol>

@property (nonatomic, strong)  UIImageView              *timeImageView;
@property (nonatomic, strong)  UIView                   *timeBackgroundView;
@property (nonatomic, strong)  YYLabel                  *tipLabel;
@property (nonatomic, strong)  YYLabel                  *hourLabel;
@property (nonatomic, strong)  YYLabel                  *hourDotLabel;
@property (nonatomic, strong)  YYLabel                  *minDotLabel;
@property (nonatomic, strong)  YYLabel                  *minuteLabel;
@property (nonatomic, strong)  YYLabel                  *secondLabel;
/** 倒计时总秒数 */
@property (nonatomic, copy) NSString                    *startTimeStamp;
/** 开启倒计时key */
@property (nonatomic, copy) NSString                    *startTimerKey;

@property (nonatomic, assign) CGFloat                   timerWidth;

@property (nonatomic, assign) CGFloat                   timerHeight;

@end

@implementation ZFGoodsListCountDownView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 默认配置
        _timerWidth = 16;
        _timerHeight = 22;
        _timerBackgroundColor = ZFCOLOR(244, 57, 79, 0.8);
        _timerTextColor = ZFCOLOR(255, 255, 255, 1);
        _timerDotColor = ZFCOLOR(255, 255, 255, 1);
        _timerTextBackgroundColor = [UIColor clearColor];
        
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = self.timerBackgroundColor;
    [self addSubview:self.timeImageView];
    
    [self addSubview:self.tipLabel];
    
    [self addSubview:self.timeBackgroundView];
    
    [self.timeBackgroundView addSubview:self.hourLabel];
    [self.timeBackgroundView addSubview:self.hourDotLabel];
    
    [self.timeBackgroundView addSubview:self.minuteLabel];
    [self.timeBackgroundView addSubview:self.minDotLabel];
    
    [self.timeBackgroundView addSubview:self.secondLabel];
}

- (void)zfAutoLayoutView {
    NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    if (![lang isEqualToString:@"en"]) {
        self.tipLabel.hidden = YES;
        
        [self.timeBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.height.mas_equalTo(22);
            make.centerX.mas_equalTo(self.mas_centerX).offset(10);
        }];
        
        [self.timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).offset(-1);
            make.size.mas_equalTo(CGSizeMake(14, 14));
            make.right.mas_equalTo(self.timeBackgroundView.mas_left).offset(-5);
        }];
    } else {
        self.tipLabel.hidden = NO;
        
        [self.timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).offset(-1);
            make.size.mas_equalTo(CGSizeMake(14, 14));
            make.left.mas_equalTo(self.mas_left).offset(2);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(self.timeImageView.mas_right).offset(2);
            make.height.mas_equalTo(self.timerHeight);
            make.bottom.mas_equalTo(0);
        }];
        
        [self.timeBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_equalTo(0);
            make.left.mas_equalTo(self.tipLabel.mas_right).offset(-2);
        }];
    }
    
    // 小时
    [self.hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(self.timerWidth, self.timerHeight));
    }];
    
    
    [self.hourDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hourLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(3, 11));
    }];
    
    [self.minuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hourDotLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(self.timerWidth, self.timerHeight));
    }];
    
    [self.minDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.minuteLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(3, 11));
    }];
    
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.minDotLabel.mas_right).offset(0);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(self.timerWidth, self.timerHeight));
    }];
}

#pragma mark - Setter

/**
 * 开启倒计时
 */
- (void)startTimerWithStamp:(NSString *)startTimeStamp timerKey:(NSString *)startTimerKey {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTime) name:kTimerManagerUpdate object:nil];
    self.startTimeStamp = startTimeStamp;
    self.startTimerKey = startTimerKey;
    [self reloadTime];
}

- (void)reloadTime {
    int timeOut =  [self.startTimeStamp doubleValue] - [[ZFTimerManager shareInstance] timeInterval:self.startTimerKey];
    
    if(timeOut <= 0){ //倒计时结束，关闭
        [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.hourLabel.text   = @"00";
        self.minuteLabel.text = @"00";
        self.secondLabel.text = @"00";
        
    }else{
        int hours = timeOut / 3600;
        int minute = timeOut / 60 % 60;
        int second = timeOut % 60;
        
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
}

#pragma mark - 颜色配置

- (void)setTimerBackgroundColor:(UIColor *)timerBackgroundColor {
    _timerBackgroundColor = timerBackgroundColor;
    self.backgroundColor = _timerBackgroundColor;
}

- (void)setTimerTextBackgroundColor:(UIColor *)timerTextBackgroundColor {
    
    _timerTextBackgroundColor = timerTextBackgroundColor;
    self.timeBackgroundView.backgroundColor = _timerTextBackgroundColor;
    self.tipLabel.backgroundColor = _timerTextBackgroundColor;
    self.hourLabel.backgroundColor = _timerTextBackgroundColor;
    self.minuteLabel.backgroundColor = _timerTextBackgroundColor;
    self.secondLabel.backgroundColor = _timerTextBackgroundColor;
}

- (void)setTimerTextColor:(UIColor *)timerTextColor {
    
    _timerTextColor = timerTextColor;
    self.tipLabel.textColor = _timerTextColor;
    self.hourLabel.textColor = _timerTextColor;
    self.minuteLabel.textColor = _timerTextColor;
    self.secondLabel.textColor = _timerTextColor;
}

- (void)setTimerDotColor:(UIColor *)timerDotColor {
    
    _timerDotColor = timerDotColor;
    self.hourDotLabel.textColor = _timerDotColor;
    self.minDotLabel.textColor = _timerDotColor;
}

#pragma mark - Getter
- (UIView *)timeBackgroundView {
    if (!_timeBackgroundView) {
        _timeBackgroundView = [[UIView alloc] init];
    }
    return _timeBackgroundView;
}

- (UIImageView *)timeImageView {
    if (!_timeImageView) {
        _timeImageView = [[UIImageView alloc] init];
        _timeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _timeImageView.image = [UIImage imageNamed:@"clock"];
    }
    return _timeImageView;
}

- (YYLabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[YYLabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:11.0f];
        _tipLabel.textColor = self.timerTextColor;
        _tipLabel.backgroundColor = self.timerTextBackgroundColor;
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.text = ZFLocalizedString(@"ListTimeCountDown_Tip", nil);
    }
    return _tipLabel;
}


- (YYLabel *)hourLabel {
    if (!_hourLabel) {
        _hourLabel = [[YYLabel alloc] init];
        _hourLabel.font = [UIFont systemFontOfSize:11.0f];
        _hourLabel.textColor =self.timerTextColor;
        _hourLabel.backgroundColor = self.timerTextBackgroundColor;
        _hourLabel.textAlignment = NSTextAlignmentCenter;
        _hourLabel.text = @"00h";
    }
    return _hourLabel;
}

- (YYLabel *)hourDotLabel {
    if (!_hourDotLabel) {
        _hourDotLabel = [[YYLabel alloc] init];
        _hourDotLabel.font = [UIFont systemFontOfSize:11.0f];
        _hourDotLabel.text = @":";
        _hourDotLabel.textColor = self.timerDotColor;
        _hourDotLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hourDotLabel;
}

- (YYLabel *)minDotLabel {
    if (!_minDotLabel) {
        _minDotLabel = [[YYLabel alloc] init];
        _minDotLabel.font = [UIFont systemFontOfSize:11.0f];
        _minDotLabel.text = @":";
        _minDotLabel.textColor = self.timerDotColor;
        _minDotLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minDotLabel;
}

- (YYLabel *)minuteLabel {
    if (!_minuteLabel) {
        _minuteLabel = [[YYLabel alloc] init];
        _minuteLabel.font = [UIFont systemFontOfSize:11.0f];
        _minuteLabel.textColor = self.timerTextColor;
        _minuteLabel.textAlignment = NSTextAlignmentCenter;
        _minuteLabel.backgroundColor = self.timerTextBackgroundColor;
        _minuteLabel.text = @"00m";
    }
    return _minuteLabel;
}

- (YYLabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[YYLabel alloc] init];
        _secondLabel.font = [UIFont systemFontOfSize:11.0f];
        _secondLabel.textColor = self.timerTextColor;
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = self.timerTextBackgroundColor;
        _secondLabel.text = @"00s";
    }
    return _secondLabel;
}

@end
