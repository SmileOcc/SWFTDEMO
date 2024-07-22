//
//  ZFCategoryRefinePriceCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefinePriceCCell.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFProgressHUD.h"

@interface ZFCategoryRefinePriceCCell()<UITextFieldDelegate>

@end

@implementation ZFCategoryRefinePriceCCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.mainView.hidden = YES;
    }
    return self;
}

- (void)refinePriceMin:(NSString *)min max:(NSString *)max {
    self.minPriceTextField.text = @"";
    self.maxPriceTextField.text = @"";
    if (!ZFIsEmptyString(min)) {
        self.minPriceTextField.text = min;
    }
    if (!ZFIsEmptyString(max)) {
        self.maxPriceTextField.text = max;
    }
}
- (void)zfInitView {
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.minPriceTextField];
    [self.contentView addSubview:self.maxPriceTextField];
}

- (void)zfAutoLayoutView {
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(38, 1));
    }];
    
    [self.minPriceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.mas_leading);
        make.trailing.mas_equalTo(self.lineView.mas_leading).offset(-12);
        make.height.mas_equalTo(28);
    }];
    
    [self.maxPriceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.leading.mas_equalTo(self.lineView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.height.mas_equalTo(28);
    }];
}

//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//
//    // 获得每个cell的属性集
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    // 计算cell里面textfield的宽度
//    CGRect frame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font,NSFontAttributeName, nil] context:nil];
//
//    // 如果内容宽度 大于显示cell的宽度，显示会卡死
//    CGFloat maxW = 150;
//    if (self.superview) {
//        CGFloat suprW = CGRectGetWidth(self.superview.frame);
//        if (suprW > maxW) {
//            maxW = suprW - 24;
//        }
//    }
//
//    if (frame.size.width >= maxW) {
//        frame.size.width = maxW;
//    }
//
//    CGRect frame = CGRectZero;
//    frame.size.width = CGRectGetWidth(self.superview.frame);
//    frame.size.height = 28;
//
//    // 重新赋值给属性集
//    attributes.frame = frame;
//
//    return attributes;
//}

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth {
    CGSize size = CGSizeMake(maxWidth, 28);
    return size;
}

