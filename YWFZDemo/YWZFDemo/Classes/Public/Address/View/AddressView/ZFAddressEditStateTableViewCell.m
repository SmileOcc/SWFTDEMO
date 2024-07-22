//
//  ZFAddressEditStateTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditStateTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFAddressEditStateTableViewCell () <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UITextField       *stateTextField;
@property (nonatomic, strong) UIImageView       *arrowView;
@property (nonatomic, strong) UILabel           *tipsLabel;
@end

@implementation ZFAddressEditStateTableViewCell
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

    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    
    if(textField.text.length == 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_State_TipLabel",nil);
        [self baseShowTips:YES overMax:NO content:textField.text];
    } else if (textField.text.length < 2) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
        [self baseShowTips:YES overMax:NO content:textField.text];

    } else if (textField.text.length < 32) {
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
    [self.contentView addSubview:self.stateTextField];
    [self.contentView addSubview:self.arrowView];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {
    [self.stateTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.trailing.mas_equalTo(self.arrowView.mas_leading).offset(-16);
        make.height.mas_equalTo(30);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.stateTextField);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.stateTextField);
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
    
    self.stateTextField.userInteractionEnabled = !hasUpper;
    self.arrowView.hidden = !hasUpper;
    self.stateTextField.text = ZFToString(self.infoModel.province);
    self.lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    self.tipsLabel.hidden = YES;
    
    //有城市选择，箭头处理
    [self.stateTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowView.mas_leading).mas_offset(hasUpper ? -16 : 16);
    }];
    
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

- (void)updateContentText:(NSString *)text {
    if (!ZFIsEmptyString(text)) {
        self.stateTextField.text = text;
    }
}

- (BOOL)isShowTips {
    BOOL showTips = NO;
    
    if (self.infoModel.isStateTip) {
        self.tipsLabel.text = ZFToString(self.infoModel.stateTipMsg);
        return YES;
    }
    
    if([self.stateTextField.text length] == 0){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddress_State_TipLabel",nil);
        showTips = YES;
    } else if (self.stateTextField.text.length < 2) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Minimum_TipLabel",nil),@"2"];
        showTips = YES;
    } else if (self.stateTextField.text.length >= 32) {
        self.tipsLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_Maxmum_TipLabel",nil),@"32"];
        showTips = YES;
    }
    return showTips;
}

#pragma mark - getter

- (UITextField *)stateTextField {
    if (!_stateTextField) {
        _stateTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _stateTextField.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _stateTextField.font = [UIFont systemFontOfSize:14];
        _stateTextField.delegate = self;
        _stateTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _stateTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _stateTextField.placeholder = ZFLocalizedString(@"ModifyAddress_State_Placeholder", nil);
    }
    return _stateTextField;
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
