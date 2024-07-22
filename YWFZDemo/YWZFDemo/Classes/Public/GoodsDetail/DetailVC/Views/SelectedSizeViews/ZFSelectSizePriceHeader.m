//
//  ZFSelectSizePriceHeader.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSelectSizePriceHeader.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "ZFInitViewProtocol.h"
#import "ZFRRPLabel.h"
#import "GoodsDetailModel.h"
#import "ZFSizeSelectItemsModel.h"

@interface ZFSelectSizePriceHeader() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *shopPriceLabel;
@property (nonatomic, strong) ZFRRPLabel        *marketPriceLabel;
@property (nonatomic, strong) UILabel           *titleLabel;
@end


@implementation ZFSelectSizePriceHeader

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Setter

- (void)setGoodsDetailModel:(GoodsDetailModel *)goodsDetailModel {
    _goodsDetailModel = goodsDetailModel;

    self.titleLabel.text = ZFToString(goodsDetailModel.goods_name);
    
    self.shopPriceLabel.text = [ExchangeManager transforPrice:goodsDetailModel.shop_price];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[ExchangeManager transforPrice:goodsDetailModel.market_price]];
    
    [attriString addAttributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0, attriString.string.length)];
    self.marketPriceLabel.attributedText = attriString;

    if ([goodsDetailModel showMarketPrice]) {
        self.shopPriceLabel.textColor = ZFC0xFE5269();
        self.marketPriceLabel.hidden = NO;
    } else {
        self.shopPriceLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        self.marketPriceLabel.hidden = YES;
    }
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.shopPriceLabel];
    [self addSubview:self.marketPriceLabel];
    [self addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(5);
        make.leading.mas_equalTo(self.mas_leading).offset(12);
    }];
    
    [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shopPriceLabel.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.shopPriceLabel.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.shopPriceLabel.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
    }];
}

#pragma mark - getter

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.textColor = ZFC0xFE5269();
        _shopPriceLabel.font = ZFFontBoldSize(18);
    }
    return _shopPriceLabel;
}

- (ZFRRPLabel *)marketPriceLabel {
    if (!_marketPriceLabel) {
        _marketPriceLabel = [[ZFRRPLabel alloc] initWithFrame:CGRectZero];
        _marketPriceLabel.textColor = ZFC0x999999();
        _marketPriceLabel.font = ZFFontSystemSize(14);
        _marketPriceLabel.hidden = YES;
    }
    return _marketPriceLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = ZFFontSystemSize(16);
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

@end