- (void)updatePlaceholder:(NSString *)min max:(NSString *)max {
    
    self.min = ZFToString(min);
    self.max = ZFToString(max);
    
    if (ZFIsEmptyString(min)) {
        min = ZFLocalizedString(@"Gategory_Search_Price_Min", nil);
    }
    if (ZFIsEmptyString(max)) {
        max = ZFLocalizedString(@"Gategory_Search_Price_Max", nil);
    }
    
    NSMutableAttributedString *placeholderStr = [[NSMutableAttributedString alloc] initWithString:min];
    [placeholderStr addAttribute:NSForegroundColorAttributeName value:ZFC0xCCCCCC() range:NSMakeRange(0, min.length)];
    
    self.minPriceTextField.attributedPlaceholder = placeholderStr;
    
     NSMutableAttributedString *maxPlaceholderStr = [[NSMutableAttributedString alloc] initWithString:max];
     [maxPlaceholderStr addAttribute:NSForegroundColorAttributeName value:ZFC0xCCCCCC() range:NSMakeRange(0, max.length)];
     
     self.maxPriceTextField.attributedPlaceholder = maxPlaceholderStr;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (![string isEqualToString:@""]){ //增加字符
        NSString *counts = [NSString stringWithFormat:@"%@%@", textField.text, string];
        if (self.maxPriceTextField == textField && !ZFIsEmptyString(self.max) && [counts integerValue] > [self.max integerValue]) {
            textField.text = self.max;
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

    NSString *counts = ZFToString(textField.text);
    if (self.maxPriceTextField == textField && !ZFIsEmptyString(self.max) && [counts integerValue] > [self.max integerValue]) {
        textField.text = self.max;

    } else if (self.maxPriceTextField == textField && !ZFIsEmptyString(self.min) && !ZFIsEmptyString(self.max) && [counts integerValue] < [self.min integerValue]) {
        
        NSInteger maxCount = [self.min integerValue] + 1;
        if ([self.minPriceTextField.text integerValue] > [self.min integerValue]) {
            if ([self.minPriceTextField.text integerValue] + 1 >= [self.max integerValue] || [self.maxPriceTextField.text integerValue] <= 0) {
                maxCount = [self.max integerValue];
            } else {
                maxCount = [self.minPriceTextField.text integerValue] + 1;
            }
        } else if([self.maxPriceTextField.text integerValue] <= 0) {
            maxCount = [self.max integerValue];
        }
        textField.text = [NSString stringWithFormat:@"%li",maxCount];
        
    } else if (self.maxPriceTextField == textField && [self.maxPriceTextField.text integerValue] > 0) {
        if ([self.maxPriceTextField.text integerValue] < [self.minPriceTextField.text integerValue]) {
            if (!ZFIsEmptyString(self.max) && ([self.minPriceTextField.text integerValue] + 1) < [self.max integerValue]) {
                textField.text = [NSString stringWithFormat:@"%li",([self.minPriceTextField.text integerValue] + 1)];
                
            } else if(!ZFIsEmptyString(self.max) && ([self.minPriceTextField.text integerValue] + 1) >= [self.max integerValue]) {
                textField.text = self.max;
                
            } else {
                textField.text = [NSString stringWithFormat:@"%li",([self.minPriceTextField.text integerValue] + 1)];
            }
        }
    }
    else if (self.minPriceTextField == textField && !ZFIsEmptyString(self.min) && [counts integerValue] < [self.min integerValue]) {
        textField.text = self.min;
        
    } else if(self.minPriceTextField == textField && !ZFIsEmptyString(self.min) && !ZFIsEmptyString(self.max) && [counts integerValue] >= [self.min integerValue] && [counts integerValue] > [self.max integerValue]) {
        textField.text = [NSString stringWithFormat:@"%li",([self.max integerValue] - 1)];
    }
    
    if (self.editBlock) {
        self.editBlock(ZFToString(self.minPriceTextField.text), ZFToString(self.maxPriceTextField.text));
    }
}
#pragma mark - Property Method

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFC0xF7F7F7();
    }
    return _lineView;
}
- (UITextField *)minPriceTextField {
    if (!_minPriceTextField) {
        _minPriceTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _minPriceTextField.textAlignment = NSTextAlignmentCenter;
        _minPriceTextField.keyboardType = UIKeyboardTypeNumberPad;
        _minPriceTextField.backgroundColor = ZFC0xF7F7F7();
        _minPriceTextField.layer.cornerRadius = 2.0;
        _minPriceTextField.layer.masksToBounds = YES;
        _minPriceTextField.textColor = ZFC0x2D2D2D();
        _minPriceTextField.font = [UIFont systemFontOfSize:12];
        _minPriceTextField.delegate = self;
        
        NSString *placedholder = [NSString stringWithFormat:@"%@", ZFLocalizedString(@"Gategory_Search_Price_Min", nil)];
        NSMutableAttributedString *placeholderStr = [[NSMutableAttributedString alloc] initWithString:placedholder];
        [placeholderStr addAttribute:NSForegroundColorAttributeName value:ZFC0xCCCCCC() range:NSMakeRange(0, placedholder.length)];
        
        _minPriceTextField.attributedPlaceholder = placeholderStr;
    }
    return _minPriceTextField;
}


- (UITextField *)maxPriceTextField {
    if (!_maxPriceTextField) {
        _maxPriceTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _maxPriceTextField.textAlignment = NSTextAlignmentCenter;
        _maxPriceTextField.keyboardType = UIKeyboardTypeNumberPad;
        _maxPriceTextField.backgroundColor = ZFC0xF7F7F7();
        _maxPriceTextField.layer.cornerRadius = 2.0;
        _maxPriceTextField.layer.masksToBounds = YES;
        _maxPriceTextField.textColor = ZFC0x2D2D2D();
        _maxPriceTextField.font = [UIFont systemFontOfSize:12];
        _maxPriceTextField.delegate = self;
        
        NSString *placedholder = [NSString stringWithFormat:@"%@", ZFLocalizedString(@"Gategory_Search_Price_Max", nil)];
        NSMutableAttributedString *placeholderStr = [[NSMutableAttributedString alloc] initWithString:placedholder];
        [placeholderStr addAttribute:NSForegroundColorAttributeName value:ZFC0xCCCCCC() range:NSMakeRange(0, placedholder.length)];
        
        _maxPriceTextField.attributedPlaceholder = placeholderStr;
    }
    return _maxPriceTextField;
}

@end
