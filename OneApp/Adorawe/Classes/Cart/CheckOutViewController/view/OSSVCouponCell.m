//
//  OSSVCouponCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCouponCell.h"

@interface OSSVCouponCell ()
@property (nonatomic, strong) UITextField *couponInputTF;
@property (nonatomic, strong) UIButton *applyButton;
@end

@implementation OSSVCouponCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.couponInputTF];
        [contentView addSubview:self.applyButton];
        
        [self.couponInputTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(contentView);
            make.bottom.mas_equalTo(contentView);
            make.trailing.mas_equalTo(self.applyButton.mas_leading).mas_offset(-CheckOutCellLeftPadding);
            make.leading.mas_equalTo(contentView).mas_offset(CheckOutCellLeftPadding);
            make.height.mas_offset(55).priorityHigh();
        }];
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(contentView.mas_trailing).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.mas_equalTo(contentView);
            make.width.mas_offset(80);
            make.height.mas_offset(32);
        }];
        
        [self.couponInputTF addTarget:self action:@selector(didInputText:) forControlEvents:UIControlEventEditingChanged];
        [self.couponInputTF addTarget:self action:@selector(beginInputText:) forControlEvents:UIControlEventEditingDidBegin];
        
        [self addBottomLine:CellSeparatorStyle_LeftRightInset];
    }
    return self;
}

#pragma mark - target

-(void)buttonAction
{
    OSSVCouponCellModel *model = _model;
    if (!model.couponModel.code.length) {
        STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:nil message:STLLocalizedString_(@"validCouponCode",nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok",nil) : STLLocalizedString_(@"ok",nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:^{}];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(STL_CouponCellDidClickApply:)]) {
            [self.delegate STL_CouponCellDidClickApply:_model];
        }
    }
}

-(void)didInputText:(UITextField *)textField{
    OSSVCouponCellModel *model = _model;
    model.couponModel.code = textField.text;
    [self handleApplyUserEnabled:textField.text];
}

-(void)beginInputText:(UITextField *)textField{

}

-(void)handleApplyUserEnabled:(NSString *)text{
    if (text.length) {
        self.applyButton.backgroundColor = OSSVThemesColors.col_FFCC33;
        [self.applyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.applyButton.enabled = YES;
    }else{
        self.applyButton.backgroundColor = OSSVThemesColors.col_999999;
        [self.applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.applyButton.enabled = NO;
    }
}

#pragma mark - setter and getter

- (void)setModel:(OSSVCouponCellModel *)model{
    _model = model;
    
    self.couponInputTF.userInteractionEnabled = model.inputUserInteractionEnabled;
    self.couponInputTF.text = model.codeText;
    [self handleApplyUserEnabled:model.codeText];
    
    if (model.status == ApplyButtonStatusApply) {
        [self.applyButton setTitle:STLLocalizedString_(@"category_filter_apply", nil) forState:UIControlStateNormal];
    }else if(model.status == ApplyButtonStatusClear){
        [self.applyButton setTitle:STLLocalizedString_(@"Clear", nil) forState:UIControlStateNormal];
    }
}

-(UITextField *)couponInputTF
{
    if (!_couponInputTF) {
        _couponInputTF = ({
            UITextField *textField = [[UITextField alloc] init];
            textField.placeholder = STLLocalizedString_(@"inputdCouponCode", nil);
            textField.font = [UIFont systemFontOfSize:14];
            textField.borderStyle = UITextBorderStyleNone;
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
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:OSSVThemesColors.col_0B0B0B forState:UIControlStateNormal];
            button.backgroundColor = OSSVThemesColors.col_FFCC33;
            [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _applyButton;
}

@end

#pragma mark - coupon save cell

@interface STLCouponSaveCell()

@property (nonatomic, strong) UILabel *saveLabel;

@end

@implementation STLCouponSaveCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        [contentView addSubview:self.saveLabel];
        
        [self.saveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(contentView).mas_offset(CheckOutCellLeftPadding);
            make.trailing.mas_equalTo(contentView);
            make.top.bottom.mas_equalTo(contentView);
            make.height.mas_offset(32);
        }];
    }
    return self;
}

#pragma mark - setter and getter

- (void)setModel:(STLCouponSaveCellModel *)model
{
    _model = model;

    self.saveLabel.attributedText = model.attriSaveValue;
}

- (UILabel *)saveLabel
{
    if (!_saveLabel) {
        _saveLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"save", nil);
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _saveLabel;
}


@end
