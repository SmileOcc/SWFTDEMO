//
//  ZFGeshopGridGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopGridGoodsCell.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIImage+ZFExtended.h"
#import "ZFLocalizationString.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFCollocationBuyModel.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "UIColor+ExTypeChange.h"
#import "ZFGeshopSectionModel.h"
#import "ZFRRPLabel.h"

@interface ZFGeshopGridGoodsCell ()
@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *saleMarkLabel;
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@property (nonatomic, strong) ZFRRPLabel            *markPriceLabel;
@property (nonatomic, strong) YYAnimatedImageView   *discountBgView;
@property (nonatomic, strong) UILabel               *discountLabel;
@property (nonatomic, strong) UILabel               *soldOutLabel;
@end

@implementation ZFGeshopGridGoodsCell

@synthesize sectionModel = _sectionModel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat radius = 8;//self.sectionModel.component_style.item_radius;
    [self.contentView zfAddCorners:UIRectCornerAllCorners
                       cornerRadii:CGSizeMake(radius, radius)];
}

#pragma mark - setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;

    //是否显示整体样式，1显示整体样式，0显示单个样式
    CGFloat value = 228 / 171.0;
    CGFloat titleMargin = 12;
    if (sectionModel.component_style.box_is_whole == 1) {
        value = 212 / 159.0;
        titleMargin = 0;
    }
    [self.goodsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.goodsImageView.mas_width).multipliedBy(value);
    }];

    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(titleMargin);
    }];
    
    ZFGeshopSectionListModel *_listModel = nil;
    if (sectionModel.component_data.list.count > self.indexPath.item) {
        _listModel = sectionModel.component_data.list[self.indexPath.item];
    }
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_listModel.goods_img]
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
    
    self.soldOutLabel.hidden = (_listModel.goods_number > 0);

    NSString *marketPrice = [ExchangeManager transforPrice:_listModel.market_price];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];

    self.titleLabel.text = ZFToString(_listModel.goods_title);
    self.saleMarkLabel.text = ZFToString(self.sectionModel.shopPrice_style.text);
    self.markPriceLabel.attributedText = attribtStr;
    self.shopPriceLabel.text = [ExchangeManager transforPrice:_listModel.shop_price];

    NSString *text_color = self.sectionModel.shopPrice_style.text_color;
    self.shopPriceLabel.textColor = [UIColor colorWithAlphaHexColor:text_color
                                                   defaultColor:ZFCOLOR(45, 45, 45, 1)];

    self.discountBgView.hidden = (self.sectionModel.discount_style.show != 1 || _listModel.discount <= 0);
    if (self.discountBgView.isHidden) return;
    self.discountBgView.image = nil;
    
    NSString *bg_color = self.sectionModel.discount_style.bg_color;
    NSString *imageUrl = self.sectionModel.discount_style.bg_img;

    if (!ZFIsEmptyString(imageUrl)) {
        self.discountBgView.layer.masksToBounds = NO;
        [self.discountBgView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
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

    } else if (!ZFIsEmptyString(bg_color)){
        self.discountBgView.layer.masksToBounds = YES;
        self.discountBgView.backgroundColor = [UIColor colorWithAlphaHexColor:bg_color
        defaultColor:ZFCOLOR(51, 51, 51, 1)];
    }

    /** 折扣标显示格式: [0: **%， 1： **%OFF] */
    NSString *discounTitle = nil;
    if (self.sectionModel.discount_style.type == 1) {
        discounTitle = [NSString stringWithFormat:@"%ld%%\n%@", (long)_listModel.discount, ZFLocalizedString(@"CartOrderInfo_ShippingMethodSubCell_Cell_OFF", nil)];
    } else {
        discounTitle = [NSString stringWithFormat:@"-%ld%%", (long)_listModel.discount];
    }
    self.discountLabel.text = discounTitle;

    NSString *discountTextColor = self.sectionModel.discount_style.text_color;
    UIColor *discountColor = [UIColor colorWithAlphaHexColor:discountTextColor
    defaultColor:ZFCOLOR(51, 51, 51, 1)];
    self.discountLabel.textColor = discountColor;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.saleMarkLabel];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.markPriceLabel];
    [self.contentView addSubview:self.soldOutLabel];
    [self.goodsImageView addSubview:self.discountBgView];
    [self.discountBgView addSubview:self.discountLabel];
}

