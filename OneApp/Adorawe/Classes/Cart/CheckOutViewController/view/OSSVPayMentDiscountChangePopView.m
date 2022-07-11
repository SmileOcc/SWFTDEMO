//
//  OSSVPayMentDiscountChangePopView.m
// XStarlinkProject
//
//  Created by Kevin on 2020/12/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVPayMentDiscountChangePopView.h"
@interface OSSVPayMentDiscountChangePopView ()
@property (nonatomic, strong) UIView   *contentView;
@property (nonatomic, strong) UIView   *contentBgView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *okButton;
@end

@implementation OSSVPayMentDiscountChangePopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentBgView];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.okButton];
    }
    return self;
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
        make.height.mas_equalTo(152*kScale_375);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(24*kScale_375);
        make.height.equalTo(36*kScale_375);
    }];
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentLabel.mas_trailing);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(24*kScale_375);
        make.height.equalTo(44*kScale_375);
    }];
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


- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.text = STLLocalizedString_(@"payMentDiscountChange", nil);
        _contentLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 2;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLabel;
}

- (UIButton *)okButton {
    if (!_okButton) {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okButton setBackgroundColor:OSSVThemesColors.col_0D0D0D];
        if (APP_TYPE == 3) {
            [_okButton setTitle:STLLocalizedString_(@"ok", nil) forState:UIControlStateNormal];
        } else {
            [_okButton setTitle:STLLocalizedString_(@"ok", nil).uppercaseString forState:UIControlStateNormal];

        }
        [_okButton setTitleColor:OSSVThemesColors.col_FFFFFF forState:UIControlStateNormal];
        _okButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _okButton.layer.cornerRadius = 2.f;
        _okButton.layer.masksToBounds = YES;
        [_okButton addTarget:self action:@selector(makeSureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}


- (void)makeSureAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(updateOrderMakeSure)]) {
        [_delegate updateOrderMakeSure];
    }
    [self hiddenView];
}
#pragma mark ---私有方法
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

@end
