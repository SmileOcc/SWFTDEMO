//
//  OSSVCouponApplyView.m
// XStarlinkProject
//
//  Created by 10010 on 20/10/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCouponApplyView.h"
#import "OSSVCouponCellModel.h"
#import "OSSVCouponModel.h"
#import "OSSVMyCouponsListsModel.h"

#define CheckOutCellLeftPadding  12
#define CheckOutCellNormalHeight

@interface OSSVCouponApplyView ()

@property (nonatomic, strong) UIView   *textFieldBg;
@end

@implementation OSSVCouponApplyView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        if (APP_TYPE != 3) {
            self.layer.cornerRadius = 6;
            self.layer.masksToBounds = YES;
        }
        
        [self addSubview:self.textFieldBg];
        [self.textFieldBg addSubview:self.couponInputTF];
        [self addSubview:self.applyButton];
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
    
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mas_centerY);
            if (APP_TYPE == 3) {
                make.size.equalTo(CGSizeMake(68, 28));
            } else {
                make.size.equalTo(CGSizeMake(90, 36));
            }
        }];
        
        [self.textFieldBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading).offset(CheckOutCellLeftPadding);
            make.trailing.mas_equalTo(self.applyButton.mas_leading).offset(-8);
            make.height.equalTo(36);

        }];
        
        [self.couponInputTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.textFieldBg.mas_leading).offset(11);
            make.top.bottom.trailing.mas_equalTo(self.textFieldBg);
        }];
        
        [self.couponInputTF addTarget:self action:@selector(didInputText:) forControlEvents:UIControlEventEditingChanged];
        [self.couponInputTF addTarget:self action:@selector(beginInputText:) forControlEvents:UIControlEventEditingDidBegin];
        
        
    }
    return self;
}

//-(void)updateConstraints{
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(12);
//        make.trailing.equalTo(-12);
//        make.top.mas_equalTo(12);
//        make.height.equalTo(48);
//    }];
//    [super updateConstraints];
//}


#pragma mark - action
-(void)buttonAction {
    [self.couponInputTF resignFirstResponder];
    if (!self.model.couponModel.code.length) {
        //不需要弹窗了
//        STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:nil message:STLLocalizedString_(@"validCouponCode",nil) preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:STLLocalizedString_(@"ok",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        }]];
//        [self.window.rootViewController presentViewController:alertController animated:YES completion:^{}];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_CouponCellDidClickApply:)]) {
            [self.delegate STL_CouponCellDidClickApply:_model];
        }
    }
}

-(void)didInputText:(UITextField *)textField {
    self.model.couponModel.code = textField.text;
    [self handleApplyUserEnabled:textField.text];
}

-(void)beginInputText:(UITextField *)textField {

}

