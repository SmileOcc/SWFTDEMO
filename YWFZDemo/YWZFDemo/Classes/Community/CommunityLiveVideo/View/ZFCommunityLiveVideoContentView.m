//
//  ZFCommunityLiveVideoContentView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityLiveVideoContentView.h"
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
#import "ZFInitViewProtocol.h"

#import "ZFCommunityLiveVideoGoodsView.h"
#import "ZFCommunityLiveVideoActivityView.h"
#import "ZFCommunityHomeScrollView.h"
#import "ZFCommunityLiveVideoChatView.h"

@interface ZFCommunityLiveVideoContentView()<UIScrollViewDelegate>

@property (nonatomic, strong) ZFCommunityHomeScrollView                   *contentScrollView;
@property (nonatomic, strong) UIView                                      *currentGoodsItemView;
@property (nonatomic, strong) UIView                                      *tempView;
@property (nonatomic, strong) UIView                                      *contView;



@end

@implementation ZFCommunityLiveVideoContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.menuView];
        [self addSubview:self.contentScrollView];
        [self addSubview:self.tempView];
        
        [self.contentScrollView addSubview:self.contView];
        [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(44);
        }];
        
        [self.tempView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top).offset(44);
            make.width.mas_equalTo(KScreenWidth);
        }];
        
        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(44);
            make.leading.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(self.mas_trailing);
        }];
        
        [self.contView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentScrollView);
            make.width.mas_equalTo(2 * KScreenWidth);
        }];
        
        [self bringSubviewToFront:self.menuView];
        [self.menuView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisVertical];
        [self.menuView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //当旋转后，需要重新滚动回原先位置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.contentScrollView setContentOffset:CGPointMake(self.menuView.selectIndex * KScreenWidth, 0) animated:NO];
    });
}

- (void)updateMenuModel:(ZFCommunityLiveVideoMenuCateModel *)menuModel index:(NSInteger)index {
    if (self.menuView.datasArray.count > index) {
        [self.menuView updateMode:menuModel index:index];
    }
}

