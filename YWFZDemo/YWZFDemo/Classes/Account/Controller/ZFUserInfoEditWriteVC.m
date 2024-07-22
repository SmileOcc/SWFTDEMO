//
//  ZFUserInfoEditWriteVC.m
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFUserInfoEditWriteVC.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "SystemConfigUtils.h"
#import "NSStringUtils.h"

@interface ZFUserInfoEditWriteVC ()<ZFInitViewProtocol>

@property (nonatomic, strong) UIView           *contentView;
@property (nonatomic, strong) UITextField      *textField;
@property (nonatomic, strong) UIButton         *saveButton;




@end

@implementation ZFUserInfoEditWriteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = ZFC0xF7F7F7();
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)zfInitView {
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.saveButton];
    [self.contentView addSubview:self.textField];
}

- (void)zfAutoLayoutView {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(24);
        make.height.mas_equalTo(40);
    }];
}

- (void)saveBtnClick {
    
    if (![self checkInput:self.typeModel content:self.textField.text]) {
        return;
    }
    if (!ZFIsEmptyString(self.textField.text) && self.inputTextBlock) {
        self.inputTextBlock(self.textField.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setTypeModel:(ZFUserInfoTypeModel *)typeModel {
    _typeModel = typeModel;

    self.title = ZFToString(typeModel.typeName);
    self.textField.text = ZFToString(typeModel.content);
    
    self.textField.placeholder = ZFToString(typeModel.typeName);
    if (typeModel.editType == ZFUserInfoEditTypeEmail) {
        self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    } else {
        self.textField.keyboardType = UIKeyboardTypeDefault;
    }
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = ZFC0xFFFFFF();
    }
    return _contentView;
}

- (UITextField *)textField {
    if (!_textField) {
        UITextField  *textField = [UITextField new];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyDone;
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        textField.textColor = ZFCOLOR(51, 51, 51, 1.0);
        if (kiOSSystemVersion < 13.0) {
            [textField setValue:ZFCOLOR(178, 178, 178, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
            [textField setValue:[UIFont systemFontOfSize:14.0] forKeyPath:@"_placeholderLabel.font"];
        }
        textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        textField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _textField = textField;
    }
    return _textField;
}

-(UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.layer.cornerRadius = 3;
        _saveButton.layer.masksToBounds = YES;
        [_saveButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_saveButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        NSString *title = [ZFLocalizedString(@"Profile_Save_Button",nil) uppercaseString];
        [_saveButton setTitle:title forState:UIControlStateNormal];
        [_saveButton setTitleColor:ZFCOLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        _saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_saveButton addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}


- (BOOL)checkInput:(ZFUserInfoTypeModel *)typeModel content:(NSString *)content{
    
    BOOL isCheckValid = YES;
    NSString *showHudErrorString = nil;
    
    if (typeModel.editType == ZFUserInfoEditTypeFirstName) {
        if ([NSStringUtils isEmptyString:content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(content.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((content.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypeLastName) {
        if ([NSStringUtils isEmptyString:content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(content.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((content.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypeNickName) {
        if ([NSStringUtils isEmptyString:content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(content.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((content.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypePhone) {
        if ([NSStringUtils isEmptyString:content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            
            return NO;
        }
        if ((content.length < 6)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((content.length > 20)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    return YES;
}
@end