- (void)zfAutoLayoutView {
    CGFloat value = 212 / 159.0;
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.goodsImageView.mas_width).multipliedBy(value);
    }];
    
    [self.soldOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView).offset(12);
        make.trailing.mas_equalTo(self.goodsImageView).offset(-12);
        make.centerY.mas_equalTo(self.goodsImageView.mas_centerY);
        make.height.mas_equalTo(30);
    }];
    
    [self.discountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_top).offset(0);
        make.trailing.mas_equalTo(self.goodsImageView.mas_trailing).offset(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.discountBgView.mas_centerX);
        make.centerY.mas_equalTo(self.discountBgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.markPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-14);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
    }];
    
    [self.saleMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.bottom.mas_equalTo(self.markPriceLabel.mas_top).offset(-7);;
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.saleMarkLabel.mas_bottom);
        make.leading.mas_equalTo(self.saleMarkLabel.mas_trailing).offset(1);
    }];
}

#pragma mark - getter

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds = YES;
    }
    return _goodsImageView;
}

- (UILabel *)soldOutLabel {
    if (!_soldOutLabel) {
        _soldOutLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _soldOutLabel.font = [UIFont boldSystemFontOfSize:12];
        _soldOutLabel.backgroundColor = ZFCOLOR(0, 0, 0, 0.4);
        _soldOutLabel.textColor = ZFCOLOR(255, 255, 255, 1);
        _soldOutLabel.preferredMaxLayoutWidth = ( KScreenWidth - 24 * 2 + 9) / 2;
        _soldOutLabel.layer.cornerRadius = 15;
        _soldOutLabel.layer.masksToBounds = YES;
        _soldOutLabel.textAlignment = NSTextAlignmentCenter;
        NSString *title = ZFLocalizedString(@"cart_soldOut", nil);
        _soldOutLabel.text = [title uppercaseString];
        _soldOutLabel.hidden = YES;
    }
    return _soldOutLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.preferredMaxLayoutWidth = ( KScreenWidth - 24 * 2 + 9) / 2;
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)saleMarkLabel {
    if (!_saleMarkLabel) {
        _saleMarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _saleMarkLabel.font = [UIFont boldSystemFontOfSize:13];
        _saleMarkLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _saleMarkLabel.numberOfLines = 1;
    }
    return _saleMarkLabel;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:18];
        _shopPriceLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _shopPriceLabel.numberOfLines = 1;
    }
    return _shopPriceLabel;
}

- (ZFRRPLabel *)markPriceLabel {
    if (!_markPriceLabel) {
        _markPriceLabel = [[ZFRRPLabel alloc] initWithFrame:CGRectZero];
        _markPriceLabel.font = [UIFont systemFontOfSize:12];
        _markPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _markPriceLabel.numberOfLines = 1;
    }
    return _markPriceLabel;
}

- (YYAnimatedImageView *)discountBgView {
    if (!_discountBgView) {
        _discountBgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _discountBgView.backgroundColor = ZFCOLOR(51, 51, 51, 1);
        _discountBgView.layer.cornerRadius = 20;//因为宽度固定为40
        _discountBgView.layer.masksToBounds = YES;
        _discountBgView.hidden = YES;
    }
    return _discountBgView;
}

- (UILabel *)discountLabel {
    if (!_discountLabel) {
        _discountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _discountLabel.font = [UIFont systemFontOfSize:12];
        _discountLabel.textColor = ZFCOLOR_WHITE;
        _discountLabel.numberOfLines = 2;
        _discountLabel.textAlignment = NSTextAlignmentCenter;
        _discountLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _discountLabel;
}
@end