- (void)updateMenuViewDatas:(NSArray <ZFCommunityLiveVideoMenuCateModel*> *)menuDatas liveModel:(ZFCommunityLiveListModel *)liveModel{
    
    
    if ([menuDatas isKindOfClass:[NSArray class]]) {
        [self.contView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

        self.menuView.datasArray = menuDatas;
        CGFloat itemHeight = CGRectGetHeight(self.frame);

        UIView *tempItemView;
        UIView *itemView;
        @weakify(self)
        for (int i=0; i<menuDatas.count; i++) {
            ZFCommunityLiveVideoMenuCateModel *cateModel = menuDatas[i];
            if (i == 0) {
                itemView = [[ZFCommunityLiveVideoGoodsView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, itemHeight - 44) cateName:ZFToString(cateModel.cateName) cateID:ZFToString(cateModel.cateId) skus:ZFToString(cateModel.skus)];
                itemView.tag = 201900 + i;
                itemView.frame = CGRectMake(self.contentScrollView.width * i, 0, self.contentScrollView.width, itemHeight - 44);
                [self.contView addSubview:itemView];

                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(self.contView.mas_leading);
                    make.top.mas_equalTo(self.contView.mas_top);
                    make.bottom.mas_equalTo(self.contView.mas_bottom);
                    make.height.mas_equalTo(self.tempView.mas_height);
                    make.width.mas_equalTo(KScreenWidth);
                }];
                
                ZFCommunityLiveVideoGoodsView *goodsItemView = (ZFCommunityLiveVideoGoodsView *)itemView;
                goodsItemView.selectBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
                    @strongify(self)
                    if (self.videoSelectGoodsBlock) {
                        self.videoSelectGoodsBlock(goodModel);
                    }
                };
                goodsItemView.cartGoodsBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
                    @strongify(self)
                    if (self.videoAddCartBlock) {
                        self.videoAddCartBlock(goodModel);
                    }
                };
                
                goodsItemView.similarGoodsBlock = ^(ZFGoodsModel * _Nonnull goodModel) {
                    @strongify(self)
                    if (self.videoSimilarGoodsBlock) {
                        self.videoSimilarGoodsBlock(goodModel);
                    };
                };
                
                goodsItemView.goodsArrayBlock = ^(NSMutableArray<ZFGoodsModel *> *goodsArray) {
                    @strongify(self)
                    if (self.goodsArrayBlock) {
                        self.goodsArrayBlock(goodsArray);
                    }
                };
                
                
                [goodsItemView zfViewWillAppear];
                tempItemView = itemView;
                self.currentGoodsItemView = itemView;
                
            } else {
                
                
                if (cateModel.isChat) {
                    itemView = [[ZFCommunityLiveVideoChatView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, itemHeight - 44)];
                    itemView.tag = 201900 + i;
                    itemView.frame = CGRectMake(self.contentScrollView.width * i, 0, self.contentScrollView.width, itemHeight - 44);
                    [self.contView addSubview:itemView];

                } else {
                    
                    itemView = [[ZFCommunityLiveVideoActivityView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, itemHeight - 44) cateName:ZFToString(cateModel.cateName) cateID:ZFToString(cateModel.cateId)];
                    itemView.tag = 201900 + i;
                    itemView.frame = CGRectMake(self.contentScrollView.width * i, 0, self.contentScrollView.width, itemHeight - 44);
                    [self.contView addSubview:itemView];

                    ZFCommunityLiveVideoActivityView *activityView = (ZFCommunityLiveVideoActivityView*)itemView;
                    if (liveModel) {
                        if (ZFJudgeNSArray(liveModel.ios_hot)) {
                            [activityView updateHotActivity:liveModel.ios_hot];
                        }
                    }
                    
                    activityView.liveVideoBlock = ^(NSString * _Nonnull deeplink) {
                        @strongify(self)
                        if (self.videoActivityBllock) {
                            self.videoActivityBllock(deeplink);
                        }
                    };
                    
                    [activityView zfViewWillAppear];
                }

                
                if (i == menuDatas.count - 1) {
                    
                    if (tempItemView) {
                        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.mas_equalTo(tempItemView.mas_trailing);
                            make.trailing.mas_equalTo(self.contView.mas_trailing);
                            make.top.bottom.mas_equalTo(tempItemView);
                            make.height.mas_equalTo(self.tempView.mas_height);
                            make.width.mas_equalTo(KScreenWidth);
                        }];
                    }
                } else {
                    if (tempItemView) {
                        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.mas_equalTo(tempItemView.mas_trailing);
                            make.top.bottom.mas_equalTo(tempItemView);
                            make.height.mas_equalTo(self.tempView.mas_height);
                            make.width.mas_equalTo(KScreenWidth);
                        }];
                    }
                }
                tempItemView = itemView;
            }
            
            if ([SystemConfigUtils isRightToLeftShow]) {
                self.contView.transform = CGAffineTransformMakeScale(-1.0,1.0);
//                if (itemView) {
//                    itemView.transform = CGAffineTransformMakeScale(-1.0,1.0);
//                }
            }
            
        }
        [self.contView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(menuDatas.count * KScreenWidth);
        }];
        self.contentScrollView.contentSize = CGSizeMake(menuDatas.count * KScreenWidth, 0);
    } else {
        self.currentGoodsItemView = nil;
    }
}

#pragma mark -  Action

- (void)fullScreen:(BOOL)isFull {
    
    NSArray *subViews = self.contView.subviews;
    for (UIView *sub in subViews) {
        if ([sub respondsToSelector:@selector(fullScreen:)]) {
            [sub performSelector:@selector(fullScreen:) withObject:@(isFull)];
        }
    }
}

- (void)clearAllSeting {
    NSArray *subViews = self.contView.subviews;
    for (UIView *sub in subViews) {
        if ([sub isKindOfClass:[ZFCommunityLiveVideoChatView class]]) {
            ZFCommunityLiveVideoChatView *chatSubView = (ZFCommunityLiveVideoChatView *)sub;
            [chatSubView clearAllSeting];
        }
    }
}

- (void)selectMenuIndex:(NSInteger)menuIndex {
    
    [self.contentScrollView setContentOffset:CGPointMake(menuIndex * KScreenWidth, 0) animated:YES];
    UIView *itemView = [self.contentScrollView viewWithTag:(201900 + menuIndex)];
    if (itemView && self.currentGoodsItemView != itemView) {
        self.currentGoodsItemView = itemView;
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        NSInteger currenIndex = scrollView.contentOffset.x / KScreenWidth;
        self.menuView.selectIndex = currenIndex;
    }
}

