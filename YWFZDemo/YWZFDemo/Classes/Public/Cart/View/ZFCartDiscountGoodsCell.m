//
//  ZFCartDiscountGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartDiscountGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartNumberOptionView.h"
#import "ZFCartGoodsModel.h"
#import "ZFLabel.h"
#import "ZFMultiAttributeInfoView.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFRRPLabel.h"

@interface ZFCartDiscountGoodsCell () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView               *goodsImageView;
@property (nonatomic, strong) UIView                    *unavailableMask;
@property (nonatomic, strong) UILabel                   *soldOutLabel;
@property (nonatomic, strong) UILabel                   *titleLabel;
//v510 购物车去掉市场价https://axhub.im/pro/cab800d6cacd107a/#g=1&p=5_z-app-__rrp_____app__--___
//@property (nonatomic, strong) ZFRRPLabel                *markPriceLabel;
@property (nonatomic, strong) UILabel                   *shopPriceLabel;
@property (nonatomic, strong) UIView                    *sizeBgView;
@property (nonatomic, strong) UILabel                   *sizeLabel;
@property (nonatomic, strong) UIImageView               *sizeArrowImageView;
@property (nonatomic, strong) ZFMultiAttributeInfoView  *attrView;
@property (nonatomic, strong) ZFCartNumberOptionView    *countOptionView;
@end

@implementation ZFCartDiscountGoodsCell
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
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.goodsImageView];
    [self.goodsImageView addSubview:self.unavailableMask];
    [self.goodsImageView addSubview:self.soldOutLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.shopPriceLabel];
//    [self.contentView addSubview:self.markPriceLabel];
    [self.contentView addSubview:self.sizeBgView];
    [self.sizeBgView addSubview:self.sizeLabel];
    [self.sizeBgView addSubview:self.sizeArrowImageView];
    [self.contentView addSubview:self.attrView];
    [self.contentView addSubview:self.countOptionView];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(13);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(90, 120));
    }];
    
    [self.unavailableMask mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.soldOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.goodsImageView);
        make.width.mas_equalTo(80);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    self.soldOutLabel.layer.cornerRadius = 10;
    
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_top);
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-28);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
    }];
    
//    [self.markPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(8);
//        make.centerY.mas_equalTo(self.shopPriceLabel.mas_centerY);
//    }];
    
    [self.sizeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(22);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_lessThanOrEqualTo(self.titleLabel.mas_trailing);
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
    
    [self.attrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sizeBgView.mas_bottom);
        make.leading.mas_equalTo(self.shopPriceLabel.mas_leading);
        make.trailing.mas_equalTo(self.titleLabel.mas_trailing);
        make.height.mas_equalTo(0);
    }];
    
    [self.countOptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom).offset(-4);
        make.size.mas_equalTo(CGSizeMake(112, 30));
    }];
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
                                 completion:nil];
    
    self.titleLabel.text = _model.goods_title;
    self.shopPriceLabel.text = [ExchangeManager transforPrice:_model.shop_price];
    
    //折扣商品显示主题色
    if ([_model showMarketPrice]) {
        self.shopPriceLabel.textColor = ZFC0xFE5269();
    } else {
        self.shopPriceLabel.textColor = ZFCOLOR_BLACK;
    }
    
    self.sizeLabel.text = ZFToString(_model.cartSizeAttrTitle);
    self.attrView.hidden = _model.multi_attr.count <= 0;
    
    if (_model.multi_attr.count > 0) {
        self.attrView.attrsArray = _model.multi_attr;
        [self.attrView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.sizeBgView.mas_bottom);
            make.leading.mas_equalTo(self.shopPriceLabel.mas_leading);
            make.trailing.mas_equalTo(self.titleLabel.mas_trailing);
            make.height.mas_equalTo(self.model.multi_attr.count * 16);
        }];
    }
    self.countOptionView.maxGoodsNumber = ZFIsEmptyString(_model.manzeng_id) ? _model.goods_number : 1;
    self.countOptionView.goodsNumber = _model.buy_number;
    
    self.unavailableMask.hidden = YES;
    self.soldOutLabel.hidden = YES;
    if (!ZFIsEmptyString(_model.manzeng_id)) { // 赠品
        if (_model.is_valid) { //有效
            if (!_model.is_full) { //未达到满赠金额显示遮罩
                self.unavailableMask.hidden = NO;
            }
            if (!ZFIsEmptyString(_model.giftLeftMsg)) { //剩余件数
                self.soldOutLabel.hidden = NO;
                self.soldOutLabel.text = _model.giftLeftMsg;
            }
        } else { //失效: 显示sold Out
            self.soldOutLabel.hidden = NO;
            self.soldOutLabel.text = ZFLocalizedString(@"cart_soldOut", nil);
        }
    }
}

