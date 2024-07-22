

//
//  ZFSubmitReviewCheckHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewCheckHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "Masonry.h"
#import "ZFReviewsDetailStarsView.h"
#import "ZFRRPLabel.h"

@interface ZFSubmitReviewCheckHeaderView() <ZFInitViewProtocol>

@property (nonatomic, strong )UIView                *lineView;
@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *shopPriceLabel;
@property (nonatomic, strong) ZFRRPLabel            *marketPriceLabel;
@property (nonatomic, strong) UILabel               *sizeLabel;
@property (nonatomic, strong) UILabel               *goodsNumLabel;
@property (nonatomic, strong) ZFReviewsDetailStarsView      *starsView;

@end

@implementation ZFSubmitReviewCheckHeaderView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.marketPriceLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.goodsNumLabel];
    [self.contentView addSubview:self.starsView];
}

- (void)zfAutoLayoutView {
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(10);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 120));
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.titleLabel);
    }];
    
    [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shopPriceLabel);
        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(10);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.titleLabel);
    }];
    
    [self.goodsNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(self.sizeLabel.mas_bottom);
    }];
    
    [self.starsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.goodsImageView.mas_bottom);
        make.leading.mas_equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
}

#pragma mark - setter
- (void)setModel:(ZFOrderReviewModel *)model {
    _model = model;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_model.goods_info.goods_grid]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
    self.titleLabel.text = _model.goods_info.goods_title;
    self.shopPriceLabel.text = [ExchangeManager transAppendPrice:_model.goods_info.goods_price  currency:_model.goods_info.order_currency];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[ExchangeManager transAppendPrice:_model.goods_info.market_price  currency:_model.goods_info.order_currency]];
    [attriString addAttributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0, attriString.string.length)];
    self.marketPriceLabel.attributedText = attriString;
    self.sizeLabel.text = _model.goods_info.attr_strs;
    
    NSInteger count = _model.goods_info.goods_number.integerValue;
    self.goodsNumLabel.text = [NSString stringWithFormat:@"X%ld", MAX(1, count)];
    self.starsView.rateAVG = _model.reviewList.firstObject.rate_overall;
}

#pragma mark - getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    }
    return _lineView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    return _shopPriceLabel;
}

- (ZFRRPLabel *)marketPriceLabel {
    if (!_marketPriceLabel) {
        _marketPriceLabel = [[ZFRRPLabel alloc] initWithFrame:CGRectZero];
        _marketPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _marketPriceLabel.font = [UIFont systemFontOfSize:12];
    }
    return _marketPriceLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _sizeLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _sizeLabel;
}

- (UILabel *)goodsNumLabel {
    if (!_goodsNumLabel) {
        _goodsNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsNumLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _goodsNumLabel.font = [UIFont systemFontOfSize:14];
        _goodsNumLabel.hidden = YES;
    }
    return _goodsNumLabel;
}

- (ZFReviewsDetailStarsView *)starsView {
    if (!_starsView) {
        _starsView = [[ZFReviewsDetailStarsView alloc] initWithFrame:CGRectZero withRateSize:CGSizeZero];
        _starsView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _starsView;
}

@end
