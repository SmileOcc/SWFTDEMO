//
//  ZFCommunityPostDetailUserView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostDetailUserView.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"

static CGFloat const kUserImageHeight = 40.0;
@interface ZFCommunityPostDetailUserView ()

@property (nonatomic, strong) UIImageView                 *userImageView;
@property (nonatomic, strong) UILabel                     *userNickNameLabel;
@property (nonatomic, strong) UILabel                     *userInfoLabel;
@property (nonatomic, strong) UIView                      *separeteView;

@property (nonatomic, strong) UILabel                     *userPreviewNickNameLabel;


@property (nonatomic, strong) UIButton                    *followButton;
@property (nonatomic, strong) UIImageView                 *rankImageView;

@end

@implementation ZFCommunityPostDetailUserView

+ (ZFCommunityPostDetailUserView *)userHeaderViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *headerIdentifer = NSStringFromClass([ZFCommunityPostDetailUserView class]);
    [collectionView registerClass:[self class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:headerIdentifer];
    
    ZFCommunityPostDetailUserView *userHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifer forIndexPath:indexPath];
    return userHeaderView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.userImageView];
    [self addSubview:self.userNickNameLabel];
    [self addSubview:self.userInfoLabel];
    [self addSubview:self.followButton];
    [self addSubview:self.separeteView];
    [self addSubview:self.rankImageView];
    [self addSubview:self.userPreviewNickNameLabel];
}

- (void)layout {
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kUserImageHeight);
        make.leading.mas_equalTo(self).offset(12.0);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80.0);
        make.height.mas_equalTo(26.0);
        make.trailing.mas_equalTo(self).offset(-12.0);
        make.centerY.mas_equalTo(self.userImageView.mas_centerY);
    }];
    
    [self.userNickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImageView.mas_top).offset(2.0);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8.0);
        make.trailing.mas_equalTo(self.followButton.mas_leading).offset(-12.0);
        make.height.mas_equalTo(19.0);
    }];
    
    [self.userInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.userImageView.mas_bottom).offset(-2.0);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8.0);
        make.trailing.mas_equalTo(self.followButton.mas_leading).offset(-12.0);
        make.height.mas_equalTo(14.0);
    }];
    
    [self.separeteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(MIN_PIXEL);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-MIN_PIXEL);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.userPreviewNickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userImageView.mas_centerY);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(8.0);
        make.trailing.mas_equalTo(self.followButton.mas_leading).offset(-12.0);
    }];
}

- (void)followAction {
    if (self.followActionHandle) {
        self.followActionHandle();
    }
}

- (void)tapUserAvarteAction {
    if (self.userAvarteActionHandle) {
        self.userAvarteActionHandle();
    }
}

- (void)showSepareteView {
    self.separeteView.hidden = NO;
}

#pragma mark - getter/setter
- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] init];
        _userImageView.layer.cornerRadius     = kUserImageHeight / 2;
        _userImageView.layer.masksToBounds    = YES;
        _userImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapUserAvarteAction)];
        [_userImageView addGestureRecognizer:tapGesture];
    }
    return _userImageView;
}

- (UILabel *)userNickNameLabel {
    if (!_userNickNameLabel) {
        _userNickNameLabel       = [[UILabel alloc] init];
        _userNickNameLabel.font  = [UIFont systemFontOfSize:16.0];
        _userInfoLabel.textColor = [UIColor colorWithHex:0x2d2d2d];
    }
    return _userNickNameLabel;
}

- (UILabel *)userInfoLabel {
    if (!_userInfoLabel) {
        _userInfoLabel           = [[UILabel alloc] init];
        _userInfoLabel.font      = [UIFont systemFontOfSize:12.0];
        _userInfoLabel.textColor = [UIColor colorWithHex:0x999999];
    }
    return _userInfoLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.layer.borderWidth = MIN_PIXEL;
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        _followButton.titleLabel.font   = [UIFont systemFontOfSize:14.0];
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        //FIXME: occ Bug 1101
        [_followButton setTitle:ZFLocalizedString(@"Community_Follow", nil) forState:UIControlStateNormal];
//        [_followButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        [_followButton addTarget:self action:@selector(followAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
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


- (UIView *)separeteView {
    if (!_separeteView) {
        _separeteView = [[UIView alloc] init];
        _separeteView.backgroundColor = ZFC0xDDDDDD();
        _separeteView.hidden = YES;
    }
    return _separeteView;
}

- (UILabel *)userPreviewNickNameLabel {
    if (!_userPreviewNickNameLabel) {
        _userPreviewNickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userPreviewNickNameLabel.font  = [UIFont systemFontOfSize:16.0];
        _userPreviewNickNameLabel.textColor = [UIColor colorWithHex:0x2d2d2d];
        _userPreviewNickNameLabel.hidden = YES;
    }
    return _userPreviewNickNameLabel;
}

- (void)setIsFollow:(BOOL)isFollow {
    _isFollow = isFollow;
    self.followButton.selected = isFollow;
    if (!isFollow) {
        self.followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [self.followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [self.followButton setTitle:ZFLocalizedString(@"Community_Follow", nil) forState:UIControlStateNormal];

//        [_followButton setImage:[UIImage imageNamed:@"style_follow"] forState:UIControlStateNormal];
    } else {
        self.followButton.layer.borderColor = ZFC0x999999().CGColor;
        [self.followButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
//        [_followButton setImage:nil forState:UIControlStateNormal];
        [self.followButton setTitle:ZFLocalizedString(@"community_topicdetail_followed", nil) forState:UIControlStateNormal];
    }
}

- (void)setIsMyTopic:(BOOL)isMyTopic {
    _isMyTopic = isMyTopic;
    self.followButton.hidden = isMyTopic;
}

- (void)setUserWithAvarteURL:(NSString *)avarteURL {
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:avarteURL]
                               placeholder:[UIImage imageNamed:@"public_user"]];
}

- (void)setUserWithNickName:(NSString *)nickName {
    self.userNickNameLabel.text = nickName;
    self.userPreviewNickNameLabel.hidden = YES;
}

- (void)setPreviewNickName:(NSString *)nickName {
    self.userPreviewNickNameLabel.text = ZFToString(nickName);
    self.userPreviewNickNameLabel.hidden = NO;
}

- (void)setUserWithPost:(NSString *)postNum totalLiked:(NSString *)likedNum {
    self.userInfoLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"community_topicdetail_userinfp", nil), postNum, likedNum];
}

- (void)setUserWithRank:(NSInteger)vRank imgUrl:(NSString *)vRankUrl content:(NSString *)vRankContent {
    if (vRank > 0) {
        self.rankImageView.hidden = NO;
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:vRankUrl] options:kNilOptions];
        if (!ZFIsEmptyString(vRankContent)) {
            self.userInfoLabel.text = vRankContent;
        }
    } else {
        self.rankImageView.hidden = YES;
    }
}

- (void)hideFollowView {
    self.followButton.hidden = YES;
}

@end
