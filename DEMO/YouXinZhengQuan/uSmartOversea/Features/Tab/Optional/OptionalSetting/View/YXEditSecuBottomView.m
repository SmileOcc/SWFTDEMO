//
//  YXEditStockBottomView.m
//  uSmartOversea
//
//  Created by ellison on 2018/10/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXEditSecuBottomView.h"
#import "YXSecuGroupManager.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXEditSecuBottomView ()

@property (nonatomic, strong) QMUIButton *changeButton;
@property (nonatomic, strong) QMUIButton *deleteButton;

@end

@implementation YXEditSecuBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [QMUITheme foregroundColor];
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
    [contentView addSubview:self.deleteButton];

    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(49);
    }];
    
    [self.selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.left.equalTo(contentView).offset(15);
    }];
    
    [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.centerX.equalTo(contentView);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(contentView);
        make.right.equalTo(contentView).offset(-22);
    }];
    
//    NSArray *buttons = @[self.selectAllButton, self.changeButton, self.deleteButton];
//    [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:1 leadSpacing:12 tailSpacing:12];
//    [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(contentView);
//        make.height.equalTo(contentView);
//    }];
    
    UIView *topLineView = [[UIView alloc] init];
    topLineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    [contentView addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.left.equalTo(contentView);
        make.height.mas_equalTo(1);
    }];
}

//- (void)setcou:(NSArray *)checkedStocks {
//    _checkedStocks = checkedStocks;
//
//    NSInteger count = [_checkedStocks count];
//}
- (void)setCheckedCount:(NSUInteger)checkedCount {
    _checkedCount = checkedCount;
    
//    if (checkedCount == 1) {
//        self.changeButton.enabled = YES;
//    } else {
//        self.changeButton.enabled = NO;
//    }
    
    if (checkedCount > 0) {
        self.deleteButton.enabled = YES;
        self.changeButton.enabled = YES;
        [self.deleteButton setTitle:[NSString stringWithFormat:@"%@ (%zd)", [YXLanguageUtility kLangWithKey:@"mine_delete"], checkedCount] forState:UIControlStateNormal];
        [self.changeButton setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"add_to_group_unit"], (int)checkedCount] forState:UIControlStateNormal];
    } else {
        [self.deleteButton setTitle:[YXLanguageUtility kLangWithKey:@"mine_delete"] forState:UIControlStateNormal];
        [self.changeButton setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"add_to_group_unit"], 0] forState:UIControlStateNormal];
        self.changeButton.enabled = NO;
        self.deleteButton.enabled = NO;
    }
}

#pragma mark - actions
- (void)selectedAallAction {
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

- (void)deleteButtonAction {
 //   [[YXSecuGroupManager shareInstance] removeArray:self.checkedStocks secuGroup:self];
    if (self.onClickDelete) {
        self.onClickDelete();
    }
}

#pragma mark - getter

- (QMUIButton *)selectAllButton {
    if (_selectAllButton == nil) {
        _selectAllButton = [QMUIButton buttonWithType:UIButtonTypeCustom];//[UIButton buttonWithType:UIButtonTypeCustom title:@"全选" font:[UIFont systemFontOfSize:14] titleColor:[QMUITheme textColorLevel1] target:self action:@selector(selectedAallAction)];
        [_selectAllButton setTitle:[YXLanguageUtility kLangWithKey:@"addstock_photo_select_all"] forState:UIControlStateNormal];
        [_selectAllButton setImage:[UIImage imageNamed:@"edit_uncheck2"] forState:UIControlStateNormal];
        [_selectAllButton setImage:[UIImage imageNamed:@"edit_checked"] forState:UIControlStateSelected];
        [_selectAllButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateSelected];
        [_selectAllButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        _selectAllButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_selectAllButton addTarget:self action:@selector(selectedAallAction) forControlEvents:UIControlEventTouchUpInside];
//        _selectAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _selectAllButton.imagePosition = QMUIButtonImagePositionLeft;
        _selectAllButton.spacingBetweenImageAndTitle = 3;
    }
    return _selectAllButton;
}

- (QMUIButton *)changeButton {
    if (_changeButton == nil) {
        _changeButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"add_to_group_unit"], 0] forState:UIControlStateNormal];
        [_changeButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        [_changeButton addTarget:self action:@selector(changeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _changeButton.titleLabel.font = [UIFont systemFontOfSize: 14];
        [_changeButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateDisabled];
        [_changeButton setImage:[UIImage imageNamed:@"add_oversea"] forState:UIControlStateNormal];
        _changeButton.imagePosition = QMUIButtonImagePositionLeft;
        _changeButton.spacingBetweenImageAndTitle = 3;
    }
    return _changeButton;
}

- (QMUIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:[YXLanguageUtility kLangWithKey:@"mine_delete"] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize: 14];
        [_deleteButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateDisabled];
        [_deleteButton setImage:[UIImage imageNamed:@"delete_oversea"] forState:UIControlStateNormal];
        _deleteButton.imagePosition = QMUIButtonImagePositionLeft;
        _deleteButton.spacingBetweenImageAndTitle = 3;
    }
    return _deleteButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
