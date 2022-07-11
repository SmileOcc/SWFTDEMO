//
//  YXStockDetailTopTipView.m
//  uSmartOversea
//
//  Created by 陈明茂 on 2019/5/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockDetailTopTipView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
@interface YXStockDetailTopTipView ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *tipBtn;

@end

@implementation YXStockDetailTopTipView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.backgroundColor = [QMUITheme noticeBackgroundColor];
    self.clipsToBounds = YES;
    [self addSubview:self.iconView];
    [self addSubview:self.closeButton];
    [self addSubview:self.tipBtn];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.mas_equalTo(30);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.height.top.equalTo(self);
        make.width.mas_equalTo(40);
    }];
    
    [self.tipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.closeButton.mas_left).offset(5);
        make.centerY.equalTo(self);
        make.left.equalTo(self.iconView.mas_right).offset(5);
    }];
    
   
}

- (void)resetTitle {
    if (self.isTrade && self.isTradeBmp) {
        [self.tipBtn setTitle:[YXLanguageUtility kLangWithKey:@"trading_bmp_tips"] forState:UIControlStateNormal];
    } else {
        [self.tipBtn setTitle:[YXLanguageUtility kLangWithKey:@"trading_delay_tips"] forState:UIControlStateNormal];
    }
}

- (void)closeButtonAction {
    if (self.isTrade) {
        [YXUserManager shared].isTradeTipsHide = YES;
    }else {
        [YXUserManager shared].isBMPTipsHide = YES;
    }
    if (self.closeCallBack) {
        self.closeCallBack();
    }
}

- (void)tipBtnDidClick:(UIButton *)sender {
    
    YXAlertView *alertView = [YXAlertView alertViewWithMessage:self.tipBtn.currentTitle];
    alertView.messageLabel.font = [UIFont systemFontOfSize:16];
    alertView.messageLabel.textAlignment = NSTextAlignmentLeft;
    [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
        
    }]];
    [alertView showInWindow];
}

#pragma mark - 懒加载
- (UIButton *)tipBtn {
    if (_tipBtn == nil) {
        _tipBtn = [[UIButton alloc] init];
        _tipBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_tipBtn setTitleColor:[QMUITheme noticeTextColor] forState:UIControlStateNormal];
        [_tipBtn setTitle:[YXLanguageUtility kLangWithKey:@"trading_bmp_tips"] forState:UIControlStateNormal];
        _tipBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _tipBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_tipBtn addTarget:self action:@selector(tipBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tipBtn;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        _iconView.image = [[UIImage imageNamed:@"trade_notice"] qmui_imageWithTintColor:[QMUITheme noticeTextColor]];
    }
    return _iconView;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom image:[[UIImage imageNamed:@"trade_notice_close"] qmui_imageWithTintColor:[QMUITheme noticeTextColor]] target:self action:@selector(closeButtonAction)];
    }
    return _closeButton;
}


@end
