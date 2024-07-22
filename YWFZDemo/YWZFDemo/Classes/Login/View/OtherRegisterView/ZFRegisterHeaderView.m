//
//  ZFRegisterHeaderView.m
//  ZZZZZ
//
//  Created by YW on 28/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRegisterHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFRegisterHeaderView ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *avatar;
@property (nonatomic, copy)   UILabel               *warmPromptLabel;
@end

@implementation ZFRegisterHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.warmPromptLabel];
}

- (void)zfAutoLayoutView {
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.centerX.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(75, 75));
    }];
    
    [self.warmPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatar.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo(KScreenWidth - 73);
    }];
}

#pragma mark - Setter
- (void)setAvatarURL:(NSString *)avatarURL {
    _avatarURL = avatarURL;
    
}

#pragma mark - Getter
- (YYAnimatedImageView *)avatar {
    if (!_avatar) {
        _avatar = [[YYAnimatedImageView alloc] init];
        _avatar.layer.cornerRadius = 37.5;
        _avatar.layer.masksToBounds = YES;
        _avatar.image = [UIImage imageNamed:@"account_head"];
    }
    return _avatar;
}

- (UILabel *)warmPromptLabel {
    if (!_warmPromptLabel) {
        _warmPromptLabel = [[UILabel alloc] init];
        _warmPromptLabel.font = ZFFontSystemSize(14);
        _warmPromptLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _warmPromptLabel.numberOfLines = 0;
        _warmPromptLabel.preferredMaxLayoutWidth = KScreenWidth - 73;
        _warmPromptLabel.textAlignment = NSTextAlignmentCenter;
        _warmPromptLabel.backgroundColor = ZFCOLOR_WHITE;
        _warmPromptLabel.text = ZFLocalizedString(@"warmPrompt", nil);
    }
    return _warmPromptLabel;
}

@end
