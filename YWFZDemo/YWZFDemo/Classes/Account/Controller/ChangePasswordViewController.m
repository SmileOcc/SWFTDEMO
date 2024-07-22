//
//  ChangePasswordViewController.m
//  Dezzal
//
//  Created by ZJ1620 on 16/8/6.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ZFInitViewProtocol.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "CustomTextField.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"
#import "UIButton+ZFButtonCategorySet.h"

#import "ZFRequestModel.h"
#import "YWLocalHostManager.h"
#import "ZFNetwork.h"
#import "ZFApiDefiner.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "RSA.h"
#import "MF_Base64Additions.h"

@import GlobalegrowIMSDK;

@interface ChangePasswordViewController () <UITextFieldDelegate, ZFInitViewProtocol>
@property (nonatomic, strong) UITextField           *oldpassWordField;
@property (nonatomic, strong) UITextField           *passWordField;
@property (nonatomic, strong) UITextField           *confirmPassWordField;
@property (nonatomic, strong) UIButton                  *resetButton;
@property (nonatomic, strong) UILabel                   *pointOldLabel;
@property (nonatomic, strong) UILabel                   *pointNewLabel;
@property (nonatomic, strong) UILabel                   *pointConfirmLabel;
@property (nonatomic, strong) UIImageView               *roundMarkImageView;
@property (nonatomic, strong) UILabel                   *roundMarkTipLabel;
@end

@implementation ChangePasswordViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlankPage)];
    [self.view addGestureRecognizer:tap];
    self.fd_interactivePopDisabled = YES;
}

#pragma mark - action methods
- (void)resetButtonAction:(UIButton *)sender {
    if (![self checkInfo]) {
        return;
    }
    
    NSDictionary *dataDict = @{@"token"        : TOKEN ? : @"",
                               @"old_password" : ZFToString(self.oldpassWordField.text),
                               @"password"     : ZFToString(self.passWordField.text),
                               @"repassword"   : ZFToString(self.confirmPassWordField.text),
                               ZFApiLangKey   : ZFToString([ZFLocalizationString shareLocalizable].nomarLocalizable)
                               };
    NSString *dataJson = [dataDict yy_modelToJSONString];
    NSString *encryptString = [RSA encryptString:dataJson publicKey:kEncryptPublicKey];
    
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url = API(Port_editPassword);
    model.forbidAddPublicArgument = YES; // 修改密码接口需要加密,不添加公共参数
    model.parmaters = @{@"is_enc"  : @"2",
                        @"data"    : ZFToString(encryptString) };
    
    ShowLoadingToView(self.view);
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        HideLoadingFromView(self.view);
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDict)) {
            ShowToastToViewWithText(nil, resultDict[@"msg"]);
            
            if ([resultDict[@"error"] integerValue] == 0) {
                YWLog(@"修改密码成功退出当前页面====%@", resultDict);
                [self doChangePasswordSuccess];
                return ;
            }
        }
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"ChangePassword_VC_Request_Failure_Message",nil));
        
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"ChangePassword_VC_Request_Failure_Message",nil));
    }];
}

// 退出登录时添加一个翻转的转场动画
- (void)doChangePasswordSuccess
{
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                      duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];//防止设备横屏，新vc的View有异常旋转动画
                        [UIView setAnimationsEnabled:NO];
                        [[AccountManager sharedManager] clearUserInfo];
                        [UIView setAnimationsEnabled:oldState];
                        
                    } completion:^(BOOL finished) {
                        [[ChatConfig share] logout];
                        
                        //弹出登录页面
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[UIViewController currentTopViewController] judgePresentLoginVCCompletion:nil];
                        });
                    }];
}

- (void)tapBlankPage {
    [self.oldpassWordField resignFirstResponder];
    [self.passWordField resignFirstResponder];
    [self.confirmPassWordField resignFirstResponder];
    [self checkInfo];
}

- (BOOL)checkInfo {
    
    if ([self.oldpassWordField.text isEqualToString:@""] || self.oldpassWordField.text.length == 0) {
        self.pointOldLabel.text = ZFLocalizedString(@"ChangePassword_VC_Provide_Message",nil);
        self.pointOldLabel.hidden = NO;
        return NO;
    }
    
    if (![NSStringUtils checkPassWord:self.passWordField.text])
    {
        if (self.passWordField.text.length<8) {
            self.pointNewLabel.text = ZFLocalizedString(@"Register_password_less",nil);
        } else {
            self.pointNewLabel.text = ZFLocalizedString(@"Register_password_include",nil);
        }
        self.pointNewLabel.hidden = NO;
        return NO;
    }
    
    if ([self.confirmPassWordField.text isEqualToString:@""] || self.confirmPassWordField.text.length == 0) {
        self.pointConfirmLabel.text = ZFLocalizedString(@"ChangePassword_VC_Confirm_Message",nil);
        self.pointConfirmLabel.hidden = NO;
        return NO;
    }
    if (![self.confirmPassWordField.text isEqualToString:self.passWordField.text]) {
        self.pointConfirmLabel.text = ZFLocalizedString(@"ChangePassword_VC_NotMatch_Message",nil);
        self.pointConfirmLabel.hidden = NO;
        return NO;
    }
    return YES;
}

