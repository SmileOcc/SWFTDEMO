//
//  OSSVPersonalIdView.m
// XStarlinkProject
//
//  Created by Kevin on 2020/12/5.
//  Copyright © 2020 starlink. All rights reserved.
//  -----个人身份证信息-----

#import "OSSVPersonalIdView.h"
#import "Adorawe-Swift.h"
@interface OSSVPersonalIdView ()<UITextFieldDelegate>
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *verifyBtn;
@property (nonatomic, strong) UIView   *contentView;
@property (nonatomic, strong) UIView   *contentBgView;
@property (nonatomic, strong) UILabel  *promptLabel; //提示语
@property (nonatomic, strong) UILabel  *warningLabel; //输入过程中提示
@property (nonatomic, strong) NSString *countryID;
@property (nonatomic, strong) NSString *countryCode; //国家简码
@end

@implementation OSSVPersonalIdView

-(void)setErrorText:(NSString *)errorText{
    _errorText = errorText;
    self.warningLabel.text = errorText;
    self.warningLabel.hidden = !errorText.length;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    STLLog(@"----- OSSVPersonalIdView");
}
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.countryID = @"";
        _countryCode = @"";
        [self addSubview:self.contentBgView];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.tipLabel];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.lineView];
        [self.contentView addSubview:self.cancelBtn];
        [self.contentView addSubview:self.verifyBtn];
        [self.contentView addSubview:self.promptLabel];
        [self.contentView addSubview:self.warningLabel];
        
        //创建观察者，监听键盘的弹出
       [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHandle:)name: UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    CGFloat space = SCREEN_WIDTH < 375 ? 25 : 36;
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentBgView.mas_leading).offset(space);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-space);
        make.centerY.mas_equalTo(self.contentBgView.mas_centerY);
//        make.height.mas_equalTo(230*kScale_375);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(20);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-20);
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(8);
    }];
    
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(12);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.promptLabel.mas_bottom);
        make.height.equalTo(36*kScale_375);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.textField);
        make.top.mas_equalTo(self.textField.mas_bottom);
        make.height.equalTo(0.5);
    }];

    [self.warningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(1);
        make.height.equalTo(13);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView.mas_leading);
        make.height.equalTo(36);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(24);
        make.width.mas_equalTo(self.verifyBtn.mas_width);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
    }];
    
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.lineView.mas_trailing);
        make.leading.mas_equalTo(self.cancelBtn.mas_trailing).offset(8);
        make.height.equalTo(36);
        make.centerY.mas_equalTo(self.cancelBtn.mas_centerY);
    }];

}

- (UIView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [UIView new];
        _contentBgView.backgroundColor = OSSVThemesColors.col_0D0D0D ;
        _contentBgView.alpha = 0.5;
        _contentBgView.frame = self.frame;
    }
    return _contentBgView;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.layer.cornerRadius = 6.f;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _contentView;
}
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel  new];
        _tipLabel.text = STLLocalizedString_(@"tip", nil);
        _tipLabel.font = [UIFont boldSystemFontOfSize:16];
        _tipLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel  new];
        _titleLabel.text = STLLocalizedString_(@"titleContent", nil);
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [UILabel  new];
        _promptLabel.text = STLLocalizedString_(@"promptText", nil);
        _promptLabel.font = [UIFont systemFontOfSize:10];
        _promptLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _promptLabel.hidden = YES;
    }
    return _promptLabel;
}


