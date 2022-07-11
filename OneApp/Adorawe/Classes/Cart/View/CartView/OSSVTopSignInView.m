//
//  OSSVTopSignInView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVTopSignInView.h"

@interface OSSVTopSignInView ()
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *signInButton;
@end

@implementation OSSVTopSignInView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.signInButton];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel  new];
        if (APP_TYPE == 3) {
            _titleLabel.textColor = OSSVThemesColors.stlWhiteColor;
        } else {
            _titleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        }
        
        _titleLabel.font      = [UIFont systemFontOfSize:12];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _titleLabel.textAlignment = NSTextAlignmentLeft;
        }
        _titleLabel.text = STLLocalizedString_(@"TopSignIn", nil);
    }
    return _titleLabel;
}

- (UIButton *)signInButton {
    if (!_signInButton) {
        _signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            [_signInButton setTitle:STLLocalizedString_(@"sws_login", nil) forState:UIControlStateNormal];
        } else {
            [_signInButton setTitle:STLLocalizedString_(@"sws_login", nil).uppercaseString forState:UIControlStateNormal];
        }
        
        
        if (APP_TYPE == 3) {
            _signInButton.backgroundColor = OSSVThemesColors.stlWhiteColor;
            [_signInButton setTitleColor:OSSVThemesColors.stlBlackColor forState:UIControlStateNormal];
            _signInButton.titleLabel.font = [UIFont systemFontOfSize:12];
        } else {
            _signInButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
            [_signInButton setTitleColor:OSSVThemesColors.stlWhiteColor forState:UIControlStateNormal];
            _signInButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        }
        [_signInButton addTarget:self action:@selector(jumpSign:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signInButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.signInButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.mas_centerY);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            make.size.equalTo(CGSizeMake(80, 28));
        } else {
            make.size.equalTo(CGSizeMake(60, 28));
        }
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.top.bottom.mas_equalTo(self);
        make.trailing.mas_equalTo(self.signInButton.mas_leading).offset(-2);
    }];
}

- (void)jumpSign:(id)sender {
    
    if (self.jumpIntoSignViewController) {
        self.jumpIntoSignViewController();
    }
}
@end
