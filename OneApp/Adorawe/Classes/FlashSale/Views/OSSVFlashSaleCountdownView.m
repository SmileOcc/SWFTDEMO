//
//  OSSVFlashSaleCountdownView.m
// XStarlinkProject
//
//  Created by odd on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleCountdownView.h"

@implementation OSSVFlashSaleCountdownView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.timeBgView];
        [self.timeBgView addSubview:self.endLabel];
        [self.timeBgView addSubview:self.hourLabel];
        [self.timeBgView addSubview:self.minuteLabel];
        [self.timeBgView addSubview:self.secondLabel];
        [self.timeBgView addSubview:self.pointLabel1];
        [self.timeBgView addSubview:self.pointLabel2];
        [self.timeBgView addSubview:self.dayLabel];
        [self.timeBgView addSubview:self.pointLabel3];
//        _countdownL = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer];
//        _countdownL.delegate = self;
//        [_countdownL setCountDownTime:0];

        
//        [self addSubview:self.timeLabel];

//        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.equalTo(self.mas_leading).offset(12);
//            make.trailing.equalTo(self.mas_trailing).offset(-12);
//            make.height.equalTo(@18);
//            make.top.equalTo(self.mas_top).offset(8);
//        }];
        
        [self.timeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.leading.mas_equalTo(self.mas_leading).offset(116);
    //        make.trailing.mas_equalTo(self.mas_trailing).offset(-116);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.timeBgView.mas_trailing).offset(0);
            make.width.mas_equalTo(@18);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];
        
        [self.pointLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.secondLabel.mas_leading);
            make.width.mas_equalTo(@8);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];
        
        [self.minuteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.pointLabel1.mas_leading);
            make.width.mas_equalTo(@18);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];
        
        [self.pointLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.minuteLabel.mas_leading);
            make.width.mas_equalTo(@8);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];

        [self.hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.pointLabel2.mas_leading);
            make.width.mas_equalTo(@18);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];

        [self.pointLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.hourLabel.mas_leading).offset(-2);
            make.width.mas_equalTo(@9);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];

        [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.pointLabel3.mas_leading).offset(-2);
            make.width.mas_equalTo(@18);
            make.height.mas_equalTo(@18);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];

        [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.dayLabel.mas_leading).offset(-10);
            make.height.mas_equalTo(@24);
            make.leading.mas_equalTo(self.timeBgView.mas_leading);
            make.centerY.mas_equalTo(self.timeBgView.mas_centerY);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    CGFloat timeBgViewWidth = SCREEN_WIDTH - 162*2;
    
    

}

- (UIView *)timeBgView {
    if (!_timeBgView) {
        _timeBgView = [UIView new];
        _timeBgView.backgroundColor = [UIColor clearColor];
    }
        return _timeBgView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = OSSVThemesColors.col_B62B21;
        _timeLabel.font = [UIFont boldSystemFontOfSize:11.f];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.layer.borderColor = OSSVThemesColors.col_B62B21.CGColor;
        _timeLabel.layer.borderWidth = 1.f;
        _timeLabel.layer.cornerRadius = 9.f;
        _timeLabel.layer.masksToBounds = YES;
    }
    return _timeLabel;
}

- (UILabel *)endLabel {
    if (!_endLabel) {
        _endLabel = [UILabel new];
        _endLabel.textAlignment = NSTextAlignmentRight;
        _endLabel.font = [UIFont systemFontOfSize:12];
        _endLabel.textColor = OSSVThemesColors.col_131313;
    }
    return _endLabel;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [UILabel new];
        _dayLabel.font = [UIFont systemFontOfSize:12];
        _dayLabel.textColor = [UIColor whiteColor];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _dayLabel;
}

