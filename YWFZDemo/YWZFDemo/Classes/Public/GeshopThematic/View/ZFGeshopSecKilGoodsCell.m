//
//  ZFGeshopSecKilGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSecKilGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"
#import "ZFCMSProgressView.h"
#import "ZFRRPLabel.h"
#import <YYWebImage/YYWebImage.h>
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFGeshopSectionModel.h"

#define kSecKillSkuPriceHeight          25.0
#define kSecKillSkuMarkPriceHeight      20.0
#define kSecKillSkuProgressHeight       5.0

@interface ZFGeshopSecKilGoodsCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) YYAnimatedImageView   *goodsImageView;
@property (nonatomic, strong) YYAnimatedImageView   *discountBgView;
@property (nonatomic, strong) UILabel               *discountLabel;
@property (nonatomic, strong) UILabel               *soldoutLabel;
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) ZFRRPLabel            *markerPriceLabel;
@property (nonatomic, strong) ZFCMSProgressView     *progressView;
@property (nonatomic, strong) UILabel               *countsLabel;
@property (nonatomic, strong) UIButton              *buyNowButton;
@end

@implementation ZFGeshopSecKilGoodsCell

+ (ZFGeshopSecKilGoodsCell *)reusableSecKillSkuCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
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
    self.priceLabel.text = nil;
    self.markerPriceLabel.text = nil;
    self.countsLabel.text = nil;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.discountBgView];
    [self.discountBgView addSubview:self.discountLabel];
    [self.contentView addSubview:self.soldoutLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.markerPriceLabel];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.countsLabel];
    [self.contentView addSubview:self.buyNowButton];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(187);
    }];
    
    [self.discountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(self.goodsImageView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.discountBgView.mas_centerX);
        make.centerY.mas_equalTo(self.discountBgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.soldoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.goodsImageView.mas_centerX);
        make.centerY.mas_equalTo(self.goodsImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(5);
        make.leading.trailing.mas_equalTo(self.contentView);
    }];
    
    [self.markerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(5);
        make.leading.trailing.mas_equalTo(self.contentView);
    }];

    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.markerPriceLabel.mas_bottom).offset(5);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(6);
    }];
    
    [self.countsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(4);
        make.leading.trailing.mas_equalTo(self.contentView);
    }];
    
    [self.buyNowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.countsLabel.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(30);
//        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    
    ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[self.indexPath.item];
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:listModel.goods_img]
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
    
    
    // 秒杀状态文案 0:默认 1:还未开始 2:已经开始 3:已经结束
    self.soldoutLabel.hidden = YES;
    NSString *soldoutTitl = nil;
    NSInteger status = sectionModel.component_data.countDownStatus;
    if (status == 1) {
        soldoutTitl = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"coming_soon", nil)];
        self.soldoutLabel.hidden = NO;
        
    } else if (status == 1) {
        soldoutTitl = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"Detail_Product_SoldOut", nil)];
        self.soldoutLabel.hidden = (listModel.stock_num <= 0) ? NO: YES;
        
    } else if (status == 3) {
        soldoutTitl = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"Seckil_ended", nil)];
        self.soldoutLabel.hidden = NO;
    }
    self.soldoutLabel.text = ZFToString(soldoutTitl);
    
    /// 秒杀价格
    self.priceLabel.text = [ExchangeManager transforPrice:listModel.tsk_price];
    
    NSString *priceColor = self.sectionModel.component_style.shop_price_color;
    self.priceLabel.textColor = [UIColor colorWithAlphaHexColor:priceColor
                                                   defaultColor:ZFCOLOR(45, 45, 45, 1)];
    
    NSString *kitBgColor = sectionModel.component_style.bg_color;
    UIColor *backgroundColor = [UIColor colorWithAlphaHexColor:kitBgColor
                                                  defaultColor:ZFCOLOR_WHITE];
    self.priceLabel.backgroundColor = backgroundColor;
    self.markerPriceLabel.backgroundColor = backgroundColor;
    self.markerPriceLabel.RRPColor = ZFC0x999999();
    self.markerPriceLabel.attributedText = nil;
    self.countsLabel.backgroundColor = backgroundColor;
    
    if (!ZFIsEmptyString(listModel.market_price)) {
        NSString *market_color_Str = self.sectionModel.component_style.market_price_color;
        UIColor *marketColor = [UIColor colorWithAlphaHexColor:market_color_Str
                                                  defaultColor:ZFC0x999999()];
        
        NSString *market_price = [ExchangeManager transforPrice:listModel.market_price];
        self.markerPriceLabel.RRPColor = marketColor;
        self.markerPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:ZFToString(market_price) attributes:@{
            NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName : marketColor
        }];;
    }
    
    /// 库存条
    NSInteger leftCount = listModel.tsk_total_num - listModel.tsk_sale_num;
    [self.progressView updateProgressMax:listModel.tsk_total_num min:leftCount];
    
    NSString *barTrackColor = self.sectionModel.component_style.bar_left_bg_color;
    self.progressView.trackColor = [UIColor colorWithAlphaHexColor:barTrackColor
                                                      defaultColor:ZFC0x333333()];
    
    NSString *barBackColor = self.sectionModel.component_style.bar_bg_color;
    self.progressView.backColor = [UIColor colorWithAlphaHexColor:barBackColor
                                                     defaultColor:ColorHex_Alpha(0xD8D8D8, 1.0)];
    
    /// 库存件数
    NSString *barTextColor = self.sectionModel.component_style.bar_text_color;
    self.countsLabel.textColor = [UIColor colorWithAlphaHexColor:barTextColor
                                                   defaultColor:ZFC0x333333()];
    self.countsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"Detail_Only_count_left", nil), [NSString stringWithFormat:@"%ld", (long)leftCount]];
    
    /// 立即购买按钮
    NSString *btnTitleColorStr = sectionModel.component_style.buynow_text_color;
    UIColor *btnTitleColor = [UIColor colorWithAlphaHexColor:btnTitleColorStr
                                           defaultColor:ZFC0xFFFFFF()];
    [self.buyNowButton setTitleColor:btnTitleColor forState:UIControlStateNormal];
    
    
    NSString *btnBgColorStr = sectionModel.component_style.buynow_bg_color;
    UIColor *btnBgColor = [UIColor colorWithAlphaHexColor:btnBgColorStr
    defaultColor:ZFC0xFFFFFF()];
    [self.buyNowButton setBackgroundColor:btnBgColor forState:UIControlStateNormal];
    [self.buyNowButton setBackgroundColor:[btnBgColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    /// 折扣
    self.discountBgView.hidden = (self.sectionModel.discount_style.show != 1 || listModel.discount <= 0);
    self.discountBgView.image = nil;
    
    NSString *discountBgcolor = self.sectionModel.discount_style.bg_color;
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

    } else if (!ZFIsEmptyString(discountBgcolor)){
        self.discountBgView.layer.masksToBounds = YES;
        self.discountBgView.backgroundColor = [UIColor colorWithAlphaHexColor:discountBgcolor
        defaultColor:ZFCOLOR(51, 51, 51, 1)];
    }

    /** 折扣标显示格式: [0: **%， 1： **%OFF] */
    if (self.sectionModel.discount_style.type == 1) {
        self.discountLabel.text = [NSString stringWithFormat:@"%ld%%\n%@", (long)listModel.discount, ZFLocalizedString(@"CartOrderInfo_ShippingMethodSubCell_Cell_OFF", nil)];
    } else {
        self.discountLabel.text = [NSString stringWithFormat:@"-%ld%%", (long)listModel.discount];
    }

    NSString *discountTextColor = self.sectionModel.discount_style.text_color;
    UIColor *discountColor = [UIColor colorWithAlphaHexColor:discountTextColor
                                                defaultColor:ZFCOLOR(51, 51, 51, 1)];
    self.discountLabel.textColor = discountColor;
    
}

