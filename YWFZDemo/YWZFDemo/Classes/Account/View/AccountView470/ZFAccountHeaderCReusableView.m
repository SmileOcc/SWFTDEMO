//
//  ZFAccountHeaderCReusableView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountHeaderCReusableView.h"
#import "Constants.h"
#import "YSAlertView.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "AccountManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"

#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UINavigationItem+ZFChangeSkin.h"

#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>
#import "UIImage+ZFExtended.h"
#import "NSString+Extended.h"
#import "ZFMyOrderListTopMessageView.h"
#import "ZFPushManager.h"

@interface ZFAccountHeaderCReusableView ()

@property (nonatomic, strong) YYAnimatedImageView   *headerImagewView;
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) UILabel               *welcomeLabel;
@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UIButton              *signButton;
@property (nonatomic, strong) UIButton              *editProfileButton;
@property (nonatomic, strong) UIButton              *zmeHomeButton;
@property (nonatomic, strong) UILabel               *guestTipsLabel;
@property (nonatomic, strong) UIButton              *guestTipsButton;
@property (nonatomic, strong) UIImageView           *studentMarkIcon;

@end

@implementation ZFAccountHeaderCReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showType = ZFNewAccountInfoStatusTypeNormal;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFCClearColor();
    [self addSubview:self.headerImagewView];
    [self addSubview:self.contentView];
    if ([ZFPushManager canShowAlertViewWithKey:kAccountShowNotificationAlertTimestamp time:7]) {
        [self.contentView addSubview:self.topMessageView];
        self.topMessageView.hidden = NO;
    }
    CGFloat notificationsTipHeight = [ZFPushManager canShowAlertViewWithKey:kAccountShowNotificationAlertTimestamp time:7] ? 44 : 0;
    self.frame = CGRectMake(0, 0, KScreenWidth, 116 + 44 + STATUSHEIGHT + notificationsTipHeight);
    
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
        
        NSString *title = ZFLocalizedString(@"Account_View_and_edit_profile", nil);
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
    
    if ([ZFPushManager canShowAlertViewWithKey:kAccountShowNotificationAlertTimestamp time:7]) {
        // 推送提示
        [self.topMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.top.mas_equalTo(44 + STATUSHEIGHT);
            make.height.mas_lessThanOrEqualTo(@44);
        }];
    }
    
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
                make.trailing.mas_equalTo(self.avatorView.mas_trailing).mas_offset(10);
                make.bottom.mas_equalTo(self.avatorView.mas_top).mas_offset(32);
                make.size.mas_equalTo(CGSizeMake(64, 46));
            }];
        }
        
        BOOL showReviewBtn = [AccountManager sharedManager].account.user_review_sku;
        CGFloat scale = (ISLOGIN && showReviewBtn) ? 0.5 : 0.7;
        CGFloat userImageWidth = 70;
        
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
                make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(scale).offset(-userImageWidth);
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
                make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(scale).offset(-userImageWidth);
            }];
        }
        
        CGFloat offsetX = [SystemConfigUtils isRightToLeftShow] ? 14 : 18;
        [self.zmeHomeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.avatorView);
            make.height.mas_equalTo(30);
            make.trailing.mas_equalTo(self.contentView).offset(offsetX);
            //make.size.mas_equalTo(CGSizeMake(90, 30)); //自适应Z-me按钮宽度
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
    
    /// 自适应Z-me按钮宽度:防止被拉升变长
    [self.zmeHomeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.zmeHomeButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self configuShowReviewPoint];
}

#pragma mark - target method

- (void)signButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountHeaderCReusableViewDidClickLogin)]) {
        [self.delegate ZFAccountHeaderCReusableViewDidClickLogin];
    }
}

- (void)editProfileButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountHeaderCReusableViewDidClickEditProfile)]) {
        [self.delegate ZFAccountHeaderCReusableViewDidClickEditProfile];
    }
}

- (void)zmeHomeButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountHeaderCReusableViewDidClickZ_ME)]) {
        [self.delegate ZFAccountHeaderCReusableViewDidClickZ_ME];
    }
}

- (void)guestTipsButtonAction {
    NSString *title = ZFLocalizedString(@"GameLogin_GuestUser", nil);
    NSString *message = ZFLocalizedString(@"GameLogin_GuestUserTips", nil);
    NSString *cancelTitle = ZFLocalizedString(@"OK", nil);
    ShowAlertView(title, message, nil, ^(NSInteger buttonIndex, id buttonTitle) {}, cancelTitle, nil);
}

#pragma mark - publick method

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
    
    // v5.5.0 去掉
//    UIColor *titleColor = [AccountManager sharedManager].appNavFontColor;
//    if ([AccountManager sharedManager].isSignIn) {  //登陆状态
//        self.nameLabel.textColor = titleColor;
//        UIColor *btnColor = [titleColor colorWithAlphaComponent:0.5];
//        [self.editProfileButton setTitleColor:btnColor forState:UIControlStateNormal];
//
//    } else {  //非登陆状态
//        self.welcomeLabel.textColor = titleColor;
//    }
}

