//
//  ZFCountDownView.m
//  ZZZZZ
//
//  Created by YW on 14/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCountDownView.h"
#import "ZFInitViewProtocol.h"
#import "ZFTimerManager.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "Masonry.h"
#import "Constants.h"
#import "NSString+Extended.h"

@interface ZFCountDownView()<ZFInitViewProtocol>
@property (nonatomic, strong)  UIView                   *dayView;
@property (nonatomic, strong)  YYLabel                  *dayLabel;
@property (nonatomic, strong)  YYLabel                  *hourLabel;
@property (nonatomic, strong)  YYLabel                  *hourDotLabel;
@property (nonatomic, strong)  YYLabel                  *minuteLabel;
@property (nonatomic, strong)  YYLabel                  *minDotLabel;
@property (nonatomic, strong)  YYLabel                  *secondLabel;
/** 倒计时总秒数 */
@property (nonatomic, copy) NSString                    *startTimeStamp;
/** 开启倒计时key */
@property (nonatomic, copy) NSString                    *startTimerKey;
/** 天区块是否显示：默认 不显示 */
@property (nonatomic, assign) BOOL                      isShowDay;
@property (nonatomic, assign) CGFloat                   dayViewWidth;
@property (nonatomic, assign) CGFloat                   timerHeight;
@property (nonatomic, copy) void (^completeBlock)(void);//倒计时完成回调
@end

@implementation ZFCountDownView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame tierSizeHeight:(CGFloat)timerSizeHeight showDay:(BOOL)showDay {
    self = [super initWithFrame:frame];
    if (self) {
        [self createCountDownView:timerSizeHeight showDay:showDay];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createCountDownView:24.0 showDay:NO];
    }
    return self;
}

/**
 * 自定义配置
 */
- (void)createCountDownView:(CGFloat)timerSizeHeight showDay:(BOOL)showDay {
    _timerBackgroundColor = ZFCOLOR(252, 191, 55, 1);
    _timerTextColor = ZFC0x2D2D2D();
    _timerDotColor = ZFC0x2D2D2D();
    _timerTextBackgroundColor = ZFC0xFFFFFF();
    
    _timerHeight = timerSizeHeight > 0 ? timerSizeHeight : 24;
    _timerCircleRadius = self.timerHeight / 2.0;
    // 4 空白间隙
    _dayViewWidth = self.timerHeight + 4;
    _isShowDay = showDay;
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTime) name:kTimerManagerUpdate object:nil];
}

- (CGFloat)heightTimerLump {
    return self.timerHeight > 0 ? self.timerHeight : 24;
}

- (void)zfInitView {
    self.backgroundColor = self.timerBackgroundColor;
    [self addSubview:self.dayView];
    [self.dayView addSubview:self.dayLabel];
    [self addSubview:self.hourLabel];
    [self addSubview:self.hourDotLabel];
    [self addSubview:self.minuteLabel];
    [self addSubview:self.minDotLabel];
    [self addSubview:self.secondLabel];
}

- (void)zfAutoLayoutView {
    CGFloat currentDayWidth = self.isShowDay ? self.dayViewWidth : 0;
    self.dayView.hidden = !self.isShowDay;
    
    // 天
    [self.dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(currentDayWidth, self.timerHeight));
        make.bottom.mas_equalTo(self);
    }];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.dayView);
        make.size.mas_equalTo(CGSizeMake(self.timerHeight, self.timerHeight));
        make.bottom.mas_equalTo(self);
    }];
    
    
    // 小时
    [self.hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.mas_equalTo(self.dayView.mas_right);
        make.height.mas_offset(self.timerHeight);
        make.size.mas_equalTo(CGSizeMake(self.timerHeight, self.timerHeight));
        make.bottom.mas_equalTo(self);
    }];
    [self.hourDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hourLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(4, 11));
    }];
    
    
    // 分
    [self.minuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hourDotLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(self.timerHeight, self.timerHeight));
    }];
    [self.minDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minuteLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(4, 11));
    }];
    
    
    // 秒
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minDotLabel.mas_right).offset(4);
        make.right.mas_equalTo(self);
        make.centerY.mas_equalTo(self.hourLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(self.timerHeight, self.timerHeight));
    }];
}

#pragma mark - Setter

/**
 *  根据相应的key开启倒计时
 */
- (void)startTimerWithStamp:(NSString *)timeStamp
                   timerKey:(NSString *)timerKey
              completeBlock:(void(^)(void))completeBlock {
    self.completeBlock = completeBlock;
    [self startTimerWithStamp:timeStamp timerKey:timerKey];
}

