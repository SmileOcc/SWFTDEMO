//
//  YXTabView.m
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/29.
//  Copyright © 2018 ellison. All rights reserved.
//

#import "YXTabView.h"
#import "YXPageView.h"
#import "YXTabItemView.h"
@interface YXTabView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *bottomlineView;
@property (nonatomic, strong) YXTabLayout *layout;

@property (nonatomic, copy) NSArray<YXTabItem *> *items;

@property (nonatomic, assign) CGFloat lrMargin;
@property (nonatomic, assign) CGFloat tabMargin;

@property (nonatomic, assign, readwrite) NSUInteger selectedIndex;

@property (nonatomic, strong) NSMutableSet *showBadgeIndexs;
@property (nonatomic, strong) NSMutableSet *showArrowImageIndexs;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation YXTabView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame withLayout:[YXTabLayout defaultLayout]];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withLayout:(YXTabLayout *)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        _layout = layout;
        _needLayout = YES;
        [self initializeData];
        [self initializeViews];
    }
    return self;
}

- (void)dealloc
{
    [_contentScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)initializeData {
    _items = @[];
    _showBadgeIndexs = [[NSMutableSet alloc] init];
    self.selectedIndex = 0;
    _showArrowImageIndexs = [[NSMutableSet alloc] init];
}

- (void)initializeViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_collectionView registerClass:[YXTabItemView class]
        forCellWithReuseIdentifier:NSStringFromClass([YXTabItemView class])];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_collectionView];
    
    _bottomlineView = [[UIView alloc] init];
    _bottomlineView.backgroundColor = _layout.lineColor;
    _bottomlineView.hidden = _layout.lineHidden;
    if (_layout.lineHeight != 2) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_collectionView insertSubview:_bottomlineView atIndex:0];
