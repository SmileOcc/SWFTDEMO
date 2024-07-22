
//
//  ZFAddressEditZipCodeTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditZipCodeTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"


@interface ZFAddressEditZipCodeTableViewCell () <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UITextField           *enterTextField;
@property (nonatomic, strong) UILabel               *tipsLabel;
@property (nonatomic, strong) UIImageView           *arrowView;
@property (nonatomic, strong) UIButton              *zipButton;

@property (nonatomic, strong) UIView                *aoutFillTipView;
@property (nonatomic, strong) UIImageView           *tipImageView;
@property (nonatomic, strong) UILabel               *fillTipLabel;





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


#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)Textfield {
    [Textfield resignFirstResponder];//关闭键盘
    [self baseIsEditEvent:NO];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self baseIsEditEvent:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {//删除字符
        
        if (textField.text.length == 10 && self.typeModel.isShowTips == YES) {

            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            self.tipsLabel.hidden = YES;
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            [self baseCancelContent:[textField.text substringToIndex:textField.text.length - 1]];
        } else {
            [self baseShowTips:NO overMax:NO content:[textField.text substringToIndex:textField.text.length - 1]];
        }
        
    } else if (![string isEqualToString:@""]){//增加字符
        if ([self.infoModel isMustZip]) {
            if ([self.infoModel isIndiaCountry]) {
                //印度用户填写地址时邮政编码的限制只能填写6位数字的格式，不允许填写字母、空格或者标点符号等
                if (textField.text.length >=6) {
                    [self baseShowTips:NO overMax:NO content:textField.text];
                    return NO;
                }
            } else if (textField.text.length >= 9) {
                [self baseShowTips:YES overMax:YES content:textField.text];
                return NO;
            }
            [self baseShowTips:NO overMax:NO content:[NSString stringWithFormat:@"%@%@", textField.text, string]];
        }
    }
    
    return YES;

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    
    if ([self.infoModel isMustZip]) {
        //  需求链接: https://jcaclx.axshare.com/#g=1&p=%E6%94%AF%E4%BB%98%E7%BB%84%E8%A1%A8%E5%8D%95%E6%A0%A1%E9%AA%8C%E6%9D%A1%E4%BB%B6
        if ([self.infoModel isPhilippinesCountry]) {
            if (self.enterTextField.text.length != 4) {
                self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Zip_include_Digits", nil),@"4"];
                [self baseShowTips:YES overMax:NO content:textField.text];
            } else {
                [self baseCancelContent:textField.text];
            }
            
        } else if ([self.infoModel isIndiaCountry]) {
            NSString *pwdRegex = @"^\\d{6}$";  // (6个连续数字,以数字开头,以数字结尾)
            NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
            BOOL isMatch= [pwdTest evaluateWithObject:self.enterTextField.text];
            if (!isMatch) {
                self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Zip_include_Digits", nil),@"6"];
                [self baseShowTips:YES overMax:NO content:textField.text];
            } else {
                [self baseCancelContent:textField.text];
            }
        } else if ([self.infoModel isCanadaCountry]) {
            NSString *pwdRegex = @"[a-zA-Z\\d\\-\\s]{6,9}";
            NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
            BOOL isMatch= [pwdTest evaluateWithObject:self.enterTextField.text];
            if (!isMatch) {
                self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Zip_Range_Digits", nil),@"6",@"9"];
                [self baseShowTips:YES overMax:NO content:textField.text];
            } else {
                [self baseCancelContent:textField.text];
            }
        } else if ([self.infoModel.country_id isEqualToString:@"41"] && textField.text.length < 5) {
            //非美国地区 2 ～ 10， 美国地区 5 ～ 10 根据countryId 判断。
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"5"];
            [self baseShowTips:YES overMax:NO content:textField.text];
        } else if(textField.text.length == 0){
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_ZipCode_TipLabel",nil);
            [self baseShowTips:YES overMax:NO content:textField.text];
        } else if (textField.text.length < 2) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
            [self baseShowTips:YES overMax:NO content:textField.text];
        } else if (textField.text.length < 10){
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            self.tipsLabel.hidden = YES;
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            [self baseCancelContent:textField.text];
        }
    } else {
        [self baseShowTips:NO overMax:NO content:textField.text];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.enterTextField];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.arrowView];
    [self.contentView addSubview:self.zipButton];
    
    [self.contentView addSubview:self.aoutFillTipView];
    [self.aoutFillTipView addSubview:self.tipImageView];
    [self.aoutFillTipView addSubview:self.fillTipLabel];

}

