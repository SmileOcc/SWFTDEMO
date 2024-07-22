//
//  ZFCommunityOutiftConfigurateBorderView.m
//  ZZZZZ
//
//  Created by YW on 2019/2/28.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutiftConfigurateBordersView.h"
#import "WMMenuView.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFProgressHUD.h"
#import <YYWebImage/YYWebImage.h>
#import "UIButton+ZFButtonCategorySet.h"

#import "ZFCommunityHomeScrollView.h"
#import "ZFCommunityOutiftConfigurateBordersItemView.h"

#import "ZFCommunityOutfitBorderViewModel.h"

static NSInteger ZFCommunityOutiftConfigurateBorders = 301900;


@interface ZFCommunityOutiftConfigurateBordersView()<UIScrollViewDelegate>

@property (nonatomic, strong) ZFCommunityOutfitBorderViewModel              *borderViewModel;

@property (nonatomic, strong) ZFCommunityHomeScrollView                     *contentScrollView;

/** 当前显示的子视图*/
@property (nonatomic, strong) ZFCommunityOutiftConfigurateBordersItemView   *currentBordersItemView;

@property (nonatomic, assign) BOOL                                          hadRequest;

@property (nonatomic, strong) UIView                                        *emptyView;
@property (nonatomic, strong) YYAnimatedImageView                           *emptyImageView;
@property (nonatomic, strong) UILabel                                       *emptyLabel;
@property (nonatomic, strong) UIButton                                      *emptyButton;
@end

@implementation ZFCommunityOutiftConfigurateBordersView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.menuView];
        [self addSubview:self.contentScrollView];
        
        [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0);
        }];
        
        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.top.mas_equalTo(self.menuView.mas_bottom);
        }];
        
        [self loadCateMenuRequest];
    }
    return self;
}

#pragma mark - 网络请求
- (void)loadCateMenuRequest {
    ShowLoadingToView(self);
    @weakify(self)
    [self.borderViewModel requestOutfitBorderCateID:@"" finished:^{
        @strongify(self)
        HideLoadingFromView(self);
        
        if (self.borderViewModel.bordersCateArray.count <= 0) {
            [self showAgainRequestView];
        } else {
            [self removeAgainRequestView];
            [self updateMenuViewDatas:self.borderViewModel.bordersCateArray];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        NSInteger currenIndex = scrollView.contentOffset.x / KScreenWidth;
        self.menuView.selectIndex = currenIndex;
        
        ZFCommunityOutiftConfigurateBordersItemView *itemView = [self.contentScrollView viewWithTag:(ZFCommunityOutiftConfigurateBorders + currenIndex)];
        if (itemView && [itemView isKindOfClass:[ZFCommunityOutiftConfigurateBordersItemView class]] && self.currentBordersItemView != itemView) {
            [itemView zfViewWillAppear];
            self.currentBordersItemView = itemView;
        }
    }
}


#pragma mark - Public Method

- (void)showMenuView:(BOOL)isShow {
    [self.menuView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(isShow ? 44 : 0);
    }];
    self.menuView.hidden = isShow ? NO : YES;
    self.menuView.isHiddenUnderLineView = isShow ? NO : YES;
}

- (void)updateMenuViewDatas:(NSArray <ZFCommunityOutfitBorderCateModel*> *)menuDatas {
    if ([menuDatas isKindOfClass:[NSArray class]]) {
        self.menuView.datasArray = menuDatas;
        
        @weakify(self)
        CGFloat itemHeight = CGRectGetHeight(self.frame);
        for (int i=0; i<menuDatas.count; i++) {
            
            ZFCommunityOutiftConfigurateBordersItemView *itemView = [[ZFCommunityOutiftConfigurateBordersItemView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, itemHeight - 44)];
            itemView.tag = ZFCommunityOutiftConfigurateBorders + i;
            itemView.frame = CGRectMake(self.contentScrollView.width * i, 0, self.contentScrollView.width, itemHeight - 44);
            itemView.cateModel = menuDatas[i];
            [self.contentScrollView addSubview:itemView];
            
            itemView.selectOutfitBorderBlock = ^(ZFCommunityOutfitBorderModel * _Nonnull borderModel) {
                @strongify(self)
                [self handleSelectBorder:borderModel];
            };
            
            if (i == 0) {
                [itemView zfViewWillAppear];
            }
            if ([SystemConfigUtils isRightToLeftShow]) {
                itemView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
        self.contentScrollView.contentSize = CGSizeMake(menuDatas.count * KScreenWidth, 0);
    }
}

// 选择商品
- (void)handleSelectBorder:(ZFCommunityOutfitBorderModel *)borderModel {
    if (self.selectBlock) {
        self.selectBlock(borderModel);
    }
    
    for (ZFCommunityOutiftConfigurateBordersItemView *itemView in self.contentScrollView.subviews) {
        if ([itemView isKindOfClass:[ZFCommunityOutiftConfigurateBordersItemView class]]) {
            [itemView zfReloadView];
        }
    }
}

#pragma mark - privete method
- (void)removeAgainRequestView {
    if (_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
}
- (void)showAgainRequestView {
    
    if (!_emptyView) {
        [self addSubview:self.emptyView];
        [self.emptyView addSubview:self.emptyImageView];
        [self.emptyView addSubview:self.emptyLabel];
        [self.emptyView addSubview:self.emptyButton];
        
        
        [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(50);
            make.leading.trailing.mas_equalTo(self);
        }];
        
        [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.mas_equalTo(self.emptyView);
            make.size.mas_equalTo(CGSizeMake(110, 110));
        }];
        
        CGFloat maxWidth = KScreenWidth - 56;
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emptyImageView.mas_bottom).offset(36);
            make.centerX.equalTo(self.emptyImageView);
            make.width.greaterThanOrEqualTo(@(maxWidth));
        }];
        
        [self.emptyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.emptyImageView);
            make.top.equalTo(self.emptyLabel.mas_bottom).offset(36);
            make.size.mas_equalTo(CGSizeMake(maxWidth, 44));
            make.bottom.equalTo(self.emptyView);
        }];
        
    }
}

