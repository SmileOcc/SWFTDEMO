
//
//  OSSVChangePasswordVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChangePasswordVC.h"
#import "OSSVChangPasswordsViewModel.h"
#import "STLTextField.h"
#import "SignViewController.h"
#import "Adorawe-Swift.h"

@interface OSSVChangePasswordVC ()<UITextFieldDelegate>

// 上部背景View
@property (nonatomic, strong) UIView                   *topBackView;
// 上部SubViews
@property (nonatomic, strong) UILabel                  *originPasswordLabel;
@property (nonatomic, strong) STLTextField              *originPasswordTextField;
@property (nonatomic, strong) UILabel                  *passwordLabel;
@property (nonatomic, strong) STLTextField              *passwordTextField;
@property (nonatomic, strong) UILabel                  *confirmPasswordLabel;
@property (nonatomic, strong) STLTextField              *confirmPasswordTextField;
// SubmitButton
@property (nonatomic, strong) UIButton                 *submitButton;
@property (nonatomic, strong) OSSVChangPasswordsViewModel  *viewModel;

@end

@implementation OSSVChangePasswordVC

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"changePassword",nil);
    self.view.backgroundColor = OSSVThemesColors.col_F1F1F1;
    [self initSubViews];

}

#pragma mark - MakeUI
- (void)initSubViews {
    
    [self.view addSubview:self.topBackView];
    [self.view addSubview:self.submitButton];
    [self.topBackView addSubview:self.originPasswordLabel];
    [self.topBackView addSubview:self.originPasswordTextField];
    [self.topBackView addSubview:self.passwordLabel];
    [self.topBackView addSubview:self.passwordTextField];
    [self.topBackView addSubview:self.confirmPasswordLabel];
    [self.topBackView addSubview:self.confirmPasswordTextField];
    
    [self makeConstraints];
}

- (void)makeConstraints {
    
    [self.topBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
    }];
    
    [self.originPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.mas_equalTo(@15);
        make.leading.mas_equalTo(@10);
        make.trailing.mas_equalTo(@(-10));
        make.height.mas_equalTo(@20);
    }];
    
    [self.originPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.originPasswordLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.originPasswordLabel.mas_leading);
        make.trailing.equalTo(self.originPasswordLabel.mas_trailing);
        make.height.mas_equalTo(@40);
    }];
    
    [self.passwordLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.originPasswordTextField.mas_bottom).offset(15);
        make.leading.equalTo(self.originPasswordLabel.mas_leading);
        make.trailing.equalTo(self.originPasswordLabel.mas_trailing);
        make.height.equalTo(self.originPasswordLabel.mas_height);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.passwordLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.originPasswordTextField.mas_leading);
        make.trailing.equalTo(self.originPasswordTextField.mas_trailing);
        make.height.equalTo(self.originPasswordTextField.mas_height);
    }];
    
    [self.confirmPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(15);
        make.leading.equalTo(self.originPasswordLabel.mas_leading);
        make.trailing.equalTo(self.originPasswordLabel.mas_trailing);
        make.height.equalTo(self.originPasswordLabel.mas_height);
    }];
    
    [self.confirmPasswordTextField mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.confirmPasswordLabel.mas_bottom).offset(10);
        make.leading.equalTo(self.originPasswordLabel.mas_leading);
        make.trailing.equalTo(self.originPasswordLabel.mas_trailing);
        make.height.equalTo(self.originPasswordTextField.mas_height);
    }];
    
    [self.topBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.confirmPasswordTextField.mas_bottom).offset(15);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.topBackView.mas_bottom).offset(20);
        make.leading.mas_equalTo(@30);
        make.trailing.mas_equalTo(@(-30));
        make.height.mas_equalTo(@40);
    }];
}

#pragma mark - 确认