- (UILabel *)hourLabel {
    if (!_hourLabel) {
        _hourLabel = [UILabel new];
        _hourLabel.font = [UIFont systemFontOfSize:12];
        _hourLabel.textColor = [UIColor whiteColor];
        _hourLabel.textAlignment = NSTextAlignmentCenter;
        _hourLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _hourLabel;
}

- (UILabel *)minuteLabel {
    if (!_minuteLabel) {
        _minuteLabel = [UILabel new];
        _minuteLabel.font = [UIFont systemFontOfSize:12];
        _minuteLabel.textColor = [UIColor whiteColor];
        _minuteLabel.textAlignment = NSTextAlignmentCenter;
        _minuteLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _minuteLabel;
}
- (UILabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [UILabel new];
        _secondLabel.font = [UIFont systemFontOfSize:12];
        _secondLabel.textColor = [UIColor whiteColor];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
    return _secondLabel;
}
- (UILabel *)pointLabel1 {
    if (!_pointLabel1) {
        _pointLabel1 = [UILabel new];
        _pointLabel1.text = @":";
        _pointLabel1.backgroundColor = [OSSVThemesColors stlClearColor];
        _pointLabel1.font = [UIFont systemFontOfSize:12];
        _pointLabel1.textColor = OSSVThemesColors.col_131313;
        _pointLabel1.textAlignment = NSTextAlignmentCenter;
    }
    
    return _pointLabel1;
}

- (UILabel *)pointLabel2 {
    if (!_pointLabel2) {
        _pointLabel2 = [UILabel new];
        _pointLabel2.text = @":";
        _pointLabel2.backgroundColor = [OSSVThemesColors stlClearColor];
        _pointLabel2.font = [UIFont systemFontOfSize:12];
        _pointLabel2.textColor = OSSVThemesColors.col_131313;
        _pointLabel2.textAlignment = NSTextAlignmentCenter;
    }
    
    return _pointLabel2;
}


- (UILabel *)pointLabel3 {
    if (!_pointLabel3) {
        _pointLabel3 = [UILabel new];
        _pointLabel3.text = @"D";
        _pointLabel3.backgroundColor = [OSSVThemesColors stlClearColor];
        _pointLabel3.font = [UIFont systemFontOfSize:11];
        _pointLabel3.textColor = OSSVThemesColors.col_0D0D0D;
        _pointLabel3.textAlignment = NSTextAlignmentCenter;
    }
    
    return _pointLabel3;
}
- (void)updateTimeWithDay:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second endString:(NSString *)string{
    if (day < 1) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.secondLabel.hidden = YES;
            self.pointLabel1.hidden = YES;
            self.dayLabel.hidden = NO;
            self.pointLabel3.hidden = NO;

        }else {
            self.dayLabel.hidden = YES;
            self.pointLabel3.hidden = YES;
            self.secondLabel.hidden = NO;
            self.pointLabel1.hidden = NO;
            
            [self.dayLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(0);
            }];
            [self.pointLabel3 mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(0);
            }];
            
            [self.endLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.dayLabel.mas_leading).offset(-5);

            }];
        }
    }
    else {
        [self.dayLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(18);
        }];
        [self.pointLabel3 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(9);
        }];
        
        [self.endLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.dayLabel.mas_leading).offset(-10);

        }];

        self.secondLabel.hidden = NO;
        self.pointLabel1.hidden = NO;
        self.dayLabel.hidden = NO;
        self.pointLabel3.hidden = NO;
    }
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.secondLabel.text =  [NSString stringWithFormat:@"%02ld",(long)day];
        self.minuteLabel.text = [NSString stringWithFormat:@"%02ld",(long)hour];
        self.hourLabel.text = [NSString stringWithFormat:@"%02ld",(long)minute];
        self.dayLabel.text = [NSString stringWithFormat:@"%02ld",(long)second];
        self.pointLabel3.text = @":";
        self.pointLabel1.text = @"D";
        self.endLabel.text = string;
        [self.pointLabel3 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(4);
        }];
        
        [self.pointLabel1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(10);
        }];
        
    } else {
        self.hourLabel.text = [NSString stringWithFormat:@"%02ld",(long)hour];
        self.minuteLabel.text = [NSString stringWithFormat:@"%02ld",(long)minute];
        self.secondLabel.text = [NSString stringWithFormat:@"%02ld",(long)second];
        self.dayLabel.text =  [NSString stringWithFormat:@"%02ld",(long)day];
        self.endLabel.text = string;
        self.pointLabel3.text = @"D";
        self.pointLabel1.text = @":";
    }

}

@end