- (void)zfAutoLayoutView {
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.enterTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.trailing.mas_equalTo(self.arrowView.mas_leading).offset(-16);
        make.height.mas_equalTo(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.enterTextField);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.zipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.size.mas_equalTo(CGSizeMake(48, 40));
    }];
    
    [self.aoutFillTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.aoutFillTipView.mas_leading);
        make.centerY.mas_equalTo(self.aoutFillTipView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.fillTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tipImageView.mas_trailing).offset(1);
        make.centerY.mas_equalTo(self.aoutFillTipView.mas_centerY);
        make.trailing.mas_equalTo(self.aoutFillTipView.mas_trailing);
    }];
}

#pragma mark - setter

- (void)fillInZip:(NSString *)zipString {
    if (!ZFIsEmptyString(zipString)) {
        self.enterTextField.text = zipString;
        self.infoModel.zipcode = zipString;
    }
}


/*
 *
 若为菲律宾国家：1）多个邮编数据返回时，支持下拉选择，不支持再编辑邮编；2）一个邮编时，默认填充，不能编辑；3）无邮编返回时，支持输入框输入编辑。

 其他国家：1）多个邮编数据返回时，支持下拉选择，也支持再次编辑；2）一个邮编时，默认填充，且能编辑；3）无邮编返回时，支持输入框输入编辑。
 */
- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel zips:(NSArray *)zipArrays {
    [self updateInfo:infoModel typeModel:typeModel];
    
    self.arrowView.hidden = YES;
    self.zipButton.hidden = YES;
    self.enterTextField.userInteractionEnabled = YES;
    
    if (ZFJudgeNSArray(zipArrays)) {
        if (zipArrays.count > 0) {
            self.enterTextField.userInteractionEnabled = NO;
            
            if (zipArrays.count > 1) {
                self.arrowView.hidden = NO;
                self.zipButton.hidden = NO;
            }
            
            if (![infoModel isPhilippinesCountry]) {
                self.enterTextField.userInteractionEnabled = YES;
            }
        }
    }
}

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    self.infoModel = infoModel;
    self.typeModel = typeModel;
    
    self.enterTextField.text = ZFToString(self.infoModel.zipcode);
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    self.tipsLabel.hidden = YES;
    self.zipButton.hidden = YES;
    
    //菲律宾国家地址需要验证邮编 不需要清空 保持四位
    if ([self.infoModel isMustZip]) {
        NSString *placeStr = [NSString stringWithFormat:@"*%@",ZFLocalizedString(@"ModifyAddress_ZipCode_Placeholder", nil)];
        self.enterTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.enterTextField.placeholder = placeStr;
        if ([self.infoModel isIndiaCountry] || [self.infoModel isPhilippinesCountry]) {
            self.enterTextField.keyboardType = UIKeyboardTypeNumberPad;
        }
    } else {
        NSString *placeStr = [NSString stringWithFormat:@"%@",ZFLocalizedString(@"ModifyAddress_ZipCode_Placeholder", nil)];
        self.enterTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.enterTextField.placeholder = placeStr;
    }
    
    [self showFillZipTip:NO];

    if ([self isShowTips] && self.typeModel.isShowTips) {
        self.tipsLabel.hidden = NO;
        self.lineView.backgroundColor = ZFC0xFE5269();
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
        
    } else if(typeModel.isShowFillZipTips) {//显示自动填充邮编提示
        
        [self showFillZipTip:YES];
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
        
    } else {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
}


