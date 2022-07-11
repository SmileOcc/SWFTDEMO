//
//  CellTextfield.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "CellTextfield.h"
#import <JVFloatLabeledTextField.h>
#import "CountryModel.h"
#import "STLPhoneNumTextField.h"

@interface CellTextfield ()

///国旗
@property (weak,nonatomic) YYAnimatedImageView *flagImg;



@property (weak,nonatomic) YYAnimatedImageView *vertileLine;
@property (weak,nonatomic) YYAnimatedImageView *arrowDown;
@end

@implementation CellTextfield

-(void)setUpViews{
    self.axis = UILayoutConstraintAxisVertical;
    
    UIStackView *inputContainer = [[UIStackView alloc] init];
    inputContainer.axis = UILayoutConstraintAxisHorizontal;
    [self addSubview:inputContainer];
    [inputContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
    }];
    
    YYAnimatedImageView *flagImg = [YYAnimatedImageView new];
    [flagImg yy_setImageWithURL:nil placeholder:[UIImage imageNamed:@"region_place_polder"]];
    _flagImg = flagImg;
    [inputContainer addSubview:flagImg];
    [flagImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(inputContainer.mas_left);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(inputContainer.mas_bottom).offset(-2);
    }];
    
    UITapGestureRecognizer *flagTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountrytapped)];
    [flagImg addGestureRecognizer:flagTap];
    flagImg.userInteractionEnabled = YES;
    
    UILabel *regionLbl = [UILabel new];
    _regionCodeLbl = regionLbl;
    regionLbl.text = @"";
    regionLbl.textColor = OSSVThemesColors.col_0D0D0D;
    [regionLbl setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [regionLbl setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    regionLbl.font = [UIFont boldSystemFontOfSize:15];
    [inputContainer addSubview:regionLbl];
    [regionLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(flagImg.mas_right).offset(10);
        make.centerY.mas_equalTo(flagImg.mas_centerY);
    }];
    UITapGestureRecognizer *flagTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountrytapped)];
    [regionLbl addGestureRecognizer:flagTap1];
    regionLbl.userInteractionEnabled = YES;
    
    YYAnimatedImageView *arrowDown = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"bind_arrow_down"]];
    _arrowDown = arrowDown;
    [inputContainer addSubview:arrowDown];
    [arrowDown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(regionLbl.mas_right).offset(4);
        make.width.height.mas_equalTo(24);
        make.centerY.mas_equalTo(flagImg.mas_centerY);
    }];
    UITapGestureRecognizer *flagTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCountrytapped)];
    [arrowDown addGestureRecognizer:flagTap2];
    arrowDown.userInteractionEnabled = YES;
    
    YYAnimatedImageView *line = [[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"bind_verticle_line"]];
    _vertileLine = line;
    [inputContainer addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(18);
        make.left.mas_equalTo(arrowDown.mas_right).offset(4);
        make.centerY.mas_equalTo(flagImg.mas_centerY);
    }];
    
    UITextField *inputField = [STLPhoneNumTextField new];

    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputField.placeholder = self.placeholder;
    inputField.font = [UIFont boldSystemFontOfSize:15];
    self.inputField = inputField;
    inputField.delegate = self;
    [inputContainer addSubview:inputField];
    self.keyboardType = UIKeyboardTypePhonePad;
    [inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(line.mas_right).offset(4);
        make.top.mas_equalTo(inputContainer.mas_top);
        make.bottom.mas_equalTo(inputContainer.mas_bottom);
        make.right.mas_equalTo(inputContainer.mas_right);
    }];
    
    
    UIView *devider = [UIView new];
    [self addSubview:devider];
    self.devider = devider;
    [devider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputContainer.mas_bottom).offset(10);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *detailLbl = [UILabel new];
    detailLbl.font = [UIFont systemFontOfSize:11];
    self.detailLbl = detailLbl;
    [self addSubview:detailLbl];
    [detailLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(devider.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
//    self.inputField.textAlignment = ![OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
}

-(void)selectCountrytapped{
    if ([self.delegate respondsToSelector:@selector(didtapedSelectCountryButton:)]) {
        id delegate = self.delegate;
        [delegate didtapedSelectCountryButton:nil];
    }
}

-(void)setCountryModel:(STLBindCountryModel *)countryModel{
    _countryModel = countryModel;
    NSURL *imgURL = [NSURL URLWithString:countryModel.picture];
    [_flagImg yy_setImageWithURL:imgURL placeholder:[UIImage imageNamed:@"region_place_polder"]];
    _regionCodeLbl.text = countryModel.code.length > 0 ? countryModel.code : @"";
}

-(void)setCanSelectCountry:(BOOL)canSelectCountry{
    _canSelectCountry = canSelectCountry;
    [_arrowDown mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(canSelectCountry ? 24 : 0);
    }];
    _arrowDown.hidden = !canSelectCountry;
    _regionCodeLbl.textColor = canSelectCountry ? OSSVThemesColors.col_0D0D0D : OSSVThemesColors.col_6C6C6C;
}

@end
