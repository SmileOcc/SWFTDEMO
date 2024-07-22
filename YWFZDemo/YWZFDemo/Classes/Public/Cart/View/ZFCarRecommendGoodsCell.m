//
//  ZFCarRecommendGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/4.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCarRecommendGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"

// 购物车推荐商品Cell的宽度
#define kCarRecommendImageWidth   (130 * 1)
// 购物车推荐商品Cell的高度
#define kCarRecommendImageHeight   (173 * 1)

@interface ZFCarRecommendGoodsCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@end

@implementation ZFCarRecommendGoodsCell
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.shopPriceLabel];
}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.contentView);
        make.width.mas_offset(kCarRecommendImageWidth);
        make.height.mas_equalTo(kCarRecommendImageHeight);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(12);
        //make.bottom.mas_equalTo(self.contentView).offset(-21);
    }];
}

#pragma mark - setter
- (void)setGoodsModel:(ZFGoodsModel *)model {
    _goodsModel = model;
    [self.iconImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.wp_image]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {
                                     return image;
                                 }
                                completion:nil];
    self.shopPriceLabel.text = [ExchangeManager transforPrice: _goodsModel.shop_price];
    
    if ([_goodsModel showMarketPrice]) {
        self.shopPriceLabel.textColor = ZFC0xFE5269();
    } else {
        self.shopPriceLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _shopPriceLabel.font = ZFFontBoldSize(14);
        _shopPriceLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _shopPriceLabel.textAlignment = NSTextAlignmentRight;
        }
        
    }
    return _shopPriceLabel;
}


@end
