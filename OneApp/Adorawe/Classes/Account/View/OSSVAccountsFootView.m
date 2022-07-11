//
//  OSSVAccountsFootView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountsFootView.h"
#import "CacheFileManager.h"

@interface OSSVAccountsFootView ()

@property (nonatomic, strong) UIButton *signOutButton;

@end

@implementation OSSVAccountsFootView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.signOutButton];
        [self.signOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@12);
            make.leading.mas_equalTo(@(30));
            make.width.mas_equalTo(@(SCREEN_WIDTH - 60));
            make.height.mas_equalTo(@44);
        }];
    }
    return self;
}

- (void)signOutTouch:(UIButton *)sender {
    if (self.signOutBlock) {
        self.signOutBlock();
    }
}

#pragma mark - LazyLoad

- (UIButton *)signOutButton {
    if (!_signOutButton) {
        _signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signOutButton setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        [_signOutButton setTitle:[STLLocalizedString_(@"SignOut", nil) uppercaseString]  forState:UIControlStateNormal];
        _signOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _signOutButton.backgroundColor = [OSSVThemesColors col_ffffff:1];
        _signOutButton.layer.cornerRadius = 2;
        [_signOutButton addTarget:self action:@selector(signOutTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signOutButton;
}

@end
