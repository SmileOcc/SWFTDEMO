
//
//  ZFAccountInfoHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

/*
 * 备注：个人中心顶部Header
 * 根据是否登陆进行UI布局。
 * 非登陆情况，仅有登陆按钮。App标示语
 * 登陆情况下，有Z-Me 社区个人中心页面入口，以及修改个人资料入口，和用户头像 用户名信息等。
 */

#import "ZFAccountInfoHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "AccountManager.h"
#import "Constants.h"

@interface ZFAccountInfoHeaderView() <ZFInitViewProtocol>

@property (nonatomic, strong) YYAnimatedImageView   *headerImagewView;
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) UIImageView           *avatorView;
@property (nonatomic, strong) UILabel               *welcomeLabel;
@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UIButton              *signButton;
@property (nonatomic, strong) UIButton              *editProfileButton;
@property (nonatomic, strong) UIButton              *zmeHomeButton;
@property (nonatomic, strong) UILabel               *guestTipsLabel;
@property (nonatomic, strong) UIButton              *guestTipsButton;
@property (nonatomic, strong) UIImageView           *studentMarkIcon;

@property (nonatomic, strong) YYAnimatedImageView   *birthdayIcon;
@end

@implementation ZFAccountInfoHeaderView

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
- (void)signButtonAction:(UIButton *)sender {
    if (self.accountInfoHeaderActionCompletionHandler) {
        self.accountInfoHeaderActionCompletionHandler(ZFAccountInfoHeaderOptionTypeSign);
    }
}

- (void)editProfileButtonAction:(UIButton *)sender {
    if (self.accountInfoHeaderActionCompletionHandler) {
        self.accountInfoHeaderActionCompletionHandler(ZFAccountInfoHeaderOptionTypeEditProfile);
    }
}

- (void)zmeHomeButtonAction:(UIButton *)sender {
    if (self.accountInfoHeaderActionCompletionHandler) {
        self.accountInfoHeaderActionCompletionHandler(ZFAccountInfoHeaderOptionTypeZmeHome);
    }
}

- (void)guestTipsButtonAction {
    NSString *title = ZFLocalizedString(@"GameLogin_GuestUser", nil);
    NSString *message = ZFLocalizedString(@"GameLogin_GuestUserTips", nil);
    NSString *cancelTitle = ZFLocalizedString(@"OK", nil);
    ShowAlertView(title, message, nil, ^(NSInteger buttonIndex, id buttonTitle) {}, cancelTitle, nil);
}

/**
 * 换肤: 更新头部背景图片和登录状态的信息字体颜色
 */
- (void)changeAccountHeadInfoViewSkin {
    if (![AccountManager sharedManager].needChangeAppSkin) return;

    UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
    UIImage *headImage = [AccountManager sharedManager].appAccountHeadImage;
    BOOL hasChange = [self.headerImagewView zfChangeCustomViewSkin:navBgColor skinImage:headImage];
    if (!hasChange) { // 复原头部背景图
        self.headerImagewView.image = [UIImage imageNamed:@"account_home_headerTopbg"];
    }

    UIColor *titleColor = [AccountManager sharedManager].appNavFontColor;
    if ([AccountManager sharedManager].isSignIn) {  //登陆状态
        self.nameLabel.textColor = titleColor;
        UIColor *btnColor = [titleColor colorWithAlphaComponent:0.5];
        [self.editProfileButton setTitleColor:btnColor forState:UIControlStateNormal];

    } else {  //非登陆状态
        self.welcomeLabel.textColor = titleColor;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.headerImagewView];
    [self addSubview:self.contentView];
    
    if ([AccountManager sharedManager].isSignIn) {  //登陆状态
        if ([AccountManager sharedManager].account.student_level > 0) {
            //学生卡用户
            [self.contentView addSubview:self.studentMarkIcon];
        }
        [self.contentView addSubview:self.avatorView];
        
        [self.contentView addSubview:self.zmeHomeButton];
        if ([AccountManager sharedManager].account.is_guest == 1) {
            [self.contentView addSubview:self.guestTipsLabel];
            [self.contentView addSubview:self.guestTipsButton];
        }
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.editProfileButton];
        
        NSString *birthday = [AccountManager sharedManager].account.birthday;
        NSString *title = nil;
        if (ZFIsEmptyString(birthday)) {
            [self.contentView addSubview:self.birthdayIcon];
            title = ZFLocalizedString(@"Account_birthday_gain", nil);
        } else {
            title = ZFLocalizedString(@"Account_View_and_edit_profile", nil);
        }
        [self.editProfileButton setTitle:title forState:UIControlStateNormal];
    } else {    //非登陆状态
        [self.contentView addSubview:self.welcomeLabel];
        [self.contentView addSubview:self.signButton];
    }
}

