//
//  ZFCommunityPostDetailCommentCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostDetailCommentCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"


@interface ZFCommunityPostDetailCommentCCell ()<ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView                   *userImageView;
@property (nonatomic, strong) UILabel                       *userNameLabel;
@property (nonatomic, strong) UILabel                       *commentLabel;


@property (nonatomic, strong) ZFCommunityPostDetailReviewsListMode           *model;

@end


@implementation ZFCommunityPostDetailCommentCCell

+ (ZFCommunityPostDetailCommentCCell *)commentCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *identifer = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:identifer];
    ZFCommunityPostDetailCommentCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        
    }
    return self;
}


- (void)zfInitView {
    
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.commentLabel];
}

- (void)zfAutoLayoutView {
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(6);
        make.bottom.mas_equalTo(self.userImageView.mas_centerY).offset(-1);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(6);
        make.top.mas_equalTo(self.userImageView.mas_centerY).offset(1);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
}

- (void)configWithViewModel:(ZFCommunityPostDetailReviewsListMode *)viewModel {
    self.model = viewModel;
}

- (void)setModel:(ZFCommunityPostDetailReviewsListMode *)model {
    _model = model;
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:model.avatar]
    placeholder:[UIImage imageNamed:@"index_cat_loading"]
        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
       progress:nil
      transform:^UIImage *(UIImage *image, NSURL *url) {
          if ([image isKindOfClass:[YYImage class]]) {
              YYImage *showImage = (YYImage *)image;
              if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                  return image;
              }
          }
          return [image zf_imageByResizeToSize:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFill];
      }
     completion:nil];
    
    NSString *commentStr = [ZFToString(_model.content) stringByRemovingPercentEncoding];

    self.userNameLabel.text = ZFToString(_model.nickname);
    self.commentLabel.text = commentStr;
}

#pragma mark - Property Method

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.layer.cornerRadius = 16;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNameLabel.textColor = ZFC0x999999();
        _userNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _userNameLabel;
}

- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentLabel.textColor = ZFC0x2D2D2D();
        _commentLabel.font = [UIFont systemFontOfSize:14];
        _commentLabel.numberOfLines = 0;
    }
    return _commentLabel;
}

+ (CGFloat)fetchReviewCellHeight:(ZFCommunityPostDetailReviewsListMode *)reviewModel {
    
    ZFCommunityPostDetailCommentCCell *reviewCell = [[ZFCommunityPostDetailCommentCCell alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    reviewCell.model = reviewModel;
    [reviewCell layoutIfNeeded];
    CGFloat calculateHeight = CGRectGetMaxY(reviewCell.commentLabel.frame) + 10;
    return calculateHeight < 52 ? 52 : calculateHeight;
}
@end
