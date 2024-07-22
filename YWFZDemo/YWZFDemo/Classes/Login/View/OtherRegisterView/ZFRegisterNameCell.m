
//
//  ZFRegisterNameCell.m
//  ZZZZZ
//
//  Created by YW on 29/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRegisterNameCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFTextField.h"
#import "DLPickerView.h"
#import "ZFRegisterModel.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFRegisterNameCell ()<ZFInitViewProtocol,UITextFieldDelegate>
@property (nonatomic, strong) ZFTextField   *nameTextField;
@property (nonatomic, strong) UILabel       *genderTipLabel;
@property (nonatomic, strong) UILabel       *genderLabel;
@property (nonatomic, strong) UIImageView   *arrowImageView;
@property (nonatomic, strong) UIView        *bottomLine;
@end

@implementation ZFRegisterNameCell

+ (ZFRegisterNameCell *)cellWith:(UITableView *)tableView index:(NSIndexPath *)index {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:index];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.nameTextField];
    [self.contentView addSubview:self.genderTipLabel];
    [self.contentView addSubview:self.genderLabel];
    [self.genderLabel addSubview:self.arrowImageView];
    [self.contentView addSubview:self.bottomLine];
}

- (void)zfAutoLayoutView {
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(28);
    }];
    
    [self.genderTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTextField.mas_bottom).offset(13);
        make.leading.equalTo(self.nameTextField.mas_leading);
    }];
    
    [self.genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.genderTipLabel.mas_bottom).offset(5);
        make.leading.equalTo(self.genderTipLabel.mas_leading).offset(-2);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(20);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.genderLabel);
        make.trailing.equalTo(self.contentView).offset(-12);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.genderTipLabel.mas_leading);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(0);
    }];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (ZFIsEmptyString(textField.text)) {
//        if (ZFIsEmptyString(textField.text)) {
//            [self.nameTextField resetAnimation];
//        }
//        return;
//    }
//}
#pragma mark - Setter
- (void)setModel:(ZFRegisterModel *)model {
    _model = model;
    self.nameTextField.text = model.nickName;
    if (!ZFIsEmptyString(model.email)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.nameTextField hidenErrorTipLine];
            [self.nameTextField resetMoved:NO];
            [self.nameTextField showPlaceholderAnimation];
        });
    }
}

#pragma mark - Action
- (void)nameTextFieldEditingDidEnd {
    if (self.completeHandler) {
        self.model.nickName = self.nameTextField.text;
        self.completeHandler(self.model);
    }
}

- (void)showGender {
    @weakify(self)
    NSArray *array = @[ZFLocalizedString(@"Profile_Female", nil),
                       ZFLocalizedString(@"Profile_Male", nil),
                       ZFLocalizedString(@"Profile_Privacy", nil)];
    DLPickerView *pickerView = [[DLPickerView alloc] initWithDataSource:array
                                                       withSelectedItem:nil
                                                      withSelectedBlock:^(id selectedItem) {
                                                          @strongify(self);
                                                          self.genderLabel.text = selectedItem;
                                                          if (self.completeHandler) {
                                                              self.model.gender = selectedItem;
                                                              self.completeHandler(self.model);
                                                          }
                                                      }
                                ];
    pickerView.shouldDismissWhenClickShadow = YES;
    [pickerView show];
}

#pragma mark - Getter
- (ZFTextField *)nameTextField {
    if (!_nameTextField) {
        _nameTextField = [[ZFTextField alloc] init];
        _nameTextField.backgroundColor = [UIColor whiteColor];
        _nameTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _nameTextField.returnKeyType = UIReturnKeyNext;
        _nameTextField.placeholder = ZFLocalizedString(@"Profile_NickName_Placeholder",nil);
        _nameTextField.font = [UIFont systemFontOfSize:14.f];
        _nameTextField.placeholderColor = ZFCOLOR(212, 212, 212, 1);
        _nameTextField.clearImage = [UIImage imageNamed:@"clearButton"];
        _nameTextField.errorTip = ZFLocalizedString(@"Login_email_format_error",nil);
        _nameTextField.errorFontSize = 12.f;
        _nameTextField.errorTipColor = [UIColor orangeColor];
         _nameTextField.lineColor = ZFCOLOR(212, 212, 212, 1);
        _nameTextField.placeholderSelectStateColor = ZFCOLOR(153, 153, 153, 1.0);
        _nameTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [_nameTextField addTarget:self action:@selector(nameTextFieldEditingDidEnd) forControlEvents:(UIControlEventEditingDidEnd)];
        _nameTextField.delegate = self;
    }
    return _nameTextField;
}

- (UILabel *)genderTipLabel {
    if (!_genderTipLabel) {
        _genderTipLabel = [[UILabel alloc] init];
        _genderTipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _genderTipLabel.font = ZFFontSystemSize(14);
        _genderTipLabel.text = ZFLocalizedString(@"gender",nil);
        _genderTipLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _genderTipLabel;
}

- (UILabel *)genderLabel {
    if (!_genderLabel) {
        _genderLabel = [[UILabel alloc] init];
        _genderLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _genderLabel.font = ZFFontSystemSize(14);
        _genderLabel.text = ZFLocalizedString(@"Profile_Female",nil);
        _genderLabel.backgroundColor = ZFCOLOR_WHITE;
        @weakify(self)
        [_genderLabel addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self showGender];
        }];
    }
    return _genderLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"register_arrow"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _bottomLine;
}


@end
