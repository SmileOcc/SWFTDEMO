//
//  ZFCategoryPostListCell.m
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityCategoryPostListCell.h"
#import "ZFInitViewProtocol.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"

@interface ZFCommunityCategoryPostListCell()<ZFInitViewProtocol>

@property (nonatomic, strong) YYAnimatedImageView    *iconImg;
@end

@implementation ZFCommunityCategoryPostListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self setShadowAndCornerCell];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.iconImg];
}

- (void)zfAutoLayoutView {
    [self.iconImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter

- (void)setShowsModel:(GoodsShowExploreModel *)showsModel {
    _showsModel = showsModel;
    
    [self.iconImg yy_setImageWithURL:[NSURL URLWithString:showsModel.bigPic]
                         placeholder:[UIImage imageNamed:@"community_loading_product"]
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                           transform:^UIImage *(UIImage *image, NSURL *url) {
                               return image;
                           }
                          completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                          }];
}

- (void)setModel:(ZFCommunityCategoryPostItemModel *)model {
    _model = model;
    
    [self.iconImg yy_setImageWithURL:[NSURL URLWithString:model.pic.small_pic]
                         placeholder:[UIImage imageNamed:@"community_loading_product"]
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                           transform:^UIImage *(UIImage *image, NSURL *url) {
                               return image;
                           }
                          completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                          }];
}

- (YYAnimatedImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[YYAnimatedImageView alloc] init];
        _iconImg.contentMode = UIViewContentModeScaleAspectFill;
        _iconImg.layer.cornerRadius = 4;
        _iconImg.clipsToBounds = YES;
    }
    return _iconImg;
}
@end
