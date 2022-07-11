//
//  STLSendResetSuccessViewController.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLSendResetSuccessViewController.h"
#import "SignViewModel.h"

@interface STLSendResetSuccessViewController ()
@property (weak,nonatomic) UIButton *closeButton;
@property (weak,nonatomic) UILabel *boldTitleLable;
@property (weak,nonatomic) UILabel *detailTextLabel;;
@property (weak,nonatomic) UIButton *returnToSignIn;
@property (weak,nonatomic) UIButton *resend;
@property (nonatomic, strong) SignViewModel             *viewModel;
@end

@implementation STLSendResetSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

-(void)setupViews{
    
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"close_sign"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.width.height.mas_equalTo(30);
        make.leading.mas_equalTo(20);
    }];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    _boldTitleLable = titleLbl;
    titleLbl.text = STLLocalizedString_(@"send_success", nil);
    if (APP_TYPE == 3) {
        titleLbl.font = [UIFont vivaiaSemiBoldFont:18];

    } else {
        titleLbl.font = [UIFont boldSystemFontOfSize:24];
    }
    [self.view addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(closeBtn.mas_bottom).offset(24);
    }];
    
    UILabel *detailsLabel = [[UILabel alloc] init];
    
    detailsLabel.font = [UIFont systemFontOfSize:13];
    detailsLabel.numberOfLines = 0;
    _detailTextLabel = detailsLabel;
    detailsLabel.textColor = OSSVThemesColors.col_666666;
    [self.view addSubview:detailsLabel];
    [detailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(24);
    }];
    NSString *srctext = [NSString stringWithFormat:STLLocalizedString_(@"send_success_details", nil),self.email];
    NSRange rage = [srctext rangeOfString:self.email];
    NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithString:srctext];
    [detailText setAttributes:@{
        NSForegroundColorAttributeName: OSSVThemesColors.col_0D0D0D
    } range:rage];
    detailsLabel.attributedText = detailText;
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
    actionButton.layer.cornerRadius = 2;
        if (APP_TYPE == 3) {
            actionButton.titleLabel.font = [UIFont vivaiaSemiBoldFont:18];
            [actionButton setTitle:STLLocalizedString_(@"reset_return_to_signin", nil) forState:UIControlStateNormal];

        } else {
            actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            [actionButton setTitle:STLLocalizedString_(@"reset_return_to_signin", nil).uppercaseString forState:UIControlStateNormal];

        }
    [actionButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.view addSubview:actionButton];
    _returnToSignIn = actionButton;
    [actionButton addTarget:self action:@selector(returnToSignInAction) forControlEvents:UIControlEventTouchUpInside];
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(detailsLabel.mas_bottom).offset(36);
    }];
    
    UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            resendButton.titleLabel.font = [UIFont vivaiaSemiBoldFont:18];
            resendButton.layer.borderColor = OSSVThemesColors.col_0D0D0D.CGColor;
            resendButton.layer.borderWidth =  2.f;
            [resendButton setTitle:STLLocalizedString_(@"reset_resent", nil) forState:UIControlStateNormal];

        } else {
            resendButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [resendButton setTitle:STLLocalizedString_(@"reset_resent", nil).uppercaseString forState:UIControlStateNormal];
        }

    [resendButton setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
    [self.view addSubview:resendButton];
    [resendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        if (APP_TYPE == 3) {
            make.top.mas_equalTo(actionButton.mas_bottom).offset(12);
        } else {
            make.top.mas_equalTo(actionButton.mas_bottom).offset(0);
        }
        
    }];
    _resend = resendButton;
    [resendButton addTarget:self action:@selector(requestResetPassword) forControlEvents:UIControlEventTouchUpInside];
}

-(void)returnToSignInAction{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


-(void)cancelAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)requestResetPassword{
    _resend.enabled = NO;
    @weakify(self)
    [self.viewModel requestForgotPasswordNetwork: self.email completion:^(id obj){
         @strongify(self)
        if([obj isEqual:@(YES)]) {
            self.resend.enabled = YES;
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"reset_send_success", nil)];
        }else{
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"reset_send_failed", nil)];
        }
    } failure:^(id obj){
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"reset_send_failed", nil)];
    }];
}

#pragma mark - Lazy
- (SignViewModel *)viewModel {
    
    if(!_viewModel) {
        _viewModel = [[SignViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}



@end
