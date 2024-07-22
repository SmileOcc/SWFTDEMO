//
//  ZFNativeSKUBannerGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 1/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFNativeSKUBannerGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFNativeSKUBannerGoodsCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel                   *priceLabel;
@property (nonatomic, strong) UILabel                   *viewMoreLabel;
@end

@implementation ZFNativeSKUBannerGoodsCell

+ (ZFNativeSKUBannerGoodsCell *)SKUGoodsListCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFNativeSKUBannerGoodsCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.goodsImageView addSubview:self.viewMoreLabel];
    [self.contentView addSubview:self.priceLabel];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = width / KImage_SCALE;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.viewMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goodsImageView.mas_bottom).offset(12);
        make.leading.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - Setter
- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.wp_image]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionAvoidSetImage
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                     if (image && stage == YYWebImageStageFinished) {
                                         self.goodsImageView.image = image;
                                     }
                                 }];
    
    
    self.priceLabel.text = self.isShowViewMore ? @"": [ExchangeManager transforPrice:goodsModel.shop_price];
}

- (void)setIsShowViewMore:(BOOL)isShowViewMore {
    _isShowViewMore = isShowViewMore;
    
    self.viewMoreLabel.hidden = !isShowViewMore;
}

#pragma mark - Getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
    }
    return _goodsImageView;
}


- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = ZFFontBoldSize(14);
        _priceLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _priceLabel;
}

- (UILabel *)viewMoreLabel {
    if (!_viewMoreLabel) {
        _viewMoreLabel = [[UILabel alloc] init];
        _viewMoreLabel.font = ZFFontSystemSize(14);
        _viewMoreLabel.textColor = ZFCOLOR(255, 255, 255, 1);
        _viewMoreLabel.backgroundColor = ZFCOLOR(0, 0, 0, 0.5);
        _viewMoreLabel.textAlignment = NSTextAlignmentCenter;
        _viewMoreLabel.numberOfLines = 0;
        _viewMoreLabel.preferredMaxLayoutWidth = self.contentView.width - 28;
        _viewMoreLabel.text = ZFLocalizedString(@"CartUnavailableViewMoreTips", nil);
        _viewMoreLabel.hidden = YES;
    }
    return _viewMoreLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.goodsImageView.image = nil;
    self.priceLabel.text = nil;
}


@end
