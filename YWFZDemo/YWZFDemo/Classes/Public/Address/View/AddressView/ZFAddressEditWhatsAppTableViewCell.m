
//
//  ZFAddressEditWhatsAppTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/11/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditWhatsAppTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFAddressEditWhatsAppTableViewCell() <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UITextField           *enterTextField;
@property (nonatomic, strong) UILabel               *tipsLabel;
@end

@implementation ZFAddressEditWhatsAppTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)Textfield {
    [Textfield resignFirstResponder];//关闭键盘
    [self baseIsEditEvent:NO];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self baseIsEditEvent:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@""]) {//删除字符
        if (textField.text.length == 35 && self.typeModel.isShowTips == YES) {
            self.tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
            self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
            [self baseCancelContent:[textField.text substringToIndex:textField.text.length - 1]];
        } else {
            [self baseShowTips:NO overMax:NO content:[textField.text substringToIndex:textField.text.length - 1]];

        }
        return YES;
        
    } else if (![string isEqualToString:@""]){//增加字符
        if (textField.text.length > 34) {
            [self baseShowTips:YES overMax:YES content:textField.text];
            return NO;
            
        } else if (textField.text.length < 35) {
            [self baseShowTips:NO overMax:NO content:[NSString stringWithFormat:@"%@%@", textField.text, string]];
            return YES;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    
    if (ZFIsEmptyString(textField.text)) {
        textField.text = @"";
        [self baseShowTips:NO overMax:NO content:textField.text];
        return;
    }
    if (textField.text.length < 35) {
        self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
        self.tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        [self baseCancelContent:textField.text];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.enterTextField];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
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
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-30);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
}

#pragma mark - setter
- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel {
    self.infoModel = infoModel;
    self.typeModel = typeModel;
    
    self.enterTextField.text = ZFToString(self.infoModel.whatsapp);
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    self.tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
    
    if ([self isShowTips]) {
        self.lineView.backgroundColor = ZFC0xFE5269();
        self.tipsLabel.textColor = ZFC0xFE5269();
    } else {
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Extra_Tips",nil);
    }
}

- (BOOL)isShowTips {
    BOOL showTips = NO;
    if (self.enterTextField.text.length >= 35) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),@"35"];
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
        _enterTextField.keyboardType = UIKeyboardTypeNumberPad;
        _enterTextField.delegate = self;
        _enterTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _enterTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;;
        _enterTextField.placeholder = @"WhatsApp";
    }
    return _enterTextField;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        _tipsLabel.numberOfLines = 2;
        _tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Extra_Tips",nil);
    }
    return _tipsLabel;
}
@end
