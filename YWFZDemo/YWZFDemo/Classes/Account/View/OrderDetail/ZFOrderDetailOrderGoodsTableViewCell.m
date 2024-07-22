//
//  ZFOrderDetailOrderGoodsTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailOrderGoodsTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ExchangeManager.h"
#import "Masonry.h"
#import "ZFRRPLabel.h"
#import "ZFWaitCommentModel.h"
#import "ZFLocalizationString.h"
#import "OrderDetailOrderModel.h"

@interface ZFOrderDetailOrderGoodsTableViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@property (nonatomic, strong) ZFRRPLabel            *marketPriceLabel;
@property (nonatomic, strong) UILabel               *sizeLabel;
@property (nonatomic, strong) UILabel               *numberLabel;
@property (nonatomic, strong) UIButton              *reviewButton;
@property (nonatomic, strong) UIView                *lineView;
@end

@implementation ZFOrderDetailOrderGoodsTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
- (NSString *)showCurrency:(NSString *)price {
    NSString *priceString = [ExchangeManager transAppendPrice:price currency:self.model.order_currency rateModel:self.orderDetailModel.order_exchange];
    return priceString;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.marketPriceLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.numberLabel];
    [self.contentView addSubview:self.reviewButton];
//    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 80));
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel);
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom);
    }];
    
    [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(8);
        make.centerY.mas_equalTo(self.shopPriceLabel);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
//        make.top.mas_equalTo(self.sizeLabel.mas_top);
        make.centerY.mas_equalTo(self.shopPriceLabel);
    }];
    
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.bottom.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(.5f);
//    }];

    [self.reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        make.height.mas_offset(25);
    }];
}

#pragma mark - setter
//- (void)setModel:(OrderDetailGoodModel *)model {
//    _model = model;
//    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_model.wp_image]
//                                placeholder:[UIImage imageNamed:@"loading_cat_list"]];
//    self.titleLabel.text = _model.goods_title;
//    self.sizeLabel.text = [NSString stringWithFormat:@"%@%@%@", _model.attr_color ?: @"", (_model.attr_color && _model.attr_size) ? @"/" : @"", _model.attr_size ?: @""];
//    self.shopPriceLabel.text = [self showCurrency:_model.goods_price];
//    self.numberLabel.text = [NSString stringWithFormat:@"X%@", _model.goods_number];
//}

- (void)configCellDataWithGoodsModel:(OrderDetailGoodModel *)goodsModel orderDetailModel:(OrderDetailOrderModel *)orderDetailModel {
    _model = goodsModel;
    _orderDetailModel = orderDetailModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_model.wp_image]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]];
    self.titleLabel.text = _model.goods_title;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@%@%@", _model.attr_color ?: @"", (_model.attr_color && _model.attr_size) ? @"/" : @"", _model.attr_size ?: @""];
    self.shopPriceLabel.text = [self showCurrency:_model.goods_price];
    self.numberLabel.text = [NSString stringWithFormat:@"X%@", _model.goods_number];
}

- (void)showReviewButtonState:(NSInteger)orderStatus
                        isCod:(BOOL)isCod
                     isReview:(NSUInteger)isReview
{
    self.reviewButton.hidden = YES;
    
    if (isCod) {
        if (orderStatus == 0 || orderStatus == 3 || orderStatus == 4) {
            self.reviewButton.hidden = isReview>0;
        }
    } else {
        if (orderStatus == 3 || orderStatus == 4) {
            self.reviewButton.hidden = isReview>0;
        }
    }
}

- (void)reviewButtonAction {
    if (self.touchReviewBlock) {
        ZFWaitCommentModel *model = [[ZFWaitCommentModel alloc] init];
        model.goods_title = self.model.goods_title;
        model.goods_id = self.model.goods_id;
        model.goods_attr_str = self.sizeLabel.text;
        model.goods_thumb = self.model.wp_image;
        self.touchReviewBlock(model);
    }
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

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.textColor = ZFC0x999999();
        _sizeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _sizeLabel;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _shopPriceLabel;
}

- (ZFRRPLabel *)marketPriceLabel {
    if (!_marketPriceLabel) {
        _marketPriceLabel = [[ZFRRPLabel alloc] initWithFrame:CGRectZero];
        _marketPriceLabel.textColor = ZFCOLOR(136, 136, 136, 1.0);
        _marketPriceLabel.font = [UIFont systemFontOfSize:14];
    }
    return _marketPriceLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _numberLabel.font = [UIFont systemFontOfSize:14];
    }
    return _numberLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

- (UIButton *)reviewButton {
    if (!_reviewButton) {
        _reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reviewButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reviewButton setBackgroundColor:[ZFCOLOR_WHITE colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_reviewButton addTarget:self action:@selector(reviewButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_reviewButton setTitle:ZFLocalizedString(@"Order_Comment", nil) forState:0];
        [_reviewButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _reviewButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        _reviewButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _reviewButton.layer.cornerRadius = 2;
        _reviewButton.layer.masksToBounds = YES;
        _reviewButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1).CGColor;
        _reviewButton.layer.borderWidth = 1;
        _reviewButton.hidden = YES;
    }
    return _reviewButton;
}

@end
