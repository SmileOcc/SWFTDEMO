

//
//  ZFCartNoDataEmptyView.m
//  Zaful
//
//  Created by liuxi on 2017/9/20.
//  Copyright © 2017年 Y001. All rights reserved.
//

#import "ZFCarPiecingOrderBottomView.h"
#import "ZFInitViewProtocol.h"

@interface ZFCarPiecingOrderBottomView () <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UILabel               *emptyTipsLabel;
@property (nonatomic, strong) UIButton              *continueShopButton;
@property (nonatomic, strong) UIView                *lineView;

@end

@implementation ZFCarPiecingOrderBottomView
#pragma mark - init methods 
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)continueShopButtonAction:(UIButton *)sender {
    if (self.cartNoDataContinueShopCompletionHandler) {
        self.cartNoDataContinueShopCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.iconImageView];
    [self addSubview:self.emptyTipsLabel];
    [self addSubview:self.continueShopButton];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    
    [self.emptyTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.emptyTipsLabel.mas_bottom).offset(-16);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.continueShopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyTipsLabel.mas_bottom).offset(28);
        make.size.mas_equalTo(CGSizeMake(224, 44));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(12);
    }];
}

#pragma mark - setter
- (void)setHasSepareLine:(BOOL)hasSepareLine {
    _hasSepareLine = hasSepareLine;
    self.lineView.hidden = !_hasSepareLine;
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blankPage_noCart"]];
    }
    return _iconImageView;
}

- (UILabel *)emptyTipsLabel {
    if (!_emptyTipsLabel) {
        _emptyTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyTipsLabel.font = [UIFont systemFontOfSize:16];
        _emptyTipsLabel.textAlignment = NSTextAlignmentCenter;
        _emptyTipsLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _emptyTipsLabel.text = ZFLocalizedString(@"CartViewModel_NoData_TitleLabel", nil);
    }
    return _emptyTipsLabel;
}

- (UIButton *)continueShopButton {
    if (!_continueShopButton) {
        _continueShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_continueShopButton setTitle:ZFLocalizedString(@"CartViewModel_NoData_TitleButton", nil) forState:UIControlStateNormal];
        [_continueShopButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _continueShopButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _continueShopButton.backgroundColor = ZFCOLOR_BLACK;
        [_continueShopButton addTarget:self action:@selector(continueShopButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _continueShopButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    }
    return _lineView;
}
@end
