//
//  ZFGeshopSiftBarView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSiftBarView.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGeshopSectionModel.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFButton.h"
#import "SystemConfigUtils.h"

@interface ZFCategorySiftBarItemView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation ZFCategorySiftBarItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self addSubview:self.titleLabel];
    [self addSubview:self.arrowImageView];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(KScreenWidth/3-20);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(3);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _arrowImageView.image = ZFImageWithName(@"sift_arrow_down");
    }
    return _arrowImageView;
}
@end

//=============================================================================

@interface ZFGeshopSiftBarView ()
@property (nonatomic, strong) ZFCategorySiftBarItemView *categoryItemView;
@property (nonatomic, strong) ZFCategorySiftBarItemView *sortItemView;
@property (nonatomic, strong) ZFCategorySiftBarItemView *refineItemView;
@property (nonatomic, strong) ZFCategorySiftBarItemView *lastBarItemView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, assign) BOOL isAnimationIng;
@end

@implementation ZFGeshopSiftBarView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recoverArrowNotification) name:kNativeThemeRecoverArrowNotification object:nil];
}

- (void)recoverArrowNotification {
    [self showButtonAnimation:self.lastBarItemView];
    self.lastBarItemView = nil;
}

- (void)showButtonAnimation:(ZFCategorySiftBarItemView *)lastBarItemView {
    if (self.isAnimationIng)return;
    self.isAnimationIng = YES;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if ([lastBarItemView isEqual:self.lastBarItemView]) {
            lastBarItemView.arrowImageView.transform = CGAffineTransformIdentity;
        } else {
            if (self.lastBarItemView) {
                self.lastBarItemView.arrowImageView.transform = CGAffineTransformIdentity;
            }
            if (lastBarItemView.tag != ZFCategoryColumn_RefineType) {
                lastBarItemView.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }
    } completion:^(BOOL finished) {
        self.isAnimationIng = NO;
    }];
}

#pragma mark - Setter

- (void)itemViewAction:(ZFCategorySiftBarItemView *)barItemView {
    BOOL openList = ![barItemView isEqual:self.lastBarItemView];
    [self showButtonAnimation:barItemView];
    
    if (self.itemButtonActionBlock) {
        self.itemButtonActionBlock(barItemView.tag, openList);
    }
    self.lastBarItemView = barItemView;
}

- (void)refreshCategoryTitle:(NSString *)categoryTitle sortTitle:(NSString *)sortTitle {
    if (ZFIsEmptyString(categoryTitle)) {
        categoryTitle = ZFLocalizedString(@"Category_Item_Segmented_Category", nil);
    }
    self.categoryItemView.titleLabel.text = ZFToString(categoryTitle);
    
    if (ZFIsEmptyString(sortTitle)) {
        sortTitle = ZFLocalizedString(@"Category_Item_Segmented_Sort", nil);
    }
    self.sortItemView.titleLabel.text = ZFToString(sortTitle);
    
    self.refineItemView.titleLabel.text = ZFLocalizedString(@"Category_Item_Segmented_Refine", nil);
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.categoryItemView];
    [self addSubview:self.sortItemView];
    [self addSubview:self.refineItemView];
    [self addSubview:self.bottomLine];
}

- (void)zfAutoLayoutView {
    BOOL isAr = ([SystemConfigUtils isRightToLeftShow]) ? YES : NO;
    
    UIView *firstView = isAr ? self.refineItemView : self.categoryItemView;
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(KScreenWidth/3);
        make.centerX.mas_equalTo(self.mas_centerX).offset(-KScreenWidth*1/3);
    }];
    
    [self.sortItemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(KScreenWidth/3);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    UIView *thirdView = isAr ? self.categoryItemView : self.refineItemView;
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(KScreenWidth/3);
        make.centerX.mas_equalTo(self.mas_centerX).offset(KScreenWidth*1/3);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0.8);
    }];
}

#pragma mark - Getter

- (ZFCategorySiftBarItemView *)categoryItemView {
    if (!_categoryItemView) {
        _categoryItemView = [[ZFCategorySiftBarItemView alloc] initWithFrame:CGRectZero];
        _categoryItemView.tag = ZFCategoryColumn_CategoryType;
        
        @weakify(self);
        [_categoryItemView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self itemViewAction:self.categoryItemView];
        }];
    }
    return _categoryItemView;
}

- (ZFCategorySiftBarItemView *)sortItemView {
    if (!_sortItemView) {
        _sortItemView = [[ZFCategorySiftBarItemView alloc] initWithFrame:CGRectZero];
        _sortItemView.tag = ZFCategoryColumn_SortType;
        
        @weakify(self);
        [_sortItemView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self itemViewAction:self.sortItemView];
        }];
    }
    return _sortItemView;
}

- (ZFCategorySiftBarItemView *)refineItemView {
    if (!_refineItemView) {
        _refineItemView = [[ZFCategorySiftBarItemView alloc] initWithFrame:CGRectZero];
        _refineItemView.tag = ZFCategoryColumn_RefineType;
        _refineItemView.arrowImageView.image = ZFImageWithName(@"sift_filter");
        
        @weakify(self);
        [_refineItemView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self itemViewAction:self.refineItemView];
        }];
    }
    return _refineItemView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _bottomLine;
}

@end
