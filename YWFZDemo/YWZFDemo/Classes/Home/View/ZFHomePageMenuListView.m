//
//  ZFHomePageMenuListView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomePageMenuListView.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "ZFSkinModel.h"
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"
#import "AccountManager.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFHomePageMenuListView () {
    NSArray *_itemDatas;
    CGFloat _mainHeight;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) NSMutableArray *itemButtonArray;
@property (nonatomic, strong) CALayer *separetorLayer;
@property (nonatomic, assign) BOOL isAddCorners;
@end

@implementation ZFHomePageMenuListView

- (instancetype)initWithMenuTitles:(NSArray *)menuTitles selectedIndex:(NSInteger)selectedIndex {
    if (self = [super init]) {
        _itemDatas     = menuTitles;
        _selectedIndex = selectedIndex;
        self.itemButtonArray = [[NSMutableArray alloc] initWithCapacity:_itemDatas.count];
        [self setupView];
        [self addGesture];
    }
    return self;
}

- (void)setupView {
    [self.backgroundView addSubview:self.mainView];
    
    CGFloat space      = 20.0f;
    CGFloat offsetY    = 12.0f;
    CGFloat offsetX    = space;
    CGFloat itemHeight = 32.0f;
    CGFloat itemWidth  = (self.mainView.width - 40.0 - 5.0 * 3) / 4;
    UIFont *font       = [UIFont systemFontOfSize:14.0f];
    
    [self.itemButtonArray removeAllObjects];
    for (NSInteger i = 0; i < _itemDatas.count; i++) {
        
        NSString *menuTitle = _itemDatas[i];
        CGFloat nextOffsetX = offsetX + itemWidth + 5.0f;
        if (i % 4 == 0
            && i != 0) {
            offsetY     = offsetY + itemHeight + 12.0f;
            offsetX     = space;
            nextOffsetX = offsetX + itemWidth + 5.0f;
        }
        
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        item.frame     = CGRectMake(offsetX, offsetY, itemWidth, itemHeight);
        item.titleLabel.font    = font;
        item.layer.borderWidth  = 1.0f;
        item.layer.cornerRadius = 2.0;
        item.layer.masksToBounds = YES;
        item.tag = i;
        [item setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [item setTitleColor:ZFC0x999999() forState:UIControlStateSelected];
        item.backgroundColor    = ZFC0xF7F7F7();
        
        [item setTitle:menuTitle forState:UIControlStateNormal];
        [item addTarget:self action:@selector(menuItemSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.mainView addSubview:item];
        [self.itemButtonArray addObject:item];
        offsetX = nextOffsetX;
        _mainHeight = offsetY + itemHeight + 14.0f;
        if (i == _selectedIndex) {
            [self didSelectedWithIndex:i];
        } else {
            [self deSelectWithIndex:i];
        }
    }

    self.separetorLayer                 = [[CALayer alloc] init];
    self.separetorLayer.frame           = CGRectMake(0.0, _mainHeight - 1.0f, self.mainView.width, 1.0f);
    self.separetorLayer.backgroundColor = ZFCOLOR(221.0, 221.0, 221.0, 1.0).CGColor;
    [self.mainView.layer addSublayer:self.separetorLayer];
    
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.mainView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        NSArray *subMenuButtons = self.mainView.subviews;
        for (UIView *subMenuBtn in subMenuButtons) {
            if ([subMenuBtn isKindOfClass:[UIButton class]]) {
                subMenuBtn.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
}

- (void)addGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapHidden)];
    [self.backgroundView addGestureRecognizer:tapGesture];
}

- (void)showWithOffsetY:(CGFloat)offsetY {
    self.backgroundView.y      = offsetY;
    self.backgroundView.height = KScreenHeight - offsetY;
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
        self.mainView.height = self->_mainHeight;
        if (!self.isAddCorners) {
            self.isAddCorners = YES;
            [self.mainView zfAddCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(8, 8)];
        }
    }];
}

- (void)hidden {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.mainView.height = 0.0f;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
}