//        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView insertSubview:_bottomlineView atIndex:0];
        });
    } else {
        [_collectionView addSubview:_bottomlineView];
    }
    
    if (_layout.isGradientTail) {
        _gradientLayer = [[CAGradientLayer alloc] init];
        _gradientLayer.colors = @[(__bridge id)[_layout.gradientTailColor colorWithAlphaComponent:0].CGColor, (__bridge id)_layout.gradientTailColor.CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        [self.layer addSublayer:_gradientLayer];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (_layout.isGradientTail && _gradientLayer) {
        _gradientLayer.colors = @[(__bridge id)[_layout.gradientTailColor colorWithAlphaComponent:0].CGColor, (__bridge id)_layout.gradientTailColor.CGColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientLayer.frame = CGRectMake(self.bounds.size.width-20, 0, 20, self.bounds.size.height);
    [self reloadDataIfNeed];
}

- (void)setDefaultSelectedIndex:(NSUInteger)defaultSelectedIndex {
    _defaultSelectedIndex = defaultSelectedIndex;
    _selectedIndex = defaultSelectedIndex;
}

- (void)selectTabAtIndex:(NSUInteger)index {
    [self selectTabAtIndex:index animated:NO];
}

- (void)selectTabAtIndex:(NSUInteger)index animated:(BOOL)animated {
    [self selectItemAtIndex:index];
    [_contentScrollView setContentOffset:CGPointMake(_selectedIndex * _contentScrollView.bounds.size.width, 0) animated:animated];
}

- (void)_reloadData {
    [self refreshItems];
    [self refreshState];
    [_collectionView.collectionViewLayout invalidateLayout];
    [_collectionView reloadData];
}

- (void)reloadData {
    [self _reloadData];
}

- (void)reloadDataKeepOffset {
    CGFloat offset = _collectionView.contentOffset.x;
    [self _reloadData];
    [_collectionView setContentOffset:CGPointMake(offset, 0)];
}

//展示index的badge
- (void)showBadgeAtIndex:(NSUInteger)index {
    [self.showBadgeIndexs addObject:@(index)];
    [_collectionView reloadData];
}

- (void)hideBadgeAtIndex:(NSUInteger)index {
    YXTabItemView *itemView = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    itemView.hideRedDot = true;
    [self.showBadgeIndexs removeObject:@(index)];
}

- (void)showArrowImageAtIndexs:(NSArray<NSNumber *> *)indexs {
    [self.showArrowImageIndexs addObjectsFromArray:indexs];
    [_collectionView reloadData];
}

- (UIView *)getArrowViewAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)reloadDataIfNeed {
    if (_needLayout) {
        _needLayout = NO;
        [self _reloadData];
    }
}

- (void)refreshItems {
    __block NSMutableArray *array = [NSMutableArray array];
    [_titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = self.layout.tabWidth;
        CGFloat lineWidth = self.layout.lineWidth;
        if (fabs(width) < CGFLOAT_MIN) {
            UIFont *font = self.layout.titleFont;
            if (idx == self.selectedIndex) {
                font = self.layout.titleSelectedFont;
            }
            width = [obj boundingRectWithSize:CGSizeMake(MAXFLOAT, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil].size.width + self.layout.tabPadding * 2;
        }
        if (fabs(lineWidth) < CGFLOAT_MIN) {
            lineWidth = width;
        }
        
        YXTabItem *item = [[YXTabItem alloc] init];
        item.title = obj;
        item.width = width;
        item.lineWidth = lineWidth;
        item.color = self.layout.tabColor;
        item.selectedColor = self.layout.tabSelectedColor;
        item.titleFont = self.layout.titleFont;
        item.titleSelectedFont = self.layout.titleSelectedFont;
        item.titleColor = self.layout.titleColor;
        item.titleSelectedColor = self.layout.titleSelectedColor;
        item.cornerRadius = self.layout.tabCornerRadius;
        item.clipsToBounds = self.layout.itemClipsToBounds;
        item.layerColor = self.layout.layerColor;
        item.layerSelectedColor = self.layout.layerSelectedColor;
        item.layerWidth = self.layout.layerWidth;

        if (idx == self.selectedIndex) {
            item.selected = YES;
        }else {
            item.selected = NO;
        }
        [array addObject:item];
    }];
    
    _items = array;
}

- (void)refreshState {
    if (_items.count < 1) {
        return;
    }
    
    if (self.selectedIndex >= _items.count) {
        self.selectedIndex = 0;
    }
    
    if (_items.count < 1) {
        return;
    }
    
    __block CGFloat totalWidth = _layout.lrMargin;
    __block CGFloat totalItemWidth = 0;
    [_items enumerateObjectsUsingBlock:^(YXTabItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalItemWidth += obj.width;
        totalWidth += obj.width + self.layout.tabMargin;
    }];
    totalWidth -= _layout.tabMargin;
    totalWidth += _layout.lrMargin;
    
    if (totalWidth < self.bounds.size.width && _layout.leftAlign == NO) {
        CGFloat spacing = 0;
        if (_items.count > 0) {
            if (_layout.tabMargin == 0 && _items.count > 1) {
                _lrMargin = _layout.lrMargin;
                spacing = (self.bounds.size.width - totalItemWidth - _lrMargin * 2)/(_items.count - 1);
            } else {
                spacing = (self.bounds.size.width - totalItemWidth)/(_items.count - 1 + 1);
                _lrMargin = spacing/2.0;
            }
        }
        _tabMargin = spacing;
    } else if (totalWidth > self.bounds.size.width && _layout.leftAlign == YES) {
        CGFloat spacing = 0;
        if (_items.count > 0 && _items.count > 1) {
            _lrMargin = _layout.lrMargin;
            spacing = (self.bounds.size.width - totalItemWidth - _lrMargin * 2)/(_items.count - 1);
            if (spacing < 0) {
                spacing = _layout.tabMargin;
            }
        }
        _tabMargin = spacing;
    } else {
        _lrMargin = _layout.lrMargin;
        _tabMargin = _layout.tabMargin;
    }
    
    __block CGFloat selectedItemX = _lrMargin;
    __block CGFloat selectedItemWidth = 0;
    totalWidth = _lrMargin;
    [_items enumerateObjectsUsingBlock:^(YXTabItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < self.selectedIndex) {
            selectedItemX += obj.width + self.tabMargin;
        } else if (idx == self.selectedIndex) {
            selectedItemWidth = obj.width;
        }
        totalWidth += obj.width + self.tabMargin;
    }];
    totalWidth -= _layout.tabMargin;
    totalWidth += _layout.lrMargin;
    
    CGFloat minX = 0;
    CGFloat maxX = totalItemWidth - self.bounds.size.width;
    CGFloat targetX = selectedItemX - self.bounds.size.width/2.0 + selectedItemWidth/2.0;
    [_collectionView setContentOffset:CGPointMake(MAX(MIN(maxX, targetX), minX), 0) animated:NO];
    
    [_contentScrollView setContentOffset:CGPointMake(_selectedIndex * _contentScrollView.bounds.size.width, 0) animated:NO];
    CGFloat lineWidth = _items[_selectedIndex].lineWidth;
    _bottomlineView.frame = CGRectMake(selectedItemX + (_items[_selectedIndex].width - lineWidth)/2, self.bounds.size.height - _layout.lineHeight - _layout.linePadding, lineWidth, _layout.lineHeight);
    _bottomlineView.layer.cornerRadius = _layout.lineCornerRadius;
}

- (void)setPageView:(YXPageView *)pageView {
    if (_contentScrollView != nil) {
        [_contentScrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    _pageView = pageView;
    _contentScrollView = pageView.contentView;
    
    [_contentScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && (self.contentScrollView.isTracking || self.contentScrollView.isDecelerating)) {
        
        CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        [self contentScrollViewDidChanged:contentOffset];
    }
}

- (void)contentScrollViewDidChanged:(CGPoint)contentOffset {
    CGFloat ratio = contentOffset.x/self.contentScrollView.bounds.size.width;
    if (ratio > _items.count - 1 || ratio < 0) {
        return;
    }
    if (contentOffset.x == 0 && self.selectedIndex == 0) {
        return;
    }
    if (contentOffset.x + _contentScrollView.bounds.size.width == _contentScrollView.contentSize.width && self.selectedIndex == _items.count - 1) {
        return;
    }
    ratio = MAX(0, MIN(_items.count - 1, ratio));
    NSInteger baseIndex = floorf(ratio);
    CGFloat remainderRatio = ratio - baseIndex;
    
    [self contentScrollViewDidScrollWithLeftIndex:baseIndex percent:remainderRatio];
    
    if (fabs(remainderRatio) < CGFLOAT_MIN) {
        [self selectItemAtIndex:baseIndex withScrolling:YES];
        [_contentScrollView setContentOffset:CGPointMake(baseIndex * _contentScrollView.bounds.size.width, 0) animated:YES];
    }else {
        if (fabs(ratio - _selectedIndex) > 0.5) {
            NSUInteger targetIndex = baseIndex;
            if (ratio < _selectedIndex) {
                targetIndex = baseIndex;
            }
            if (ratio > _selectedIndex) {
                targetIndex = baseIndex + 1;
            }
            [self selectItemAtIndex:targetIndex withScrolling:YES];
        }
        //        if (self.delegateFlags.scrollingFromLeftIndexToRightIndexFlag) {
        //            [self.delegate categoryView:self scrollingFromLeftIndex:baseIndex toRightIndex:baseIndex + 1 ratio:remainderRatio];
        //        }
    }
    
}

- (void)contentScrollViewDidScrollWithLeftIndex:(NSUInteger)leftIndex percent:(CGFloat)percent {
    NSUInteger rightIndex = leftIndex + 1;
    if (rightIndex >= _items.count) {
        return;
    }
    CGRect leftItemFrame = [self getItemViewFrame:leftIndex];
    CGRect rightItemFrame = [self getItemViewFrame:rightIndex];
    
    CGFloat lineWidth = _items[leftIndex].lineWidth;
    CGFloat lineX = leftItemFrame.origin.x + (leftItemFrame.size.width - lineWidth)/2.0;
    if (percent > CGFLOAT_MIN) {
        CGFloat rightWidth = _items[rightIndex].lineWidth;
        CGFloat rightX = rightItemFrame.origin.x + (rightItemFrame.size.width - rightWidth)/2.0;
        percent = MIN(1, percent);
        lineX = lineX + (rightX - lineX) * percent;
        lineWidth = lineWidth + (rightWidth - lineWidth) * percent;
    }
    CGRect frame = _bottomlineView.frame;
    frame.origin.x = lineX;
    frame.size.width = lineWidth;
    _bottomlineView.frame = frame;
}

- (void)selectItemAtIndex:(NSUInteger)targetIndex {
    [self selectItemAtIndex:targetIndex withScrolling:NO];
}

- (void)selectItemAtIndex:(NSUInteger)targetIndex withScrolling:(BOOL)scrolling {
    YXTabItem *oldItem = _items[_selectedIndex];
    YXTabItem *targetItem = _items[targetIndex];
    oldItem.selected = NO;
    targetItem.selected = YES;
    
    YXTabItemView *oldItemView = (YXTabItemView *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    [oldItemView reloadItem:oldItem];
    YXTabItemView *targetItemView = (YXTabItemView *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0]];
    [targetItemView reloadItem:targetItem];
    
    self.selectedIndex = targetIndex;
    [self refreshItems];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
//    [self _reloadData];

    if (targetIndex == _items.count - 1) {
        // 延时为了解决点击最后几个cell，scrollToItem会出现位置偏移问题。需要等 reloadData 绘制结束后再滚动
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        });
    } else {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }

    if (!scrolling) {
        CGRect targetItemFrame = [self getItemViewFrame:targetIndex];
        CGFloat lineWidth = _items[targetIndex].lineWidth;
        CGFloat lineX = targetItemFrame.origin.x + (targetItemFrame.size.width - lineWidth)/2.0;
        if (_layout.lineScrollDisable) {
            CGRect frame = self.bottomlineView.frame;
            frame.origin.x = lineX;
            frame.size.width = lineWidth;
            self.bottomlineView.frame = frame;
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = self.bottomlineView.frame;
                frame.origin.x = lineX;
                frame.size.width = lineWidth;
                self.bottomlineView.frame = frame;
            }];
        }
    }
    
    
    [_delegate tabView:self didSelectedItemAtIndex:targetIndex withScrolling:scrolling];
}

