
//
//  ZFCommunityAccountInfoView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountInfoView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityAccountInfoModel.h"
#import "ZFCommunityViewModel.h"
#import "BigClickAreaButton.h"
#import "UIView+ZFBadge.h"
#import "NSString+Extended.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"

#define kEditBtnWidth       (KScreenWidth - (12+75+25+12))

@interface ZFCommunityAccountInfoView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *avatorImageView;
@property (nonatomic, strong) UIImageView           *joinMarkImageView;
@property (nonatomic, strong) UIButton              *followButton;
@property (nonatomic, strong) UIButton              *followingButton;
@property (nonatomic, strong) UIButton              *followerButton;
@property (nonatomic, strong) UIButton              *belikeButton;
@property (nonatomic, strong) UILabel               *helpLabel;
@property (nonatomic, strong) UIButton              *helpButton;

//只针对是其他人是博主的时候
@property (nonatomic, strong) UIButton              *giftButton;
@property (nonatomic, strong) UIButton              *drawButton;
//荣耀等级V
@property (nonatomic, strong) UIImageView           *rankImageView;

@property (nonatomic, strong) UIButton              *birthdayButton;
@property (nonatomic, strong) UIView                *birthdayView;
@property (nonatomic, strong) UILabel               *birthdayLabel;
@property (nonatomic, strong) YYAnimatedImageView   *birthdayIcon;

@property (nonatomic, strong) ZFCommunityViewModel  *viewModel;
@end

@implementation ZFCommunityAccountInfoView
#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)clearUserProfileTag {
    [self.followButton.titleLabel clearBadge];
}

- (void)setUserProfileTag {
    if ([_model.userId isEqualToString:USERID]) {
        self.followButton.titleLabel.badgeBgColor = ZFC0xFE5269();
        [self.followButton.titleLabel showBadgeWithStyle:WBadgeStyleRedDot value:0];
        
        NSString *text = self.followButton.titleLabel.text;
        UIFont *font = self.followButton.titleLabel.font;
        CGSize size = [NSString sizeForString:text font:font maxWidth:kEditBtnWidth];
        self.followButton.titleLabel.badge.x = size.width;
    }
}

- (void)defaultUserIsEditState {
    [self.followButton setTitle:[NSString stringWithFormat:@" %@",ZFLocalizedString(@"StyleHeaderView_Edit_Profile",nil)] forState:UIControlStateNormal];
    [self.followButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
    self.followButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1).CGColor;
    
    [self isShowBirthdayGift];
}

- (void)isShowBirthdayGift {
//    if ([self.model.userId isEqualToString:USERID]) {
//        NSString *birthday = [AccountManager sharedManager].account.birthday;
//        if (ZFIsEmptyString(birthday)) {
//            self.followButton.hidden = YES;
//            self.birthdayButton.hidden = NO;
//        } else {
//            self.followButton.hidden = NO;
//            self.birthdayButton.hidden = YES;
//        }
//    }
}

#pragma mark - action methods
- (void)infoButtonAction:(UIButton *)sender {
    CommunityAccountInfoActionType actionType = sender.tag;
    
    if (actionType == FollowButtonActionType) {
        if ([self.model.userId isEqualToString:USERID]) {
            actionType = EditProfileButtonActionType;
        }
    }
    if (self.infoBtnActionBlcok) {
        self.infoBtnActionBlcok(actionType, self.model);
    }
}

- (void)birthdayButtonAction:(UIButton *)sender {
    if (self.infoBtnActionBlcok) {
        self.infoBtnActionBlcok(EditProfileButtonActionType, self.model);
    }
}

- (void)helpButtonAction:(UIButton *)sender {
    if (self.infoBtnActionBlcok) {
        if (!self.rankImageView.isHidden) {
            self.infoBtnActionBlcok(UserRankInforActionType, self.model);
        } else {
            self.infoBtnActionBlcok(HelpButonActionType, self.model);
        }
    }
}

- (void)giftButtonAction:(UIButton *)sender {
    if (self.infoBtnActionBlcok) {
        self.infoBtnActionBlcok(GiftButtonAction, self.model);
    }
}