- (void)submitAction {

    [GATools logEditProfileWithAction:@"Password_Submit" screenGroup:@"ChangePassword"];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    // 验证密码
    if (![self checkInputTextIsValid]) {
        return;
    }
    
    NSDictionary *dic = @{
                          ChangePasswordKeyOfOldWord   : self.originPasswordTextField.text,
                          ChangePasswordKeyOfNewWord   : self.passwordTextField.text
                          };
    @weakify(self)
    [self.viewModel requestNetwork:dic completion:^(id obj){
        @strongify(self)
        if (obj) {
            [self showSuccessAlertView];
        }
    
    } failure:^(id obj){
    }];
}

#pragma mark 返回首页

- (void)signOutBackToHomeMethod {
    
    [[OSSVAccountsManager sharedManager] clearUserInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Logout object:nil];
    [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[self.tabBarController.viewControllers objectAtIndex:0]];
    [self.tabBarController setSelectedIndex:0];
    [self.navigationController popToRootViewControllerAnimated:YES];
    

}

#pragma mark 去登录

- (void)goToLoginMethod {
    
    [[OSSVAccountsManager sharedManager] clearUserInfo];
     [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Logout object:nil];
    SignViewController *signVC = [[SignViewController alloc] init];
    signVC.modalPresentationStyle = UIModalPresentationFullScreen;
    @weakify(self)
    signVC.signBlock = ^{
        @strongify(self)
        self.tabBarController.selectedIndex = 0;
    };
 
    [self.tabBarController presentViewController:signVC animated:YES completion:^{
        @strongify(self)
        [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[self.tabBarController.viewControllers objectAtIndex:0]];
        [self.tabBarController setSelectedIndex:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
  
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!CGColorEqualToColor(textField.layer.borderColor,OSSVThemesColors.col_DDDDDD.CGColor)) {
        textField.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
    }
    [GATools logEditProfileWithAction:@"Password_Change" screenGroup:@"ChangePassword"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // MAX Length = 35
    if (textField.text.length + string.length > STL_TEXTFIELD_INPUT_MAX_LENGTH) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.confirmPasswordTextField) {
        [self submitAction];
    }
    return YES;
}


#pragma mark - SuccessHUD
- (void)showSuccessAlertView {
    NSArray *upperTitle = @[STLLocalizedString_(@"ok",nil).uppercaseString,STLLocalizedString_(@"loginNow",nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"ok",nil),STLLocalizedString_(@"loginNow",nil)];
    
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLLocalizedString_(@"newPasswordHadChanged",nil) buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        
        if (index == 0) {
            [self signOutBackToHomeMethod];
        } else {
            [self goToLoginMethod];
        }
        
    }];
    
}


#pragma mark - Error HUD
- (BOOL)checkInputTextIsValid {
    
    /**
     *  注意此处的提示语已经是国际化啦
     */
    BOOL isCheckValid = YES;
    NSString *showHudErrorString = nil;
    
    if ([OSSVNSStringTool isEmptyString:self.originPasswordTextField.text])  {
   
        [self showErrorBorderColorWithTextField:self.originPasswordTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"originalPasswordEmpty", nil);
        isCheckValid = NO;
    }
    if ([OSSVNSStringTool isEmptyString:self.passwordTextField.text]) {
      
        [self showErrorBorderColorWithTextField:self.passwordTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"passwordEmptyMsg", nil);
        isCheckValid = NO;
    }
    if ([OSSVNSStringTool isEmptyString:self.confirmPasswordTextField.text]) {
   
        [self showErrorBorderColorWithTextField:self.confirmPasswordTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"passwordComfirmEmptyMsg", nil);
        isCheckValid = NO;
    }
    
    if ([self.originPasswordTextField.text isEqualToString:self.passwordTextField.text]) {
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"passwordNewEqualOld", nil);
        isCheckValid = NO;
    }
    
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        
        [self showErrorBorderColorWithTextField:self.confirmPasswordTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"passwordEqualToMsg", nil);
        isCheckValid = NO;
    }
    // 截取 收尾空格
    self.passwordTextField.text = [OSSVNSStringTool cutLeadAndTrialBlankCharacter:self.passwordTextField.text];
    self.confirmPasswordTextField.text = [OSSVNSStringTool cutLeadAndTrialBlankCharacter:self.confirmPasswordTextField.text];
    
    if (!(self.passwordTextField.text.length > 5)) {

        [self showErrorBorderColorWithTextField:self.passwordTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"passwordMinLengthMsg", nil);
        isCheckValid = NO;
    }
    if ((self.passwordTextField.text.length > 30)) {
    
        [self showErrorBorderColorWithTextField:self.passwordTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"passwordMaxLengthMsg", nil);
        isCheckValid = NO;
    }
    if (!isCheckValid) {
        [self showHUDWithErrorText:showHudErrorString];
    }
    return isCheckValid;
}

