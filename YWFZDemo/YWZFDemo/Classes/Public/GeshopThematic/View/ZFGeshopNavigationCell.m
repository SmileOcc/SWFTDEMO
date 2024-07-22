//
//  ZFGeshopNavigationCell.m
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopNavigationCell.h"
#import "ZFGeshopNavigationItemCell.h"
#import "SystemConfigUtils.h"
#import "ZFBannerTimeView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFNotificationDefiner.h"

@interface ZFGeshopNavigationCell ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL hasChangeScrollX;
@property (nonatomic) NSRange selectedRange;
@end

@implementation ZFGeshopNavigationCell

@synthesize sectionModel = _sectionModel;


- (void)dealloc {
    ZFRemoveAllNotification(self);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndex = 0;
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark -- Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshItemStatus:) name:kRefreshNativeThemeNavigationItem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkScrollItemIsShow) name:kCheckScrollItemIsShow object:nil];
}

/// 滚动列表实时选中水平导航栏中的指定标签
- (void)refreshItemStatus:(NSNotification *)notify {
    if (!self.sectionModel)return;
    
    CGFloat offsetY = [notify.object floatValue];
    CGFloat location = self.selectedRange.location;
    CGFloat length = self.selectedRange.length;
    
    if (offsetY >= location && offsetY < (location + length))  {
        //偏移量小于第一个标签时选中第一个标签
        if (offsetY < self.sectionModel.firstSelectedRange.location) {
            self.sectionModel.component_data.list.firstObject.isActiveNavigatorItem = YES;
        }
        return;
    }
    NSInteger selectedIndex = 0;
    for (NSInteger i=0; i<self.sectionModel.component_data.list.count; i++) {
        ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[i];
        
        CGFloat location2 = listModel.selectedRange.location;
        CGFloat length2 = listModel.selectedRange.length;
        
        if (offsetY >= location2 && offsetY < (location2 + length2)) {
            self.selectedRange = listModel.selectedRange;
            listModel.isActiveNavigatorItem = YES;
            selectedIndex = i;
        } else {
            listModel.isActiveNavigatorItem = NO;
        }
    }
    //偏移量小于第一个标签时选中第一个标签
    if (offsetY < self.sectionModel.firstSelectedRange.location) {
        self.sectionModel.component_data.list.firstObject.isActiveNavigatorItem = YES;
    }
    [self.collectionView reloadData];
    [self setScrollToIndexItem:selectedIndex animated:YES];
    self.hasChangeScrollX = NO;
}

/// 滚动到指定标签位置
- (void)setScrollToIndexItem:(NSInteger)index animated:(BOOL)animated {
    if (index >= self.sectionModel.component_data.list.count) return;
    self.selectedIndex = index;
    CGFloat maxScrollWidth = self.collectionView.contentSize.width - KScreenWidth;
    if (maxScrollWidth < 0) return;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:path];
    if (!cell) return;
    
    ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[index];
    CGFloat cellX = CGRectGetMinX(cell.frame) - listModel.navigatorItemWidth / 2;
    if (cellX < 0) {
        cellX = CGRectGetMinX(cell.frame);
    }
    CGFloat scrollX = MIN(cellX, maxScrollWidth);
    [self.collectionView setContentOffset:CGPointMake(scrollX, 0) animated:animated];
}

/// 主列表在滚动过程中顶部标签是否在可见区域内显示
- (void)checkScrollItemIsShow {
    if (!self.hasChangeScrollX && ![self.collectionView.visibleCells containsObject:self]) {
        self.hasChangeScrollX = YES;
        [self setScrollToIndexItem:self.selectedIndex animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.hasChangeScrollX = NO;
        });
    }
}

#pragma mark - Setter

- (void)setSectionModel:(ZFGeshopSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sectionModel.component_data.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.component_data.list.count <= indexPath.item) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    }
    ZFGeshopNavigationItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFGeshopNavigationItemCell class]) forIndexPath:indexPath];
    ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[indexPath.item];
    cell.listModel = listModel;
    cell.styleModel = self.sectionModel.component_style;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.component_data.list.count > indexPath.item) {
        ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[indexPath.item];
        CGFloat itemWidth = (listModel.navigatorItemWidth > 0) ? listModel.navigatorItemWidth : 80;
        return CGSizeMake(itemWidth, self.sectionModel.component_style.height);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionModel.component_data.list.count <= indexPath.item) return;
    
    ZFGeshopSectionListModel *listModel = self.sectionModel.component_data.list[indexPath.item];
    for (ZFGeshopSectionListModel *tmpListModel in self.sectionModel.component_data.list) {
        if ([tmpListModel.component_id isEqualToString:listModel.component_id]) {
            tmpListModel.isActiveNavigatorItem = YES;
        } else {
            tmpListModel.isActiveNavigatorItem = NO;
        }
    }
    [collectionView reloadData];
    [self setScrollToIndexItem:indexPath.item animated:YES];
    
    if (self.sectionModel.clickNavigationItemBlock) {
        self.sectionModel.clickNavigationItemBlock(listModel, self.frame.size.height);
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[ZFGeshopNavigationItemCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFGeshopNavigationItemCell class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _collectionView;
}


@end
