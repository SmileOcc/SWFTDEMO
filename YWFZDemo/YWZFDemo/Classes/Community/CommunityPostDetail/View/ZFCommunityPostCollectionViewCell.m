//
//  ZFCommunityTopicCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostCollectionViewCell.h"
#import "ZFCommunityPostDetailViewModel.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFLocalizationString.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"

static CGFloat const kUserImageViewHeight = 25.0;
@interface ZFCommunityPostCollectionViewCell ()

@property (nonatomic, strong) UIImageView                *imageView;
@property (nonatomic, strong) UILabel                    *contentLabel;
@property (nonatomic, strong) UIImageView                *userImageView;
@property (nonatomic, strong) UIImageView                *rankImageView;
@property (nonatomic, strong) UILabel                    *nickNameLabel;
@property (nonatomic, strong) UIButton                   *likedButton;

@end

@implementation ZFCommunityPostCollectionViewCell

+ (ZFCommunityPostCollectionViewCell *)topicCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *identifer = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:identifer];
    ZFCommunityPostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
        [self setShadowAndCornerCell];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.rankImageView];
    [self.contentView addSubview:self.nickNameLabel];
    [self.contentView addSubview:self.likedButton];
}

- (void)layout {
    CGFloat imageWidt = [ZFCommunityTopicDetailRelateSection relateCellWidth];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.width.mas_equalTo(imageWidt);
        make.height.mas_equalTo(0.0);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(12.0);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(5.0);
        make.trailing.mas_equalTo(self.contentView).offset(-12.0);
        make.height.mas_equalTo(14.0);
    }];
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(12.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(6.0);
        make.width.height.mas_equalTo(kUserImageViewHeight);
    }];
    
    [self.rankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.userImageView.mas_trailing);
        make.bottom.mas_equalTo(self.userImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    [self.likedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView).offset(-12.0);
        make.centerY.mas_equalTo(self.userImageView.mas_centerY).offset(1);
        make.height.mas_equalTo(44);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userImageView.mas_centerY);
        make.trailing.mas_equalTo(self.likedButton.mas_leading).offset(-4.0);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(4.0);
    }];
    
    
    [self.likedButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.likedButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    [self.nickNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.contentView layoutIfNeeded];
}

- (void)configWithViewModel:(ZFCommunityPostDetailViewModel *)viewModel indexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityPostListInfoModel *model = [[viewModel relateSectionWithSection:indexPath.section] topicPicModelWithIndex:indexPath.item];
    
    self.infoModel = model;
    
    CGFloat height = [[viewModel relateSectionWithSection:indexPath.section] imageRateWidthToHeight:indexPath.item] * self.imageView.width;
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    //图片
    if (!self.infoModel.randomColor) {
        self.infoModel.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.imageView.backgroundColor = self.infoModel.randomColor;

    [self.imageView yy_setImageWithURL:[NSURL URLWithString:[[viewModel relateSectionWithSection:indexPath.section] topicImageURLWithIndex:indexPath.item]]
                          placeholder:nil];
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:[[viewModel relateSectionWithSection:indexPath.section] topicUserImageURLWithIndex:indexPath.item]]
                          placeholder:[UIImage imageNamed:@"public_user"]];
    
    self.rankImageView.hidden = YES;
    if ([model.identify_type integerValue] > 0) {
        [self.rankImageView yy_setImageWithURL:[NSURL URLWithString:model.identify_icon] options:kNilOptions];
        self.rankImageView.hidden = NO;
    }
    
    
    NSString *contentString   = [[viewModel relateSectionWithSection:indexPath.section] topicListContentWithIndex:indexPath.item];
    self.contentLabel.text    = contentString;
    CGFloat contentHeight = 14.0;
    CGFloat cellWidth  = (KScreenWidth - 12.0 * 3) / 2;
    CGSize contentSize = [contentString sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
    if (contentSize.width > cellWidth - 24.0) {
        contentHeight = 32.0;
    }
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentHeight);
    }];
    
    self.nickNameLabel.text   = [[viewModel relateSectionWithSection:indexPath.section] topicUserNickNameWithIndex:indexPath.item];
    self.likedButton.selected = [[viewModel relateSectionWithSection:indexPath.section] topicIsLikedWithIndex:indexPath.item];
    
    NSInteger likeNum = [[[viewModel relateSectionWithSection:indexPath.section] topicLikeNumWithIndex:indexPath.item] integerValue];
    if (likeNum > 0) {
        NSString *likeStr = [NSString stringWithFormat:@"%zd",likeNum];
        if (likeNum >= 10000) {
            likeStr = @"9.9k+";
        }
        [self.likedButton setTitle:likeStr forState:UIControlStateNormal];
        self.likedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    } else {
        [self.likedButton setTitle:@"" forState:UIControlStateNormal];
        self.likedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
}

- (void)likedButtonAction:(UIButton *)sender {
    if (self.likeTopicHandle) {
        [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScale] forKey:@"cellLike"];
        self.likeTopicHandle();
    }
}

#pragma mark - getter/setter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:12.0];
        _contentLabel.textColor = [UIColor colorWithHex:0x666666];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] init];
        _userImageView.layer.cornerRadius  = kUserImageViewHeight / 2;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:12.0];
        _nickNameLabel.textColor = ZFC0x999999();
    }
    return _nickNameLabel;
}

- (UIButton *)likedButton {
    if (!_likedButton) {
        _likedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likedButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_likedButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [_likedButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_likedButton setImage:[UIImage imageNamed:@"Community_like_gray"] forState:UIControlStateNormal];
        UIImage *likeImage = [UIImage imageNamed:@"Community_like_red"];
        [_likedButton setImage:[likeImage imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        [_likedButton addTarget:self action:@selector(likedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_likedButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_likedButton convertUIWithARLanguage];
    }
    return _likedButton;
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