- (void)showHUDWithErrorText:(NSString *)text {
    
    [HUDManager showHUDWithMessage:STLToString(text) customView:[[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"prompt"]]];
    
}
- (void)showErrorBorderColorWithTextField:(STLTextField *)textField {
    textField.layer.borderColor = OSSVThemesColors.col_FF6F00.CGColor;
}


#pragma mark - LazyLoad

- (UILabel *)createLabelText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = OSSVThemesColors.col_333333;
    return label;
}

- (STLTextField *)createTextField:(NSString *)placeholder {
    
    STLTextField *textField = [[STLTextField alloc] init];
    textField.delegate = self;
//    textField.borderStyle = UITextBorderStyleLine;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.placeholder = placeholder;
    textField.secureTextEntry = YES;
    textField.layer.borderColor = [OSSVThemesColors.col_DDDDDD CGColor];
    textField.layer.borderWidth = 0.5;
    textField.layer.cornerRadius = 4.0;
    textField.layer.masksToBounds = YES;
    textField.font = [UIFont systemFontOfSize:12];
    textField.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    return textField;
}

- (OSSVChangPasswordsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVChangPasswordsViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (UIView *)topBackView {
    if (!_topBackView) {
        _topBackView = [[UIView alloc] init];
        _topBackView.backgroundColor = [UIColor whiteColor];
    }
    return _topBackView;
}

- (UILabel *)originPasswordLabel {
    if (!_originPasswordLabel) {
        _originPasswordLabel = [self createLabelText:STLLocalizedString_(@"originalPassword",nil)];
    }
    return _originPasswordLabel;
}

- (STLTextField *)originPasswordTextField {
    if (!_originPasswordTextField) {
        _originPasswordTextField = [self createTextField:STLLocalizedString_(@"originalPassword",nil)];
    }
    return _originPasswordTextField;
}

- (UILabel *)passwordLabel {
    if (!_passwordLabel) {
        _passwordLabel = [self createLabelText:STLLocalizedString_(@"newPassword",nil)];
    }
    return _passwordLabel;
}

- (STLTextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [self createTextField:STLLocalizedString_(@"newPassword",nil)];
    }
    return _passwordTextField;
}

- (UILabel *)confirmPasswordLabel {
    if (!_confirmPasswordLabel) {
        _confirmPasswordLabel = [self createLabelText:STLLocalizedString_(@"confirmPassword",nil)];
    }
    return _confirmPasswordLabel;
}

- (STLTextField *)confirmPasswordTextField {
    if (!_confirmPasswordTextField) {
        _confirmPasswordTextField = [self createTextField:STLLocalizedString_(@"confirmPassword",nil)];
        _confirmPasswordTextField.delegate  = self;
    }
    return _confirmPasswordTextField;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitButton setTitle:STLLocalizedString_(@"submit",nil) forState:UIControlStateNormal];
        _submitButton.backgroundColor = [OSSVThemesColors col_262626];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = 4.0;
        _submitButton.layer.masksToBounds = YES;
        [_submitButton addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

@end
