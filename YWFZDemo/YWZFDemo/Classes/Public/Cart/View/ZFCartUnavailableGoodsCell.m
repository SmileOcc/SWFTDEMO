//
//  ZFCartUnavailableGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartUnavailableGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartGoodsModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"

@interface ZFCartUnavailableGoodsCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *unavailableLabel;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) UIView                *sizeBgView;
@property (nonatomic, strong) UILabel               *sizeLabel;
@property (nonatomic, strong) UIImageView           *sizeArrowImageView;
@property (nonatomic, strong) UILabel               *stateLabel;
@property (nonatomic, strong) UIButton              *deleteButton;
@end

@implementation ZFCartUnavailableGoodsCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.unavailableLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.sizeBgView];
    [self.sizeBgView addSubview:self.sizeLabel];
    [self.sizeBgView addSubview:self.sizeArrowImageView];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.deleteButton];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(13);
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.size.mas_equalTo(CGSizeMake(90, 120));
    }];
    
    [self.unavailableLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.goodsImageView);
        make.width.mas_equalTo(80);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    self.unavailableLabel.layer.cornerRadius = 10;
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_top);
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(12);
        make.height.mas_equalTo(21);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(8);
        make.centerY.mas_equalTo(self.shopPriceLabel.mas_centerY);
        make.height.mas_equalTo(21);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom);
        make.leading.mas_equalTo(self.shopPriceLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-28);
        make.height.mas_equalTo(16);
    }];
    
    [self.sizeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
        make.leading.mas_equalTo(self.shopPriceLabel.mas_leading);
        make.trailing.mas_lessThanOrEqualTo(self.contentView.mas_trailing).offset(-28);
        make.height.mas_greaterThanOrEqualTo(18);
    }];
    
    CGFloat sizeMargin = 5;
    [self.sizeArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.sizeBgView.mas_trailing).offset(-sizeMargin);
        make.size.mas_equalTo(CGSizeMake(13, 13));
        make.centerY.mas_equalTo(self.sizeBgView.mas_centerY);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sizeBgView.mas_top).offset(sizeMargin);
        make.leading.mas_equalTo(self.sizeBgView.mas_leading).offset(sizeMargin);
        make.trailing.mas_lessThanOrEqualTo(self.sizeArrowImageView.mas_leading).offset(-sizeMargin);
        make.bottom.mas_equalTo(self.sizeBgView.mas_bottom).offset(-sizeMargin);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel);
        make.bottom.mas_equalTo(self.goodsImageView);
        make.height.mas_equalTo(24);
        make.width.mas_equalTo(0.0);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-7);
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

- (void)tapSimilarGoods {
    if (self.tapSimilarGoodsHandle) {
        self.tapSimilarGoodsHandle();
    }
}

- (void)deleteButtonAction:(UIButton *)button {
    if (self.deleteGoodsBlock) {
        self.deleteGoodsBlock(self.model);
    }
}

#pragma mark - setter
- (void)setModel:(ZFCartGoodsModel *)model {
    _model = model;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_model.wp_image]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                   }
                                  transform:^UIImage *(UIImage *image, NSURL *url) {
                                      image = [image yy_imageByResizeToSize:CGSizeMake(150 * 1, 200 * 1) contentMode:UIViewContentModeScaleAspectFit];
                                      return image;
                                  }
                                 completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                     if (from == YYWebImageFromDiskCache) {
                                         YWLog(@"load from disk cache");
                                     }
                                 }];
    
    self.titleLabel.text = _model.goods_title;
    self.shopPriceLabel.text = [ExchangeManager transforPrice:_model.shop_price];
    
    NSString *marketPrice = [ExchangeManager transPurePriceforPrice:_model.market_price];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];
    self.priceLabel.attributedText = attribtStr;
    
    NSMutableString *colorString = [NSMutableString new];
    if (_model.attr_color.length > 0
        && _model.attr_size.length > 0) {
        [colorString appendFormat:@"%@/%@", _model.attr_color, _model.attr_size];
        
    } else if (_model.attr_color.length > 0) {
        [colorString appendString:_model.attr_color];
        
    } else if (_model.attr_size.length > 0) {
        [colorString appendString:_model.attr_size];
    }
    self.sizeLabel.text = ZFToString(colorString);
    
    [self similarGoodsWithIsSimilar:model.is_similar];
}