-(void)handleApplyUserEnabled:(NSString *)text {
    if (self.textFieldBlock) {
        self.textFieldBlock(text);
    }
    
    if (text.length) {
        self.applyButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
        [self.applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.applyButton.enabled = YES;
    }else{
        self.applyButton.backgroundColor = OSSVThemesColors.col_CCCCCC;
        [self.applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.applyButton.enabled = NO;
    }
}

#pragma mark - setter and getter

- (void)setCouponModel:(OSSVCouponModel *)couponModel {
    _couponModel = couponModel;
    
    if ([OSSVNSStringTool isEmptyString:_couponModel.code]) {
        ///为空的时候
        self.model.inputUserInteractionEnabled = YES;
        self.model.status = ApplyButtonStatusApply;
        self.model.codeText = @"";
        self.model.couponModel.code = @"";
    }else{
        self.model.inputUserInteractionEnabled = YES;
        self.model.status = ApplyButtonStatusClear;
        self.model.codeText = _couponModel.code;
        self.model.couponModel.code = _couponModel.code;
    }
    
    self.couponInputTF.userInteractionEnabled = self.model.inputUserInteractionEnabled;
    self.couponInputTF.text = self.model.codeText;
    [self handleApplyUserEnabled:self.model.codeText];
    ///1.4.4 remove 的时候不允许编辑
    if (self.model.status == ApplyButtonStatusApply) {
        if (APP_TYPE == 3) {
            [self.applyButton setTitle:STLLocalizedString_(@"category_filter_apply", nil) forState:UIControlStateNormal];
        } else {
            [self.applyButton setTitle:STLLocalizedString_(@"category_filter_apply", nil).uppercaseString forState:UIControlStateNormal];
        }
        self.couponInputTF.enabled = true;
    }else if(self.model.status == ApplyButtonStatusClear){
        if (APP_TYPE == 3) {
            [self.applyButton setTitle:STLLocalizedString_(@"Clear", nil) forState:UIControlStateNormal];
        } else {
            [self.applyButton setTitle:STLLocalizedString_(@"Clear", nil).uppercaseString forState:UIControlStateNormal];
        }
        self.couponInputTF.enabled = false;
    }
}

- (void)setSelectedModel:(OSSVMyCouponsListsModel *)selectedModel {
    
    _selectedModel = selectedModel;
    self.couponInputTF.enabled = true;
    if (![OSSVNSStringTool isEmptyString:_selectedModel.couponCode]) {
        self.model.inputUserInteractionEnabled = YES;
        self.model.status = ApplyButtonStatusApply;
        self.model.codeText = _selectedModel.couponCode;
        self.model.couponModel.code = _selectedModel.couponCode;
    }
    
    self.couponInputTF.userInteractionEnabled = self.model.inputUserInteractionEnabled;
    self.couponInputTF.text = self.model.codeText;
    [self handleApplyUserEnabled:self.model.codeText];
    
    
    if(self.model.status == ApplyButtonStatusClear || [self.couponModel.code isEqualToString:STLToString(self.couponInputTF.text)]){
        [self.applyButton setTitle:STLLocalizedString_(@"Clear", nil).uppercaseString forState:UIControlStateNormal];
        self.couponInputTF.enabled = false;
    }else if (self.model.status == ApplyButtonStatusApply ) {
        [self.applyButton setTitle:STLLocalizedString_(@"category_filter_apply", nil).uppercaseString forState:UIControlStateNormal];
        self.couponInputTF.enabled = true;
    }
}


- (OSSVCouponCellModel *)model {
    if (!_model) {
        _model = [[OSSVCouponCellModel alloc] init];
        _model.couponModel = [[OSSVCouponModel alloc] init];
    }
    return _model;
}

- (UIView *)textFieldBg {
    if (!_textFieldBg) {
        _textFieldBg = [UIView new];
//        _textFieldBg.backgroundColor = OSSVThemesColors.col_F5F5F5;
    }
    return _textFieldBg;
}

-(UITextField *)couponInputTF
{
    if (!_couponInputTF) {
        _couponInputTF = ({
            UITextField *textField = [[UITextField alloc] init];
            textField.placeholder = STLLocalizedString_(@"inputdCouponCode", nil);
            textField.font = [UIFont boldSystemFontOfSize:14];
            textField.borderStyle = UITextBorderStyleNone;
            textField.backgroundColor = [UIColor clearColor];
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.layer.cornerRadius = 2.f;
            textField.layer.masksToBounds = YES;
            textField.textAlignment = NSTextAlignmentLeft;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                textField.textAlignment = NSTextAlignmentRight;
            }
            textField;
        });
    }
    return _couponInputTF;
}

-(UIButton *)applyButton
{
    if (!_applyButton) {
        _applyButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [button setTitle:STLLocalizedString_(@"category_filter_apply", nil) forState:UIControlStateNormal];
            if (APP_TYPE == 3) {
                button.titleLabel.font = [UIFont systemFontOfSize:12];
            } else {
                button.titleLabel.font = [UIFont stl_buttonFont:12];
            }
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [OSSVThemesColors col_262626];
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _applyButton;
}

@end