- (void)setShowEditFlag:(BOOL)showEditFlag {
    _showEditFlag = showEditFlag;
    self.countOptionView.hidden = !showEditFlag;
    self.sizeBgView.userInteractionEnabled = showEditFlag;
    if (showEditFlag) {
        self.sizeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        self.sizeArrowImageView.image = ZFImageWithName(@"cart_normal_arrow_down");
    } else {
        self.sizeLabel.textColor = ZFCOLOR(204, 204, 204, 1);
        self.sizeArrowImageView.image = ZFImageWithName(@"cart_disabled_arrow_down");
    }
}

#pragma mark - Private Method

- (void)selectedSizeAction:(UIButton *)button {
    if (self.selectedSizeBlock) {
        self.selectedSizeBlock(self.model);
    }
}

#pragma mark - getter

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UIView *)unavailableMask {
    if (!_unavailableMask) {
        _unavailableMask = [[UIView alloc] initWithFrame:CGRectZero];
        _unavailableMask.backgroundColor = ZFCOLOR(0, 0, 0, 0.4f);
        _unavailableMask.hidden = YES;
    }
    return _unavailableMask;
}

- (UILabel *)soldOutLabel {
    if (!_soldOutLabel) {
        _soldOutLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _soldOutLabel.backgroundColor = ZFCOLOR(0, 0, 0, 0.4f);
        _soldOutLabel.textColor = ZFCOLOR_WHITE;
        _soldOutLabel.font = [UIFont systemFontOfSize:12];
        _soldOutLabel.textAlignment = NSTextAlignmentCenter;
        _soldOutLabel.text = ZFLocalizedString(@"cart_soldOut", nil);
        _soldOutLabel.numberOfLines = 0;
        _soldOutLabel.clipsToBounds = YES;
        _soldOutLabel.hidden = YES;
    }
    return _soldOutLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = ZFC0x999999();
    }
    return _titleLabel;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:14];
        _shopPriceLabel.textColor = ZFC0xFE5269();
    }
    return _shopPriceLabel;
}

//- (ZFRRPLabel *)markPriceLabel {
//    if (!_markPriceLabel) {
//        _markPriceLabel = [[ZFRRPLabel alloc] initWithFrame:CGRectZero];
//        _markPriceLabel.font = [UIFont systemFontOfSize:12];
//        _markPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
//    }
//    return _markPriceLabel;
//}

/// 选择规格
- (UIView *)sizeBgView {
    if (!_sizeBgView) {
        _sizeBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _sizeBgView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _sizeBgView.clipsToBounds = YES;
        @weakify(self);
        [_sizeBgView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.selectedSizeBlock) {
                self.selectedSizeBlock(self.model);
            }
        }];
    }
    return _sizeBgView;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _sizeLabel.numberOfLines = 2;
    }
    return _sizeLabel;
}

- (UIImageView *)sizeArrowImageView {
    if (!_sizeArrowImageView) {
        _sizeArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sizeArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _sizeArrowImageView.image = ZFImageWithName(@"cart_normal_arrow_down");
    }
    return _sizeArrowImageView;
}

- (ZFMultiAttributeInfoView *)attrView {
    if (!_attrView) {
        _attrView = [[ZFMultiAttributeInfoView alloc] initWithFrame:CGRectZero];
        _attrView.hidden = YES;
    }
    return _attrView;
}

- (ZFCartNumberOptionView *)countOptionView {
    if (!_countOptionView) {
        _countOptionView = [[ZFCartNumberOptionView alloc] initWithFrame:CGRectZero];
        _countOptionView.backgroundColor = [UIColor clearColor];
        @weakify(self);
        _countOptionView.cartGoodsCountChangeCompletionHandler = ^(NSInteger number) {
            @strongify(self);
            if (number > 0) {
                self.model.buy_number = number;
            }
            if (self.changeNumberBlock) {
                self.changeNumberBlock(self.model, (number==0));
            }
        };
    }
    return _countOptionView;
}

@end
