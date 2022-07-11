//
//  OSSVCategoryRefinesPriceCCell.m
// XStarlinkProject
//
//  Created by odd on 2021/4/16.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesPriceCCell.h"


@interface OSSVCategoryRefinesPriceCCell()<UITextFieldDelegate>

@end

@implementation OSSVCategoryRefinesPriceCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        self.mainView.hidden = YES;
        [self.contentView addSubview:self.minTextField];
        [self.contentView addSubview:self.minLabel];
        [self.contentView addSubview:self.minLineView];
        
        [self.contentView addSubview:self.maxTextField];
        [self.contentView addSubview:self.maxLabel];
        [self.contentView addSubview:self.maxLineView];
        
        
        [self.minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.trailing.mas_equalTo(self.minTextField.mas_trailing);
        }];
        
        [self.minTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.height.mas_equalTo(44);
        }];
        
        [self.minLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.minTextField.mas_leading);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.trailing.mas_equalTo(self.minTextField.mas_trailing);
            make.height.mas_equalTo(1);
        }];
        
        [self.maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.maxTextField.mas_leading);
            make.top.mas_equalTo(self.contentView.mas_top);
            make.trailing.mas_equalTo(self.maxTextField.mas_trailing);
        }];
        
        [self.maxTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.leading.mas_equalTo(self.minTextField.mas_trailing).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.width.mas_equalTo(self.minTextField.mas_width);
            make.height.mas_equalTo(44);
        }];
        
        [self.maxLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.maxTextField.mas_leading);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.trailing.mas_equalTo(self.maxTextField.mas_trailing);
            make.height.mas_equalTo(1);
        }];
        
    }
    return self;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (![string isEqualToString:@""]){ //增加字符
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    if (self.editBlock) {
        self.editBlock(STLToString(self.minTextField.text), STLToString(self.maxTextField.text));
    }
}

- (void)refinePriceMin:(NSString *)min max:(NSString *)max {
    self.minTextField.text = @"";
    self.maxTextField.text = @"";
    if (!STLIsEmptyString(min)) {
        self.minTextField.text = min;
    }
    if (!STLIsEmptyString(max)) {
        self.maxTextField.text = max;
    }
}
#pragma mark - setter/getter

- (UILabel *)minLabel {
    if (!_minLabel) {
        _minLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _minLabel.textColor = [OSSVThemesColors col_999999];
        _minLabel.font = [UIFont systemFontOfSize:11];
        _minLabel.text = STLLocalizedString_(@"category_filter_price_min", nil);
    }
    return _minLabel;
}

- (UITextField *)minTextField {
    if (!_minTextField) {
        _minTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"theme_min_price", nil) attributes:
                                           @{NSForegroundColorAttributeName:[OSSVThemesColors col_999999]}];
        _minTextField.attributedPlaceholder = attrString;
        _minTextField.keyboardType = UIKeyboardTypeNumberPad;
        _minTextField.font = [UIFont boldSystemFontOfSize:15];
        _minTextField.textColor = [OSSVThemesColors col_0D0D0D];
        _minTextField.delegate = self;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _minTextField.textAlignment = NSTextAlignmentRight;
        } else {
            _minTextField.textAlignment = NSTextAlignmentLeft;
        }

    }
    return _minTextField;
}

- (UIView *)minLineView {
    if (!_minLineView) {
        _minLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _minLineView.backgroundColor = [OSSVThemesColors col_CCCCCC];
    }
    return _minLineView;
}


- (UILabel *)maxLabel {
    if (!_maxLabel) {
        _maxLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _maxLabel.textColor = [OSSVThemesColors col_999999];
        _maxLabel.font = [UIFont systemFontOfSize:11];
        _maxLabel.text = STLLocalizedString_(@"category_filter_price_max", nil);;
    }
    return _maxLabel;
}


- (UITextField *)maxTextField {
    if (!_maxTextField) {
        _maxTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"theme_max_price", nil) attributes:
                                           @{NSForegroundColorAttributeName:[OSSVThemesColors col_999999]}];
        _maxTextField.attributedPlaceholder = attrString;
        _maxTextField.keyboardType = UIKeyboardTypeNumberPad;
        _maxTextField.font = [UIFont boldSystemFontOfSize:15];
        _maxTextField.textColor = [OSSVThemesColors col_0D0D0D];
        _maxTextField.delegate = self;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _maxTextField.textAlignment = NSTextAlignmentRight;
        } else {
            _maxTextField.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _maxTextField;
}

- (UIView *)maxLineView {
    if (!_maxLineView) {
        _maxLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _maxLineView.backgroundColor = [OSSVThemesColors col_CCCCCC];
    }
    return _maxLineView;
}


@end