- (void)drawButtonAction:(UIButton *)sender {
    if (self.infoBtnActionBlcok) {
        self.infoBtnActionBlcok(DrawButtonAction, self.model);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.avatorImageView];
    [self addSubview:self.joinMarkImageView];
    [self addSubview:self.followingButton];
    [self addSubview:self.followerButton];
    [self addSubview:self.belikeButton];
    [self addSubview:self.followButton];
    [self addSubview:self.helpLabel];
    [self addSubview:self.helpButton];
    [self addSubview:self.giftButton];
    [self addSubview:self.drawButton];
    [self addSubview:self.rankImageView];
    
    [self addSubview:self.birthdayButton];
    [self.birthdayButton addSubview:self.birthdayView];
    [self.birthdayButton addSubview:self.birthdayLabel];
    [self.birthdayButton addSubview:self.birthdayIcon];
}

- (void)zfAutoLayoutView {
    [self.avatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.top.mas_equalTo(self.mas_top).offset(16);
        make.size.mas_equalTo(CGSizeMake(75, 75));
    }];
    
    [self.joinMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.avatorImageView.mas_trailing);
        make.bottom.mas_equalTo(self.avatorImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    //id非自己时,显示关注按钮
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kEditBtnWidth, 35));
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.avatorImageView.mas_bottom);
    }];
    
    [self.followingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.followButton.mas_top).offset(-7);
        make.centerX.mas_equalTo(self.followButton.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(kEditBtnWidth/3, 40));
    }];

    [self.followerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.followButton.mas_leading);
        make.top.mas_equalTo(self.followingButton.mas_top);
        make.size.mas_equalTo(CGSizeMake(kEditBtnWidth/3, 40));
    }];

    [self.belikeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.followButton.mas_trailing);
        make.top.mas_equalTo(self.followingButton.mas_top);
        make.size.mas_equalTo(CGSizeMake(kEditBtnWidth/3, 40));
    }];
    
    [self.helpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 24 - 25);
        make.top.mas_equalTo(self.avatorImageView.mas_bottom);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.helpLabel.mas_trailing).offset(9);
        make.centerY.mas_equalTo(self.helpLabel.mas_centerY);
    }];
    
    [self.giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.followButton.mas_leading);
        make.bottom.mas_equalTo(self.avatorImageView.mas_bottom);
        make.trailing.mas_equalTo(self.followingButton.mas_centerX).offset(-2);
        make.height.mas_equalTo(35);
    }];
    
    [self.drawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.followingButton.mas_centerX).offset(2);
        make.bottom.mas_equalTo(self.avatorImageView.mas_bottom);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.height.mas_equalTo(35);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.avatorImageView.mas_trailing);
        make.bottom.mas_equalTo(self.avatorImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    
    [self.birthdayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.followButton);
    }];
    
    [self.birthdayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.birthdayButton);
        make.width.mas_lessThanOrEqualTo(kEditBtnWidth);
    }];
    
    [self.birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.birthdayView.mas_centerY);
        make.trailing.mas_equalTo(self.birthdayIcon.mas_leading).offset(-4);
        make.leading.mas_equalTo(self.birthdayView.mas_leading).offset(4);
    }];
    
    [self.birthdayIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.birthdayView.mas_centerY).offset(-2);
        make.trailing.mas_equalTo(self.birthdayView.mas_trailing).offset(-4);
        make.size.mas_offset(CGSizeMake(22, 22));
    }];
}

#pragma mark - setter

