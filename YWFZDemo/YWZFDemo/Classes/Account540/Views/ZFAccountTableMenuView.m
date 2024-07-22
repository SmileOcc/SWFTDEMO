//
//  ZFAccountTableMenuView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountTableMenuView.h"
#import "WMMenuView.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

@interface ZFAccountTableMenuView()<WMMenuViewDelegate,WMMenuViewDataSource>
@property (nonatomic, strong) WMMenuView            *menuView;
@property (nonatomic, strong) UIView                *underLineView;
@property (nonatomic, strong) NSMutableArray        *titleWidthArray;
@end

@implementation ZFAccountTableMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _datasArray = @[];
        _selectIndex = 0;
        [self addSubview:self.menuView];
        [self addSubview:self.underLineView];
        
        [self.underLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)setIsHiddenUnderLineView:(BOOL)isHiddenUnderLineView{
    _isHiddenUnderLineView = isHiddenUnderLineView;
    self.underLineView.hidden = _isHiddenUnderLineView;
}

#pragma mark - menuView datasource

- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
    if (self.datasArray.count > 0) {
        return self.datasArray.count;
    }
    return 1;
}

- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
    if (self.datasArray.count > index) {
        NSString *itmeName = self.datasArray[index];
        return ZFToString(itmeName);
    }
    return @"";
}

-(CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
//    if (self.datasArray.count > index && self.titleWidthArray.count > index) {
//        NSString *width = self.titleWidthArray[index];
//        //内容宽度大于滑块宽度
//        return [width floatValue] + 25;
//    }
    return KScreenWidth/2;
}


- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    if (state == WMMenuItemStateSelected) {
        return ColorHex_Alpha(0x2D2D2D, 1.0);
    }
    return ColorHex_Alpha(0x999999, 1.0);
}

- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    return 14;
}


-(void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    if (index != currentIndex) {
        _selectIndex = index;
        if (self.selectBlock) {
            self.selectBlock(self.selectIndex);
        }
    }
}

#pragma mark - setter/getter

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex) {
        _selectIndex = selectIndex;
        [self.menuView selectItemAtIndex:selectIndex];
        if (self.selectBlock) {
            self.selectBlock(_selectIndex);
        }
    }
}

- (void)setDatasArray:(NSArray<NSString *> *)datasArray {
    if (_datasArray != datasArray) {
        _datasArray = datasArray;
        
        [self.titleWidthArray removeAllObjects];
        [_datasArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIFont *titleFont = [UIFont fontWithName:self.menuView.fontName size:14];
            NSDictionary *attrs = @{NSFontAttributeName: titleFont};
            CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width  + 20;;
            NSString *itemWidthStr = [NSString stringWithFormat:@"%.2f",ceil(itemWidth)];
            [self.titleWidthArray addObject:itemWidthStr];
        }];
        
        self.menuView.progressWidths = [[NSArray alloc] initWithArray:self.titleWidthArray];
        [self.menuView reload];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            NSArray *subMenuViews = self.menuView.scrollView.subviews;
            for (UIView *subView in subMenuViews) {
                if ([subView isKindOfClass:[WMMenuItem class]]) {
                    subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
        }
        
        //刷新时，菜单总数据个数小于选中数时，重置选中最后一个
        if (_datasArray.count <= self.selectIndex) {
            self.selectIndex = _datasArray.count - 1;
            if (self.selectBlock) {
                self.selectBlock(self.selectIndex);
            }
        } else {
            [self.menuView selectItemAtIndex:self.selectIndex];
        }
    }
}

- (NSMutableArray *)titleWidthArray {
    if (!_titleWidthArray) {
        _titleWidthArray = [[NSMutableArray alloc] init];
    }
    return _titleWidthArray;
}

- (WMMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[WMMenuView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kSelectMenuViewHeight)];
        _menuView.dataSource = self;
        _menuView.delegate = self;
        _menuView.style = WMMenuViewStyleLine;
        _menuView.speedFactor = 10;
        _menuView.progressViewCornerRadius = 10;
        _menuView.contentMargin = 0;
        // _menuView.fontName = @"Helvetica";
        _menuView.lineColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        
    }
    return _menuView;
}

- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _underLineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1);
        _underLineView.hidden = YES;
    }
    return _underLineView;
}
@end
