//
//  OSSVPriceView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPriceView.h"

@implementation OSSVPriceView

- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor {
    if (self = [super initWithFrame:frame]) {
        
        self.font = font;
        self.textColor = textColor;
        
        [self addSubview:self.priceLabel];
        [self addSubview:self.descLabel];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self);
        }];
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.descLabel.mas_trailing).mas_offset(2);
            make.trailing.top.bottom.mas_equalTo(self);
        }];
        
        [self.descLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)updateFirstDesc:(NSString *)desc secondPrice:(NSString *)price {
    self.priceLabel.text = STLToString(price);
    self.descLabel.text = STLToString(desc);
}

- (void)setFont:(UIFont *)font {
    if (font) {
        _font = font;
        self.priceLabel.font = _font;
        self.descLabel.font = _font;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor) {
        _textColor = textColor;
        self.priceLabel.textColor = _textColor;
        self.descLabel.textColor = _textColor;
    }
}


- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont systemFontOfSize:11];
        _priceLabel.textColor = OSSVThemesColors.col_333333;
        _priceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return _priceLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:11];
        _descLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _descLabel;
}
@end
