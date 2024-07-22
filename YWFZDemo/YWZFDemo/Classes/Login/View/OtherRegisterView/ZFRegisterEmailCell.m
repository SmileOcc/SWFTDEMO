//
//  ZFRegisterEmailCell.m
//  ZZZZZ
//
//  Created by YW on 29/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRegisterEmailCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFTextField.h"
#import "ZFRegisterModel.h"
#import "LoginViewModel.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFRegisterEmailCell ()<ZFInitViewProtocol,UITextFieldDelegate>
@property (nonatomic, strong) ZFTextField   *emailTextField;
@property (nonatomic, strong) UILabel       *tipLabel;
@property (nonatomic, strong) LoginViewModel    *viewModel;
@end

@implementation ZFRegisterEmailCell

+ (ZFRegisterEmailCell *)cellWith:(UITableView *)tableView index:(NSIndexPath *)index {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:index];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)zfInitView {
    [self.contentView addSubview:self.emailTextField];
    [self.contentView addSubview:self.tipLabel];
}

- (void)zfAutoLayoutView {
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(28);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTextField.mas_bottom).offset(8);
        make.leading.equalTo(self.emailTextField.mas_leading);
        make.trailing.mas_equalTo(-12);
    }];
}

#pragma mark - Setter
- (void)setModel:(ZFRegisterModel *)model {
    _model = model;
    
    [self updateViewModel:model];
    [self checkValidEmail:model.email];
}

- (void)updateViewModel:(ZFRegisterModel *)model {

   self.emailTextField.text = model.email;
    if (!ZFIsEmptyString(model.errorMsg)) {
        self.emailTextField.errorTip = model.errorMsg;
    } else {
        self.emailTextField.errorTip = ZFLocalizedString(@"Login_email_format_error",nil);
    }
    
    if (model.showEmailError) {
        self.tipLabel.hidden = YES;
        [self.emailTextField showErrorTipLabel:YES];
    }else{
        [self.emailTextField hidenErrorTipLine];
        self.tipLabel.hidden = NO;
    }
    if (!ZFIsEmptyString(model.email)) {
        [self.emailTextField resetMoved:NO];
        [self.emailTextField showPlaceholderAnimation];
    }
}

#pragma mark - Action
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![NSStringUtils isValidEmailString:textField.text] || ZFIsEmptyString(textField.text)) {
        self.tipLabel.hidden = YES;
        [self.emailTextField showErrorTipLabel:YES];
        if (ZFIsEmptyString(textField.text)) {
            [self.emailTextField resetAnimation];
            self.tipLabel.hidden = NO;
        } else {
            [self.emailTextField resetMoved:NO];
            self.model.errorMsg = @"";
            self.emailTextField.errorTip = ZFLocalizedString(@"Login_email_format_error",nil);
        }
        return;
    }
    
    [self checkValidEmail:textField.text];
}

- (void)checkValidEmail:(NSString *)email {
    NSDictionary *dict = @{@"email": email};
    @weakify(self)
    [self.viewModel requestVerifyEamilHasRegister:dict completion:^(NSString *emailTextTipString) {
        @strongify(self)
        
        BOOL flag = NO;
        if (ZFIsEmptyString(emailTextTipString)) {
            flag = YES;
            self.model.errorMsg = @"";
            self.model.showEmailError = NO;
        } else {
            self.model.errorMsg = emailTextTipString;
        }
        if (self.emailTextFieldEditingDidEndHandler) {
            self.model.email = self.emailTextField.text;
            self.model.isValidEmail = flag;
            self.emailTextFieldEditingDidEndHandler(self.model);
        }
        [self updateViewModel:self.model];
        
    } failure:^(id obj) {
        self.model.errorMsg = @"";
        if (self.emailTextFieldEditingDidEndHandler) {
            self.model.email = self.emailTextField.text;
            self.model.isValidEmail = NO;
            self.emailTextFieldEditingDidEndHandler(self.model);
        }
    }];
}

#pragma mark - Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (!ZFIsEmptyString(textField.text) && [NSStringUtils isValidEmailString:self.model.email] ) {
//        return NO;
//    }
    self.tipLabel.hidden = NO;
    return YES;
}

#pragma mark - getter
- (ZFTextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[ZFTextField alloc] init];
        _emailTextField.backgroundColor = [UIColor whiteColor];
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTextField.placeholder = ZFLocalizedString(@"Register_Email",nil);
        _emailTextField.font = [UIFont systemFontOfSize:14.f];
        _emailTextField.placeholderColor = ZFCOLOR(153, 153, 153, 1);
        _emailTextField.clearImage = [UIImage imageNamed:@"clearButton"];
        _emailTextField.errorTip = ZFLocalizedString(@"Login_email_format_error",nil);
        _emailTextField.errorFontSize = 12.f;
        _emailTextField.errorTipColor = [UIColor orangeColor];
        _emailTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _emailTextField.lineColor = ZFCOLOR(153, 153, 153, 1);
        _emailTextField.placeholderSelectStateColor = ZFCOLOR(153, 153, 153, 1.0);
        _emailTextField.delegate = self;
    }
    return _emailTextField;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = ZFFontSystemSize(12);
        _tipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _tipLabel.backgroundColor = ZFCOLOR_WHITE;
        _tipLabel.numberOfLines = 0;
        _tipLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _tipLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
        _tipLabel.text = ZFLocalizedString(@"emailTip", nil);
    }
    return _tipLabel;
}

- (LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}


@end