#pragma mark - Getter
- (YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [YYAnimatedImageView new];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds  = YES;
        _goodsImageView.image = [UIImage imageNamed:@"index_banner_loading"];
    }
    return _goodsImageView;
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
        _discountLabel = [[UILabel alloc] init];
        _discountLabel.font = ZFFontSystemSize(13);
        _discountLabel.textColor = ZFC0xFFFFFF();
        _discountLabel.textAlignment = NSTextAlignmentCenter;
        _discountLabel.backgroundColor = [UIColor clearColor];
        _discountLabel.numberOfLines = 0;
        _discountLabel.layer.masksToBounds = YES;
        _discountLabel.layer.cornerRadius = 20;
    }
    return _discountLabel;
}

- (UILabel *)soldoutLabel {
    if (!_soldoutLabel) {
        _soldoutLabel = [[UILabel alloc] init];
        _soldoutLabel.font = ZFFontSystemSize(14);
        _soldoutLabel.textColor = ZFC0xFFFFFF();
        _soldoutLabel.backgroundColor = ColorHex_Alpha(0x333333, 0.6);
        _soldoutLabel.textAlignment = NSTextAlignmentCenter;
        _soldoutLabel.layer.masksToBounds = YES;
        _soldoutLabel.layer.cornerRadius = 40;
        _soldoutLabel.numberOfLines = 0;
        _soldoutLabel.hidden = YES;
    }
    return _soldoutLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = ZFFontBoldSize(16);
        _priceLabel.textColor = ZFC0x333333();
        _priceLabel.backgroundColor = [UIColor whiteColor];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}

- (ZFRRPLabel *)markerPriceLabel {
    if (!_markerPriceLabel) {
        _markerPriceLabel = [[ZFRRPLabel alloc] init];
        _markerPriceLabel.textColor = ZFC0x999999();
        _markerPriceLabel.font = ZFFontSystemSize(12);
        _markerPriceLabel.backgroundColor = [UIColor whiteColor];
        _markerPriceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _markerPriceLabel;
}

- (ZFCMSProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[ZFCMSProgressView alloc] initWithFrame:CGRectZero];
        _progressView.trackColor = ZFC0x333333();
        _progressView.backColor = ColorHex_Alpha(0xD8D8D8, 1.0);
        _progressView.max = 100;
        _progressView.min = 50;
    }
    return _progressView;
}

- (UILabel *)countsLabel {
    if (!_countsLabel) {
        _countsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countsLabel.backgroundColor = [UIColor whiteColor];
        _countsLabel.textColor = ZFC0x333333();
        _countsLabel.font = ZFFontSystemSize(12);
    }
    return _countsLabel;
}

- (UIButton *)buyNowButton {
    if (!_buyNowButton) {
        _buyNowButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buyNowButton setBackgroundColor:ZFC0x333333() forState:UIControlStateNormal];
        [_buyNowButton setBackgroundColor:ZFC0x333333() forState:UIControlStateHighlighted];
        [_buyNowButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_buyNowButton setTitle:ZFLocalizedString(@"SecKil_buy_now", nil) forState:UIControlStateNormal];
        _buyNowButton.titleLabel.font = ZFFontBoldSize(14);
        _buyNowButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _buyNowButton.userInteractionEnabled = NO;
    }
    return _buyNowButton;
}

@end
