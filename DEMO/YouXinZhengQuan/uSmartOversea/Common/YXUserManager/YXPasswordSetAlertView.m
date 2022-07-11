//
//  YXPasswordSetAlertView.m
//  uSmartOversea
//
//  Created by JC_Mac on 2018/10/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXPasswordSetAlertView.h"
#import <Masonry/Masonry.h>
#import <RxSwift/RxSwift-Swift.h>
#import "uSmartOversea-Swift.h"

@interface YXPasswordSetAlertView ()

@property (nonatomic, copy) NSString *textFldText;
@property (nonatomic, strong) UILabel *subTitleLab;

@end

@implementation YXPasswordSetAlertView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.layer.cornerRadius = 6;
    self.layer.masksToBounds = YES;
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont systemFontOfSize:20 weight:UIFontWeightRegular];
    self.titleLab.textColor = QMUITheme.textColorLevel1;
    
    [self addSubview:self.titleLab];
  
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self).offset(32);
        make.centerX.equalTo(self);
    }];
    
    self.backgroundColor = QMUITheme.popupLayerColor;
    
    self.subTitleLab = [[UILabel alloc] init];
    self.subTitleLab.textAlignment = NSTextAlignmentCenter;
    self.subTitleLab.textColor = QMUITheme.textColorLevel2;
    self.subTitleLab.font = [UIFont systemFontOfSize:15];
    self.subTitleLab.adjustsFontSizeToFitWidth = true;
    self.subTitleLab.minimumScaleFactor = 0.5;
    
    [self addSubview:self.subTitleLab];
    [self.subTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.titleLab.mas_bottom).offset(8);
        make.leading.equalTo(self.mas_leading).offset(18);
        make.trailing.equalTo(self.mas_trailing).offset(-18);
    }];

    [self addSubview:self.passwordResetView];
    [self.passwordResetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(42);
        make.top.equalTo(self.subTitleLab.mas_bottom).offset(32);
        make.left.width.equalTo(self);
    }];
    
    
    self.dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dismissBtn setTitle:@"✕" forState:UIControlStateNormal];
    self.dismissBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.dismissBtn setTitleColor: [UIColor themeColorWithNormal:[[UIColor qmui_colorWithHexString:@"#353547"] colorWithAlphaComponent:0.2] andDarkColor:QMUITheme.textColorLevel1] forState:UIControlStateNormal];

    [self addSubview:self.dismissBtn];
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self).offset(9);
        make.right.equalTo(self).offset(-6);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.passwordResetView.textField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)textField1TextChange:(UITextField *)textField{

    if (textField.text.length == 6) {
//        if (self.alertType == YXPasswordSetAlertTypePwd) {
//
//            //切换确认输入密码， 清空界面
//            self.pwd = textField.text;
//            self.alertType = YXPasswordSetAlertTypeConfirm;
//            self.titleLab.text = [YXLanguageUtility kLangWithKey:@"mine_confirm_tpwd"];
//            [self.passwordResetView clearText];
//
//        }else if (self.alertType == YXPasswordSetAlertTypeConfirm){
//
//            if ([self.pwd isEqualToString:textField.text]) {
//
//                if ([self isAllNumber: self.pwd] ) {
//                    if ([self.delegate respondsToSelector:@selector(passwordSetAlertViewDidSetPwd:)]) {
//                        [self.delegate passwordSetAlertViewDidSetPwd:self.pwd];
//                    }
//                    self.pwd = @"";
//                }else {
//
//                    if ([self.delegate respondsToSelector:@selector(alertWithMsg:alertType:)]) {
//                        [self.delegate alertWithMsg: [YXLanguageUtility kLangWithKey:@"mine_tpwd_num"] alertType:YXPasswordSetAlertTypePwd];
//                    }
//                }
//
//            }else{
//                if ([self.delegate respondsToSelector:@selector(alertWithMsg:alertType:)]) {
//                    [self.delegate alertWithMsg: [YXLanguageUtility kLangWithKey:@"mine_pwd_diff"] alertType:YXPasswordSetAlertTypePwd];
//                }
//            }
//        }else { //验证交易密码
            self.pwd = textField.text;
            if ([self isAllNumber: self.pwd]) {
                if ([self.delegate respondsToSelector:@selector(passwordSetAlertViewDidValidPwd:)]) {
                    [self.delegate passwordSetAlertViewDidValidPwd:self.pwd];
                }
                self.pwd = @"";
            }else {
                if ([self.delegate respondsToSelector:@selector(alertWithMsg:alertType:)]) {
                    [self.delegate alertWithMsg:[YXLanguageUtility kLangWithKey:@"mine_tpwd_num"] alertType:YXPasswordSetAlertTypeValid];
                }
            }
            
//        }
    }
}

- (BOOL)isAllNumber:(NSString *)text {
    
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:text]) {
        return YES;
    }
    return NO;
}

#pragma mark -懒加载
- (YXPasswordResetView *)passwordResetView{
    if (!_passwordResetView) {
        
        _passwordResetView = [[YXPasswordResetView alloc] initWithGridWidth:42 viewWidth:YXConstant.screenWidth-58];
        _passwordResetView.textColor = QMUITheme.textColorLevel1;
 
        _passwordResetView.textFont = [UIFont fontWithName:@"DINPro-Regular" size:30];
        _passwordResetView.seletedColor = [QMUITheme mainThemeColor];//[[UIColor qmui_colorWithHexString:@"#58687F"] colorWithAlphaComponent:0.7];
        _passwordResetView.normalColor = QMUITheme.textColorLevel4;
        
        
    }
    
    return _passwordResetView;
}

- (void)setAlertType:(YXPasswordSetAlertType)alertType {
    
    _alertType = alertType;
    self.backgroundColor = QMUITheme.popupLayerColor;
    self.subTitleLab.hidden = NO;
    
//    if (self.alertType == YXPasswordSetAlertTypePwd) {
//        self.titleLab.text = [YXLanguageUtility kLangWithKey:@"mine_set_tpwd"];
//    }else if (self.alertType == YXPasswordSetAlertTypeConfirm) {
//        self.titleLab.text = [YXLanguageUtility kLangWithKey:@"mine_confirm_tpwd"];
//    }else {
        self.titleLab.text = [YXLanguageUtility kLangWithKey:@"mine_input_tpwd"];
        self.subTitleLab.hidden = YES;
        [self.passwordResetView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLab.mas_bottom).offset(39);
        }];
//    }
    self.subTitleLab.text = [YXLanguageUtility kLangWithKey:@"mine_tpwd_tip"];
}

@end
