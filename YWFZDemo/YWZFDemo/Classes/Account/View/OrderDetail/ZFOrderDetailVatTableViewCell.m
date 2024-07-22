//
//  ZFOrderDetailVatTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailVatTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "Masonry.h"

@interface ZFOrderDetailVatTableViewCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UIButton              *tipsButton;
@property (nonatomic, strong) UILabel               *priceLabel;
@end

@implementation ZFOrderDetailVatTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)tipsButtonAction:(UIButton *)sender {
    if (self.orderDetaiVatTipsCompletionHandler) {
        self.orderDetaiVatTipsCompletionHandler(self.model.VATModel.tips);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tipsButton];
    [self.contentView addSubview:self.priceLabel];
}

- (void)zfAutoLayoutView {
 
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(4);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-4);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
    }];
    
    [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
}

#pragma mark - setter
- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    NSString *taxString = [ExchangeManager transAppendPrice:_model.VATModel.taxPrice currency:_model.order_currency rateModel:_model.order_exchange];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:taxString attributes:attribtDic];
    self.priceLabel.attributedText = attribtStr;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = ZFLocalizedString(@"TotalPrice_Cell_VAT", nil);
    }
    return _titleLabel;
}

- (UIButton *)tipsButton {
    if (!_tipsButton) {
        _tipsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tipsButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
        [_tipsButton addTarget:self action:@selector(tipsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tipsButton;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _priceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _priceLabel;
}

@end