/**
 * 开启倒计时
 */
- (void)startTimerWithStamp:(NSString *)startTimeStamp timerKey:(NSString *)startTimerKey {
    self.startTimeStamp = startTimeStamp;
    self.startTimerKey = startTimerKey;
    [self reloadTime];
}

- (void)reloadTime {
    if (!self.startTimerKey) {
        return;
    }
    double startTime = [[ZFTimerManager shareInstance] timeInterval:self.startTimerKey];
    double startTimeStamp = [self.startTimeStamp doubleValue];
    int timeOut =  startTimeStamp - startTime;
    
    BOOL tempShowDay = self.isShowDay;
    if(timeOut <= 0){ //倒计时结束，关闭
        
        // 倒计时完成回调
        if (self.completeBlock) {
            self.completeBlock();
        }
        [[ZFTimerManager shareInstance] stopTimer:self.startTimerKey];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.dayLabel.text    = @"00";
        self.hourLabel.text   = @"00";
        self.minuteLabel.text = @"00";
        self.secondLabel.text = @"00";
        
        if (!self.dayView.isHidden) {// 不隐藏 ——> 到隐藏
            if (!self.isShowDay) {
                self.dayView.hidden = YES;
                [self.dayView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(0, self.timerHeight));
                }];
            }
        }
    } else {
        int day = timeOut / 3600 / 24;
        int hours = timeOut / 3600 % 24;
        int minute = timeOut / 60 % 60;
        int second = timeOut % 60;
        
        // 有些地方暂时不要Day 所以只处理重显示到不显示，不处理重新显示
        // 但是有天的值，而不显示Day,会有问题
        // self.isShowDay = day <= 0 ? NO : YES;
        
        // 若要支持重新显示，开放上面这个，注释这个
        /**
            if (self.isShowDay && day <= 0) {
                self.isShowDay = NO;
            }
         */
        if (!self.dayView.isHidden) {// 不隐藏 ——> 到隐藏
            if (!self.isShowDay) {
                self.dayView.hidden = YES;
                [self.dayView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(0, self.timerHeight));
                }];
            }
            
        } else if (tempShowDay != self.isShowDay && self.isShowDay) {// 隐藏状态时：前后显示状态不同，要变成显示时
            self.dayView.hidden = NO;
            [self.dayView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(self.dayViewWidth, self.timerHeight));
            }];
        }
        
        if (day < 10) {
            self.dayLabel.text = [NSString stringWithFormat:@"%dD",day];
        } else {
            if (day > 99) day = 99;
            self.dayLabel.text = [NSString stringWithFormat:@"%d",day];
        }
        
        // 如果不显示"天", 则把小时数折算成: 天的小时数+实际小时数
        if (self.dayView.hidden || !self.isShowDay) {
            hours = hours + day * 24;
        }
        
        if (hours < 10) {
            self.hourLabel.text = [NSString stringWithFormat:@"0%d",hours];
        } else {
            if (hours > 99) {
                NSString *text = [NSString stringWithFormat:@"%d",hours];
                CGFloat width = [text textSizeWithFont:self.hourLabel.font constrainedToSize:CGSizeMake(100, self.timerHeight) lineBreakMode:self.hourLabel.lineBreakMode].width + 3;
                if (self.hourLabel.frame.size.width <= width) {
                    [self.hourLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.size.mas_offset(CGSizeMake(width, self.timerHeight));
                    }];
                }
            }
            self.hourLabel.text = [NSString stringWithFormat:@"%d",hours];
        }
        
        if (minute < 10) {
            self.minuteLabel.text = [NSString stringWithFormat:@"0%d",minute];
        } else {
            self.minuteLabel.text = [NSString stringWithFormat:@"%d",minute];
        }
        
        if (second < 10) {
            self.secondLabel.text = [NSString stringWithFormat:@"0%d",second];
        } else {
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
    self.dayLabel.backgroundColor = _timerTextBackgroundColor;
    self.hourLabel.backgroundColor = _timerTextBackgroundColor;
    self.minuteLabel.backgroundColor = _timerTextBackgroundColor;
    self.secondLabel.backgroundColor = _timerTextBackgroundColor;
}

- (void)setTimerTextColor:(UIColor *)timerTextColor {
    
    _timerTextColor = timerTextColor;
    self.dayLabel.textColor = _timerTextColor;
    self.hourLabel.textColor = _timerTextColor;
    self.minuteLabel.textColor = _timerTextColor;
    self.secondLabel.textColor = _timerTextColor;
}

