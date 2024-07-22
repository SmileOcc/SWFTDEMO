//
//  ZFNoNetEmptyView.m
//  ZZZZZ
//
//  Created by YW on 2017/9/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFNoNetEmptyView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFNoNetEmptyView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UILabel               *noNetTipsLabel;
@property (nonatomic, strong) UIButton              *reloadButton;
@end;

@implementation ZFNoNetEmptyView
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
- (void)reloadButtonAction:(UIButton *)sender {
    if (self.noNetEmptyReRequestCompletionHandler) {
        self.noNetEmptyReRequestCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.iconImageView];
    [self addSubview:self.noNetTipsLabel];
    [self addSubview:self.reloadButton];
}

- (void)zfAutoLayoutView {

    
    [self.noNetTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.leading.trailing.mas_equalTo(self);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.noNetTipsLabel.mas_top).offset(-36);
    }];
    
    [self.reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.noNetTipsLabel.mas_bottom).offset(36);
        make.height.mas_equalTo(45);
        make.leading.mas_equalTo(self.mas_leading).offset(28);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-28);
    }];
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blankPage_requestFail"]];
    }
    return _iconImageView;
}

- (UILabel *)noNetTipsLabel {
    if (!_noNetTipsLabel) {
        _noNetTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noNetTipsLabel.font = [UIFont systemFontOfSize:16];
        _noNetTipsLabel.textColor = ZFCOLOR(45, 45, 45, 1.0f);
        _noNetTipsLabel.textAlignment = NSTextAlignmentCenter;
        _noNetTipsLabel.numberOfLines = 2;
        _noNetTipsLabel.text = ZFLocalizedString(@"Global_NO_NET_404", nil);
    }
    return _noNetTipsLabel;
}

- (UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.backgroundColor = ZFCOLOR_BLACK;
        [_reloadButton setTitle:ZFLocalizedString(@"Base_VC_ShowAgain_TitleLabel", nil) forState:UIControlStateNormal];
        [_reloadButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _reloadButton.contentEdgeInsets = UIEdgeInsetsMake(14, 30, 14, 30);
    }
    return _reloadButton;
}
@end
