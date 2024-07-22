
//
//  ZFAddressEditZipCodeTableViewCell.m
//  Zaful
//
//  Created by liuxi on 2017/8/31.
//  Copyright © 2017年 Y001. All rights reserved.
//

#import "ZFAddressEditZipCodeTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFAddressInfoModel.h"

@interface ZFAddressEditZipCodeTableViewCell () <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UITextField           *enterTextField;
@property (nonatomic, strong) UIView                *lineView;
@property (nonatomic, strong) UILabel               *tipsLabel;
@end

@implementation ZFAddressEditZipCodeTableViewCell
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
- (void)errorEnterTipsLayout {
    self.lineView.backgroundColor = ColorHex_Alpha(0xCA4343, 1.0);
    [self.contentView addSubview:self.tipsLabel];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.enterTextField);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-25);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(4);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-4);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];        
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)Textfield {
    [Textfield resignFirstResponder];//关闭键盘
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if ([string isEqualToString:@""]) {
        //删除字符
        
        if (textField.text.length == 10 && self.isOverLength == YES) {
            if (self.addressEditZipCodeCancelOverLengthCompletionHandler) {
                self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
                [self.tipsLabel removeFromSuperview];
                self.addressEditZipCodeCancelOverLengthCompletionHandler([textField.text substringToIndex:textField.text.length - 1]);
            }
        } else {

            if (self.addressEditZipCodeCheckErrorCompletionHandler) {
                self.addressEditZipCodeCheckErrorCompletionHandler(NO, [textField.text substringToIndex:textField.text.length - 1]);
            }
        }
        return YES;
    } else if (![string isEqualToString:@""]){
        //增加字符
        if (textField.text.length > 9) {
            if (self.addressEditZipCodeCheckErrorCompletionHandler) {
                self.addressEditZipCodeCheckErrorCompletionHandler(YES, textField.text);
            }
            return NO;
        } else if (textField.text.length < 10) {

            if (self.addressEditZipCodeCheckErrorCompletionHandler) {
                self.addressEditZipCodeCheckErrorCompletionHandler(NO, [NSString stringWithFormat:@"%@%@", textField.text, string]);
            }
            return YES;
        }
        
    }
    
    return YES;

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    
    //非美国地区 2 ～ 10， 美国地区 5 ～ 10 根据countryId 判断。
    if ([self.model.country_id isEqualToString:@"41"] && textField.text.length < 5) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"5"];
        if (self.addressEditZipCodeCheckErrorCompletionHandler) {
            self.addressEditZipCodeCheckErrorCompletionHandler(YES, textField.text);
        }
        
    } else if(textField.text.length == 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_ZipCode_TipLabel",nil);
        if (self.addressEditZipCodeCheckErrorCompletionHandler) {
            self.addressEditZipCodeCheckErrorCompletionHandler(YES, textField.text);
        }
        
    } else if (textField.text.length < 2) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
        if (self.addressEditZipCodeCheckErrorCompletionHandler) {
            self.addressEditZipCodeCheckErrorCompletionHandler(YES, textField.text);
        }
    } else if (textField.text.length < 10){
        if (self.addressEditZipCodeCancelOverLengthCompletionHandler) {
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            [self.tipsLabel removeFromSuperview];
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.enterTextField);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
                make.height.mas_equalTo(1);
            }];
            self.addressEditZipCodeCancelOverLengthCompletionHandler(textField.text);
        }
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.enterTextField];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.enterTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.height.mas_equalTo(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.enterTextField);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFAddressInfoModel *)model {
    _model = model;
    self.enterTextField.text = _model.zipcode;
}

- (void)setIsContinueCheck:(BOOL)isContinueCheck {
    _isContinueCheck = isContinueCheck;
    if (_isContinueCheck) {
        BOOL isOk = YES;
        //非美国地区 2 ～ 10， 美国地区 5 ～ 10 根据countryId 判断。
        if ([self.model.country_id isEqualToString:@"41"] && [self.enterTextField.text length] < 5) {//美国
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"5"];
            isOk = NO;
            
        } else if([self.enterTextField.text length] == 0){
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_ZipCode_TipLabel",nil);
            isOk = NO;
            
        } else if ([self.enterTextField.text length] < 2) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
            isOk = NO;
        }
        
        if (!isOk) {
            [self errorEnterTipsLayout];
        } else {
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            [self.tipsLabel removeFromSuperview];
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.enterTextField);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
                make.height.mas_equalTo(1);
            }];
            [self zfAutoLayoutView];
        }

    } else {
        self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
        [self.tipsLabel removeFromSuperview];
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.enterTextField);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
            make.height.mas_equalTo(1);
        }];
        [self zfAutoLayoutView];
    }
}

- (void)setIsOverLength:(BOOL)isOverLength {
    _isOverLength = isOverLength;
    if (_isOverLength) {
        BOOL isOk = YES;
        if([self.enterTextField.text length] == 0){
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_ZipCode_TipLabel",nil);
            isOk = NO;
        } else if ([self.model.country_id isEqualToString:@"41"] && self.enterTextField.text.length < 5) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"5"];
            isOk = NO;
        } else if ([self.enterTextField.text length] < 2) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
            isOk = NO;
        } else if (self.enterTextField.text.length >= 10) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),@"10"];
            isOk = NO;
        }
        
        if (!isOk) {
            [self errorEnterTipsLayout];
        } else {
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            [self.tipsLabel removeFromSuperview];
            [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.enterTextField);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
                make.height.mas_equalTo(1);
            }];
            [self zfAutoLayoutView];
        }
    } else {
        [self zfAutoLayoutView];
    }
}

#pragma mark - getter

- (UITextField *)enterTextField {
    if (!_enterTextField) {
        _enterTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _enterTextField.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _enterTextField.font = [UIFont systemFontOfSize:14];
        _enterTextField.delegate = self;
        _enterTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _enterTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _enterTextField.textAlignment = NSTextAlignmentLeft;
        _enterTextField.placeholder = ZFLocalizedString(@"ModifyAddress_ZipCode_Placeholder", nil);
    }
    return _enterTextField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ColorHex_Alpha(0xCA4343, 1.0);
        _tipsLabel.font = [UIFont systemFontOfSize:12];
    }
    return _tipsLabel;
}
@end
