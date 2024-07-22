//
//  ZFCommunitySearchSuggestUsersListCell.m
//  ZZZZZ
//
//  Created by YW on 2017/7/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchSuggestUsersListCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunitySuggestedUsersModel.h"
#import "ZFCommunityPictureModel.h"
#import "CommunityEnumComm.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface ZFCommunitySearchSuggestUsersListCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIView                *backView;
@property (nonatomic, strong) UIImageView           *userHeadImageView;
@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UILabel               *postsLabel;
@property (nonatomic, strong) UILabel               *beLikesLabel;
@property (nonatomic, strong) UIButton              *followButton;
@property (nonatomic, strong) UIView                *showImagesContentView;

@property (nonatomic, strong) UIImageView           *rankImageView;

@end

@implementation ZFCommunitySearchSuggestUsersListCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.userHeadImageView.image = nil;
    self.nameLabel.text = nil;
    self.postsLabel.text = nil;
    self.beLikesLabel.text = nil;
    [self.showImagesContentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    }];
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
    if (self.followUserCompletionHandler) {
        self.followUserCompletionHandler(self.model);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFC0xF2F2F2();
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.userHeadImageView];
    [self.backView addSubview:self.nameLabel];
    [self.backView addSubview:self.postsLabel];
    [self.backView addSubview:self.beLikesLabel];
    [self.backView addSubview:self.followButton];
    [self.backView addSubview:self.showImagesContentView];
    [self.backView addSubview:self.rankImageView];

}

- (void)zfAutoLayoutView {
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(6, 12, 6, 12));
        make.height.mas_equalTo(185);
    }];
    [self.userHeadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(39, 39));
        make.leading.mas_equalTo(self.backView.mas_leading).offset(16);
        make.top.mas_equalTo(self.backView.mas_top).offset(16);
    }];
    self.userHeadImageView.layer.cornerRadius = 39.0 / 2;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userHeadImageView.mas_trailing).offset(10);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_centerY).offset(-2);
    }];
    
    [self.postsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel.mas_leading);
        make.top.mas_equalTo(self.userHeadImageView.mas_centerY).offset(2);
    }];
    
    [self.beLikesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.postsLabel.mas_trailing).offset(10);
        make.centerY.mas_equalTo(self.postsLabel.mas_centerY);
    }];
    
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.backView.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.userHeadImageView.mas_centerY).offset(-5);
        make.size.mas_equalTo(CGSizeMake(80, 26));
    }];
    
    [self.showImagesContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.backView);
        make.top.mas_equalTo(self.userHeadImageView.mas_bottom).offset(12);
        make.bottom.mas_equalTo(self.backView.mas_bottom).offset(-24);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userHeadImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userHeadImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
}

#pragma mark - setter
- (void)setModel:(ZFCommunitySuggestedUsersModel *)model {
    _model = model;
    [self.userHeadImageView yy_setImageWithURL:[NSURL URLWithString:_model.avatar]
                                   placeholder:[UIImage imageNamed:@"public_user"]
                                       options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                      progress:nil
                                     transform:nil
                                    completion:nil];
    
    self.nameLabel.text = _model.nickname;
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.postsLabel.text = [NSString stringWithFormat:@"%@ %@",_model.review_total,ZFLocalizedString(@"CommendUserCell_Posts",nil)];
        self.beLikesLabel.text = [NSString stringWithFormat:@"%@ %@",_model.likes_total,ZFLocalizedString(@"CommendUserCell_BeLiked",nil)];
    } else {
        self.postsLabel.text = [NSString stringWithFormat:@"%@ %@",ZFLocalizedString(@"CommendUserCell_Posts",nil),_model.review_total];
        self.beLikesLabel.text = [NSString stringWithFormat:@"%@ %@",ZFLocalizedString(@"CommendUserCell_BeLiked",nil),_model.likes_total];
    }
    self.followButton.hidden = _model.isFollow;
    @weakify(self)
    CGFloat width = (KScreenWidth - 39 - 24)/4;
    [self.showImagesContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.backView);
        make.top.mas_equalTo(self.userHeadImageView.mas_bottom);
        make.bottom.mas_equalTo(self.backView.mas_bottom).offset(-12);
        make.height.mas_equalTo(width);
    }];
    [_model.postlist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            @strongify(self)
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            NSString *img = [[self->_model.postlist objectAtIndex:idx] valueForKey:@"pic"];
            [imageView yy_setImageWithURL:[NSURL URLWithString:img]
                             placeholder:[UIImage imageNamed:@"community_loading_default"]
                                  options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 }
                                transform:^UIImage *(UIImage *image, NSURL *url) {
                                    return image;
                                }
                               completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                   if (from == YYWebImageFromDiskCache) {
                                   }
                               }];
            [self.showImagesContentView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.showImagesContentView.mas_centerY);
                make.width.height.mas_equalTo(width);
                make.leading.mas_equalTo(self.showImagesContentView.mas_leading).offset(12 + width *idx + 5 * idx);
            }];
        }
    }];
    
    self.rankImageView.hidden = YES;
    if ([_model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:_model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;        
    }
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
        _backView.layer.shadowOffset = CGSizeMake(2, 2);//偏移距离
        _backView.layer.shadowOpacity = 0.1;//不透明度
        _backView.layer.shadowRadius = 2;//半径
    }
    return _backView;
}

#pragma mark - getter
- (UIImageView *)userHeadImageView {
    if (!_userHeadImageView) {
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userHeadImageView.contentMode = UIViewContentModeScaleToFill;
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

- (UILabel *)beLikesLabel {
    if (!_beLikesLabel) {
        _beLikesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _beLikesLabel.font = [UIFont systemFontOfSize:12];
        _beLikesLabel.textColor = ZFCOLOR(170, 170, 170, 1.0);
    }
    return _beLikesLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.backgroundColor = [UIColor whiteColor];
        _followButton.tag = followBtnTag;
        _followButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _followButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_followButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_followButton setTitle:[NSString stringWithFormat:@"%@",ZFLocalizedString(@"Community_Follow",nil)] forState:UIControlStateNormal];
        _followButton.layer.borderWidth = MIN_PIXEL;
        _followButton.layer.cornerRadius = 2;
        _followButton.layer.masksToBounds = YES;
        [_followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _followButton.backgroundColor = ZFC0xFFFFFF();
    }
    return _followButton;
}

- (UIView *)showImagesContentView {
    if (!_showImagesContentView) {
        _showImagesContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _showImagesContentView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _showImagesContentView;
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