/// 是否显示评论入口
- (void)configuShowReviewPoint {
    [self.zmeHomeButton setAttributedTitle:nil forState:0];
    [self.zmeHomeButton setTitle:nil forState:0];
    
    BOOL showReviewBtn = [AccountManager sharedManager].account.user_review_sku;
    if (ISLOGIN && showReviewBtn) {
        self.zmeHomeButton.titleLabel.font = [UIFont boldSystemFontOfSize:8];
        self.zmeHomeButton.backgroundColor = ZFCOLOR(254, 82, 105, 1);
        [self.zmeHomeButton setImage:[[UIImage imageNamed:@"account_zme"] imageWithColor:ZFCOLOR_WHITE] forState:UIControlStateNormal];
        [self.zmeHomeButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [self.zmeHomeButton setTitleColor:[ZFCOLOR_WHITE colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        
        NSArray *textArray = @[ZFLocalizedString(@"Order_Comment_Reward", nil), @""];
        NSArray *fontArray = @[ZFFontSystemSize(12), ZFFontSystemSize(8)];
        NSArray *colorArray = @[ZFCOLOR_WHITE];
        NSAttributedString *attributedText = [NSString getAttriStrByTextArray:textArray
                                                                      fontArr:fontArray
                                                                     colorArr:colorArray
                                                                  lineSpacing:0
                                                                    alignment:3];
        [self.zmeHomeButton setAttributedTitle:attributedText
                                      forState:(UIControlStateNormal)];
        
    } else {
        self.zmeHomeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        self.zmeHomeButton.titleLabel.numberOfLines = 1;
        [self.zmeHomeButton setTitle:ZFLocalizedString(@"Account_TopInfo_ZmeHome", nil) forState:UIControlStateNormal];
        [self.zmeHomeButton setImage:[[UIImage imageNamed:@"account_zme"] imageWithColor:ZFC0x2D2D2D()] forState:UIControlStateNormal];
        [self.zmeHomeButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [self.zmeHomeButton setTitleColor:[ZFC0x2D2D2D() colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        self.zmeHomeButton.backgroundColor = ZFC0xDDDDDD();
    }
    self.zmeHomeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 25);
    [self.zmeHomeButton zfLayoutStyle:ZFButtonEdgeInsetsStyleRight imageTitleSpace:3];
}

#pragma mark - Property Method

- (void)setShowType:(ZFNewAccountInfoStatusType)showType {
    if (_showType == showType && showType != ZFNewAccountInfoStatusNeedReload) {
        return;
    }
    _showType = showType;
    //根据登陆和非登陆，布局界面。当外部切换登陆状态的时候，通过该setter方法，切换页面布局。
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self zfInitView];
    [self zfAutoLayoutView];
    
    //显示赋值
    AccountModel *accountModel = [AccountManager sharedManager].account;
    if (accountModel) {
        [self.avatorView  yy_setImageWithURL:[NSURL URLWithString:[AccountManager sharedManager].account.avatar]
                                 placeholder:[UIImage imageNamed:@"account_head"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:nil
                                  completion:nil];
        
        self.nameLabel.text = [AccountManager sharedManager].account.nickname;
    }
    [self configuShowReviewPoint];
}

- (YYAnimatedImageView *)headerImagewView {
    if (!_headerImagewView) {
        _headerImagewView = [[YYAnimatedImageView alloc] init];
        _headerImagewView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImagewView.userInteractionEnabled = YES;
        _headerImagewView.clipsToBounds = YES;
        _headerImagewView.image = [UIImage imageNamed:@"account_home_headerTopbg"];
        _headerImagewView.hidden = YES;
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
            if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto)]) {
                [self.delegate ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto];
            }
        }];
    }
    return _avatorView;
}

- (UILabel *)welcomeLabel {
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _welcomeLabel.font = [UIFont systemFontOfSize:24];
        _welcomeLabel.textColor = ZFC0x2D2D2D();
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
        _nameLabel.textColor = ZFC0x2D2D2D();
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
        [_signButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_signButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateHighlighted];
        _signButton.backgroundColor = ZFC0x2D2D2D();
        [_signButton addTarget:self action:@selector(signButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signButton;
}

- (UIButton *)editProfileButton {
    if (!_editProfileButton) {
        _editProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editProfileButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _editProfileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _editProfileButton.titleLabel.numberOfLines = 2;
        [_editProfileButton setTitle:ZFLocalizedString(@"Account_View_and_edit_profile", nil) forState:UIControlStateNormal];
        [_editProfileButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [_editProfileButton setTitleColor:ZFC0x999999() forState:UIControlStateHighlighted];
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
        [_zmeHomeButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_zmeHomeButton setTitleColor:[ZFC0x2D2D2D() colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        _zmeHomeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_zmeHomeButton addTarget:self action:@selector(zmeHomeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _zmeHomeButton.backgroundColor = ZFC0xDDDDDD();
        _zmeHomeButton.layer.cornerRadius = 15;
        [_zmeHomeButton setImage:[[UIImage imageNamed:@"account_zme"] imageWithColor:ZFC0x2D2D2D()] forState:UIControlStateNormal];
        [_zmeHomeButton setTitle:ZFLocalizedString(@"Account_TopInfo_ZmeHome", nil) forState:UIControlStateNormal];
//        _zmeHomeButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;//标题过长换行
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

- (ZFMyOrderListTopMessageView *)topMessageView {
    if (!_topMessageView) {
        _topMessageView = [[ZFMyOrderListTopMessageView alloc] initWithFrame:CGRectZero];
        _topMessageView.isAccountPage = YES;
        @weakify(self)
        _topMessageView.operateCloseBlock = ^{
            @strongify(self)
            self.topMessageView.hidden = YES;
            if (self.closeBlock) {
                self.closeBlock();
            }
        };
        _topMessageView.operateEventBlock = ^{
            @strongify(self)
            if (self.openBlock) {
                self.openBlock();
            }
        };
    }
    return _topMessageView;
}

@end