- (void)setModel:(ZFCommunityAccountInfoModel *)model {
    _model = model;
    self.userInteractionEnabled = YES;
    
    // 这里因为社区的数据可能和后台不同步,因此需要取后台的个人头像
    NSString *avatarUrl = ZFToString(_model.avatar);
    if ([model.userId isEqualToString:USERID]) {
        AccountModel *account = [AccountManager sharedManager].account;
        avatarUrl = ZFToString(account.avatar);
    }
    
    [self.avatorImageView  yy_setImageWithURL:[NSURL URLWithString:avatarUrl]
                            placeholder:[UIImage imageNamed:@"account_head"]
                                 options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                progress:nil
                               transform:nil
                              completion:nil];
    
    
    NSString *followingNumber = [NSString stringWithFormat:@"%lu\n", _model.followingCount];
    NSString *followingTitle = ZFLocalizedString(@"StyleHeaderView_Following",nil);
    [self.followingButton setAttriStrWithTextArray:@[followingNumber,followingTitle]
                                         fontArr:@[ZFFontBoldSize(14), ZFFontBoldSize(12)]
                                        colorArr:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]
                                       lineSpacing:1
                                       alignment:NSTextAlignmentCenter];
    
    
    NSString *followerNumber = [NSString stringWithFormat:@"%lu\n", _model.followersCount];
    NSString *followerTitle = ZFLocalizedString(@"StyleHeaderView_Followers",nil);
    [self.followerButton setAttriStrWithTextArray:@[followerNumber,followerTitle]
                                           fontArr:@[ZFFontBoldSize(14), ZFFontBoldSize(12)]
                                          colorArr:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]
                                       lineSpacing:1
                                         alignment:NSTextAlignmentCenter];
    
    NSString *belikeNumber = [NSString stringWithFormat:@"%lu\n", _model.likeCount];
    NSString *belikeTitle = ZFLocalizedString(@"CommunityDetailHeaderCell_Likes",nil);
    [self.belikeButton setAttriStrWithTextArray:@[belikeNumber,belikeTitle]
                                         fontArr:@[ZFFontBoldSize(14), ZFFontBoldSize(12)]
                                        colorArr:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]
                                     lineSpacing:1
                                       alignment:NSTextAlignmentCenter];
    self.isFollow = _model.isFollow;
    
    
    BOOL isBigV = [_model.identify_type integerValue] > 0 ? YES : NO;
    BOOL showHelp = isBigV;
    self.rankImageView.hidden = YES;
    self.joinMarkImageView.hidden = YES;
    
    // 优先显示认证的的
    if (isBigV) {
        
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:_model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
        self.helpLabel.hidden = NO;
        self.helpButton.hidden = NO;
        self.helpLabel.text = ZFToString(_model.identify_content);
    } else {
        
        // 是不是博主
        BOOL isAffiliate = _model.affiliate_id > 0 ? YES : NO;
        showHelp = isAffiliate;
        
        self.joinMarkImageView.hidden = !isAffiliate;
        self.helpLabel.hidden = !isAffiliate;
        self.helpButton.hidden = !isAffiliate;
        self.helpLabel.text = ZFLocalizedString(@"community_Entered_Z-Me_Referral-share_Plan", nil);
    }
    
    [self.helpLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatorImageView.mas_bottom).offset(showHelp ? 18 : 0);
        make.bottom.mas_equalTo(self.mas_bottom).offset(showHelp ? -10 : 0);
    }];
    
    //不是V认证的时候，才判断处理
    if (_model.affiliate_id > 0 && ![model.userId isEqualToString:USERID] && !isBigV) {
        self.followButton.hidden = YES;
        self.drawButton.hidden = NO;
        self.giftButton.hidden = NO;
    } else {
        self.followButton.hidden = NO;
        self.drawButton.hidden = YES;
        self.giftButton.hidden = YES;
    }
}

- (void)setIsFollow:(BOOL)isFollow {
    _isFollow = isFollow;
    _model.isFollow = _isFollow;
    if ([_model.userId isEqualToString:USERID]) {
        [self defaultUserIsEditState];
        
    } else{
        if (_isFollow) {
            [self.followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"StyleHeaderView_Followed",nil)] forState:UIControlStateNormal];
//            [self.followButton setImage:[UIImage imageNamed:@"community_follow_followed"] forState:UIControlStateNormal];
            self.followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
            [self.followButton setTitleColor:ZFC0x2D2D2D() forState:0];
            self.followButton.backgroundColor = ZFCOLOR_WHITE;
            
        } else {
            [self.followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];
//            [self.followButton setImage:[UIImage imageNamed:@"community_follow_plus"] forState:UIControlStateNormal];
            self.followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
            self.followButton.backgroundColor = ZFC0x2D2D2D();
            [self.followButton setTitleColor:ZFCOLOR_WHITE forState:0];
        }
    }
}

