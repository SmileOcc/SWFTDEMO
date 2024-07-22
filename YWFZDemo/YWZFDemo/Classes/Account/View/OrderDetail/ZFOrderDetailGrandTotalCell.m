
//
//  ZFOrderDetailGrandTotalCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailGrandTotalCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "Masonry.h"

@interface ZFOrderDetailGrandTotalCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *priceLabel;
@end

@implementation ZFOrderDetailGrandTotalCell
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

#pragma mark - private methods
- (NSString *)showCurrency:(NSString *)price {
    NSString *priceString = [ExchangeManager transAppendPrice:price currency:self.model.order_currency  rateModel:self.model.order_exchange];
    return priceString;
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.priceLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
}

#pragma mark - setter
- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    self.priceLabel.text = [self showCurrency:_model.grand_total];
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = ZFLocalizedString(@"OrderInfo_priceList_grandTotal", nil);
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
        _priceLabel.textColor = ZFC0x2D2D2D();
        _priceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _priceLabel;
}



@end
