//
//  OSSVCartHeaderFreeShippingView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/6/8.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCartHeaderFreeShippingView.h"
#import "YYText.h"

@interface OSSVCartHeaderFreeShippingView ()
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UIImageView *lineImageView;

@end
@implementation OSSVCartHeaderFreeShippingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentBgView];
        if (APP_TYPE == 3) {
            [self.rightButton addSubview:self.lineImageView];
            [self.contentBgView addSubview:self.progressBgView];
            [self.progressBgView addSubview:self.currentProgressView];
            
        } else {
            [self.contentBgView addSubview:self.shipCartImageView];
            [self.rightButton addSubview:self.arrowImageView];
        }
        
        [self.contentBgView addSubview:self.freeShippingLabel];
        [self.contentBgView addSubview:self.rightButton];
        [self addSubview:self.lineView];
        
        [self.rightButton addSubview:self.pickLabel];
    }
    return self;
}

- (UIView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [UIView new];
        if (APP_TYPE != 3) {
            _contentBgView.layer.cornerRadius = 6.f;
            _contentBgView.layer.masksToBounds = YES;
        }
        _contentBgView.backgroundColor = [UIColor whiteColor];
    }
    return _contentBgView;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_F7F7F7;

    }
    return _lineView;
}

- (UIImageView *)shipCartImageView {
    if (!_shipCartImageView) {
        _shipCartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ship_cart"]];
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _shipCartImageView.transform = CGAffineTransformMakeScale(-1.0,1.0);
//        }
    }
    return _shipCartImageView;
}

- (UILabel *)freeShippingLabel {
    if (!_freeShippingLabel) {
        _freeShippingLabel = [UILabel new];
        if (APP_TYPE == 3) {
            _freeShippingLabel.textColor = OSSVThemesColors.col_FF9318;
        } else {
            _freeShippingLabel.textColor = OSSVThemesColors.col_666666;
        }
        _freeShippingLabel.font = [UIFont systemFontOfSize:14];
    }
    return _freeShippingLabel;
}

- (UILabel *)pickLabel {
    if (!_pickLabel) {
        _pickLabel = [UILabel new];
        _pickLabel.text = STLLocalizedString_(@"Pick", nil);
        _pickLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _pickLabel.backgroundColor = [UIColor clearColor];
        if (APP_TYPE == 3) {
            _pickLabel.font = [UIFont systemFontOfSize:12];
        } else {
            _pickLabel.font = [UIFont boldSystemFontOfSize:12];
        }
    }
    return _pickLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightIcon_12*12"]];
        [_arrowImageView convertUIWithARLanguage]; //自动适配阿语翻转
    }
    return _arrowImageView;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.backgroundColor = [UIColor clearColor];
        [_rightButton addTarget:self action:@selector(intoSpecialVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        UIImage *backImg = STLImageWithName(@"spic_dash_line_black");
        UIColor*bcColor =[UIColor colorWithPatternImage:backImg];
        _lineImageView.backgroundColor = bcColor;
    }
    return _lineImageView;
}

- (UIView *)progressBgView {
    if (!_progressBgView) {
        _progressBgView = [[UIView alloc] init];
        _progressBgView.backgroundColor = [[OSSVThemesColors col_FF9318] colorWithAlphaComponent:0.12];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _progressBgView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _progressBgView;
}


- (UIView *)currentProgressView {
    if (!_currentProgressView) {
        _currentProgressView = [[UIView alloc] init];
        _currentProgressView.backgroundColor = [OSSVThemesColors col_FF9318];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _currentProgressView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _currentProgressView;
}

#pragma mark ----布局
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        if (APP_TYPE == 3) {
            make.height.equalTo(52);
        } else {
            make.height.equalTo(40);
        }
//        make.height.equalTo(40);

    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-12);
        if (APP_TYPE == 3) {
            make.top.mas_equalTo(self.contentBgView.mas_top).offset(13);
        } else {
            make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
        }
        make.height.equalTo(22);
        make.width.equalTo(60);
    }];
    
    
    if (APP_TYPE == 3) {
        [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.pickLabel);
            make.top.mas_equalTo(self.pickLabel.mas_bottom).offset(1);
            make.height.mas_equalTo(1);
        }];
    } else {
        [self.shipCartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(14);
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
        }];

        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.trailing.mas_equalTo(self.rightButton.mas_trailing);
            make.centerY.mas_equalTo(self.rightButton.mas_centerY);
        }];

    }
    
    [self.pickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.trailing.mas_equalTo(self.rightButton.mas_trailing);
            make.top.mas_equalTo(self.rightButton.mas_top).offset(0);
        } else {
            make.trailing.mas_equalTo(self.arrowImageView.mas_leading);
            make.centerY.mas_equalTo(self.rightButton.mas_centerY);
        }
        make.height.equalTo(14);
        
    }];

    
    [self.freeShippingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(14);
            make.top.mas_equalTo(self.contentBgView.mas_top).offset(12);
        } else {
            make.leading.mas_equalTo(self.shipCartImageView.mas_trailing).offset(5);
            make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
        }
        make.trailing.mas_equalTo(self.rightButton.mas_leading);
        make.height.equalTo(15);
    }];
    
    if (APP_TYPE == 3) {
        [self.progressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-14);
            make.bottom.mas_equalTo(self.contentBgView.mas_bottom).offset(-10);
            make.height.equalTo(6);
        }];
    }
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.contentBgView.mas_bottom);
        make.height.equalTo(8);
    }];
    
}


- (void)setProgress:(float)progress {
    _progress = progress;
    //异步处理，是为了 解决首次进入购物车，不展示进度的bug
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        self.currentProgressView.frame = CGRectMake(0, 0, self.progressBgView.width * self.progress, self.progressBgView.height);
    });

}
- (void)intoSpecialVC {
    if (_delegate && [_delegate respondsToSelector:@selector(rightButtonAction)]) {
        [_delegate rightButtonAction];
    }
}
@end
