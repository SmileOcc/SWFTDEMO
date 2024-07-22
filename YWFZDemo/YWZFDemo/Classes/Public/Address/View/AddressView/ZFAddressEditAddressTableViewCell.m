//
//  ZFAddressEditAddressTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditAddressTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

static NSInteger kZFAddressEditAddress = 35;
static NSInteger kZFAddressEditAddressSecond = 100;

@interface ZFAddressEditAddressTableViewCell () <ZFInitViewProtocol, UITextFieldDelegate>

@property (nonatomic, assign) ZFAddressEditAddressType      editAddressType;
@property (nonatomic, strong) UITextField                   *enterTextField;
@property (nonatomic, strong) UILabel                       *tipsLabel;
@property (nonatomic, strong) UILabel                       *placedTipsLabel;
@end

@implementation ZFAddressEditAddressTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)Textfield {
    [Textfield resignFirstResponder];//关闭键盘
    [self baseIsEditEvent:NO];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!self.typeModel.isShowBottomTip && [self.infoModel isTestCountry]) {
        self.typeModel.isShowBottomTip = YES;
        [self baseShowPlaceholderTips:YES];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self baseIsEditEvent:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSInteger limitMax = [self limitLengthMax];
    
    self.enterTextField.placeholder = @"";

    
    if ([string isEqualToString:@""]) {
        //删除字符
        if (textField.text.length == limitMax && self.typeModel.isShowTips == YES) {
            
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            self.tipsLabel.hidden = YES;
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            [self baseCancelContent:[textField.text substringToIndex:textField.text.length - 1]];

        } else {
            [self baseShowTips:NO overMax:NO content:[textField.text substringToIndex:textField.text.length - 1]];

        }
        
        return YES;
    } else if (![string isEqualToString:@""]){
        //增加字符
        if (textField.text.length > limitMax - 1) {
            [self baseShowTips:YES overMax:YES content:textField.text];
            return NO;
        } else if (textField.text.length < limitMax) {
            [self baseShowTips:NO overMax:NO content:[NSString stringWithFormat:@"%@%@", textField.text, string]];
            return YES;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    self.typeModel.isShowBottomTip = NO;
    
    
    if (ZFIsEmptyString(textField.text)) {
        self.enterTextField.placeholder = (self.editAddressType == ZFAddressEditAddressTypeFirstAddress) ? ZFLocalizedString(@"ModifyAddress_Address1_Placeholder", nil) :ZFLocalizedString(@"ModifyAddress_Address2_Placeholder", nil);

    }
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    NSInteger limitMax = [self limitLengthMax];

    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    
    if (ZFIsEmptyString(textField.text)) {
        textField.text = @"";
        if (_editAddressType == ZFAddressEditAddressTypeFirstAddress) {
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_TipLabel",nil);
            [self baseShowTips:YES overMax:NO content:textField.text];
            
        } else {
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            self.tipsLabel.hidden = YES;
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            [self baseCancelContent:textField.text];
        }
        return;
    }
    
    if (_editAddressType == ZFAddressEditAddressTypeFirstAddress) {
        if(textField.text.length == 0){
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_TipLabel",nil);
            [self baseShowTips:YES overMax:NO content:textField.text];

        } else if (textField.text.length < 5) {
            self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Shipping_TipLabel",nil),@"5"];
            [self baseShowTips:YES overMax:NO content:textField.text];

        } else if (textField.text.length < limitMax) {
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            self.tipsLabel.hidden = YES;
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            [self baseCancelContent:textField.text];

        }
    } else {
        if (textField.text.length < limitMax) {
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            self.tipsLabel.hidden = YES;
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            [self baseCancelContent:textField.text];
        }
    }
}


- (NSInteger)limitLengthMax {
      NSInteger limit = _editAddressType == ZFAddressEditAddressTypeSecondAddress ? kZFAddressEditAddressSecond : kZFAddressEditAddress;
    return limit;
}
#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.enterTextField];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.placedTipsLabel];
}

- (void)zfAutoLayoutView {
    [self.enterTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.height.mas_equalTo(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.enterTextField);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.placedTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.lineView);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];

}

