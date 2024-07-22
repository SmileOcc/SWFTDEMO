//
//  ZFCMSSecKillSkuCell.m
//  ZZZZZ
//
//  Created by YW on 2019/3/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSSecKillSkuCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"
#import "SystemConfigUtils.h"

#import "ZFCMSProgressView.h"
#import "ZFRRPLabel.h"

#define kSecKillSkuPriceHeight          25.0
#define kSecKillSkuMarkPriceHeight      20.0

#define kSecKillSkuProgressHeight       5.0

@interface ZFCMSSecKillSkuCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) ZFRRPLabel            *markerPriceLabel;
@property (nonatomic, strong) ZFCMSProgressView     *progressView;
@property (nonatomic, strong) UILabel               *countsLabel;


@end

@implementation ZFCMSSecKillSkuCell

+ (ZFCMSSecKillSkuCell *)reusableSecKillSkuCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
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
    self.countsLabel.text = nil;
    
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.markerPriceLabel];
//    [self.contentView addSubview:self.progressView];
//    [self.contentView addSubview:self.countsLabel];
}

- (void)zfAutoLayoutView {
    
//    [self.countsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(20);
//        make.leading.trailing.mas_equalTo(self.contentView);
//        make.bottom.mas_equalTo(self.contentView).offset(-7);
//    }];
//
//    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(kSecKillSkuProgressHeight);
//        make.bottom.mas_equalTo(self.countsLabel.mas_top);
//    }];
    
//    [self.markerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(kSecKillSkuMarkPriceHeight);
//        make.bottom.mas_equalTo(self.progressView.mas_top).offset(-5);
//    }];
    
    [self.markerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(kSecKillSkuMarkPriceHeight);
        make.bottom.mas_equalTo(self.contentView).offset(-5);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.markerPriceLabel.mas_top).offset(5);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(kSecKillSkuPriceHeight);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.priceLabel.mas_top).offset(-2);
    }];
}

+ (CGFloat)cmsVerticalHeightNoContainImage {
//    return 20 + 7 + 5 + kSecKillSkuProgressHeight + kSecKillSkuMarkPriceHeight + kSecKillSkuPriceHeight - 5 + 2;
    return 5 + kSecKillSkuMarkPriceHeight + kSecKillSkuPriceHeight - 5 + 2;
}

#pragma mark - Setter

- (void)setItemModel:(ZFCMSItemModel *)itemModel {
    _itemModel = itemModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:itemModel.image]
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
    
    self.priceLabel.text = [ExchangeManager transforPrice:itemModel.shop_price];
    
    if (ZFIsEmptyString(itemModel.market_price)) {
        self.markerPriceLabel.attributedText = nil;
        
    } else {
        NSString *market_price = [ExchangeManager transforPrice:itemModel.market_price];
        NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:ZFToString(market_price) attributes:attribtDic];
        self.markerPriceLabel.attributedText = attribtStr;
    }
    
    self.priceLabel.textColor = self.itemModel.textSaleColor ? self.itemModel.textSaleColor : [UIColor blackColor];
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
        _priceLabel.textColor = ZFC0xFE5269();
        _priceLabel.backgroundColor = [UIColor whiteColor];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _priceLabel.textAlignment = NSTextAlignmentRight;
        }
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
        if ([SystemConfigUtils isRightToLeftShow]) {
            _markerPriceLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _markerPriceLabel;
}

- (ZFCMSProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[ZFCMSProgressView alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}

- (UILabel *)countsLabel {
    if (!_countsLabel) {
        _countsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countsLabel.backgroundColor = [UIColor whiteColor];
        _countsLabel.textColor = ZFC0x666666();
        _countsLabel.font = ZFFontSystemSize(10);
    }
    return _countsLabel;
}

@end
