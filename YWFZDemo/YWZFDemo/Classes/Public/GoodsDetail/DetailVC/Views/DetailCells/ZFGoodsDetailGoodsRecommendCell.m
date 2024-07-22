//
//  ZFGoodsDetailGoodsRecommendCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsRecommendCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YYImage.h"
#import "UIImage+ZFExtended.h"
#import "Constants.h"
#import "GoodsDetailSameModel.h"
#import "GoodsDetailModel.h"

@interface ZFGoodsDetailGoodsRecommendCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel *shopPriceLabel;
@end

@implementation ZFGoodsDetailGoodsRecommendCell

@synthesize cellTypeModel = _cellTypeModel;
@synthesize indexPath = _indexPath;

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
        make.width.mas_offset(ThreeColumnGoodsImageWidth);
        make.height.mas_equalTo(ThreeColumnGoodsImageHeight);
    }];

    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.iconImageView);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(8);
        make.height.mas_equalTo(16);
    }];
}

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;

    NSArray *recommendArray = cellTypeModel.detailModel.recommendModelArray;
    if (recommendArray.count > self.indexPath.item) {
        _goodsModel = recommendArray[self.indexPath.item];
    }

    [self.iconImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.wp_image]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {

                                     if ([image isKindOfClass:[YYImage class]]) {
                                         YYImage *showImage = (YYImage *)image;
                                         if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                                             return image;
                                         }
                                     }
                                     return [image zf_drawImageToOpaque];
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
        _shopPriceLabel.backgroundColor = [UIColor whiteColor];
        _shopPriceLabel.textAlignment = NSTextAlignmentLeft;
        _shopPriceLabel.font = ZFFontBoldSize(14);
    }
    return _shopPriceLabel;
}


@end

