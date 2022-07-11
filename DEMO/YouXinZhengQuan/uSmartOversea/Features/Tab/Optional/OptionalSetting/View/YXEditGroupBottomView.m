//
//  YXEditGroupBottomView.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/21.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXEditGroupBottomView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXEditGroupBottomView ()

@property (nonatomic, strong) QMUIButton *addButton;

@end

@implementation YXEditGroupBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [QMUITheme popupLayerColor];
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    
    [contentView addSubview:self.addButton];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(49);
    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentView);
    }];
    
    UIView *topLineView = [[UIView alloc] init];
    topLineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    [contentView addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.left.equalTo(contentView);
        make.height.mas_equalTo(1);
    }];
}

- (QMUIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:[YXLanguageUtility kLangWithKey:@"add_group"] forState:UIControlStateNormal];
        [_addButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_addButton setImage:[UIImage imageNamed:@"edit_add"] forState:UIControlStateNormal];
        [_addButton setImage:[UIImage imageNamed:@"edit_add"] forState:UIControlStateHighlighted];
        _addButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        _addButton.imagePosition = QMUIButtonImagePositionLeft;
    }
    return _addButton;
}

- (void)addButtonAction {
    if (self.onClickAdd) {
        self.onClickAdd();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
