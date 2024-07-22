//
//  AccountFooterView.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/28.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "AccountFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "Masonry.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface AccountFooterView () <ZFInitViewProtocol>

@property (nonatomic, strong) UIButton  *signOutButton;

@end

@implementation AccountFooterView
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
- (void)signOutButtonAction:(UIButton *)sender {
    if (self.signOutBlock) {
        self.signOutBlock();
    }
    // 谷歌统计
    [ZFAnalytics clickButtonWithCategory:@"Account" actionName:@"Account - Sign Out" label:@"Account - Sign Out"];
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [self addSubview:self.signOutButton];
}

- (void)zfAutoLayoutView {
    [self.signOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(36);
        make.height.mas_equalTo(40);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
}


-(UIButton *)signOutButton {
    if (!_signOutButton) {
        _signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signOutButton.layer.cornerRadius = 3;
        _signOutButton.layer.masksToBounds = YES;
        //_signOutButton.backgroundColor = ZFCThemeColor();
        _signOutButton.backgroundColor = [UIColor whiteColor];
//        [_signOutButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_signOutButton setBackgroundColor:ZFCThemeColor_A(0.8) forState:UIControlStateHighlighted];
        _signOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_signOutButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_signOutButton setTitle:ZFLocalizedString(@"Account_SignOut_Button",nil) forState:UIControlStateNormal];
        [_signOutButton addTarget:self action:@selector(signOutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signOutButton;
}

@end