#pragma mark - setter

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    
    self.infoModel = infoModel;
    self.typeModel = typeModel;
    
    self.editAddressType = self.typeModel.editType == ZFAddressEditTypeAddressFirst ? ZFAddressEditAddressTypeFirstAddress : ZFAddressEditAddressTypeSecondAddress;
    
    // 第一个地址不能输入
    self.enterTextField.enabled = (self.editAddressType == ZFAddressEditAddressTypeFirstAddress) ? NO : YES;
    self.enterTextField.text = _editAddressType == ZFAddressEditAddressTypeFirstAddress ? self.infoModel.addressline1 : self.infoModel.addressline2;
    
    // 占位文字
//    self.enterTextField.placeholder = (self.editAddressType == ZFAddressEditAddressTypeFirstAddress) ? ZFLocalizedString(@"ModifyAddress_Address1_Placeholder", nil) : ZFLocalizedString(@"ModifyAddress_Address2_Placeholder", nil);
    
    self.enterTextField.placeholder = (self.editAddressType == ZFAddressEditAddressTypeFirstAddress) ? ZFLocalizedString(@"ModifyAddress_Address1_Placeholder", nil) :ZFLocalizedString(@"ModifyAddress_Address2_Placeholder", nil);

    
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    self.tipsLabel.hidden = YES;
    self.placedTipsLabel.hidden = YES;
    if ([self isShowTips] && self.typeModel.isShowTips) {
        
        
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
        //occ测试数据 新
        if (self.typeModel.isShowBottomTip) {
            self.placedTipsLabel.hidden = NO;
            self.lineView.backgroundColor = ZFC0x2D2D2D();
            
            self.placedTipsLabel.text = (self.editAddressType == ZFAddressEditAddressTypeFirstAddress) ? ZFLocalizedString(@"ModifyAddress_Address1_Placeholder", nil) : ZFLocalizedString(@"ModifyAddress_Address2_Placeholder", nil);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.enterTextField.placeholder = @"";
                [self.enterTextField becomeFirstResponder];
            });

            
        } else {
            self.tipsLabel.hidden = NO;
            self.lineView.backgroundColor = ZFC0xFE5269();
        }
        
        
    } else {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
}

- (BOOL)isShowTips {
    
    NSInteger limitMax = [self limitLengthMax];
    
    BOOL showTips = NO;
    if ([self.enterTextField.text length] == 0) {
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_TipLabel",nil);
        showTips = YES;
    } else if ([self.enterTextField.text length] < 5) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Shipping_TipLabel",nil),@"5"];
        showTips = YES;
    } else if (self.enterTextField.text.length >= limitMax) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),[NSString stringWithFormat:@"%ld",(long)limitMax]];
        showTips = YES;
    } else if ([self.infoModel isAllNumberFirstAddressLine]) {
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_AllNum_TipLabel",nil);
        showTips = YES;
    } else if ([self.infoModel isContainSpecialMarkFirstAddressLine]) {
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_SpecialString_TipLabel",nil);
        showTips = YES;
    } else if ([self.infoModel isContainSpecialEmailMarkFirstAddressLine]) {
        
        //occ测试数据 替换文案
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_SpecialString_TipLabel",nil);
        showTips = YES;
    }
    return showTips;
}


#pragma mark - getter

- (UITextField *)enterTextField {
    if (!_enterTextField) {
        _enterTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _enterTextField.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _enterTextField.font = [UIFont systemFontOfSize:14];
        _enterTextField.delegate = self;
        _enterTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _enterTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
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

- (UILabel *)placedTipsLabel {
    if (!_placedTipsLabel) {
        _placedTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placedTipsLabel.textColor = ZFC0x999999();
        _placedTipsLabel.font = [UIFont systemFontOfSize:12];
        _placedTipsLabel.hidden = YES;
    }
    return _placedTipsLabel;
}
@end