#pragma mark - Property Method

- (NSMutableArray<ZFGoodsModel *> *)currentRecommendGoodsArray {
    UIView *videoGoodsView = [self.contentScrollView viewWithTag:201900];
    if ([videoGoodsView isKindOfClass:[ZFCommunityLiveVideoGoodsView class]]) {
        ZFCommunityLiveVideoGoodsView *goodsView = (ZFCommunityLiveVideoGoodsView *)videoGoodsView;
        return goodsView.currentGoodsArray;
    }
    return [[NSMutableArray alloc] init];
}

- (void)setIsZegoHistoryComment:(BOOL)isZegoHistoryComment {
    _isZegoHistoryComment = isZegoHistoryComment;
    
    NSArray *subViews = self.contView.subviews;
    for (UIView *sub in subViews) {
        if ([sub isKindOfClass:[ZFCommunityLiveVideoChatView class]]) {
            ZFCommunityLiveVideoChatView *chatSubView = (ZFCommunityLiveVideoChatView *)sub;
            if (isZegoHistoryComment) {
                [chatSubView addHeaderRefreshKit:YES];
            } else {
                [chatSubView addHeaderRefreshKit:NO];
            }
        }
    }
}

- (ZFCommunityLiveVideoContentMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[ZFCommunityLiveVideoContentMenuView alloc] initWithFrame:CGRectZero];
        _menuView.isHiddenUnderLineView = NO;
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
                                            
- (UIView *)tempView {
    if (!_tempView) {
        _tempView = [[UIView alloc] initWithFrame:CGRectZero];
        _tempView.hidden = YES;
    }
    return _tempView;
}

- (UIView *)contView {
    if (!_contView) {
        _contView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contView;
}

@end




#pragma mark -
#pragma mark -
@interface ZFCommunityLiveVideoContentMenuView()<WMMenuViewDelegate,WMMenuViewDataSource>

@property (nonatomic, strong) WMMenuView            *menuView;
@property (nonatomic, strong) UIView                *underLineView;
@property (nonatomic, strong) UIView                *topLineView;

@property (nonatomic, strong) NSMutableArray        *titleWidthArray;


@end

@implementation ZFCommunityLiveVideoContentMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _datasArray = @[];
        _selectIndex = 0;
        
        self.backgroundColor = ZFC0xFFFFFF();
        [self addSubview:self.menuView];
        [self addSubview:self.underLineView];
        [self addSubview:self.topLineView];
        
        [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(0.5);
        }];
        
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

- (void)updateMode:(ZFCommunityLiveVideoMenuCateModel *)cateModel index:(NSInteger)index {
    if (self.datasArray.count > index && !ZFIsEmptyString(cateModel.cateId)) {
        ZFCommunityLiveVideoMenuCateModel *model = self.datasArray[index];
        model.cateId = cateModel.cateId;
        model.cateName = cateModel.cateName;
        [self.menuView reload];
        
        // 刷新会重新还原子类
        if ([SystemConfigUtils isRightToLeftShow]) {
            NSArray *subMenuViews = self.menuView.scrollView.subviews;
            for (UIView *subView in subMenuViews) {
                if ([subView isKindOfClass:[WMMenuItem class]]) {
                    subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
        }
    }
}

- (void)updateSelectIndex:(NSInteger)index {
    
    _selectIndex = index;
    [self.menuView selectItemAtIndex:index];
    if (self.selectBlock) {
        self.selectBlock(_selectIndex);
    }
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
        ZFCommunityLiveVideoMenuCateModel *cateModel = self.datasArray[index];
        return ZFToString(cateModel.cateName);
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

#pragma mark - Property Method

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex) {
        _selectIndex = selectIndex;
        [self.menuView selectItemAtIndex:selectIndex];
        if (self.selectBlock) {
            self.selectBlock(_selectIndex);
        }
    }
}

- (void)setDatasArray:(NSArray *)datasArray {
    if (_datasArray != datasArray) {
        _datasArray = datasArray;
        
        [self.titleWidthArray removeAllObjects];
        [_datasArray enumerateObjectsUsingBlock:^(ZFCommunityLiveVideoMenuCateModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *title = ZFToString(obj.cateName);
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

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1);
        _topLineView.hidden = YES;
    }
    return _topLineView;
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




@implementation ZFCommunityLiveVideoMenuCateModel

@end