#pragma mark - getter
- (ZFCommunityViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityViewModel alloc] init];
    }
    return _viewModel;
}

- (UIImageView *)avatorImageView {
    if (!_avatorImageView) {
        _avatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatorImageView.userInteractionEnabled = YES;
        _avatorImageView.image = [UIImage imageNamed:@"public_user"];
        _avatorImageView.clipsToBounds = YES;
        _avatorImageView.layer.cornerRadius = 80/2;
        _avatorImageView.layer.masksToBounds = YES;
        @weakify(self)
        [_avatorImageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self)
            if ([USERID isEqualToString: self.model.userId]) {
                if (self.infoBtnActionBlcok) {
                    self.infoBtnActionBlcok(UploadAvatarButtonActionType, self.model);
                }
            }
        }];
    }
    return _avatorImageView;
}

- (UIImageView *)joinMarkImageView {
    if (!_joinMarkImageView) {
        _joinMarkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _joinMarkImageView.image = [UIImage imageNamed:@"community_biaoshi"];
        _joinMarkImageView.hidden = YES;
    }
    return _joinMarkImageView;
}

- (UIButton *)followerButton {
    if (!_followerButton) {
        _followerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followerButton.backgroundColor = ZFCOLOR_WHITE;
        [_followerButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _followerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _followerButton.titleLabel.numberOfLines = 0;
        _followerButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_followerButton setTitle:ZFLocalizedString(@"StyleHeaderView_Followers",nil) forState:UIControlStateNormal];
        [_followerButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followerButton.tag = FollowerButtonActionType;
        
        NSString *followerNumber = [NSString stringWithFormat:@"%d\n", 0];
        NSString *followerTitle = ZFLocalizedString(@"StyleHeaderView_Followers",nil);
        [_followerButton setAttriStrWithTextArray:@[followerNumber,followerTitle]
                                              fontArr:@[ZFFontBoldSize(14), ZFFontBoldSize(12)]
                                             colorArr:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]
                                          lineSpacing:1
                                            alignment:NSTextAlignmentCenter];
    }
    return _followerButton;
}

- (UIButton *)followingButton {
    if (!_followingButton) {
        _followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followingButton.backgroundColor = ZFCOLOR_WHITE;
        _followingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _followingButton.titleLabel.numberOfLines = 0;
        [_followingButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _followingButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_followingButton setTitle:ZFLocalizedString(@"StyleHeaderView_Following",nil) forState:UIControlStateNormal];
        [_followingButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followingButton.tag = FollowingButtonActionType;

        NSString *followingNumber = [NSString stringWithFormat:@"%d\n", 0];
        NSString *followingTitle = ZFLocalizedString(@"StyleHeaderView_Following",nil);
        [_followingButton setAttriStrWithTextArray:@[followingNumber,followingTitle]
                                               fontArr:@[ZFFontBoldSize(14), ZFFontBoldSize(12)]
                                              colorArr:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]
                                           lineSpacing:1
                                             alignment:NSTextAlignmentCenter];
    }
    return _followingButton;
}

