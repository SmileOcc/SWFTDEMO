//
//  OSSVLocationePopeView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/2/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVLocationePopeView.h"
@interface OSSVLocationePopeView ()
@property (nonatomic, strong) UIView   *contentView;
@property (nonatomic, strong) UIView   *contentBgView;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UILabel  *subTitleLabel;
@property (nonatomic, strong) UIButton *setingButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation OSSVLocationePopeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentBgView];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.setingButton];
        [self.contentView addSubview:self.cancelButton];
    }
    return self;
}

- (UIView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [UIView new];
        _contentBgView.backgroundColor = OSSVThemesColors.col_0D0D0D ;
        _contentBgView.alpha = 0.5;
        _contentBgView.frame = self.frame;
    }
    return _contentBgView;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.layer.cornerRadius = 4.f;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = STLLocalizedString_(@"LocationIsNotenabled", nil);
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.textColor = OSSVThemesColors.col_666666;
        _subTitleLabel.font = [UIFont systemFontOfSize:15];
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        _subTitleLabel.numberOfLines = 2;
        _subTitleLabel.text = STLLocalizedString_(@"OpenLocationTitle", nil);
    }
    return _subTitleLabel;
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = OSSVThemesColors.col_FFFFFF;
        if (APP_TYPE == 3) {
            [_cancelButton setTitle:STLLocalizedString_(@"cancel", nil).uppercaseString forState:UIControlStateNormal];
        } else {
            [_cancelButton setTitle:STLLocalizedString_(@"cancel", nil) forState:UIControlStateNormal];
        }
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_cancelButton setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
        _cancelButton.layer.cornerRadius = 2.f;
        _cancelButton.layer.borderColor = OSSVThemesColors.col_999999.CGColor;
        _cancelButton.layer.borderWidth = 1.f;
        _cancelButton.layer.masksToBounds = YES;
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)setingButton {
    if (!_setingButton) {
        _setingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _setingButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
        [_setingButton setTitle:STLLocalizedString_(@"Settings", nil).uppercaseString forState:UIControlStateNormal];
        _setingButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_setingButton setTitleColor:OSSVThemesColors.col_FFFFFF forState:UIControlStateNormal];
        _setingButton.layer.cornerRadius = 2.f;
        _setingButton.layer.masksToBounds = YES;
        [_setingButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setingButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(36);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-36);
        make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
        make.height.mas_equalTo(188*kScale_375);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(24);
        make.height.equalTo(18*kScale_375);
    }];
    
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.height.equalTo(36*kScale_375);
    }];

    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24);
        make.height.equalTo(44*kScale_375);
        make.width.equalTo(122*kScale_375);
    }];
    
    [self.setingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.titleLabel.mas_trailing);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-24);
        make.height.equalTo(44*kScale_375);
        make.width.equalTo(122*kScale_375);
    }];
}


-(void)showView {
    if (!self.superview) {
        [WINDOW addSubview:self];
        self.contentBgView.alpha = 0.0;
        self.contentView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
            self.contentBgView.alpha = 0.5;
        } completion:^(BOOL finished) {
            
        }];
    }
}


-(void)hiddenView
{
    [UIView animateWithDuration:.2 animations:^{
        self.contentBgView.alpha = 0.0;
        self.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)cancelAction {
//    [self hiddenView];
    if (_delegate && [_delegate respondsToSelector:@selector(cancelAction)]) {
        [self.delegate cancelAction];
    }

}

- (void)sureAction {
    if (_delegate && [_delegate respondsToSelector:@selector(jumpToSettings)]) {
        [self.delegate jumpToSettings];
    }
}

@end
