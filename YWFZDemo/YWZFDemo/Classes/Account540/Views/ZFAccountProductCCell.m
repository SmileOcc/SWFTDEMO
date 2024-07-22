//
//  ZFAccountProductCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountProductCCell.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "Masonry.h"
#import "Constants.h"
#import <YYWebImage/YYWebImage.h>

#import "ExchangeManager.h"
#import "ZFGoodsModel.h"

@interface ZFAccountProductCCell()
@property (nonatomic, strong) UIImageView  *productImage;
@property (nonatomic, strong) UILabel      *priceLabel;
@end

@implementation ZFAccountProductCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.productImage];
        [self addSubview:self.priceLabel];
        
        CGFloat width = (KScreenWidth - kMarginSpace12 * 4) / 3 ;
        CGFloat showH = width / kGoodsImageRatio;
        [self.productImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(showH);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.productImage.mas_bottom).offset(8);
            make.leading.trailing.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.goodsModel = nil;
    self.productImage.image = nil;
    self.priceLabel.text = nil;
}

#pragma mark - Property Method

-(void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.productImage yy_setImageWithURL:[NSURL URLWithString:_goodsModel.wp_image]
                              placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                  options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 }
                                transform:^UIImage *(UIImage *image, NSURL *url) {
                                    return image;
                                }
                               completion:nil];
    self.priceLabel.text = [ExchangeManager transforPrice:_goodsModel.shop_price];
}

- (UIImageView *)productImage {
    if (!_productImage) {
        _productImage = [[UIImageView alloc] init];
        _productImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _productImage;
}

-(UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.numberOfLines = 1;
        _priceLabel.textColor = ZFC0x2D2D2D();
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}
@end