- (void)didSelectedWithIndex:(NSInteger)index {
    UIButton *btn = [self.itemButtonArray objectAtIndex:index];
    btn.selected  = YES;
    [btn setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    [btn setTitleColor:ZFC0x2D2D2D() forState:UIControlStateSelected];
    btn.backgroundColor = ZFC0xFFFFFF();
    btn.layer.borderColor = ZFC0x2D2D2D().CGColor;
}

- (void)deSelectWithIndex:(NSInteger)index {
    UIButton *btn = [self.itemButtonArray objectAtIndex:index];
    btn.selected  = NO;
    [btn setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
    [btn setTitleColor:ZFC0x999999() forState:UIControlStateSelected];
    btn.backgroundColor = ZFC0xF7F7F7();
    btn.layer.borderColor = ZFC0xF7F7F7().CGColor;
}

- (void)refreshMenuColor:(ZFSkinModel *)appHomeSkinModel
              resetColor:(BOOL)needConvertColor
{
    if (!appHomeSkinModel) {
        for (NSInteger i=0; i<self.itemButtonArray.count; i++) {
            UIButton *item = self.itemButtonArray[i];
            
            if (self.selectedIndex == i) {
                [item setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
                [item setTitleColor:ZFC0x2D2D2D() forState:UIControlStateSelected];
                item.backgroundColor = ZFC0xFFFFFF();
                item.layer.borderColor = ZFC0x2D2D2D().CGColor;
            } else {
                [item setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
                [item setTitleColor:ZFC0x999999() forState:UIControlStateSelected];
                item.backgroundColor = ZFC0xF7F7F7();
                item.layer.borderColor = ZFC0xF7F7F7().CGColor;
            }
        }
        return;
    };
    
    if (!ZFIsEmptyString(appHomeSkinModel.channelBackColor) &&
        !ZFIsEmptyString(appHomeSkinModel.channelTextColor) &&
        !ZFIsEmptyString(appHomeSkinModel.channelSelectedColor)) {
        
        UIColor *backgroundColor = [UIColor colorWithHexString:appHomeSkinModel.channelBackColor];
        UIColor *selectedColor = [UIColor colorWithHexString:appHomeSkinModel.channelSelectedColor];
        UIColor *normalColor = [UIColor colorWithHexString:appHomeSkinModel.channelTextColor];
        
        self.backgroundView.backgroundColor = backgroundColor;
        self.mainView.backgroundColor = backgroundColor;
        
        for (NSInteger i=0; i<self.itemButtonArray.count; i++) {
            UIButton *item = self.itemButtonArray[i];
            if (self.selectedIndex == i) {
                if (needConvertColor) {
                    [item setTitleColor:selectedColor forState:UIControlStateNormal];
                    [item setTitleColor:selectedColor forState:UIControlStateSelected];
                    item.layer.borderColor = selectedColor.CGColor;
                    item.backgroundColor = ZFCClearColor();

                } else {
                    [item setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
                    [item setTitleColor:ZFC0x2D2D2D() forState:UIControlStateSelected];
                    item.layer.borderColor = ZFC0x2D2D2D().CGColor;
                    item.backgroundColor = ZFCClearColor();
                }
            } else {
                if (needConvertColor) {
                    [item setTitleColor:normalColor forState:UIControlStateNormal];
                    [item setTitleColor:normalColor forState:UIControlStateSelected];
                    item.layer.borderColor = ZFCOLOR(221.0, 221.0, 221.0, 1.0).CGColor;
                } else {
                    [item setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
                    [item setTitleColor:ZFC0x999999() forState:UIControlStateSelected];
                    item.layer.borderColor = ZFC0xF7F7F7().CGColor;
                    item.backgroundColor = ZFC0xF7F7F7();
                }
            }
        }
    }
}

#pragma mark - event
- (void)menuItemSelectedAction:(UIButton *)btn {
    if (btn.tag == _selectedIndex) {
        return;
    }

    self.selectedIndex = btn.tag;
    btn.selected       = !btn.selected;
    [self hidden];
    if (self.selectedMenuIndex) {
        self.selectedMenuIndex(self.selectedIndex);
    }
}

- (void)tapHidden {
    if (self.selectedMenuIndex) {
        // 传-1代表收起 menuListView
        self.selectedMenuIndex(-1);
    }
}

#pragma mark - getter/setter
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, KScreenWidth, KScreenWidth)];
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        _backgroundView.clipsToBounds   = YES;
    }
    return _backgroundView;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.backgroundView.width, 0.0)];
        _mainView.backgroundColor = [UIColor whiteColor];
        _mainView.clipsToBounds   = YES;
    }
    return _mainView;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    [self deSelectWithIndex:_selectedIndex];
    _selectedIndex        = selectedIndex;
    [self didSelectedWithIndex:selectedIndex];
    
    ZFSkinModel *appHomeSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
    [self refreshMenuColor:appHomeSkinModel resetColor:YES];
}

@end
