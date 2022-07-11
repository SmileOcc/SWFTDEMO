//
//  OSSVOrdereTrackeeView.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//    ----------------订单详情中物流状态的veiw---------------

#import "OSSVOrdereTrackeeView.h"

@implementation OSSVOrdereTrackeeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.carImgBg];
        [self addSubview:self.transitLabel];
        [self addSubview:self.tradingStatusLabel];
        [self addSubview:self.trackCodeNum];
        [self addSubview:self.addressImg];
        [self addSubview:self.addressLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.arrowImg];
        [self.carImgBg addSubview:self.trackCarImgView];
        [self addSubview:self.noOrderLabel];

    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
//    [self.carImgBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.mas_leading).offset(12);
//        make.height.width.mas_equalTo(@24);
//        make.centerY.mas_equalTo(self.mas_centerY);
//    }];
//
//    [self.trackCarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.carImgBg.mas_top).offset(4);
//        make.leading.mas_equalTo(self.carImgBg.mas_leading).offset(4);
//        make.height.width.mas_equalTo(@16);
//    }];
//
//    [self.transitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.mas_leading).offset(44);
//        make.top.mas_equalTo(self.mas_top).offset(12);
//        make.height.equalTo(@15);
//    }];
//
//    [self.tradingStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.transitLabel.mas_leading);
//        make.top.mas_equalTo(self.transitLabel.mas_bottom).offset(5);
//        make.height.equalTo(@13);
//    }];
    
    [self.carImgBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        make.height.width.mas_equalTo(@20);
        make.top.mas_equalTo(self.mas_top).offset(14);
    }];

    [self.trackCarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.carImgBg);
        make.height.width.mas_equalTo(@12);
    }];
    
    [self.transitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.carImgBg.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.carImgBg.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
    }];
    
    [self.tradingStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.arrowImg.mas_leading).offset(-2);
        make.top.mas_equalTo(self.carImgBg.mas_bottom).offset(8);
    }];
    
    [self.addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        make.top.mas_equalTo(self.tradingStatusLabel.mas_bottom).offset(6);
        make.height.width.equalTo(@12);
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressImg.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.tradingStatusLabel.mas_trailing);
        make.centerY.mas_equalTo(self.addressImg.mas_centerY);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(14);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-14);
    }];
    
    [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        make.height.width.equalTo(@12);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.trackCodeNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImg.mas_leading);
        make.top.mas_equalTo(self.mas_top).offset(14);
    }];
    
    [self.noOrderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        make.centerY.mas_equalTo(self.carImgBg.mas_centerY);
    }];
}


- (UIView *)carImgBg {
    if (!_carImgBg) {
        _carImgBg = [UIView new];
        _carImgBg.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _carImgBg.layer.cornerRadius = 10.f;
        _carImgBg.layer.masksToBounds = YES;
    }
    return _carImgBg;
}

- (UIImageView *)trackCarImgView {
    if (!_trackCarImgView) {
        _trackCarImgView = [UIImageView new];
        _trackCarImgView.image = [UIImage imageNamed:@"car_icon"];
    }
    return _trackCarImgView;
}

- (UILabel *)transitLabel {
    if (!_transitLabel) {
        _transitLabel = [UILabel new];
        _transitLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _transitLabel.font = [UIFont boldSystemFontOfSize:14];
        _transitLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _transitLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _transitLabel;
}

- (UILabel *)tradingStatusLabel {
    if (!_tradingStatusLabel) {
        _tradingStatusLabel = [UILabel new];
        _tradingStatusLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _tradingStatusLabel.font = [UIFont systemFontOfSize:14];
        _tradingStatusLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _tradingStatusLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _tradingStatusLabel;
}

- (UILabel *)trackCodeNum {
    if (!_trackCodeNum) {
        _trackCodeNum = [UILabel new];
        _trackCodeNum.textColor = [OSSVThemesColors col_6C6C6C];
        _trackCodeNum.font = [UIFont systemFontOfSize:12];
        _trackCodeNum.textAlignment = NSTextAlignmentRight;
    }
    return _trackCodeNum;
}

- (UILabel *)noOrderLabel {
    if (!_noOrderLabel) {
        _noOrderLabel = [UILabel new];
        _noOrderLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _noOrderLabel.font = [UIFont systemFontOfSize:12];
        _noOrderLabel.textAlignment = NSTextAlignmentRight;
        _noOrderLabel.hidden = YES;
        _noOrderLabel.text = STLLocalizedString_(@"NoTrackingNumber", nil);
    }
    return _noOrderLabel;
}

- (YYAnimatedImageView *)addressImg {
    if (!_addressImg) {
        _addressImg = [YYAnimatedImageView new];
        _addressImg.image = [UIImage imageNamed:@"logistics_address12" ];
    }
    return _addressImg;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [UILabel new];
        _addressLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _addressLabel.font = [UIFont systemFontOfSize:13];
        
        _addressLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _addressLabel.textAlignment = NSTextAlignmentRight;
        }
        
    }
    return _addressLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _timeLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _timeLabel;
}

- (YYAnimatedImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [YYAnimatedImageView new];
        [_arrowImg convertUIWithARLanguage]; //自动适配阿语翻转
        _arrowImg.image = [UIImage imageNamed:@"arrow_12"];
    }
    return _arrowImg;
}

@end