- (UIButton *)belikeButton {
    if (!_belikeButton) {
        _belikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _belikeButton.backgroundColor = ZFCOLOR_WHITE;
        [_belikeButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _belikeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _belikeButton.titleLabel.numberOfLines = 0;
        [_belikeButton setTitle:ZFLocalizedString(@"Community_AccountLiked",nil) forState:UIControlStateNormal];
        _belikeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _belikeButton.enabled = NO;
        
        NSString *belikeNumber = [NSString stringWithFormat:@"%d\n", 0];
        NSString *belikeTitle = ZFLocalizedString(@"CommunityDetailHeaderCell_Likes",nil);
        [_belikeButton setAttriStrWithTextArray:@[belikeNumber,belikeTitle]
                                            fontArr:@[ZFFontBoldSize(14), ZFFontBoldSize(12)]
                                           colorArr:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]
                                        lineSpacing:1
                                          alignment:NSTextAlignmentCenter];

    }
    return _belikeButton;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.backgroundColor = [UIColor whiteColor];
        _followButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_followButton addTarget:self action:@selector(infoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.tag = FollowButtonActionType;
        _followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        _followButton.layer.borderWidth = MIN_PIXEL;
        _followButton.layer.cornerRadius = 3;
        _followButton.layer.masksToBounds = YES;
        
        [_followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];
//        [_followButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    }
    return _followButton;
}

- (UILabel *)helpLabel {
    if (!_helpLabel) {
        _helpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _helpLabel.text = ZFLocalizedString(@"community_Entered_Z-Me_Referral-share_Plan", nil);
        _helpLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _helpLabel.font = ZFFontSystemSize(14);
        _helpLabel.numberOfLines = 2;
        _helpLabel.hidden = YES;
    }
    return _helpLabel;
}

- (UIButton *)helpButton {
    if (!_helpButton) {
        _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_helpButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
        [_helpButton setEnlargeEdgeWithTop:6 right:6 bottom:6 left:6];
        [_helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _helpButton.hidden = YES;
    }
    return _helpButton;
}

- (UIButton *)giftButton {
    if (!_giftButton) {
        _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_giftButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _giftButton.titleLabel.font = ZFFontSystemSize(14);
        _giftButton.layer.borderWidth = 1.0;
        _giftButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_giftButton setTitle:ZFLocalizedString(@"community_get_gift", nil) forState:UIControlStateNormal];
        [_giftButton addTarget:self action:@selector(giftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _giftButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _giftButton.hidden = YES;
    }
    return _giftButton;
}

- (UIButton *)drawButton {
    if (!_drawButton) {
        _drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_drawButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _drawButton.titleLabel.font = ZFFontSystemSize(14);
        _drawButton.layer.borderWidth = 1.0;
        _drawButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_drawButton setTitle:ZFLocalizedString(@"community_get_draw", nil) forState:UIControlStateNormal];
        [_drawButton addTarget:self action:@selector(drawButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _drawButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _drawButton.hidden = YES;
//         _drawButton.titleLabel.lineBreakMode = 0;//这句话很重要，不加这句话加上换行符也没
    }
    return _drawButton;
}

- (UIImageView *)rankImageView {
    if (!_rankImageView) {
        _rankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rankImageView.backgroundColor = [UIColor clearColor];
        _rankImageView.userInteractionEnabled = YES;
        _rankImageView.hidden = YES;
    }
    return _rankImageView;
}


- (UIButton *)birthdayButton {
    if (!_birthdayButton) {
        _birthdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _birthdayButton.backgroundColor = [UIColor whiteColor];
        [_birthdayButton addTarget:self action:@selector(birthdayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _birthdayButton.layer.borderColor = ZFC0xCCCCCC().CGColor;
        _birthdayButton.layer.borderWidth = MIN_PIXEL;
        _birthdayButton.layer.cornerRadius = 3;
        _birthdayButton.layer.masksToBounds = YES;
        _birthdayButton.hidden = YES;
    }
    return _birthdayButton;
}


- (UIView *)birthdayView {
    if (!_birthdayView) {
        _birthdayView = [[UIView alloc] initWithFrame:CGRectZero];
        _birthdayView.layer.cornerRadius = 3;
        _birthdayView.layer.masksToBounds = YES;
    }
    return _birthdayView;
}

- (UILabel *)birthdayLabel {
    if (!_birthdayLabel) {
        _birthdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _birthdayLabel.text = ZFLocalizedString(@"StyleHeaderView_Edit_Profile",nil);
        _birthdayLabel.textColor = ZFC0x999999();
        _birthdayLabel.font = [UIFont systemFontOfSize:14];
    }
    return _birthdayLabel;
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
