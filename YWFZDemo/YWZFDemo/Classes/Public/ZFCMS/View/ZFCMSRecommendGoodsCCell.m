//
//  ZFCMSRecommendGoodsCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSRecommendGoodsCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"
#import "ZFLocalizationString.h"


@interface ZFCMSRecommendGoodsCCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) UIButton              *moreOperateButton;
@property (nonatomic, strong) UIView                *coverMaskView;
@property (nonatomic, strong) UIButton              *dislikeButton;
@property (nonatomic, assign) CGFloat               disLikeMinHeight;
@end

@implementation ZFCMSRecommendGoodsCCell

+ (ZFCMSRecommendGoodsCCell *)reusableRecommendGoodsCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.disLikeMinHeight = 28;
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
    self.goodsModel = nil;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.disLikeMinHeight = 28;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.priceLabel];
    
    [self.contentView addSubview:self.coverMaskView];
    [self.contentView addSubview:self.dislikeButton];
    [self.contentView addSubview:self.moreOperateButton];
}

- (void)zfAutoLayoutView {
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-kGoodsPriceHeight);
    }];
    
    [self.moreOperateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(kGoodsPriceHeight);
        make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(8);
    }];
    
    [self.coverMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.goodsImageView);
    }];
    
    [self.dislikeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.coverMaskView.mas_leading).offset(4);
        make.trailing.mas_equalTo(self.coverMaskView.mas_trailing).offset(-4);
        make.centerY.mas_equalTo(self.coverMaskView.mas_centerY);
        make.height.mas_greaterThanOrEqualTo(self.disLikeMinHeight);
    }];
}

- (void)actionMoreOperate:(UIButton *)sender {
    [self showCoverMaskView:self.coverMaskView.isHidden];
    if (self.coverShowBlock) {
        self.coverShowBlock(self.coverMaskView.isHidden);
    }
}

- (void)actionDislike:(UIButton *)sender {
    if (self.dislikeBlock) {
        self.dislikeBlock(self.goodsModel);
    }
}

- (void)showCoverMaskView:(BOOL)show {
    self.coverMaskView.hidden = !show;
    self.dislikeButton.hidden = !show;
}
#pragma mark - Setter

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    // 更新数据源
    [self updateGoodsImage:goodsModel.wp_image shopPrice:goodsModel.shop_price];
    // 推荐商品默认使用
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    self.priceLabel.backgroundColor = ZFCOLOR_WHITE;
    
    if ([goodsModel showMarketPrice]) {
        self.priceLabel.textColor = ZFC0xFE5269();
    } else {
        self.priceLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    
    self.coverMaskView.hidden = YES;
    self.dislikeButton.hidden = YES;
}

- (void)setIsNotNeedMoreOperate:(BOOL)isNotNeedMoreOperate {
    _isNotNeedMoreOperate = isNotNeedMoreOperate;
    self.moreOperateButton.hidden = isNotNeedMoreOperate;
    
//    if (isNotNeedMoreOperate) {
//        self.priceLabel.textAlignment = NSTextAlignmentCenter;
//    } else {
//        self.priceLabel.textAlignment = NSTextAlignmentLeft;
//    }
}

// 配置价格对齐位置
- (void)setAttributes:(ZFCMSAttributesModel *)attributes {
    _attributes = attributes;
    
    // 暂时讨论是注释掉的 v5.2.0 设计提供上下间距 8 12
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
    }
    return _priceLabel;
}

- (UIView *)coverMaskView {
    if (!_coverMaskView) {
        _coverMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _coverMaskView.backgroundColor = ZFC0x000000_04();
        _coverMaskView.hidden = YES;
    }
    return _coverMaskView;
}

- (UIButton *)dislikeButton {
    if (!_dislikeButton) {
        _dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dislikeButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _dislikeButton.titleLabel.font = [UIFont systemFontOfSize:11];
        [_dislikeButton setContentEdgeInsets:UIEdgeInsetsMake(4, 10, 4, 10)];
        _dislikeButton.backgroundColor = ZFC0xFFFFFF();
        _dislikeButton.titleLabel.numberOfLines = 2;
        _dislikeButton.layer.cornerRadius = self.disLikeMinHeight / 2.0;
        _dislikeButton.layer.masksToBounds = YES;
        [_dislikeButton addTarget:self action:@selector(actionDislike:) forControlEvents:UIControlEventTouchUpInside];
        _dislikeButton.hidden = YES;
        
        [_dislikeButton setTitle:ZFLocalizedString(@"Home_Don't_Like", nil) forState:UIControlStateNormal];
    }
    return _dislikeButton;
}

- (UIButton *)moreOperateButton {
    if (!_moreOperateButton) {
        _moreOperateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreOperateButton setImage:[UIImage imageNamed:@"more_operate_v"] forState:UIControlStateNormal];
        [_moreOperateButton addTarget:self action:@selector(actionMoreOperate:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreOperateButton;
}

@end
