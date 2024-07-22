//
//  CategoryRefineToolBar.m
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryRefineToolBar.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "UIButton+ZFButtonCategorySet.h"

@interface CategoryRefineToolBar ()
@property (nonatomic, strong) UIButton      *clearButton;
@property (nonatomic, strong) UIButton      *applyButton;
//@property (nonatomic, strong) UIView        *topLineView;

@end

@implementation CategoryRefineToolBar
#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = ZFC0xDDDDDD().CGColor;
        self.layer.borderWidth = 0.5;
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundColor = ZFC0xFFFFFF();
    [self addSubview:self.clearButton];
    [self addSubview:self.applyButton];
//    [self addSubview:self.topLineView];
}

- (void)autoLayoutSubViews {
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.mas_equalTo(self);
        make.width.mas_equalTo((KScreenWidth - 75) / 2);
    }];
    
    [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.leading.mas_equalTo(self.clearButton.mas_trailing);
    }];
    
//    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.top.trailing.mas_equalTo(self);
//        make.height.mas_equalTo(1.0);
//    }];
}

#pragma mark - Target Action
- (void)clearButtonAction:(UIButton *)sender {
    if (self.clearButtonActionCompletionHandle) {
        self.clearButtonActionCompletionHandle();
    }
}

- (void)applyButtonAction:(UIButton *)sender {
    if (self.applyButtonActionCompletionHandle) {
        self.applyButtonActionCompletionHandle();
    }
}

#pragma mark - getter
- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_clearButton setTitle:ZFLocalizedString(@"GoodsRefine_VC_Clear", nil) forState:UIControlStateNormal];
        _clearButton.backgroundColor = ZFC0xFFFFFF();
        [_clearButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        _clearButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (UIButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_applyButton setTitle:ZFLocalizedString(@"Category_APPLY", nil) forState:UIControlStateNormal];
        [_applyButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_applyButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_applyButton setBackgroundColor:ZFCOLOR(135, 135, 135, 1.f) forState:UIControlStateDisabled];
        [_applyButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _applyButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_applyButton addTarget:self action:@selector(applyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyButton;
}

//- (UIView *)topLineView {
//    if (!_topLineView) {
//        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
//        _topLineView.backgroundColor = ZFC0xDDDDDD();
//    }
//    return _topLineView;
//}
@end
