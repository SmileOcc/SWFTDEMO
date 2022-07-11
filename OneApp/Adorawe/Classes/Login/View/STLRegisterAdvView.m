//
//  STLRegisterAdvView.m
// XStarlinkProject
//
//  Created by odd on 2021/4/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLRegisterAdvView.h"
#import "UIImage+Extend.h"

@implementation STLRegisterAdvView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImageView];
        [self addSubview:self.leftCircleImageView];
        [self addSubview:self.rightCircleImageView];
        [self addSubview:self.titleLabel];
        
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.leftCircleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.bgImageView.mas_trailing);
            make.centerY.mas_equalTo(self.bgImageView.mas_centerY);
        }];
        
        [self.rightCircleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgImageView.mas_leading);
            make.centerY.mas_equalTo(self.bgImageView.mas_centerY);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
    }
    return self;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.image = [UIImage resizeWithImageName:@"register_tip"];
    }
    return _bgImageView;
}

- (UIImageView *)leftCircleImageView {
    if (!_leftCircleImageView) {
        _leftCircleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _leftCircleImageView.image = [UIImage imageNamed:@"register_circle_left"];
        [_leftCircleImageView convertUIWithARLanguage];
    }
    return _leftCircleImageView;
}

- (UIImageView *)rightCircleImageView {
    if (!_rightCircleImageView) {
        _rightCircleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rightCircleImageView.image = [UIImage imageNamed:@"register_circle_right"];
        [_rightCircleImageView convertUIWithARLanguage];

    }
    return _rightCircleImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = OSSVThemesColors.col_B62B21;
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = @"xxxxfd fda";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end


@implementation STLRegisterAdvSmallView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImageView];
        [self addSubview:self.titleLabel];
        
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.bottom.mas_equalTo(self);
        }];
        
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    return self;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.image = [UIImage resizeWithImageName:@"account_register_tip"];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = OSSVThemesColors.col_B62B21;
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}
@end


