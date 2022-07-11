//
//  OSSVTransporteSpliteView.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//  物流拆单View

#import "OSSVTransporteSpliteView.h"

@implementation OSSVTransporteSpliteView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.carImgBg];
        [self addSubview:self.trackCarImgView];
        [self addSubview:self.detail];
        [self addSubview:self.arrowImg];
    }
    return self;
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
        _trackCarImgView.image = [UIImage imageNamed:@"split_icon"];
    }
    return _trackCarImgView;
}

- (UILabel *)detail {
    if (!_detail) {
        _detail = [UILabel new];
        _detail.textColor = [OSSVThemesColors col_0D0D0D];
        _detail.font = [UIFont systemFontOfSize:14];
        _detail.numberOfLines = 2;
        _detail.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _detail.textAlignment = NSTextAlignmentRight;
        }
    }
    return _detail;
}

- (YYAnimatedImageView *)arrowImg {
    if (!_arrowImg) {
        _arrowImg = [YYAnimatedImageView new];
        [_arrowImg convertUIWithARLanguage]; //自动适配阿语翻转
        _arrowImg.image = [UIImage imageNamed:@"arrow_12"];
    }
    return _arrowImg;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.carImgBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.height.width.mas_equalTo(@20);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.trackCarImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.carImgBg);
        make.height.width.mas_equalTo(@12);
    }];

    [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        make.height.width.equalTo(@12);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];

    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.carImgBg.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.arrowImg.mas_leading).offset(-2);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];

}
@end
