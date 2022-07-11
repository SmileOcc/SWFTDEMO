//
//  YXStockPickerAddSelfBottomView.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockPickerAddSelfBottomView.h"
#import <Masonry/Masonry.h>
#import "UIButton+utility.h"
#import "UILabel+create.h"
#import "uSmartOversea-Swift.h"

@interface YXStockPickerAddSelfBottomView ()

@property (nonatomic, strong) UIButton *changeButton;

@end

@implementation YXStockPickerAddSelfBottomView

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


    [contentView addSubview:self.selectAllButton];
    [contentView addSubview:self.changeButton];

    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(49);
    }];

    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.right.equalTo(contentView);
        make.width.mas_equalTo(150);
    }];

    [self.selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.left.equalTo(contentView);
        make.right.equalTo(self.changeButton.mas_left);
    }];

    UIView *topLineView = [UIView new];
    topLineView.backgroundColor = QMUITheme.separatorLineColor;
    [contentView addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.left.equalTo(contentView);
        make.height.mas_equalTo(1);
    }];
}

- (void)setCheckedCount:(NSUInteger)checkedCount {
    _checkedCount = checkedCount;

    if (checkedCount > 0) {

        self.changeButton.enabled = YES;
        [self.changeButton setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"add_to_group_unit"], checkedCount] forState:UIControlStateNormal];
    } else {
        [self.changeButton setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"add_to_group_unit"], 0] forState:UIControlStateNormal];
        self.changeButton.enabled = NO;
    }
}

#pragma mark - actions
- (void)selectedAllAction {

    self.selectAllButton.selected = !self.selectAllButton.isSelected;
    if (self.onClickSelectedAll) {
        self.onClickSelectedAll(self.selectAllButton.isSelected);
    }
}

- (void)changeButtonAction {
    if (self.onClickChange) {
        self.onClickChange();
    }
}

#pragma mark - getter

- (UIButton *)selectAllButton {
    if (_selectAllButton == nil) {
        _selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"optionalStockManager_selectAll"] font:[UIFont systemFontOfSize:14] titleColor:[QMUITheme themeTextColor] target:self action:@selector(selectedAllAction)];
        [_selectAllButton setTitle:[YXLanguageUtility kLangWithKey:@"cancel_all"] forState:UIControlStateSelected];
        _selectAllButton.selected = NO;
        _selectAllButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _selectAllButton.titleLabel.minimumScaleFactor = 0.3;
        [_selectAllButton setTitleColor:[QMUITheme themeTextColor] forState:UIControlStateSelected];
        [_selectAllButton setTitleColor:[QMUITheme themeTextColor] forState:UIControlStateNormal];
    }
    return _selectAllButton;
}

- (UIButton *)changeButton {
    if (_changeButton == nil) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom title:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"add_to_group_unit"], 0] font:[UIFont systemFontOfSize:16] titleColor:[UIColor whiteColor] target:self action:@selector(changeButtonAction)];
        [_changeButton setDisabledTheme:0];
        _changeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _changeButton.titleLabel.minimumScaleFactor = 0.3;
        _changeButton.enabled = NO;
    }
    return _changeButton;
}
@end
