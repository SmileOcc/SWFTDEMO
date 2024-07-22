
//
//  ZFAddressEditNationalIDTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressEditNationalIDTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFAddressEditNationalIDTableViewCell () <ZFInitViewProtocol, UITextFieldDelegate>

/**只是个位置,为了确定【?】按钮的位置*/
@property (nonatomic, strong) UIImageView           *arrowView;
@property (nonatomic, strong) UITextField           *enterTextField;
@property (nonatomic, strong) UIButton              *tipsInfoButton;
@property (nonatomic, strong) UILabel               *tipsLabel;


@end

@implementation ZFAddressEditNationalIDTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)tipsInfoButtonAction:(UIButton *)sender {
    [self baseSelectEvent:YES];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)Textfield {
    [Textfield resignFirstResponder];//关闭键盘
    [self baseIsEditEvent:NO];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.tipsInfoButton.hidden = textField.text.length > 0;
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self baseIsEditEvent:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.tipsInfoButton.hidden = (textField.text.length > 0) || (string.length > 0);
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    //去掉收尾空字符
    textField.text = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    if ([textField.text length] != 10) {
        [self baseShowTips:YES overMax:NO content:textField.text];

    } else {
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
    [self.contentView addSubview:self.arrowView];
    [self.contentView addSubview:self.enterTextField];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.tipsInfoButton];
    [self.contentView addSubview:self.tipsLabel];
}

- (void)zfAutoLayoutView {

    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
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
    
    [self.tipsInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.enterTextField);
        make.centerX.mas_equalTo(self.arrowView.mas_centerX).offset(-1);
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
    
    self.enterTextField.text = ZFToString(self.infoModel.id_card);
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
    if([self.enterTextField.text length] != 10){
        self.tipsLabel.text = ZFLocalizedString(@"ModifyAddressViewController_cardTipLabe2", nil);
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
        _enterTextField.keyboardType = UIKeyboardTypeNumberPad;
        _enterTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _enterTextField.placeholder =  ZFLocalizedString(@"ModifyAddressViewController_cardPlaceLabel", nil);
    }
    return _enterTextField;
}


- (UIButton *)tipsInfoButton {
    if (!_tipsInfoButton) {
        _tipsInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tipsInfoButton setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
        [_tipsInfoButton addTarget:self action:@selector(tipsInfoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _tipsInfoButton.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
    }
    return _tipsInfoButton;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowView.image = [UIImage imageNamed:@"account_arrow_right"];
        _arrowView.hidden = YES;
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
