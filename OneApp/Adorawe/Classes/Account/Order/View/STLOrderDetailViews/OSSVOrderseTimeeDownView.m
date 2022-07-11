//
//  OSSVOrderseTimeeDownView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrderseTimeeDownView.h"
#import "ZJJTimeCountDownLabel.h"
#import "ZJJTimeCountDown.h"

#define CountDownViewPadding 5

@interface OSSVOrderseTimeeDownView ()
<
    ZJJTimeCountDownDelegate
>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countDownTipsLabel;
@property (nonatomic, strong) ZJJTimeCountDownLabel *countDownLabel;
@property (nonatomic, strong) ZJJTimeCountDown *countManager;

@end

@implementation OSSVOrderseTimeeDownView

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH - 24, 69);
//        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        [self stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];

        [self initUI];
    }
    return self;
}

-(void)initUI
{
    self.backgroundColor = [OSSVThemesColors col_B62B21];
    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH - 24, CGRectGetHeight(self.frame));
//    //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
//    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
//    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
//    // 设置渐变颜色的分割点
//
//    CGFloat startY = 0;
//    gradientLayer.locations = @[@(startY)];
//
//    gradientLayer.type = kCAGradientLayerAxial;
//    gradientLayer.colors = colorsArray;
//    [self.layer addSublayer:gradientLayer];
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.countDownTipsLabel];
    [self.contentView addSubview:self.countDownLabel];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.centerY.mas_equalTo(self.mas_centerY).mas_offset(-3);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(14);
    }];
    
    [self.countDownTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.countDownTipsLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-14);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = STLToString(title);
}

#pragma mark - ZJJTimeCountDownDelegate
- (void)outDateTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    STLLog(@"---- 倒计时结束 %@",timeLabel.text);
    if (self.timeEndBlock) {
        self.timeEndBlock();
    }
}

- (void)dateWithTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown {
    
    //STLLog(@"---- outcc %@",timeLabel.text);
}
//样式改成用文字单位区分天/时/分/秒（英语区分单复数），注意转换后阿语倒计时规则
//---英语区分单复数（如：1day，2days），阿语倒计时规则优化
//---阿语倒计时规则：
//（1单数，2双数，3-10复数，11以上用单数）——阿语翻译
- (NSAttributedString *)customTextWithTimeLabel:(ZJJTimeCountDownLabel *)timeLabel timeCountDown:(ZJJTimeCountDown *)timeCountDown
{
    NSString *days = STLLocalizedString_(@"day", nil);
    NSString *hours = STLLocalizedString_(@"hour", nil);
    NSString *min = STLLocalizedString_(@"minute", nil);
    NSString *seco = STLLocalizedString_(@"second", nil);
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        if(timeLabel.days == 2) {
            days = STLLocalizedString_(@"days_Even", nil);
        } if (timeLabel.days >=3 && timeLabel.days <= 10) {
            days = STLLocalizedString_(@"days", nil);
        }
        
        if(timeLabel.hours == 2) {
            hours = STLLocalizedString_(@"hours_Even", nil);
        } if (timeLabel.hours >=3 && timeLabel.hours <= 10) {
            hours = STLLocalizedString_(@"hours", nil);
        }
        
        if(timeLabel.minutes == 2) {
            min = STLLocalizedString_(@"minutes_Even", nil);
        } if (timeLabel.minutes >=3 && timeLabel.minutes <= 10) {
            min = STLLocalizedString_(@"minutes", nil);
        }
        
        if(timeLabel.seconds == 2) {
            seco = STLLocalizedString_(@"seconds_Even", nil);
        } if (timeLabel.seconds >=3 && timeLabel.seconds <= 10) {
            seco = STLLocalizedString_(@"seconds", nil);
        }
    } else {
        if (timeLabel.days  > 1) {
            days = STLLocalizedString_(@"days", nil);
        }
        
        if (timeLabel.hours > 1) {
            hours = STLLocalizedString_(@"hours", nil);
        }
        
        if (timeLabel.minutes > 1) {
            min = STLLocalizedString_(@"minutes", nil);
        }
        
        if (timeLabel.seconds > 1) {
            seco = STLLocalizedString_(@"seconds", nil);
        }
    }
    
    NSString *dayStr = [NSString stringWithFormat:@"%.2ld",(long)timeLabel.days];
    NSString *hoursStr = [NSString stringWithFormat:@"%.2ld",(long)timeLabel.hours];
    NSString *minutesStr = [NSString stringWithFormat:@"%.2ld",(long)timeLabel.minutes];
    NSString *secondsStr = [NSString stringWithFormat:@"%.2ld",(long)timeLabel.seconds];

    if (timeLabel.days > 0) {
        NSMutableAttributedString * attribute =  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2ld %@ %.2ld %@ %.2ld %@ %.2ld %@",(long)timeLabel.days,days,(long)timeLabel.hours,hours, (long)timeLabel.minutes,min,(long)timeLabel.seconds,seco].uppercaseString];
        
        NSRange dayRange = [attribute.string rangeOfString:dayStr];
        NSRange hoursRange = [attribute.string rangeOfString:hoursStr];
        NSRange minutesRange = [attribute.string rangeOfString:minutesStr];
        NSRange secondsRange = [attribute.string rangeOfString:secondsStr];

        [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:dayRange];
        [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:hoursRange];
        [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:minutesRange];
        [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:secondsRange];
        
        return attribute;

    }
    
    NSMutableAttributedString * attribute =  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2ld %@ %.2ld %@ %.2ld %@",(long)timeLabel.hours,hours, (long)timeLabel.minutes,min,(long)timeLabel.seconds,seco].uppercaseString];
    
    NSRange hoursRange = [attribute.string rangeOfString:hoursStr];
    NSRange minutesRange = [attribute.string rangeOfString:minutesStr];
    NSRange secondsRange = [attribute.string rangeOfString:secondsStr];

    [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:hoursRange];
    [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:minutesRange];
    [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:secondsRange];
    
    return attribute;
}

