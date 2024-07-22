//
//  ZFAddressEditAlternatePhoneNumberCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditAlternatePhoneNumberCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFAddressEditAlternatePhoneNumberCell() <ZFInitViewProtocol, UITextFieldDelegate>

@property (nonatomic, strong) UILabel               *codeLabel;
@property (nonatomic, strong) UIView                *sepLineView;
@property (nonatomic, strong) UIButton              *countryCodeButton; //运营号
@property (nonatomic, strong) UITextField           *enterTextField;
@property (nonatomic, strong) UILabel               *tipsLabel;
@end

@implementation ZFAddressEditAlternatePhoneNumberCell
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
- (void)countryCodeSelectAction:(UIButton *)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self baseSelectEvent:YES];
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
    if ([textField isEqual:self.enterTextField]) {
        //限制号码不能输入0~9以外的字符
//        if (![NSStringUtils validateParamter:string AdCodeString:@"0123456789"]) return NO;
        
        if (!self.infoModel.country_id || [NSStringUtils isEmptyString:self.infoModel.country_str]) {
            [self baseSelectFirstTips:YES];
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    BOOL isError = NO;
    
    NSArray *scutNumberArr = self.infoModel.scut_number_list;
    NSString *telLengthStr = [NSString stringWithFormat:@"%zd",textField.text.length];
    
    if(textField.text.length <= 0){
        isError = NO;
    }
/** 限制号码长度 V3.5.0
    else if (self.model.configured_number == 1 && (textField.text.length != [self.model.number integerValue]) ) {  // 有限制号码长度     只要当前输入长度不等于number就提示
        isError = YES;
    }else if (self.model.configured_number == 0 && textField.text.length > [self.model.number integerValue]){       // 没有限制号码长度   电话号码长度最大不能超过 13位
        isError = YES;
    }
*/
    else if (self.infoModel.configured_number && (scutNumberArr.count > 0 && ![scutNumberArr containsObject:telLengthStr]) ) {  // 有限制号码长度     只要当前输入长度不等于number就提示
        isError = YES;
    } else if (!self.infoModel.configured_number && textField.text.length > [self.infoModel.maxPhoneLength integerValue]){       // 没有限制号码长度   电话号码长度最大不能超过20位
        isError = YES;
    } else if (!self.infoModel.configured_number && self.enterTextField.text.length < [self.infoModel.minPhoneLength integerValue]){       // 没有限制号码长度   电话号码长度最小不能小于
        isError = YES;
    }
    
    if (!isError) {
        self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    [self baseShowTips:isError content:textField.text resultTell:@""];
    
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.codeLabel];
    [self.contentView addSubview:self.sepLineView];
    [self.contentView addSubview:self.countryCodeButton];
    [self.contentView addSubview:self.enterTextField];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {

    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(8);
        make.centerY.mas_equalTo(self.enterTextField.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(45, 40));
    }];
    
    [self.sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.codeLabel.mas_trailing).offset(1);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.bottom.mas_equalTo(self.lineView.mas_top).offset(-10);
        make.width.mas_equalTo(0.5);
    }];
    
    [self.countryCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.sepLineView.mas_trailing).offset(12);
        make.centerY.mas_equalTo(self.enterTextField);
        make.height.mas_equalTo(self.enterTextField);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    
    [self.enterTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.height.mas_equalTo(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(5);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.countryCodeButton setContentHuggingPriority:UILayoutPriorityRequired
                                              forAxis:UILayoutConstraintAxisHorizontal];
    [self.countryCodeButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight) imageTitleSpace:7];
}

#pragma mark - setter

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    
    self.infoModel = infoModel;
    self.typeModel = typeModel;
    
    self.enterTextField.text = ZFToString(self.infoModel.telspare);
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    self.codeLabel.hidden = YES;
    self.sepLineView.hidden = YES;
    self.tipsLabel.hidden = YES;

    if (![NSStringUtils isEmptyString:self.infoModel.code]) {
        self.codeLabel.hidden = NO;
        self.sepLineView.hidden = NO;
        self.codeLabel.text = [NSString stringWithFormat:@"+%@",self.infoModel.code];
    }
    
    self.countryCodeButton.hidden = YES;
    if (self.infoModel.supplier_number_list.count > 0 ) {
        self.countryCodeButton.hidden = NO;
        
        if ([NSStringUtils isEmptyString:self.infoModel.supplier_number_spare]) {
            [self.countryCodeButton setTitle:ZFLocalizedString(@"ModifyAddress_Supplier_Placeholder", nil) forState:UIControlStateNormal];
        } else {
            [self.countryCodeButton setTitle:self.infoModel.supplier_number_spare forState:UIControlStateNormal];
        }
    }
    
    if ([NSStringUtils isEmptyString:self.infoModel.code] && self.infoModel.supplier_number_list.count == 0) {
        
        [self.enterTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.top.mas_equalTo(self.contentView.mas_top).offset(10);
            make.height.mas_equalTo(30);
        }];
    } else if([NSStringUtils isEmptyString:self.infoModel.code] && self.infoModel.supplier_number_list.count > 0) {
        
        [self.countryCodeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_trailing).offset(12);
            make.centerY.mas_equalTo(self.enterTextField.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(50);
        }];
        
        [self.enterTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.countryCodeButton.mas_trailing).offset(10);
            make.top.mas_equalTo(self.contentView.mas_top).offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(30);
        }];
    } else if(![NSStringUtils isEmptyString:self.infoModel.code] && self.infoModel.supplier_number_list.count == 0) {
        
        [self.enterTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sepLineView.mas_trailing).offset(8);
            make.top.mas_equalTo(self.contentView.mas_top).offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(30);
        }];
        
    } else if(![NSStringUtils isEmptyString:self.infoModel.code] && self.infoModel.supplier_number_list.count > 0) {
        
        [self.countryCodeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sepLineView.mas_trailing).offset(12);
            make.centerY.mas_equalTo(self.enterTextField.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(50);
        }];
        
        [self.enterTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.countryCodeButton.mas_trailing).offset(10);
            make.top.mas_equalTo(self.contentView.mas_top).offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(30);
        }];
    }
    
    if ([self isShowTips] && self.typeModel.isShowTips) {
        self.tipsLabel.hidden = NO;
        self.lineView.backgroundColor = ZFC0xFE5269();
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
    } else {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
    
    [self.countryCodeButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight) imageTitleSpace:7];
}

