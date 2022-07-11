//
//  YXOptionalMenuView.m
//  uSmartOversea
//
//  Created by ellison on 2018/10/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXOptionalMenuView.h"
#import <Masonry/Masonry.h>
#import <UIImage+YYAdd.h>
#import "uSmartOversea-Swift.h"

#define kYXMenuDefaultInnerMargin 15
#define kYXMenuDefaultMargin 15
#define kYXMenuDefaultArrowLeft 29

@interface YXOptionalMenuView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UIButton *stickButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, assign) CGFloat menuWidth;


@end

@implementation YXOptionalMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {
    [self addSubview:self.backgroundView];
    [self addSubview:self.backgroundImageView];
//    [self addSubview:self.arrowImageView];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
}

- (void)setTargetPoint:(CGPoint)point rect:(CGRect)targetRect {
    
//    CGFloat menuLeft = point.x - kYXMenuDefaultArrowLeft;
//
//    if (menuLeft < kYXMenuDefaultMargin) {
//        menuLeft = kYXMenuDefaultMargin;
//    }
//    CGFloat arrowLeft = point.x - 5;
//    if (arrowLeft > targetRect.size.width - kYXMenuDefaultMargin - 16) {
//        arrowLeft = targetRect.size.width - kYXMenuDefaultMargin - 16;
//    } else if (arrowLeft < kYXMenuDefaultMargin + 2) {
//        arrowLeft = kYXMenuDefaultMargin + 2;
//    }
    
//    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(arrowLeft);
//        make.top.equalTo(self.backgroundImageView.mas_bottom).offset(-1);
//    }];
    
    
    [self.backgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top).offset(targetRect.origin.y + 8);
//        make.left.equalTo(self).offset(menuLeft).priorityLow();
        make.centerX.equalTo(self);
    }];
}
- (void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = keyWindow.bounds;
    [keyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)setItemType:(YXMenuItemType)itemType {
    if (itemType == 0) { return; }

    MASViewAttribute* itemRight = self.backgroundImageView.mas_left;
    MASViewAttribute* left = self.backgroundImageView.mas_left;

    if ((itemType & YXMenuItemTypeStick) == YXMenuItemTypeStick) {
        [self.backgroundImageView addSubview:self.stickButton];
        
        [self.stickButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(left).offset(kYXMenuDefaultInnerMargin);
            make.centerY.equalTo(self.backgroundImageView);
        }];
        itemRight = self.stickButton.mas_right;
        left = [self lineViewForMenuItem:itemRight].mas_right;
    }
    
    if ((itemType & YXMenuItemTypeDelete) == YXMenuItemTypeDelete) {
        [self.backgroundImageView addSubview:self.deleteButton];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(left).offset(kYXMenuDefaultInnerMargin);
            make.centerY.equalTo(self.backgroundImageView);
        }];
        itemRight = self.deleteButton.mas_right;
        left = [self lineViewForMenuItem:itemRight].mas_right;
    }
    
    if ((itemType & YXMenuItemTypeManage) == YXMenuItemTypeManage) {
        [self.backgroundImageView addSubview: self.changeButton];
        
        [self.changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(left).offset(kYXMenuDefaultInnerMargin);
            make.centerY.equalTo(self.backgroundImageView);
        }];
        itemRight = self.changeButton.mas_right;
        left = [self lineViewForMenuItem:itemRight].mas_right;
    }
    
    if ((itemType & YXMenuItemTypeEdit) == YXMenuItemTypeEdit) {
        [self.backgroundImageView addSubview: self.editButton];
        
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(left).offset(kYXMenuDefaultInnerMargin);
            make.centerY.equalTo(self.backgroundImageView);
        }];
        itemRight = self.editButton.mas_right;
    }
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self).offset(kYXMenuDefaultMargin).priorityLow();
        make.height.mas_equalTo(36);
        make.right.equalTo(itemRight).offset(kYXMenuDefaultInnerMargin);
        make.right.lessThanOrEqualTo(self).offset(-kYXMenuDefaultMargin);
    }];
}

- (UIView *)lineViewForMenuItem:(MASViewAttribute* )right {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor themeColorWithNormalHex:@"#DDDDDD" andDarkColor:@"#101014"];
    
    [self.backgroundImageView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(right).offset(kYXMenuDefaultInnerMargin);
        make.width.mas_equalTo(1);
        make.centerY.equalTo(self.backgroundImageView);
        make.height.mas_equalTo(19);
    }];
    return line;
}

#pragma mark - actions

- (void)stickButtonAction {
    [self dismiss];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(menuClickStick:with:)]) {
        [_delegate menuClickStick:_selectedSecu with:_name];
    }
}

- (void)deleteButtonAction {
    [self dismiss];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(menuClickDelete:)]) {
        [_delegate menuClickDelete:_selectedSecu];
    }
}

- (void)changeButtonAction {
    [self dismiss];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(menuClickManage:with:)]) {
        [_delegate menuClickManage:_selectedSecu with:_name];
    }
}

- (void)editButtonAction {
    [self dismiss];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(menuClickEdit:)]) {
        [_delegate menuClickEdit:_selectedSecu];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.backgroundImageView.image = [[[UIImage imageWithColor:QMUITheme.foregroundColor size:CGSizeMake(40, 40)] imageByRoundCornerRadius:6] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

#pragma mark - getter
- (UIView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] init];
//        _backgroundView.backgroundColor = [QMUITheme commonTextColorWithAlpha:0.3];
        //[_backgroundView ]
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_backgroundView addGestureRecognizer:ges];
    }
    return _backgroundView;
}

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [[[UIImage imageWithColor:QMUITheme.popupLayerColor size:CGSizeMake(40, 40)] imageByRoundCornerRadius:6] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        _backgroundImageView.userInteractionEnabled = YES;
        if (![YXThemeTool isDarkMode]) {
            _backgroundImageView.layer.shadowColor = [QMUITheme.textColorLevel3 colorWithAlphaComponent:0.25].CGColor;
            _backgroundImageView.layer.shadowOpacity = 1;
            _backgroundImageView.layer.shadowOffset = CGSizeMake(0,1);
            _backgroundImageView.layer.shadowRadius = 4;
        }
    }
    return _backgroundImageView;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_arrow"]];
        [_arrowImageView sizeToFit];
    }
    return _arrowImageView;
}

- (UIButton *)stickButton {
    if (_stickButton == nil) {
        _stickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stickButton setTitle:[YXLanguageUtility kLangWithKey:@"common_top"] forState:UIControlStateNormal];
        _stickButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_stickButton addTarget:self action:@selector(stickButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_stickButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
    }
    return _stickButton;
}

- (UIButton *)deleteButton {
    if (_deleteButton == nil) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:[YXLanguageUtility kLangWithKey:@"common_delete"] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

- (UIButton *)changeButton {
    if (_changeButton == nil) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setTitle:[YXLanguageUtility kLangWithKey:@"modify_group"] forState:UIControlStateNormal];
        _changeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_changeButton addTarget:self action:@selector(changeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_changeButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
    }
    return _changeButton;
}

- (UIButton *)editButton {
    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setTitle:[YXLanguageUtility kLangWithKey:@"common_edit_groups"] forState:UIControlStateNormal];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_editButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
    }
    return _editButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
