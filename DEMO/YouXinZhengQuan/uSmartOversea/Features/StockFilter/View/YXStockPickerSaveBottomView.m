//
//  YXStockPickerSaveBottomView.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockPickerSaveBottomView.h"
#import <Masonry/Masonry.h>
#import "UIButton+utility.h"
#import "uSmartOversea-Swift.h"

@interface YXStockPickerSaveBottomView ()



@end

@implementation YXStockPickerSaveBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = QMUITheme.foregroundColor;
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];


    [contentView addSubview:self.selectButton];
    [contentView addSubview:self.saveButton];

    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(49);
    }];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.right.equalTo(contentView);
        make.width.mas_equalTo(150);
    }];

    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.left.equalTo(contentView);
        make.right.equalTo(self.saveButton.mas_left);
    }];

    UIView *topLineView = [[UIView alloc] init];
    topLineView.backgroundColor = QMUITheme.separatorLineColor;
    [contentView addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.left.equalTo(contentView);
        make.height.mas_equalTo(1);
    }];
}

- (void)hiddenSaveButton {
    self.saveButton.hidden = YES;
    [self.saveButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
    }];
}

#pragma mark - actions
- (void)selectedAction {
    if (self.onClickSelected) {
        self.onClickSelected();
    }
}

- (void)saveButtonAction {
    if (self.onClickSave) {
        self.onClickSave();
    }
}

#pragma mark - getter

- (UIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"add_stock_into_watchlist"] font:[UIFont systemFontOfSize:14] titleColor:[QMUITheme themeTextColor] target:self action:@selector(selectedAction)];
        [_selectButton setTitleColor:[QMUITheme themeTextColor] forState:UIControlStateSelected];
        [_selectButton setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateDisabled];
        [_selectButton setTitleColor:[QMUITheme themeTextColor] forState:UIControlStateNormal];
        [_selectButton setButtonImagePostion:YXButtonSubViewPositonLeft interval:12];
        _selectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _selectButton.titleLabel.minimumScaleFactor = 0.3;
        _selectButton.enabled = NO;
    }
    return _selectButton;
}

- (UIButton *)saveButton {
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"user_save"] font:[UIFont systemFontOfSize:16] titleColor:[UIColor whiteColor] target:self action:@selector(saveButtonAction)];
        _saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _saveButton.titleLabel.minimumScaleFactor = 0.3;
        [_saveButton setDisabledTheme:0];
    }
    return _saveButton;
}

@end