- (void)updateTipsTypeMsg:(NSString *)tipMsg {
    if (STLIsEmptyString(tipMsg)) {
        self.countDownTipsLabel.text = STLLocalizedString_(@"Remaining_payment_time", nil);
    } else {
        self.countDownTipsLabel.text = tipMsg;
    }
}

#pragma mark - public method

-(void)handleCountDownView:(NSString *)second
{
    ///因为后台传下来的是 剩余秒数， 由于控件处理的是时间戳，所以人为变成时间戳
    NSDate *date = [NSDate date];
    NSTimeInterval nowTime = [date timeIntervalSince1970];
    NSString *time = [NSString stringWithFormat:@"%ld", (long)(second.integerValue + (NSInteger)nowTime)];
    [self.countManager addTimeLabel:self.countDownLabel time:time];
}

#pragma mark - setter and getter

-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view;
        });
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titleLabel;
}

-(UILabel *)countDownTipsLabel
{
    if (!_countDownTipsLabel) {
        _countDownTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"Remaining_payment_time", nil);
            label.text = [NSString stringWithFormat:@"%@ :", label.text];
            label.textColor = [OSSVThemesColors col_FBE9E9];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentLeft;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentRight;
            }
            label;
        });
    }
    return _countDownTipsLabel;
}

-(ZJJTimeCountDownLabel *)countDownLabel
{
    if (!_countDownLabel) {
        _countDownLabel = ({
            ZJJTimeCountDownLabel *label = [[ZJJTimeCountDownLabel alloc] init];
            label.timeKey = @"time";
            label.jj_textAlignment = ZJJTextAlignmentStlyeCenterRight;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.jj_textAlignment = ZJJTextAlignmentStlyeLeftCenter;
            }
            label.font = [UIFont boldSystemFontOfSize:14];
            //设置文本自适应
            label.textAdjustsWidthToFitFont = YES;
            //边框模式
            label.textStyle = ZJJTextStlyeCustom;
            //字体颜色
            label.textColor = [OSSVThemesColors stlWhiteColor];
            label.textHeight = 18;
            label.textBackgroundColor = [UIColor clearColor];
            label.textIntervalSymbolColor = [UIColor whiteColor];
            label.isRetainFinalValue = YES;
            label;
        });
    }
    return _countDownLabel;
}

-(ZJJTimeCountDown *)countManager
{
    if (!_countManager) {
        _countManager = [[ZJJTimeCountDown alloc] init];
        _countManager.timeStyle = ZJJCountDownTimeStyleTamp;
        _countManager.delegate = self;
    }
    return _countManager;
}

-(void)dealloc
{
    if (_countManager) {
        [self.countManager destoryTimer];
    }
}

@end
