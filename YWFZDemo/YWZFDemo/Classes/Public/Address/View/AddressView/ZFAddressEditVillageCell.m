//
//  ZFAddressEditVillageCell.m
//  ZZZZZ
//
//  Created by YW on 2019/1/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressEditVillageCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"


@interface ZFAddressEditVillageCell () <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UITextField       *villageTextField;
@property (nonatomic, strong) UIImageView       *arrowView;
@property (nonatomic, strong) UILabel           *tipsLabel;
@end

@implementation ZFAddressEditVillageCell

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

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self baseEditContent:@""];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@""]) {//删除字符
        [self baseEditContent:[textField.text substringToIndex:textField.text.length - 1]];
        if (textField.text.length == 30 && self.typeModel.isShowTips == YES) {
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
    } else if (![string isEqualToString:@""]){ //增加字符
        [self baseEditContent:[NSString stringWithFormat:@"%@%@", textField.text, string]];
        if (textField.text.length > 29) {
            [self baseShowTips:YES overMax:YES content:textField.text];
            return NO;
            
        } else if (textField.text.length < 30) {
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
    
    if(textField.text.length == 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Village_TipLabel",nil);
        [self baseShowTips:YES overMax:NO content:textField.text];
        
    }
//    else if (textField.text.length < 3) {
//        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"3"];
//        [self baseShowTips:YES overMax:NO content:textField.text];
//
//    } else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^\\d{3,}$"] evaluateWithObject:self.villageTextField.text]){
//        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_City_AllNum_TipLabel",nil);
//        [self baseShowTips:YES overMax:NO content:textField.text];
//
//    }
    else if (textField.text.length < 30) {
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
    [self.contentView addSubview:self.villageTextField];
    [self.contentView addSubview:self.arrowView];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {
    [self.villageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.trailing.mas_equalTo(self.arrowView.mas_leading).offset(-16);
        make.height.mas_equalTo(30);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.villageTextField);
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
}

#pragma mark - setter

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel hasUpperLevel:(BOOL)hasUpper {
    self.infoModel = infoModel;
    self.typeModel = typeModel;
    
    self.villageTextField.text = ZFToString(self.infoModel.barangay);
    
    if (hasUpper) {
        self.villageTextField.userInteractionEnabled = NO;
        self.arrowView.hidden = NO;
        
    } else if (infoModel.showFourLevel) {//一直显示输入
        self.villageTextField.userInteractionEnabled = YES;
        self.arrowView.hidden = YES;
        
    } else {
        self.villageTextField.userInteractionEnabled = YES;
        self.arrowView.hidden = YES;
    }
    
    self.tipsLabel.hidden = YES;
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);

    //有城市选择，箭头处理
    [self.villageTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowView.mas_leading).mas_offset(hasUpper ? -16 : 16);
    }];
    
    if ([self isShowTips] && self.typeModel.isShowTips) {
        self.lineView.backgroundColor = ZFC0xFE5269();
        self.tipsLabel.hidden = NO;
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-22);
        }];
        
    } else {
        [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
}

- (void)updateContentText:(NSString *)text {
    if (!ZFIsEmptyString(text)) {
        self.villageTextField.text = text;
    }
}

- (BOOL)isShowTips {
    BOOL showTips = NO;
    if([self.villageTextField.text length] == 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_Village_TipLabel",nil);
        showTips = YES;
    }
//    else if (self.villageTextField.text.length < 3) {
//        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"3"];
//        showTips = YES;
//    } else if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^\\d{3,}$"] evaluateWithObject:self.villageTextField.text]){
//        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_City_AllNum_TipLabel",nil);
//        showTips = YES;
//    }
    else if (self.villageTextField.text.length >= 30) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),@"30"];
        showTips = YES;
    }
    return showTips;
}


#pragma mark - getter

- (UITextField *)villageTextField {
    if (!_villageTextField) {
        _villageTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _villageTextField.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _villageTextField.font = [UIFont systemFontOfSize:14];
        _villageTextField.delegate = self;
        _villageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _villageTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _villageTextField.placeholder = ZFLocalizedString(@"ModifyAddress_Village_Placeholder", nil);
    }
    return _villageTextField;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowView.image = [UIImage imageNamed:@"account_arrow_right"];
        [_arrowView convertUIWithARLanguage];
    }
    return _arrowView;
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