- (BOOL)isShowTips {
    
    NSArray *scutNumberArr = self.infoModel.scut_number_list;
    NSString *telLengthStr = [NSString stringWithFormat:@"%zd",self.enterTextField.text.length];
    
    BOOL showTips = NO;
    if([self.enterTextField.text length] <= 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Phone_TipLabel",nil);
        showTips = YES;
    }
    /** 限制号码长度 V3.5.0
     
     else if (self.model.configured_number && (self.enterTextField.text.length != [self.model.number integerValue]) ) {  // 有限制号码长度     只要当前输入长度不等于number就提示
     self.tipsLabel.text =  [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),self.model.number];
     isOk = NO;
     }else if (!self.model.configured_number && self.enterTextField.text.length > [self.model.number integerValue]){       // 没有限制号码长度   电话号码长度最大不能超过 13位
     self.tipsLabel.text =  [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_include_Digits",nil),self.model.number];
     isOk = NO;
     }
     */
    else if (self.infoModel.configured_number && (scutNumberArr.count > 0 &&  ![scutNumberArr containsObject:telLengthStr]) ) {  // 有限制号码长度     只要当前输入长度不等于number就提示
        NSString *tipLength = [scutNumberArr componentsJoinedByString:@","];
        self.tipsLabel.text =  [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_NumberCount_TipLabel",nil),tipLength];
        showTips = YES;
    } else if (!self.infoModel.configured_number && self.enterTextField.text.length > [self.infoModel.maxPhoneLength integerValue]){       // 没有限制号码长度   电话号码长度最大不能超过20位
        self.tipsLabel.text =  [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_include_Digits",nil),self.infoModel.maxPhoneLength];
        showTips = YES;
    } else if (!self.infoModel.configured_number && self.enterTextField.text.length < [self.infoModel.minPhoneLength integerValue]){       // 没有限制号码长度   电话号码长度最小不能小于
        self.tipsLabel.text =  ZFLocalizedString(@"ModifyAddress_valid_phone_number",nil);
        showTips = YES;
        
    }
    return showTips;
}

#pragma mark - getter

- (UILabel *)codeLabel {
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codeLabel.font = [UIFont systemFontOfSize:14];
        _codeLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        _codeLabel.textAlignment = NSTextAlignmentCenter;
        _codeLabel.numberOfLines = 1;
        [_codeLabel sizeToFit];
    }
    return _codeLabel;
}

- (UIView *)sepLineView {
    if (!_sepLineView) {
        _sepLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _sepLineView;
}

- (UIButton *)countryCodeButton {
    if (!_countryCodeButton) {
        _countryCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_countryCodeButton setTitle:ZFLocalizedString(@"ModifyAddress_Supplier_Placeholder", nil) forState:UIControlStateNormal];
        _countryCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_countryCodeButton setTitleColor:ZFCOLOR_BLACK forState:UIControlStateNormal];
        [_countryCodeButton setImage:[UIImage imageNamed:@"drop_down"] forState:UIControlStateNormal];
        [_countryCodeButton addTarget:self action:@selector(countryCodeSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        [_countryCodeButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight) imageTitleSpace:7];
    }
    return _countryCodeButton;
}

- (UITextField *)enterTextField {
    if (!_enterTextField) {
        _enterTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _enterTextField.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _enterTextField.font = [UIFont systemFontOfSize:14];
        _enterTextField.delegate = self;
        _enterTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _enterTextField.keyboardType = UIKeyboardTypeNumberPad;
        _enterTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _enterTextField.placeholder = ZFLocalizedString(@"ModifyAddress_AlternatePhoneNum_Placeholder", nil);
    }
    return _enterTextField;
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
@end