- (void)similarGoodsWithIsSimilar:(BOOL)isSimilar {
    if (isSimilar) {
        self.unavailableLabel.text = _model.goods_state == 1 ? ZFLocalizedString(@"CartUnavailableGoodsTypeSoldOut", nil) : _model.goods_state == 2 ? ZFLocalizedString(@"CartUnavailableGoodsTypeOutOfStore", nil) : @"";
        self.stateLabel.text = ZFLocalizedString(@"cart_unline_findsimilar_tag", nil);
        
        self.stateLabel.font = [UIFont systemFontOfSize:14.0];
        self.stateLabel.layer.borderWidth = 1.0f;
        self.stateLabel.layer.borderColor = ZFC0xFE5269().CGColor;
        self.stateLabel.textAlignment     = NSTextAlignmentCenter;
        self.stateLabel.userInteractionEnabled = YES;
        [self updateDataStateLabelLayout];
    } else {
        self.stateLabel.text = _model.goods_state == 1 ? ZFLocalizedString(@"CartUnavailableGoodsTypeSoldOut", nil) : _model.goods_state == 2 ? ZFLocalizedString(@"CartUnavailableGoodsTypeOutOfStore", nil) : @"";
        self.unavailableLabel.text = ZFLocalizedString(@"CartUnavailableGoodsTips", nil);
        self.stateLabel.layer.borderWidth = 0.0f;
        self.stateLabel.font              = [UIFont boldSystemFontOfSize:16.0];
        self.stateLabel.textAlignment     = NSTextAlignmentLeft;
        self.stateLabel.userInteractionEnabled = NO;
        [self updateDataStateLabelLayout];
    }
}

- (void)updateDataStateLabelLayout {
    CGSize stateSize = [self.stateLabel.text sizeWithAttributes:@{ NSFontAttributeName:self.stateLabel.font }];
    [self.stateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(stateSize.width + 13.0 * 2);
    }];
}

#pragma mark - getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)unavailableLabel {
    if (!_unavailableLabel) {
        _unavailableLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unavailableLabel.backgroundColor = ZFCOLOR(0, 0, 0, 0.4f);
        _unavailableLabel.textColor = ZFCOLOR_WHITE;
        _unavailableLabel.font = [UIFont systemFontOfSize:12];
        _unavailableLabel.textAlignment = NSTextAlignmentCenter;
        _unavailableLabel.text = ZFLocalizedString(@"CartUnavailableGoodsTips", nil);
        _unavailableLabel.clipsToBounds = YES;
    }
    return _unavailableLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = ZFCOLOR(204, 204, 204, 1);
    }
    return _titleLabel;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:14];
        _shopPriceLabel.textColor = ZFCOLOR(204, 204, 204, 1);
    }
    return _shopPriceLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont boldSystemFontOfSize:12];
        _priceLabel.textColor = ZFCOLOR(204, 204, 204, 1);
    }
    return _priceLabel;
}

/// 选择规格
- (UIView *)sizeBgView {
    if (!_sizeBgView) {
        _sizeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _sizeBgView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _sizeBgView.clipsToBounds = YES;
    }
    return _sizeBgView;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textColor = ZFCOLOR(204, 204, 204, 1);
        _sizeLabel.numberOfLines = 2;
    }
    return _sizeLabel;
}

- (UIImageView *)sizeArrowImageView {
    if (!_sizeArrowImageView) {
        _sizeArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sizeArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _sizeArrowImageView.image = ZFImageWithName(@"cart_disabled_arrow_down");
    }
    return _sizeArrowImageView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.font = [UIFont boldSystemFontOfSize:16];
        _stateLabel.textColor = ZFC0xFE5269();
        _stateLabel.layer.cornerRadius = 2;
        _stateLabel.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(tapSimilarGoods)];
        [_stateLabel addGestureRecognizer:tapGesture];
    }
    return _stateLabel;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deleteButton setImage:[UIImage imageNamed:@"cart_delete_goods"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _deleteButton;
}

@end