- (void)refreshAction:(UIButton *)sender {
    [self loadCateMenuRequest];
}

- (void)selectMenuIndex:(NSInteger)menuIndex {
    [self.contentScrollView setContentOffset:CGPointMake(menuIndex * KScreenWidth, 0) animated:YES];
    
    ZFCommunityOutiftConfigurateBordersItemView *itemView = [self.contentScrollView viewWithTag:(ZFCommunityOutiftConfigurateBorders + menuIndex)];
    if (itemView && [itemView isKindOfClass:[ZFCommunityOutiftConfigurateBordersItemView class]] && self.currentBordersItemView != itemView) {
        [itemView zfViewWillAppear];
        self.currentBordersItemView = itemView;
    }
}


#pragma mark - Property Method
- (ZFCommunityOutfitBorderViewModel *)borderViewModel {
    if (!_borderViewModel) {
        _borderViewModel = [[ZFCommunityOutfitBorderViewModel alloc] init];
    }
    return _borderViewModel;
}

- (ZFCommunityOutiftConfigurateBordersMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[ZFCommunityOutiftConfigurateBordersMenuView alloc] initWithFrame:CGRectZero];
        _menuView.hidden = YES;
        
        @weakify(self)
        _menuView.selectBlock = ^(NSInteger index) {
            @strongify(self)
            [self selectMenuIndex:index];
        };
    }
    return _menuView;
}

- (ZFCommunityHomeScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[ZFCommunityHomeScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, CGRectGetHeight(self.frame) - 44)];
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _contentScrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _contentScrollView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _emptyView;
}

- (YYAnimatedImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _emptyImageView.image = ZFImageWithName(@"blankPage_noCart");
    }
    return _emptyImageView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.font = ZFFontSystemSize(16.0);
        _emptyLabel.adjustsFontSizeToFitWidth = YES;
        _emptyLabel.preferredMaxLayoutWidth = KScreenWidth - 56;
        _emptyLabel.text =  ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
    }
    return _emptyLabel;
}

- (UIButton *)emptyButton {
    if (!_emptyButton) {
        _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _emptyButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _emptyButton.titleLabel.textColor = ZFCOLOR_WHITE;
        _emptyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_emptyButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_emptyButton setTitle:ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil) forState:UIControlStateNormal];
        [_emptyButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emptyButton;
}

@end






@interface ZFCommunityOutiftConfigurateBordersMenuView()<WMMenuViewDelegate,WMMenuViewDataSource>

@property (nonatomic, strong) WMMenuView            *menuView;
@property (nonatomic, strong) UIView                *underLineView;

@property (nonatomic, strong) NSMutableArray        *titleWidthArray;


@end


@implementation ZFCommunityOutiftConfigurateBordersMenuView

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
        ZFCommunityOutfitBorderCateModel *cateModel = self.datasArray[index];
        return ZFToString(cateModel.name);
    }
    return @"";
}

-(CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    if (self.datasArray.count > index && self.titleWidthArray.count > index) {
        NSString *width = self.titleWidthArray[index];
        //内容宽度大于滑块宽度
        return [width floatValue] + 25;
    }
    return 0;
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

- (void)setDatasArray:(NSArray <ZFCommunityOutfitBorderCateModel*> *)datasArray {
    if (_datasArray != datasArray) {
        _datasArray = datasArray;
        
        [self.titleWidthArray removeAllObjects];
        [_datasArray enumerateObjectsUsingBlock:^(ZFCommunityOutfitBorderCateModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *title = ZFToString(obj.name);
            UIFont *titleFont = [UIFont fontWithName:self.menuView.fontName size:14];
            NSDictionary *attrs = @{NSFontAttributeName: titleFont};
            CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
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
        _menuView = [[WMMenuView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
        _menuView.dataSource = self;
        _menuView.delegate = self;
        _menuView.style = WMMenuViewStyleLine;
        _menuView.speedFactor = 10;
        _menuView.progressViewCornerRadius = 10;
        _menuView.contentMargin = 20;
        //        _menuView.fontName = @"Helvetica";
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