- (void)setTimerDotColor:(UIColor *)timerDotColor {
    
    _timerDotColor = timerDotColor;
    self.hourDotLabel.textColor = _timerDotColor;
    self.minDotLabel.textColor = _timerDotColor;
}

- (void)setTimerCircleRadius:(CGFloat)timerCircleRadius {
    _timerCircleRadius = timerCircleRadius;
    self.dayLabel.layer.cornerRadius = _timerCircleRadius;
    self.hourLabel.layer.cornerRadius = _timerCircleRadius;
    self.minuteLabel.layer.cornerRadius = _timerCircleRadius;
    self.secondLabel.layer.cornerRadius = _timerCircleRadius;
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    
    if (fontSize <= 0) {
        return;
    }
    self.dayLabel.font = [UIFont systemFontOfSize:fontSize];
    self.hourLabel.font = self.dayLabel.font;
    self.minuteLabel.font = self.dayLabel.font;
    self.secondLabel.font = self.dayLabel.font;
    self.hourDotLabel.font = self.dayLabel.font;
    self.minDotLabel.font = self.dayLabel.font;
}

- (void)setDotPadding:(CGFloat)dotPadding
{
    _dotPadding = dotPadding;
    
    [self.hourDotLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hourLabel.mas_right).offset(1);
        make.size.mas_offset(CGSizeMake(dotPadding, 11));
    }];
    [self.minuteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hourDotLabel.mas_right).offset(1);
    }];
    [self.minDotLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minuteLabel.mas_right).offset(1);
        make.size.mas_offset(CGSizeMake(dotPadding, 11));
    }];
    [self.secondLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minDotLabel.mas_right).offset(1);
    }];
}

#pragma mark - Getter

- (UIView *)dayView {
    if (!_dayView) {
        _dayView = [[UIView alloc] initWithFrame:CGRectZero];
        _dayView.backgroundColor = [UIColor clearColor];
        _dayView.hidden = YES;
    }
    return _dayView;
}

- (YYLabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [[YYLabel alloc] init];
        _dayLabel.font = [UIFont systemFontOfSize:14.0f];
        _dayLabel.textColor = self.timerTextColor;
        _dayLabel.backgroundColor = self.timerTextBackgroundColor;
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.layer.cornerRadius = self.timerCircleRadius;
        _dayLabel.layer.masksToBounds = YES;
    }
    return _dayLabel;
}

- (YYLabel *)hourLabel {
    if (!_hourLabel) {
        _hourLabel = [[YYLabel alloc] init];
        _hourLabel.font = [UIFont systemFontOfSize:14.0f];
        _hourLabel.textColor =self.timerTextColor;
        _hourLabel.backgroundColor = self.timerTextBackgroundColor;
        _hourLabel.textAlignment = NSTextAlignmentCenter;
        _hourLabel.layer.cornerRadius = self.timerCircleRadius;
        _hourLabel.layer.masksToBounds = YES;
    }
    return _hourLabel;
}

- (YYLabel *)hourDotLabel {
    if (!_hourDotLabel) {
        _hourDotLabel = [[YYLabel alloc] init];
        _hourDotLabel.font = ZFFontBoldSize(14);
        _hourDotLabel.text = @":";
        _hourDotLabel.textColor = self.timerDotColor;
        _hourDotLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _hourDotLabel;
}

- (YYLabel *)minDotLabel {
    if (!_minDotLabel) {
        _minDotLabel = [[YYLabel alloc] init];
        _minDotLabel.font = ZFFontBoldSize(14);
        _minDotLabel.text = @":";
        _minDotLabel.textColor = self.timerDotColor;
        _minDotLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _minDotLabel;
}

- (YYLabel *)minuteLabel {
    if (!_minuteLabel) {
        _minuteLabel = [[YYLabel alloc] init];
        _minuteLabel.font = [UIFont systemFontOfSize:14.0f];
        _minuteLabel.textColor = self.timerTextColor;
        _minuteLabel.textAlignment = NSTextAlignmentCenter;
        _minuteLabel.backgroundColor = self.timerTextBackgroundColor;
        _minuteLabel.layer.cornerRadius = self.timerCircleRadius;
        _minuteLabel.layer.masksToBounds = YES;
    }
    return _minuteLabel;
}

- (YYLabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[YYLabel alloc] init];
        _secondLabel.font = [UIFont systemFontOfSize:14.0f];
        _secondLabel.textColor = self.timerTextColor;
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = self.timerTextBackgroundColor;
        _secondLabel.layer.cornerRadius = self.timerCircleRadius;
        _secondLabel.layer.masksToBounds = YES;
    }
    return _secondLabel;
}

@end