- (void)zfAutoLayoutView {
    [self.headerImagewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(300);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    if ([AccountManager sharedManager].isSignIn) {  //登陆状态
        [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        
        self.avatorView.layer.cornerRadius = 40;
        
        if ([AccountManager sharedManager].account.student_level > 0) {
            //学生卡
            [self.studentMarkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.avatorView.mas_trailing).mas_offset(14);
                make.bottom.mas_equalTo(self.avatorView.mas_top).mas_offset(25);
                make.size.mas_equalTo(CGSizeMake(64, 46));
            }];
        }
        
        if ([AccountManager sharedManager].account.is_guest == 1) {
            //游客登录布局
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.avatorView.mas_centerY).offset(4);
                make.leading.mas_equalTo(self.avatorView.mas_trailing).offset(12);
                make.width.mas_equalTo(KScreenWidth/2.5);
            }];
            
            [self.editProfileButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.avatorView.mas_centerY).offset(12);
                make.leading.mas_equalTo(self.avatorView.mas_trailing).offset(12);
                make.trailing.mas_equalTo(self.zmeHomeButton.mas_leading).mas_offset(-10);
            }];
        }else{
            //正常用户布局
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.avatorView.mas_top).offset(28);
                make.leading.mas_equalTo(self.avatorView.mas_trailing).offset(12);
                make.width.mas_equalTo(KScreenWidth/2.5);
            }];
            
            [self.editProfileButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.avatorView.mas_bottom).offset(-28);
                make.leading.mas_equalTo(self.avatorView.mas_trailing).offset(12);
                make.trailing.mas_equalTo(self.zmeHomeButton.mas_leading).mas_offset(-10);
            }];
        }
        [self.zmeHomeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.avatorView);
            make.trailing.mas_equalTo(self.contentView).offset(18);
            make.size.mas_equalTo(CGSizeMake(90, 30));
        }];
        
        if ([AccountManager sharedManager].account.is_guest == 1) {
            [self.guestTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.nameLabel);
                make.bottom.mas_equalTo(self.nameLabel.mas_top);
            }];
            
            [self.guestTipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.guestTipsLabel.mas_trailing).mas_offset(5);
                make.centerY.mas_equalTo(self.guestTipsLabel);
            }];
        }
        
        //如果用户没有填写生日
        NSString *birthday = [AccountManager sharedManager].account.birthday;
        if (ZFIsEmptyString(birthday)) {
            [self.editProfileButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.birthdayIcon.mas_trailing).mas_offset(4);
                make.centerY.mas_equalTo(self.birthdayIcon.mas_centerY).offset(2);
                make.trailing.mas_equalTo(self.zmeHomeButton.mas_leading).mas_offset(-10);
            }];
            
            [self.birthdayIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.avatorView.mas_bottom).offset(-28);
                make.leading.mas_equalTo(self.avatorView.mas_trailing).offset(12);
                make.size.mas_offset(CGSizeMake(22, 22));
            }];
        }
        
    } else {
        [self.signButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-25);
            make.height.mas_equalTo(35);
        }];
        
        [self.welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.signButton.mas_top).offset(-12);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentView);
        }];
    }
}

#pragma mark - setter
- (void)setShowType:(ZFAccountInfoStatusType)showType {
    _showType = showType;
    //根据登陆和非登陆，布局界面。当外部切换登陆状态的时候，通过该setter方法，切换页面布局。
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self zfInitView];
    [self zfAutoLayoutView];
    
    //显示赋值
    if (_showType == ZFAccountInfoStatusTypeLogin) {
        [self.avatorView  yy_setImageWithURL:[NSURL URLWithString:[AccountManager sharedManager].account.avatar]
                                    placeholder:[UIImage imageNamed:@"account_head"]
                                         options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                        progress:nil
                                       transform:nil
                                      completion:nil];
        
        self.nameLabel.text = [AccountManager sharedManager].account.nickname;
    }
}

- (void)setEditAvatorImage:(UIImage *)editAvatorImage {
    _editAvatorImage = editAvatorImage;
    self.avatorView.image = _editAvatorImage;
}

#pragma mark - getter
- (YYAnimatedImageView *)headerImagewView {
    if (!_headerImagewView) {
        _headerImagewView = [[YYAnimatedImageView alloc] init];
        _headerImagewView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImagewView.userInteractionEnabled = YES;
        _headerImagewView.clipsToBounds = YES;
        _headerImagewView.image = [UIImage imageNamed:@"account_home_headerTopbg"];
    }
    return _headerImagewView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (UIImageView *)avatorView {
    if (!_avatorView) {
        _avatorView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatorView.layer.cornerRadius = 40;
        _avatorView.clipsToBounds = YES;
        _avatorView.image = [UIImage imageNamed:@"account_head"];
        _avatorView.userInteractionEnabled = YES;
        @weakify(self);
        [_avatorView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.accountInfoHeaderActionCompletionHandler) {
                self.accountInfoHeaderActionCompletionHandler(ZFAccountInfoHeaderOptionTypeChangeAvator);
            }
        }];
    }
    return _avatorView;
}