- (BOOL)isShowTips {
    BOOL showTips = NO;
    
    //菲律宾国家地址需要验证邮编 不需要清空 保持四位
    if (self.infoModel.isZipFourTip) {
        self.tipsLabel.text = ZFToString(self.infoModel.zipFourTipMsg);
        return YES;
    }
    
    if (![self.infoModel isMustZip]) {
        return showTips;
    }
    
    if ([self.infoModel isPhilippinesCountry]) {
        if (self.enterTextField.text.length != 4) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Zip_include_Digits", nil),@"4"];
            showTips = YES;
        }
        
    } else if ([self.infoModel isIndiaCountry]) {
        NSString *pwdRegex = @"^\\d{6}$";  // (6个连续数字,以数字开头,以数字结尾)
        NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
        BOOL isMatch= [pwdTest evaluateWithObject:self.enterTextField.text];
        if (!isMatch) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Zip_include_Digits", nil),@"6"];
            showTips = YES;
        }
    } else if ([self.infoModel isCanadaCountry]) {
        //当国家选择CA的时候，长度控制在6<=长度<=9位，并且只能是“数字”、“-”、“空格”和“字母”如若输入的字符长度符合要求，但是字符格式不在上述要求内，提示NAN-ANA
        NSString *pwdRegex = @"[a-zA-Z\\d\\-\\s]{6,9}";
        NSPredicate *pwdTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pwdRegex];
        BOOL isMatch= [pwdTest evaluateWithObject:self.enterTextField.text];
        if (!isMatch) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Zip_Range_Digits", nil),@"6",@"9"];
            showTips = YES;
        }
    } else if ([self.infoModel.country_id isEqualToString:@"41"] && self.enterTextField.text.length < 5) {
        
        //非美国地区 2 ～ 10， 美国地区 5 ～ 10 根据countryId 判断。
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"5"];
        showTips = YES;
        
    } else if([self.enterTextField.text length] == 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_ZipCode_TipLabel",nil);
        showTips = YES;
    } else if ([self.enterTextField.text length] < 2) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
        showTips = YES;
    } else if (self.enterTextField.text.length >= 10) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),@"10"];
        showTips = YES;
    }
    return showTips;
}

- (void)showFillZipTip:(BOOL)isShow {
    self.aoutFillTipView.hidden = !isShow;
    self.fillTipLabel.text = ZFToString(self.infoModel.saveErrorFillZipMsg);
    if (!self.tipsLabel.isHidden && isShow) {
        self.tipsLabel.hidden = isShow;
    }
}


- (void)actionZip:(UIButton *)sender {
    [self baseSelectEvent:YES];
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
        _enterTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;;
        _enterTextField.placeholder = ZFLocalizedString(@"ModifyAddress_ZipCode_Placeholder", nil);
        _enterTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _enterTextField;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowView.image = [UIImage imageNamed:@"account_arrow_right"];
        _arrowView.hidden = YES;
        [_arrowView convertUIWithARLanguage];
    }
    return _arrowView;
}


- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFC0xFE5269();
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (UIButton *)zipButton {
    if (!_zipButton) {
        _zipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zipButton addTarget:self action:@selector(actionZip:) forControlEvents:UIControlEventTouchUpInside];
        _zipButton.hidden = YES;
    }
    return _zipButton;
}

- (UIView *)aoutFillTipView {
    if (!_aoutFillTipView) {
        _aoutFillTipView = [[UIView alloc] initWithFrame:CGRectZero];
        _aoutFillTipView.hidden = YES;
    }
    return _aoutFillTipView;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _tipImageView.image = [UIImage imageNamed:@"address_question_mark"];
    }
    return _tipImageView;
}

- (UILabel *)fillTipLabel {
    if (!_fillTipLabel) {
        _fillTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _fillTipLabel.textColor = ZFC0x999999();
        _fillTipLabel.font = [UIFont systemFontOfSize:12];
        _fillTipLabel.text = @"Has filled the correct postal code for you";
    }
    return _fillTipLabel;
}
@end
