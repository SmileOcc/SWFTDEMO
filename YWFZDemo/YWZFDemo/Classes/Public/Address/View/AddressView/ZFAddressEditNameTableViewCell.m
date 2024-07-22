
//
//  ZFAddressEditNameTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditNameTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFAddressEditNameTableViewCell () <ZFInitViewProtocol, UITextFieldDelegate>

@property (nonatomic, assign) ZFAddressNameType         addressNameType;
@property (nonatomic, strong) UITextField               *enterTextField;
@property (nonatomic, strong) UILabel                   *tipsLabel;

@end


@implementation ZFAddressEditNameTableViewCell
#pragma mark - init methods 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse{
    self.enterTextField.text = @"";
    self.tipsLabel.text = @"";
    [super prepareForReuse];
}

- (void)becomeFirstResponder {
    [self.enterTextField becomeFirstResponder];
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

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self baseShowTips:NO overMax:NO content:@""];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    if ([string isEqualToString:@""]) {//删除字符
        
        if (textField.text.length == 32 && self.typeModel.isShowTips == YES) {
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
    } else if (![string isEqualToString:@""]){//增加字符
        
        if (textField.text.length > 31) {
            [self baseShowTips:YES overMax:YES content:textField.text];
            return NO;
            
        } else if (textField.text.length < 32) {
            [self baseShowTips:NO overMax:NO content:[NSString stringWithFormat:@"%@%@", textField.text, string]];
            return YES;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    YWLog(@"----- %@",textField.text);
    
    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    
    NSInteger strLength = [NSStringUtils mixChineseEnglishLength:textField.text];
    if (strLength == 0) {
        self.tipsLabel.text = ZFLocalizedString(self.addressNameType == ZFAddressNameTypeFirstName ? @"ModifyAddress_FirstName_TipLabel" : @"ModifyAddress_LastName_TipLabel",nil);
        [self baseShowTips:YES overMax:NO content:textField.text];

    } else if (strLength == 1) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
        [self baseShowTips:YES overMax:NO content:textField.text];

    } else if (strLength < 32) {
        self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
        self.tipsLabel.hidden = YES;
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
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
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
    NSString *placeStr = @"";
    NSString *nameStr = @"";
    
    if (self.typeModel.editType == ZFAddressEditTypeFirstName) {
        _addressNameType =  ZFAddressNameTypeFirstName;
        placeStr = ZFLocalizedString(@"ModifyAddress_FristName_Placeholder", nil);
        nameStr = ZFToString(self.infoModel.firstname);
    } else {
        _addressNameType = ZFAddressNameTypeLastName;
        placeStr = ZFLocalizedString(@"ModifyAddress_LastName_Placeholder", nil);
        nameStr = ZFToString(self.infoModel.lastname);
    }
    
    self.enterTextField.placeholder = placeStr;
    self.enterTextField.text = nameStr;
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    self.tipsLabel.hidden = YES;
   
    if ([self isShowTips] && self.typeModel.isShowTips) {
        self.tipsLabel.hidden = NO;
        self.lineView.backgroundColor = ZFC0xFE5269();
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
        
    } else {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
}

- (BOOL)isShowTips {
    
    BOOL showTips = NO;
    NSInteger strLength = [NSStringUtils mixChineseEnglishLength:self.enterTextField.text];
    if (strLength == 1) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
        showTips = YES;
    } else if(strLength == 0 && self.typeModel.isShowTips){
        self.tipsLabel.text = ZFLocalizedString(self.addressNameType == ZFAddressNameTypeFirstName ? @"ModifyAddress_FirstName_TipLabel" : @"ModifyAddress_LastName_TipLabel",nil);
        showTips = YES;
    } else if (strLength >= 32 && self.typeModel.isShowTips) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),@"32"];
        showTips = YES;
    } else {
        if (self.addressNameType == ZFAddressNameTypeFirstName && [self.infoModel isContainSpecialMarkName:self.infoModel.firstname]) {
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_LastName_Special_TipLabel",nil);
            showTips = YES;
        } else if (self.addressNameType == ZFAddressNameTypeLastName && [self.infoModel isContainSpecialMarkName:self.infoModel.lastname]) {
            self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_LastName_Special_TipLabel",nil);
            showTips = YES;
        }
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
@end