- (UILabel *)welcomeLabel {
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _welcomeLabel.font = [UIFont systemFontOfSize:24];
        _welcomeLabel.textColor = ZFCOLOR_WHITE;
        _welcomeLabel.text = ZFLocalizedString(@"Account_Welcome_ZZZZZ", nil);
        if ([SystemConfigUtils isRightToLeftLanguage]) {
            _welcomeLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _welcomeLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = ZFCOLOR_WHITE;
        _nameLabel.font = [UIFont boldSystemFontOfSize:18];
        if ([SystemConfigUtils isRightToLeftLanguage]) {
            _nameLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _nameLabel;
}

- (UIButton *)signButton {
    if (!_signButton) {
        _signButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signButton.layer.cornerRadius = 2;
        _signButton.layer.masksToBounds = YES;
        _signButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _signButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        [_signButton setTitle:ZFLocalizedString(@"Account_SignIn_SignUp", nil) forState:UIControlStateNormal];
        [_signButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_signButton setTitleColor:ZFC0x2D2D2D_05() forState:UIControlStateHighlighted];
        _signButton.backgroundColor = ZFCOLOR_WHITE;
        [_signButton addTarget:self action:@selector(signButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signButton;
}

- (UIButton *)editProfileButton {
    if (!_editProfileButton) {
        _editProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editProfileButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _editProfileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _editProfileButton.titleLabel.numberOfLines = 0;
        [_editProfileButton setTitle:ZFLocalizedString(@"Account_View_and_edit_profile", nil) forState:UIControlStateNormal];
        [_editProfileButton setTitleColor:ZFCOLOR(255, 255, 255, 0.6) forState:UIControlStateNormal];
        [_editProfileButton setTitleColor:ZFCOLOR(255, 255, 255, 0.9) forState:UIControlStateHighlighted];
        [_editProfileButton addTarget:self action:@selector(editProfileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if ([SystemConfigUtils isRightToLeftLanguage]) {
            _editProfileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
    return _editProfileButton;
}

- (UIButton *)zmeHomeButton {
    if (!_zmeHomeButton) {
        _zmeHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zmeHomeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];        
        [_zmeHomeButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_zmeHomeButton setTitleColor:[ZFCOLOR_WHITE colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        _zmeHomeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_zmeHomeButton addTarget:self action:@selector(zmeHomeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _zmeHomeButton.backgroundColor = [UIColor colorWithHex:0x000000 alpha:.4f];
        [_zmeHomeButton setImage:[UIImage imageNamed:@"account_zme"] forState:UIControlStateNormal];
        [_zmeHomeButton setTitle:ZFLocalizedString(@"Account_TopInfo_ZmeHome", nil) forState:UIControlStateNormal];
        _zmeHomeButton.layer.cornerRadius = 15;
        [_zmeHomeButton zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:3];
        [_zmeHomeButton convertUIWithARLanguage];
    }
    return _zmeHomeButton;
}

-(UILabel *)guestTipsLabel {
    if (!_guestTipsLabel) {
        _guestTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"GameLogin_GuestUser", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = ZFCOLOR_WHITE;
            label.font = [UIFont systemFontOfSize:18];
            label;
        });
    }
    return _guestTipsLabel;
}

- (UIButton *)guestTipsButton {
    if (!_guestTipsButton) {
        _guestTipsButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setEnlargeEdge:20];
            [button setImage:ZFImageWithName(@"nationalID") forState:UIControlStateNormal];
            [button addTarget:self action:@selector(guestTipsButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _guestTipsButton;
}

-(UIImageView *)studentMarkIcon
{
    if (!_studentMarkIcon) {
        _studentMarkIcon = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = ZFImageWithName(@"studentMark");
            if ([SystemConfigUtils isRightToLeftShow]) {
                imageView.image = ZFImageWithName(@"studentMark_ar");
            }
            imageView;
        });
    }
    return _studentMarkIcon;
}

-(YYAnimatedImageView *)birthdayIcon
{
    if (!_birthdayIcon) {
        _birthdayIcon = [[YYAnimatedImageView alloc] init];
        _birthdayIcon.image = [YYImage imageNamed:@"jumpGift.gif"];
    }
    return _birthdayIcon;
}

@end
