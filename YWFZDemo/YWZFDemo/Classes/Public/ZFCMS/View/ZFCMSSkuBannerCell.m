//
//  ZFCMSSkuBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSSkuBannerCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"
#import "SystemConfigUtils.h"

@interface ZFCMSSkuBannerCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *priceLabel;
@end

@implementation ZFCMSSkuBannerCell

+ (ZFCMSSkuBannerCell *)reusableSkuBannerCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
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

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.goodsImageView yy_cancelCurrentImageRequest];
    self.goodsImageView.image = nil;
    self.priceLabel.text = nil;
    self.itemModel = nil;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.priceLabel];
}

- (void)zfAutoLayoutView {
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(kGoodsPriceHeight);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.priceLabel.mas_top);
    }];
}

#pragma mark - Setter

- (void)setItemModel:(ZFCMSItemModel *)itemModel {
    _itemModel = itemModel;
    // 更新数据源
    [self updateGoodsImage:itemModel.image shopPrice:itemModel.shop_price];
}

// 配置价格对齐位置
- (void)setAttributes:(ZFCMSAttributesModel *)attributes {
    _attributes = attributes;
    
//    ZFCMSModulePosition position = [attributes.text_align integerValue];
//    switch (position) {
//        case ZFCMSModulePositionCenterLeft: {
//            [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(self.contentView.mas_left).offset(attributes.countdown_padding_left);
//                make.height.mas_equalTo(kGoodsPriceHeight);
//                make.bottom.mas_equalTo(self.contentView);
//            }];
//        }
//            break;
//        case ZFCMSModulePositionCenterRight: {
//            [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.right.mas_equalTo(self.contentView.mas_right).offset(-attributes.countdown_padding_right);
//                make.height.mas_equalTo(kGoodsPriceHeight);
//                make.bottom.mas_equalTo(self.contentView);
//            }];
//        }
//            break;
//        default: // 默认价格位置为: 居中
//            [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.mas_equalTo(self.contentView.mas_centerX);
//                make.height.mas_equalTo(kGoodsPriceHeight);
//                make.bottom.mas_equalTo(self.contentView);
//            }];
//            break;
//    }
}

/** 更新数据源 */
- (void)updateGoodsImage:(NSString *)goodsImage shopPrice:(NSString *)shopPrice
{
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsImage]
                                 placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:^UIImage *(UIImage *image, NSURL *url) {
                                       if ([image isKindOfClass:[YYImage class]]) {
                                           YYImage *showImage = (YYImage *)image;
                                           if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                                               return image;
                                           }
                                       }
                                       return [image zf_drawImageToOpaque];
                                   } completion:nil];
    self.priceLabel.text = [ExchangeManager transforPrice:shopPrice];
}

/**
 * 设置背景颜色
 */
- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor {
    _cellBackgroundColor = cellBackgroundColor;
    self.contentView.backgroundColor = cellBackgroundColor;
    self.priceLabel.backgroundColor = cellBackgroundColor;
}

#pragma mark - Getter
- (YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [YYAnimatedImageView new];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds  = YES;
    }
    return _goodsImageView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = ZFFontBoldSize(14);
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _priceLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _priceLabel;
}

@end
