//
//  ZFCommunitySearchResultCell.m
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchResultCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunitySearchResultModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

#import "UIImage+ZFExtended.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface ZFCommunitySearchResultCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView           *userHeadImageView;
@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UILabel               *postsLabel;
@property (nonatomic, strong) UILabel               *likesLabel;
@property (nonatomic, strong) UIButton              *followButton;
@property (nonatomic, strong) UIView                *lineView;

@property (nonatomic, strong) UIImageView           *rankImageView;

@end


@implementation ZFCommunitySearchResultCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.userHeadImageView.image = nil;
    self.nameLabel.text = nil;
    self.postsLabel.text = nil;
    self.likesLabel.text = nil;
}

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)followButtonAction:(UIButton *)sender {
    if (self.searchResultFollowUserCompletionHandler) {
        self.searchResultFollowUserCompletionHandler(self.model);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.userHeadImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.postsLabel];
    [self addSubview:self.likesLabel];
    [self addSubview:self.followButton];
    [self addSubview:self.lineView];
    [self addSubview:self.rankImageView];
}

- (void)zfAutoLayoutView {
    [self.userHeadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-15);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.width.height.mas_offset(39);
    }];
    self.userHeadImageView.layer.cornerRadius = 39.0 / 2;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userHeadImageView.mas_trailing).offset(8);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_centerY).offset(-2);
        make.trailing.mas_offset(-115);
    }];
    
    [self.postsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
        make.top.mas_equalTo(self.userHeadImageView.mas_centerY).offset(2);
    }];
    
    [self.likesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.postsLabel.mas_trailing).offset(10);
        make.centerY.mas_equalTo(self.postsLabel.mas_centerY);
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(80, 26));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.trailing.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userHeadImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
}

#pragma mark - setter
- (void)setModel:(ZFCommunitySearchResultModel *)model {
    _model = model;

    [self.userHeadImageView yy_setImageWithURL:[NSURL URLWithString:model.avatar]
                                   placeholder:[UIImage imageNamed:@"public_user"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:nil
                                     transform:nil
                                    completion:nil];
    self.nameLabel.text = model.nick_name;
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.postsLabel.text = [NSString stringWithFormat:@"%@ %@",model.review_total,ZFLocalizedString(@"CommendUserCell_Posts",nil)];
        self.likesLabel.text = [NSString stringWithFormat:@"%@ %@",model.likes_total,ZFLocalizedString(@"CommendUserCell_BeLiked",nil)];
    } else {
        self.postsLabel.text = [NSString stringWithFormat:@"%@ %@",ZFLocalizedString(@"CommendUserCell_Posts",nil),model.review_total];
        self.likesLabel.text = [NSString stringWithFormat:@"%@ %@",ZFLocalizedString(@"CommendUserCell_BeLiked",nil),model.likes_total];
    }
    self.followButton.hidden = model.isFollow;
    
    self.rankImageView.hidden = YES;
    if ([_model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:_model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
}

#pragma mark - getter
- (UIImageView *)userHeadImageView {
    if (!_userHeadImageView) {
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userHeadImageView.contentMode = UIViewContentModeScaleToFill;
        _userHeadImageView.userInteractionEnabled = YES;
        _userHeadImageView.clipsToBounds = YES;
    }
    return _userHeadImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = ZFCOLOR(51, 51, 51, 1.0);
    }
    return _nameLabel;
}

- (UILabel *)postsLabel {
    if (!_postsLabel) {
        _postsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _postsLabel.font = [UIFont systemFontOfSize:12];
        _postsLabel.textColor = ZFCOLOR(170, 170, 170, 1.0);
    }
    return _postsLabel;
}

- (UILabel *)likesLabel {
    if (!_likesLabel) {
        _likesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _likesLabel.font = [UIFont systemFontOfSize:12];
        _likesLabel.textColor = ZFCOLOR(170, 170, 170, 1.0);
    }
    return _likesLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _followButton.layer.borderWidth = 1;
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];
        [_followButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    }
    return _followButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(212, 212, 212, 1.0);
    }
    return _lineView;
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

@end