- (UILabel *)warningLabel {
    if (!_warningLabel) {
        _warningLabel = [UILabel  new];
        _warningLabel.font = [UIFont systemFontOfSize:11];
        _warningLabel.textColor = OSSVThemesColors.col_B62B21;
        _warningLabel.numberOfLines = 0;
    }
    return _warningLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.font = [UIFont boldSystemFontOfSize:14];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"promptText", nil) attributes:
                                          @{NSForegroundColorAttributeName:OSSVThemesColors.col_B2B2B2,NSFontAttributeName:[UIFont systemFontOfSize:14]}];
        _textField.attributedPlaceholder = attrString;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _textField.textAlignment = NSTextAlignmentRight;
        }
    }
    return _textField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_CCCCCC;
    }
    return _lineView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = OSSVThemesColors.col_FFFFFF;
        if (APP_TYPE == 3) {
            [_cancelBtn setTitle:STLLocalizedString_(@"cancel", nil) forState:UIControlStateNormal];
        } else {
            [_cancelBtn setTitle:STLLocalizedString_(@"cancel", nil).uppercaseString forState:UIControlStateNormal];
        }
        _cancelBtn.titleLabel.font = [UIFont stl_buttonFont:12];
        [_cancelBtn setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
//        _cancelBtn.layer.cornerRadius = 0.f;
        _cancelBtn.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
        _cancelBtn.layer.borderWidth = 1.f;
//        _cancelBtn.layer.masksToBounds = YES;
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)verifyBtn {
    if (!_verifyBtn) {
        _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _verifyBtn.backgroundColor = OSSVThemesColors.col_0D0D0D;
        if (APP_TYPE == 3) {
            [_verifyBtn setTitle:STLLocalizedString_(@"confirm", nil) forState:UIControlStateNormal];
        } else {
            [_verifyBtn setTitle:STLLocalizedString_(@"confirm", nil).uppercaseString forState:UIControlStateNormal];
        }
        _verifyBtn.titleLabel.font = [UIFont stl_buttonFont:12];
        [_verifyBtn setTitleColor:OSSVThemesColors.col_FFFFFF forState:UIControlStateNormal];
//        _verifyBtn.layer.cornerRadius = 0.f;
//        _verifyBtn.layer.masksToBounds = YES;
        [_verifyBtn addTarget:self action:@selector(payMentWithIdCard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyBtn;
}

- (void)setInfoModel:(OSSVCartOrderInfoViewModel *)infoModel {
    _infoModel = infoModel;
    //国家ID：172：沙特， 125：约旦， 165：卡塔尔   这几个国家需要身份证号
    self.countryID = STLToString(self.infoModel.addressModel.countryId);
    
    self.countryCode = STLToString(self.infoModel.addressModel.country_Code);

}

#pragma mark - public method

-(void)payMentWithIdCard:(UIButton *)sender {
    
    if ([self.textField.text isContainArabic] || [self.textField.text isAllSameNumber] || ![self.textField.text isPureNumber]) {
        self.warningLabel.text = STLLocalizedString_(@"id_num_format_err", nil);
        self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
        self.warningLabel.hidden = NO;
        return;
    }
    //国家ID：172：沙特， 125：约旦，加入定位后，以国家简码来判断    ---长度10位

    if ([self.countryCode isEqualToString:@"JO"] || [self.countryCode isEqualToString:@"SA"]) {
        
        if (self.textField.text.length == 10) {
            self.warningLabel.hidden = YES;
            [self hiddenView];
            if (_delegate && [_delegate respondsToSelector:@selector(payMentWithIdCard:)]) {
                [_delegate payMentWithIdCard:self.textField];
            }

        } else if (self.textField.text.length == 0) {
            self.warningLabel.text = STLLocalizedString_(@"promptText", nil);
            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
            self.warningLabel.hidden = NO;
        } else {
            self.warningLabel.text = STLLocalizedString_(@"warningStringFor10", nil);
            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
            self.warningLabel.hidden = NO;
        }
    } else if ([self.countryCode isEqualToString:@"QA"]) {
        if (self.textField.text.length == 11) {
            self.warningLabel.hidden = YES;
            [self hiddenView];
            if (_delegate && [_delegate respondsToSelector:@selector(payMentWithIdCard:)]) {
                [_delegate payMentWithIdCard:self.textField];
            }

        } else {
            self.warningLabel.text = STLLocalizedString_(@"warningStringFor11", nil);
            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
            self.warningLabel.hidden = NO;
        }
    } else {
        if (self.textField.text.length == 0) {
            self.warningLabel.text = STLLocalizedString_(@"promptText", nil);
            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
            self.warningLabel.hidden = NO;

        } else {
            self.warningLabel.hidden = YES;
            [self hiddenView];
            if (_delegate && [_delegate respondsToSelector:@selector(payMentWithIdCard:)]) {
                [_delegate payMentWithIdCard:self.textField];
            }

        }
    }
    
    //    165：卡塔尔 ---长度为11  -----卡塔尔限制
//      if ([self.countryCode isEqualToString:@"QA"]) {
//          if (self.textField.text.length == 11) {
//              self.warningLabel.hidden = YES;
//              [self hiddenView];
//              if (_delegate && [_delegate respondsToSelector:@selector(payMentWithIdCard:)]) {
//                  [_delegate payMentWithIdCard:self.textField];
//              }
//
//          } else {
//              self.warningLabel.text = STLLocalizedString_(@"warningStringFor11", nil);
//              self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
//              self.warningLabel.hidden = NO;
//          }
//      }
    
//    if ([self.countryID isEqualToString:@"172"] || [self.countryID isEqualToString:@"125"]) {
//
//        if (self.textField.text.length == 10) {
//            self.warningLabel.hidden = YES;
//            [self hiddenView];
//            if (_delegate && [_delegate respondsToSelector:@selector(payMentWithIdCard:)]) {
//                [_delegate payMentWithIdCard:self.textField];
//            }
//
//        } else if (self.textField.text.length == 0) {
//            self.warningLabel.text = STLLocalizedString_(@"promptText", nil);
//            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
//            self.warningLabel.hidden = NO;
//        } else {
//            self.warningLabel.text = STLLocalizedString_(@"warningStringFor10", nil);
//            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
//            self.warningLabel.hidden = NO;
//        }
//    } else {
//        if (self.textField.text.length == 0) {
//            self.warningLabel.text = STLLocalizedString_(@"promptText", nil);
//            self.lineView.backgroundColor = OSSVThemesColors.col_B62B21;
//            self.warningLabel.hidden = NO;
//
//        } else {
//            self.warningLabel.hidden = YES;
//            [self hiddenView];
//            if (_delegate && [_delegate respondsToSelector:@selector(payMentWithIdCard:)]) {
//                [_delegate payMentWithIdCard:self.textField];
//            }
//
//        }
//    }

    
}



-(void)showView {
    if (!self.superview) {
        [WINDOW addSubview:self];
        self.contentBgView.alpha = 0.0;
        self.contentView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
            self.contentBgView.alpha = 0.5;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)cancelAction {
    [self hiddenView];
}

-(void)hiddenView
{
    [UIView animateWithDuration:.2 animations:^{
        self.contentBgView.alpha = 0.0;
        self.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -- TextField 添加的动作方法
-(void)textFieldDidChange:(UITextField *)textField {
    self.promptLabel.hidden = textField.text.length == 0;
    if (textField.text.length == 0) {
        self.warningLabel.hidden = YES;
        self.lineView.backgroundColor = OSSVThemesColors.col_CCCCCC;
        return;
    } else {
        self.lineView.backgroundColor = OSSVThemesColors.col_0D0D0D;
    }
}

- (void)keyboardHandle:(NSNotification *)notify {
    self.promptLabel.hidden = NO;
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentBgView.mas_centerY).offset(-50);
    }];
    
}
#pragma mark ---UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}
@end