#pragma  mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.pointConfirmLabel.hidden = YES;
    self.pointNewLabel.hidden = YES;
    self.pointOldLabel.hidden = YES;
    return YES;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"ChangePassword_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    self.oldpassWordField = [self setTextFielWith:ZFLocalizedString(@"ChangePassword_VC_OrignPassword",nil)];
    self.passWordField = [self setTextFielWith:ZFLocalizedString(@"ChangePassword_VC_NewPassword",nil)];
    self.confirmPassWordField = [self setTextFielWith:ZFLocalizedString(@"ChangePassword_VC_ConfirmPassword",nil)];
    [self.view addSubview:self.pointOldLabel];
    [self.view addSubview:self.pointNewLabel];
    [self.view addSubview:self.pointConfirmLabel];
    [self.view addSubview:self.resetButton];
    [self.view addSubview:self.roundMarkImageView];
    [self.view addSubview:self.roundMarkTipLabel];
}

- (void)zfAutoLayoutView {
    //感叹号图片
    [self.roundMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).offset(20);
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    //信息安全建议提示
    [self.roundMarkTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@(15));
        make.leading.mas_equalTo(@(34));
        make.trailing.mas_equalTo(@(-20));
    }];
    
    [self.oldpassWordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.roundMarkTipLabel.mas_bottom).offset(20);
        make.leading.mas_equalTo(@(20));
        make.trailing.mas_equalTo(@(-20));
        make.height.mas_equalTo(@(50));
    }];
    
    [self.passWordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.oldpassWordField.mas_bottom).offset(25);
        make.leading.mas_equalTo(@(20));
        make.trailing.mas_equalTo(@(-20));
        make.height.mas_equalTo(@(50));
    }];
    
    [self.confirmPassWordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passWordField.mas_bottom).offset(25);
        make.leading.mas_equalTo(@(20));
        make.trailing.mas_equalTo(@(-20));
        make.height.mas_equalTo(@(50));
    }];
    
    [self.pointOldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.oldpassWordField.mas_bottom);
        make.leading.mas_equalTo(@(20));
    }];
    
    [self.pointNewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passWordField.mas_bottom).offset(5);
        make.leading.mas_equalTo(@(20));
    }];
    
    [self.pointConfirmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.confirmPassWordField.mas_bottom);
        make.leading.mas_equalTo(@(20));
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.confirmPassWordField.mas_bottom).offset(25);
        make.leading.mas_equalTo(@(20));
        make.trailing.mas_equalTo(@(-20));
        make.height.mas_equalTo(@(40));
    }];
}

- (UITextField *)setTextFielWith:(NSString *)placeholder {
    UITextField * text = [[UITextField alloc]initWithFrame:CGRectZero];
    text.placeholder = placeholder;
    text.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    text.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
    text.leftViewMode = UITextFieldViewModeAlways;
    text.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    text.textColor = ZFCOLOR(0, 0, 0, 1.0);
    text.clearButtonMode = UITextFieldViewModeWhileEditing;
    [text setSecureTextEntry:YES];
    text.delegate = self;
    text.font = [UIFont systemFontOfSize:16];
    if (kiOSSystemVersion < 13.0) {
        [text setValue:ZFCOLOR(153, 153, 153, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
        [text setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"];   
    }
    [self.view addSubview:text];
    return text;
}

#pragma mark - getter

- (UIImageView *)roundMarkImageView {
    if (!_roundMarkImageView) {
        UIImage *image = ZFImageWithName(@"share_getItFree_icon");
        _roundMarkImageView = [[UIImageView alloc] initWithImage:[image imageWithColor:ZFC0xFE5269()]];
    }
    return _roundMarkImageView;
}

- (UILabel *)roundMarkTipLabel {
    if (!_roundMarkTipLabel) {
        _roundMarkTipLabel = [[UILabel alloc] init];
        _roundMarkTipLabel.numberOfLines = 0;
        _roundMarkTipLabel.font = ZFFontSystemSize(11);
        _roundMarkTipLabel.textColor = ZFC0xFE5269();
        _roundMarkTipLabel.text = ZFLocalizedString(@"Information_security_publicAdvice",nil);
    }
    return _roundMarkTipLabel;
}

- (UILabel *)pointOldLabel {
    if (!_pointOldLabel) {
        _pointOldLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _pointOldLabel.textColor = ZFC0xFE5269();
        _pointOldLabel.font = [UIFont systemFontOfSize:14];
        _pointOldLabel.hidden = YES;
    }
    return _pointOldLabel;
}

- (UILabel *)pointNewLabel {
    if (!_pointNewLabel) {
        _pointNewLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _pointNewLabel.textColor = ZFC0xFE5269();
        _pointNewLabel.font = [UIFont systemFontOfSize:10];
        _pointNewLabel.hidden = YES;
    }
    return _pointNewLabel;
}

- (UILabel *)pointConfirmLabel {
    if (!_pointConfirmLabel) {
        _pointConfirmLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _pointConfirmLabel.textColor = ZFC0xFE5269();
        _pointConfirmLabel.font = [UIFont systemFontOfSize:14];
        _pointConfirmLabel.hidden = YES;
    }
    return _pointConfirmLabel;
}

- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetButton.layer.cornerRadius = 3;
        _resetButton.layer.masksToBounds = YES;
        //_resetButton.backgroundColor = ZFCThemeColor();
        [_resetButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_resetButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        
        [_resetButton setTitle:ZFLocalizedString(@"ChangePassword_VC_ResetPassword",nil) forState:UIControlStateNormal];
        [_resetButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _resetButton.titleLabel.font = ZFFontBoldSize(16);
        [_resetButton addTarget:self action:@selector(resetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

@end
