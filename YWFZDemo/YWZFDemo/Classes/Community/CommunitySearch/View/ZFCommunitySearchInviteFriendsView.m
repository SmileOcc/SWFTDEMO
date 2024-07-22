//
//  ZFCommunitySearchInviteFriendsView.m
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//


#import "ZFCommunitySearchInviteFriendsView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFCommunitySearchInviteFriendsView () <ZFInitViewProtocol>

@property (nonatomic, strong) UIView                *contactContainerView;
@property (nonatomic, strong) UIView                *facebookContainerView;
@property (nonatomic, strong) UIImageView           *inviteContactImageView;
@property (nonatomic, strong) UIImageView           *inviteFacebookImageView;
@property (nonatomic, strong) UILabel               *inviteContactLabel;
@property (nonatomic, strong) UILabel               *inviteFacebookLabel;
@property (nonatomic, strong) UIView                *contactLineView;

@end

@implementation ZFCommunitySearchInviteFriendsView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)inviteContactViewAction:(id)sender {
    if (self.inviteContactCompletionHandler) {
        self.inviteContactCompletionHandler();
    }
}

- (void)inviteFacebookViewAction:(id)sender {
    if (self.inviteFacebookCompletionHandler) {
        self.inviteFacebookCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.contactContainerView];
    [self.contactContainerView addSubview:self.inviteContactImageView];
    [self.contactContainerView addSubview:self.inviteContactLabel];
    [self.contactContainerView addSubview:self.contactLineView];
    
    [self addSubview:self.facebookContainerView];
    [self.facebookContainerView addSubview:self.inviteFacebookImageView];
    [self.facebookContainerView addSubview:self.inviteFacebookLabel];
}

- (void)zfAutoLayoutView {
    [self.contactContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    [self.facebookContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contactContainerView.mas_bottom);
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    [self.inviteContactImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contactContainerView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.contactContainerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.inviteContactLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.inviteContactImageView.mas_trailing).offset(16);
        make.centerY.mas_equalTo(self.contactContainerView.mas_centerY);
        make.trailing.mas_equalTo(self.contactContainerView.mas_trailing);
    }];
    
    [self.contactLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.inviteContactImageView.mas_trailing).offset(16);
        make.height.mas_equalTo(1);
        make.trailing.mas_equalTo(self.contactContainerView.mas_trailing);
        make.bottom.mas_equalTo(self.contactContainerView.mas_bottom).offset(-1);
    }];
    
    [self.inviteFacebookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.facebookContainerView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.facebookContainerView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.inviteFacebookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.inviteFacebookImageView.mas_trailing).offset(16);
        make.centerY.mas_equalTo(self.facebookContainerView.mas_centerY);
        make.trailing.mas_equalTo(self.facebookContainerView.mas_trailing);
    }];
}

#pragma mark - getter
- (UIView *)contactContainerView {
    if (!_contactContainerView) {
        _contactContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _contactContainerView.backgroundColor = ZFCOLOR_WHITE;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteContactViewAction:)];
        [_contactContainerView addGestureRecognizer:tap];
    }
    return _contactContainerView;
}

- (UIView *)facebookContainerView {
    if (!_facebookContainerView) {
        _facebookContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _facebookContainerView.backgroundColor = ZFCOLOR_WHITE;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteFacebookViewAction:)];
        [_facebookContainerView addGestureRecognizer:tap];
    }
    return _facebookContainerView;
}

- (UIImageView *)inviteContactImageView {
    if (!_inviteContactImageView) {
        _inviteContactImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contacts"]];
    }
    return _inviteContactImageView;
}

- (UILabel *)inviteContactLabel {
    if (!_inviteContactLabel) {
        _inviteContactLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _inviteContactLabel.font = [UIFont systemFontOfSize:16];
        _inviteContactLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _inviteContactLabel.text = ZFLocalizedString(@"AddMoreFriends_Contacts",nil);
    }
    return _inviteContactLabel;
}

- (UIView *)contactLineView {
    if (!_contactLineView) {
        _contactLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _contactLineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _contactLineView;
}

- (UIImageView *)inviteFacebookImageView {
    if (!_inviteFacebookImageView) {
        _inviteFacebookImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fb"]];
    }
    return _inviteFacebookImageView;
}

- (UILabel *)inviteFacebookLabel {
    if (!_inviteFacebookLabel) {
        _inviteFacebookLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _inviteFacebookLabel.font = [UIFont systemFontOfSize:16];
        _inviteFacebookLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _inviteFacebookLabel.text = ZFLocalizedString(@"AddMoreFriends_FaceBook",nil);
    }
    return _inviteFacebookLabel;
}
@end
