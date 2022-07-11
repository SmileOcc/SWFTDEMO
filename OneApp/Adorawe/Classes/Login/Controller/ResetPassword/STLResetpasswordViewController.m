//
//  STLResetpasswordViewController.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLResetpasswordViewController.h"
#import "DetailTextField.h"
#import "SignViewModel.h"
#import "STLSendResetSuccessViewController.h"

@interface STLResetpasswordViewController ()<DetailTextFieldDelegate>
@property (weak,nonatomic) UIButton *closeButton;
@property (weak,nonatomic) UILabel *boldTitleLable;
@property (weak,nonatomic) UILabel *detailTextLabel;;
@property (weak,nonatomic) DetailTextField *emailTextField;
@property (weak,nonatomic) UIButton *actionButton;
@property (nonatomic, strong) SignViewModel             *viewModel;
@end

@implementation STLResetpasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
}

-(void)setupViews{
    
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"reset_back"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn convertUIWithARLanguage];

    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.width.height.mas_equalTo(30);
        make.leading.mas_equalTo(20);
    }];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    _boldTitleLable = titleLbl;
    NSString *titleString = STLLocalizedString_(@"reset_password", nil);
    titleLbl.text = titleString;
    titleLbl.font = [UIFont boldSystemFontOfSize:24];

    if (APP_TYPE == 3) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleString];
        [attString addAttribute:NSFontAttributeName value:[UIFont vivaiaSemiBoldFont:24] range:NSMakeRange(0, titleString.length - 8)];
        [attString addAttribute:NSFontAttributeName value:[UIFont vivaiaBoldItalicFont:24] range:NSMakeRange(titleString.length - 8, 8)];
        titleLbl.attributedText = attString;
    }

    [self.view addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(closeBtn.mas_bottom).offset(24);
    }];
    
    UILabel *detailsLabel = [[UILabel alloc] init];
    detailsLabel.text = STLLocalizedString_(@"reset_password_details", nil);
    detailsLabel.font = [UIFont systemFontOfSize:13];
    detailsLabel.numberOfLines = 0;
    detailsLabel.textColor = OSSVThemesColors.col_666666;
    [self.view addSubview:detailsLabel];
    [detailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(24);
    }];
    
    DetailTextField *emailInputFiled = [[DetailTextField alloc] init];
    _emailTextField = emailInputFiled;
    [self.view addSubview:emailInputFiled];
    [emailInputFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(detailsLabel.mas_bottom).offset(24);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
    }];
    emailInputFiled.keyboardType = UIKeyboardTypeEmailAddress;
    emailInputFiled.placeholder = STLLocalizedString_(@"email_field", nil);
    emailInputFiled.deviderColor = OSSVThemesColors.col_CCCCCC;
    emailInputFiled.floatPlaceholderColor = OSSVThemesColors.col_999999;
    emailInputFiled.delegate = self;
    emailInputFiled.text = self.emailStr;
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
    actionButton.layer.cornerRadius = 2;
    [actionButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [actionButton setTitle:STLLocalizedString_(@"reset_send", nil) forState:UIControlStateNormal];
        actionButton.titleLabel.font = [UIFont vivaiaSemiBoldFont:18];

    } else {
        [actionButton setTitle:STLLocalizedString_(@"reset_send", nil).uppercaseString forState:UIControlStateNormal];
        actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];

    }
    [self.view addSubview:actionButton];
    _actionButton = actionButton;
    [actionButton addTarget:self action:@selector(requestResetPassword) forControlEvents:UIControlEventTouchUpInside];
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(emailInputFiled.mas_bottom).offset(36);
    }];
}

-(void)cancelAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)checkEmailTextIsValid:(NSString *)email {
    
    /**
     *  注意此处的提示语已经是国际化啦
     */
    if ([OSSVNSStringTool isEmptyString:email])  {
        [self.emailTextField setError:STLLocalizedString_(@"emailEmptyMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }
    if (![OSSVNSStringTool isValidEmailString:email]) {
        [self.emailTextField setError:STLLocalizedString_(@"emailFormatMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(DetailTextField *)detailField filed:(UITextField *)field{
    [detailField clearError];
}

-(BOOL)textFieldShouldReturn:(DetailTextField *)detailField filed:(UITextField *)field{
    [self requestResetPassword];
    return YES;
}

-(void)requestResetPassword{
    _actionButton.enabled = NO;
    if (![self checkEmailTextIsValid:self.emailTextField.text]) {
        _actionButton.enabled = YES;
        return;
    }
    @weakify(self)
    [self.viewModel requestForgotPasswordNetwork: self.emailTextField.text completion:^(id obj){
        self.actionButton.enabled = YES;
         @strongify(self)
        if([obj isEqual:@(YES)]) {
            [self showSuccess];
        }
    } failure:^(id obj){ }];
}

#pragma mark - Lazy
- (SignViewModel *)viewModel {
    
    if(!_viewModel) {
        _viewModel = [[SignViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

-(void)showSuccess{
    STLSendResetSuccessViewController *successVC = [STLSendResetSuccessViewController new];
    successVC.email = _emailTextField.text;
    successVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:successVC animated:YES completion:nil];
}

@end