- (CGRect)getItemViewFrame:(NSUInteger)index {
    if (index >= _items.count) {
        return CGRectZero;
    }
    CGFloat x = _lrMargin;
    for (int i = 0; i < index; i ++) {
        YXTabItem *item = _items[i];
        x += item.width + _tabMargin;
    }
    CGFloat width = _items[index].width;
    return CGRectMake(x, 0, width, self.bounds.size.height);
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YXTabItemView class]) forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    YXTabItemView *itemView = (YXTabItemView *)cell;
    if ([_delegate respondsToSelector:@selector(tabView:imageForItemAtIndex:)]) {
        itemView.arrowImageView.image = [_delegate tabView:self imageForItemAtIndex:indexPath.item];
    }
    [itemView reloadItem:_items[indexPath.item]];
    
    itemView.hideRedDot = YES;
    for (NSNumber *index in self.showBadgeIndexs) {
        if (indexPath.row == index.integerValue) {
            itemView.hideRedDot = NO;
            return;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectItemAtIndex: indexPath.item];
    [_contentScrollView setContentOffset:CGPointMake(_selectedIndex * _contentScrollView.bounds.size.width, 0) animated:NO];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, _lrMargin, 0, _lrMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YXTabItem *item = _items[indexPath.item];
    return CGSizeMake(item.width, self.bounds.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.tabMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.tabMargin;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
