//
//  ZFCustomizeCollectionLayout.m
//  ZZZZZ
//
//  Created by YW on 2019/6/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCustomizeCollectionLayout.h"
#import "Constants.h"

#define defaultBottomPadding 20

@interface ZFCustomizeCollectionLayout ()

//刷新section视图
@property (nonatomic, assign) NSInteger reloadSection;

///按分区存放的attributes
@property (nonatomic, strong) NSMutableArray *sectionAttributesList;

///所有的attributes
@property (nonatomic, strong) NSMutableArray *allAttributesItemList;

///存储每个section最终bottom
@property (nonatomic, strong) NSMutableArray *columnHeights;

///需要显示在屏幕上的
@property (nonatomic, strong) NSMutableArray *visibleItems;

///存储背景颜色or图片的attributes
@property (nonatomic, strong) NSMutableDictionary *customBackgroundAttributes;

//页眉的布局属性
@property (nonatomic, strong) NSMutableDictionary *supplementaryHeaderViewAttributes;

//页脚的布局属性
@property (nonatomic, strong) NSMutableDictionary *supplementaryFooterViewAttributes;

#pragma mark - 当前显示视图管理

//当前显示的cell
@property (nonatomic, strong) NSMutableDictionary *currentCellAttributes;

//当前显示的页眉，页脚
@property (nonatomic, strong) NSMutableDictionary *currentSupplementaryViewAttributes;

//当前显示的装饰视图
@property (nonatomic, strong) NSMutableDictionary *currentDecorationViewAttributes;

//cache
@property (nonatomic, strong) NSMutableDictionary *cacheCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *cachedSupplementaryAttributesByKind;
#pragma mark - finalizeCollectionViewUpdates 管理
//删除操作的 cell容器
@property (nonatomic, strong) NSMutableArray <NSIndexPath *>*deleteIndexPaths;

//插入操作的 cell容器
@property (nonatomic, strong) NSMutableArray <NSIndexPath *>*insertIndexPaths;

//删除操作的 section容器, 当整个section被删除时，这个容器有值
@property (nonatomic, strong) NSMutableArray *removedSectionIndices;

//插入操作的 section容器, 插入一个section时，这个容器有值
@property (nonatomic, strong) NSMutableArray *insertSectionIndices;

@end

@implementation ZFCustomizeCollectionLayout

- (void)dealloc
{
    YWLog(@"ZFCustomizeCollectionLayout dealloc");
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.reloadSection = -1;
        [self registerClass:[ZFCustomerBackgroundCRView class] forDecorationViewOfKind:CollectionViewSectionBackground];
    }
    return self;
}

-(void)inserSection:(NSInteger)section
{
    _reloadSection = section;
}

-(void)reloadSection:(NSInteger)section
{
    _reloadSection = section;
    
    [self.collectionView reloadData];
}

-(void)prepareLayout
{
    [super prepareLayout];
    NSInteger startSection = 0;
    if (_reloadSection >= 0) {
        __block NSInteger allcount = 0;
        startSection = _reloadSection;
        _reloadSection = -1;
        //获取需要刷新的 attributes count 重新计算
        [self.sectionAttributesList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= startSection) {
                NSArray *list = (NSArray *)obj;
                allcount += [list count];
            }
        }];

        NSInteger sectionNums = [self.dataSource customerLayoutNumsSection:self.collectionView];
        if (sectionNums != self.sectionAttributesList.count) {
            [self resetReloadLayout];
            return;
        }
        NSRange removeAllRange = NSMakeRange(self.allAttributesItemList.count - allcount, allcount);
        
        YWLog(@"allAttributesItemList.count -%ld", self.allAttributesItemList.count);
        YWLog(@"removeAllRange length -%ld, location -%ld", removeAllRange.length, removeAllRange.location);
        //删除需要刷新的所有 attributes
        if ((labs((NSInteger)removeAllRange.length) + labs((NSInteger)removeAllRange.location)) == self.allAttributesItemList.count) {
            [self.allAttributesItemList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeAllRange]];
        } else {
            [self resetReloadLayout];
            return;
        }
        
        NSInteger removeLength = self.sectionAttributesList.count - startSection;
        if (removeLength < 0) {
            [self resetReloadLayout];
            return;
        }
        
        //删除装饰视图
        for (NSInteger i = startSection; i < self.customBackgroundAttributes.allKeys.count; i++) {
            [self.customBackgroundAttributes removeObjectForKey:[NSString stringWithFormat:@"%d", (int)i]];
        }
        
        //删除页眉视图
        for (NSInteger i = startSection; i < self.supplementaryHeaderViewAttributes.allKeys.count; i++) {
            [self.supplementaryHeaderViewAttributes removeObjectForKey:@(i)];
        }
        
        //删除页脚视图
        for (NSInteger i = startSection; i < self.supplementaryFooterViewAttributes.allKeys.count; i++) {
            [self.supplementaryFooterViewAttributes removeObjectForKey:@(i)];
        }
        
        NSRange removeRange = NSMakeRange(startSection, removeLength);
        YWLog(@"attributesList.count -%ld", self.sectionAttributesList.count);
        YWLog(@"removeRange length -%ld, location -%ld", removeRange.length, removeRange.location);
        //删除分区 attributes item
        if ((labs((NSInteger)removeRange.length) + labs((NSInteger)removeRange.location)) == self.sectionAttributesList.count) {
            [self.sectionAttributesList removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeRange]];
        } else {
            [self resetReloadLayout];
            return;
        }
        
        NSRange columnHeightRemoveRange = NSMakeRange(startSection, self.columnHeights.count - startSection);
        YWLog(@"columnHeights.count -%ld", self.columnHeights.count);
        YWLog(@"columnHeightRemoveRange length -%ld, location -%ld", columnHeightRemoveRange.length, columnHeightRemoveRange.location);
        //删除保存section 高度的 attributes item
        if ((labs((NSInteger)columnHeightRemoveRange.length) + labs((NSInteger)columnHeightRemoveRange.location)) == self.columnHeights.count) {
            [self.columnHeights removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:columnHeightRemoveRange]];
        } else {
            [self resetReloadLayout];
            return;
        }

        [self.visibleItems removeAllObjects];
    }else{
        [self.sectionAttributesList removeAllObjects];
        [self.allAttributesItemList removeAllObjects];
        [self.columnHeights removeAllObjects];
        [self.visibleItems removeAllObjects];
        [self.customBackgroundAttributes removeAllObjects];
        [self.supplementaryHeaderViewAttributes removeAllObjects];
        [self.supplementaryFooterViewAttributes removeAllObjects];
    }
    
    self.cacheCellAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.currentCellAttributes copyItems:YES];
    self.cachedSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    [self.currentSupplementaryViewAttributes enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSMutableDictionary * attribByPath, BOOL *stop) {
        NSMutableDictionary * cachedAttribByPath = [[NSMutableDictionary alloc] initWithDictionary:attribByPath copyItems:YES];
        [self.cachedSupplementaryAttributesByKind setObject:cachedAttribByPath forKey:kind];
    }];
    NSInteger sections = [self.collectionView numberOfSections];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(customerLayoutDatasource:sectionNum:)]) {
        for (NSInteger i = startSection; i < sections; i++) {
            
            id <ZFCollectionSectionProtocol> sectionModule = [self.dataSource customerLayoutDatasource:self.collectionView sectionNum:i];
            
            //section header
            CGFloat sectionHeight = 0;
            NSMutableArray *sectionAttributes = [[NSMutableArray alloc] init];
            if ([self.dataSource respondsToSelector:@selector(customerLayoutSectionHeightHeight:layout:indexPath:)]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                sectionHeight = [self.dataSource customerLayoutSectionHeightHeight:self.collectionView layout:self indexPath:indexPath];
                if (sectionHeight) {
                    //section header
                    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CustomerLayoutHeader withIndexPath:indexPath];
                    CGFloat lastSectionHeight = [[self.columnHeights lastObject] floatValue];
                    headerAttributes.frame = CGRectMake(0, lastSectionHeight, self.collectionView.frame.size.width, sectionHeight);
                    [self.allAttributesItemList addObject:headerAttributes];
                    sectionHeight = CGRectGetMaxY(headerAttributes.frame);
                    [self.supplementaryHeaderViewAttributes setObject:headerAttributes forKey:@(indexPath.section)];
                }
            }
            
            //获取上一个section的bottom
            CGFloat lastSectionHeight = MAX(sectionHeight, [[self.columnHeights lastObject] floatValue]);
            
            NSArray *sectionAttributelist = [sectionModule childRowsCalculateFramesWithBottomOffset:lastSectionHeight section:i];
            [sectionAttributes addObjectsFromArray:sectionAttributelist];
            [self.allAttributesItemList addObjectsFromArray:sectionAttributes];

            //自定义背景section attributes
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(customerLayoutSectionAttributes:layout:indexPath:)]) {
                CustomerBackgroundAttributes *cusSectionAttributes = [self.dataSource customerLayoutSectionAttributes:self.collectionView layout:self indexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                if (cusSectionAttributes) {
                    cusSectionAttributes.frame = CGRectMake(0, lastSectionHeight, self.collectionView.frame.size.width, [sectionModule sectionBottom] - lastSectionHeight - cusSectionAttributes.bottomOffset);
                    cusSectionAttributes.zIndex = -1;
                    [self.customBackgroundAttributes setObject:cusSectionAttributes forKey:@(i)];
                    [self.allAttributesItemList addObject:cusSectionAttributes];
                }
            }
            
            self.columnHeights[i] = @([sectionModule sectionBottom]);
            
            //section footer
            CGFloat sectionFooter = 0;
            if ([self.dataSource respondsToSelector:@selector(customerLayoutSectionFooterHeight:layout:indexPath:)]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:i];
                sectionFooter = [self.dataSource customerLayoutSectionFooterHeight:self.collectionView layout:self indexPath:indexPath];
                if (sectionFooter) {
                    //section footer
                    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CustomerLayoutFooter withIndexPath:indexPath];
                    CGFloat lastSectionHeight = [[self.columnHeights lastObject] floatValue];
                    headerAttributes.frame = CGRectMake(0, lastSectionHeight, self.collectionView.frame.size.width, sectionFooter);
                    [self.allAttributesItemList addObject:headerAttributes];
                    self.columnHeights[i] = @(CGRectGetMaxY(headerAttributes.frame));
                    [self.supplementaryFooterViewAttributes setObject:headerAttributes forKey:@(indexPath.section)];
                }
            }
            
            lastSectionHeight = MAX(sectionFooter, [[self.columnHeights lastObject] floatValue]);
            
            [self.sectionAttributesList addObject:sectionAttributes];
        }
    }
    
    NSInteger idx = 0;
    NSInteger itemCounts = [self.allAttributesItemList count];
    while (idx < itemCounts) {
        CGRect rect1 = ((UICollectionViewLayoutAttributes *)self.allAttributesItemList[idx]).frame;
        idx = MIN(idx + defaultBottomPadding, itemCounts) - 1;
        CGRect rect2 = ((UICollectionViewLayoutAttributes *)self.allAttributesItemList[idx]).frame;
        [self.visibleItems addObject:[NSValue valueWithCGRect:CGRectUnion(rect1, rect2)]];
        idx++;
    }
    
    if ([self.sectionAttributesList count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(customerLayoutDidLayoutDone)]) {
            [self.delegate customerLayoutDidLayoutDone];
        }
    }
}

//完整刷新
- (void)resetReloadLayout
{
    _reloadSection = -1;
    [self prepareLayout];
}

#pragma mark - super method

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger i;
    NSInteger begin = 0, end = self.visibleItems.count;
    NSMutableArray *attrs = [NSMutableArray array];

    for (i = 0; i < self.visibleItems.count; i++) {
        if (CGRectIntersectsRect(rect, [self.visibleItems[i] CGRectValue])) {
            begin = i * defaultBottomPadding;
            break;
        }
    }
    for (i = self.visibleItems.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.visibleItems[i] CGRectValue])) {
            end = MIN((i + 1) * defaultBottomPadding, self.allAttributesItemList.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allAttributesItemList[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    [attrs enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            //保存当前显示的cell
            [self.currentCellAttributes setObject:attributes forKey:attributes.indexPath];
        }
        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
            //保存当前显示的footer or header
            NSMutableDictionary *supplementaryAttribuesByIndexPath = [self.currentSupplementaryViewAttributes objectForKey:attributes.representedElementKind];
            if (supplementaryAttribuesByIndexPath == nil)
            {
                supplementaryAttribuesByIndexPath = [NSMutableDictionary dictionary];
                [self.currentSupplementaryViewAttributes setObject:supplementaryAttribuesByIndexPath forKey:attributes.representedElementKind];
            }
            
            [supplementaryAttribuesByIndexPath setObject:attributes
                                                  forKey:attributes.indexPath];
        }
        if (attributes.representedElementCategory == UICollectionElementCategoryDecorationView) {
            //保存当前显示的装饰视图
            [self.currentDecorationViewAttributes setObject:attributes forKey:attributes.indexPath];
        }
    }];
    
    return [NSArray arrayWithArray:attrs];
}

//当系统没有获取到cell正确的attributes时，会回调这个方法，获取一个正确indexPath的attribues
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [self.sectionAttributesList count]) {
        return nil;
    }
    if (indexPath.item >= [self.sectionAttributesList[indexPath.section] count]) {
        return nil;
    }
    UICollectionViewLayoutAttributes *attributes = self.sectionAttributesList[indexPath.section][indexPath.item];
    return attributes;
}

//当系统没有获取到header or footer正确的attributes时，会回调这个方法，获取一个正确indexPath的attribues
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
//    if ([elementKind isEqualToString:CustomerLayoutHeader] && indexPath) {
//        attributes = self.supplementaryHeaderViewAttributes[@(indexPath.section)];
//    }
//    if ([elementKind isEqualToString:CustomerLayoutFooter] && indexPath) {
//        attributes = self.supplementaryFooterViewAttributes[@(indexPath.section)];
//    }
    attributes = [[self.currentSupplementaryViewAttributes objectForKey:elementKind] objectForKey:indexPath];
    return attributes;
}

//当系统没有获取装饰视图正确的attributes时，会回调这个方法，获取一个正确indexPath的attribues
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
    if ([elementKind isEqualToString:CollectionViewSectionBackground]) {
        attributes = self.customBackgroundAttributes[@(indexPath.section)];
    }
    return attributes;
}

// 返回collectionView的ContentSize
- (CGSize)collectionViewContentSize
{
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = [[self.columnHeights lastObject] floatValue];
    
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds) ||
        CGRectGetHeight(newBounds) != CGRectGetHeight(oldBounds)) {
        return YES;
    }
    return NO;
}

#pragma mark - collection update animation method

//开始动画的更新回调
- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.updateAction == UICollectionUpdateActionDelete) {
            if (obj.indexPathBeforeUpdate.item == NSNotFound)
            {
                //保存当前操作的section
                [self.removedSectionIndices addObject:@(obj.indexPathBeforeUpdate.section)];
            } else {
                //保存当前操作的cell
                [self.deleteIndexPaths addObject:obj.indexPathBeforeUpdate];
            }
        } else if (obj.updateAction == UICollectionUpdateActionInsert) {
            if (obj.indexPathAfterUpdate.item == NSNotFound) {
                //保存当前操作的section
                [self.insertSectionIndices addObject:@(obj.indexPathAfterUpdate.section)];
            } else {
                //保存当前操作的cell
                [self.insertIndexPaths addObject:obj.indexPathAfterUpdate];
            }
        }
    }];
}

//更新结束后的回调
- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    self.insertIndexPaths = nil;
    self.deleteIndexPaths = nil;
    self.removedSectionIndices = nil;
    self.insertSectionIndices = nil;
}

//插入一个cell or section时，回调一个动画效果
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertIndexPaths containsObject:itemIndexPath]) {
        attributes = [[self.sectionAttributesList objectAtIndex:itemIndexPath.section][itemIndexPath.row] copy];
        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    } else if ([self.insertSectionIndices containsObject:@(itemIndexPath.section)]) {
        attributes = [[self.sectionAttributesList objectAtIndex:itemIndexPath.section][itemIndexPath.row] copy];
        attributes.transform3D = CATransform3DMakeTranslation(-self.collectionView.bounds.size.width, 0, 0);
    }
    return attributes;
}

//删除一个cell or section时，回调一个动画效果
- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.deleteIndexPaths containsObject:itemIndexPath] || [self.removedSectionIndices containsObject:@(itemIndexPath.section)])
    {
        attributes = [[self.cacheCellAttributes objectForKey:itemIndexPath] copy];
        attributes.frame = CGRectMake(-attributes.frame.size.width, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height);
        attributes.zIndex = -999;
        attributes.alpha = 0.0f;
    }
    return attributes;
}

//插入一个collection header or footer时，回调一个动画效果
- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
    if ([self.insertSectionIndices containsObject:@(elementIndexPath.section)]) {
        attributes = [[[self.currentSupplementaryViewAttributes objectForKey:elementKind] objectForKey:elementIndexPath] copy];
        attributes.alpha = 1.0;
    }
    else {
        NSIndexPath *prevPath = [self previousIndexPathForIndexPath:elementIndexPath accountForItems:NO];
        attributes = [[[self.cachedSupplementaryAttributesByKind objectForKey:elementKind] objectForKey:prevPath] copy];
    }
    return attributes;
}

//删除一个collection header or footer时，回调一个动画效果
- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
    
    if ([self.removedSectionIndices containsObject:@(elementIndexPath.section)]) {
        // Make it fall off the screen with a slight rotation
        attributes = [[[self.cachedSupplementaryAttributesByKind objectForKey:elementKind] objectForKey:elementIndexPath] copy];
        CATransform3D transform = CATransform3DMakeTranslation(0, self.collectionView.bounds.size.height, 0);
        transform = CATransform3DRotate(transform, M_PI*0.2, 0, 0, 1);
        attributes.transform3D = transform;
        attributes.alpha = 0.0f;
    }
    return attributes;
}

//插入一个装饰视图时，回调一个动画效果
- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingDecorationElementOfKind:elementKind atIndexPath:decorationIndexPath];
    if ([self.insertSectionIndices containsObject:@(decorationIndexPath.section)]) {
        attributes = [[self.currentDecorationViewAttributes objectForKey:decorationIndexPath] copy];
        attributes.alpha = 1.0;
    }
    return attributes;
}

//删除一个装饰视图时，回调一个动画效果
- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:decorationIndexPath];
    if ([self.removedSectionIndices containsObject:@(decorationIndexPath.section)]) {
        attributes = [[self.currentDecorationViewAttributes objectForKey:decorationIndexPath] copy];
        attributes.alpha = 0.0f;
    }
    return attributes;
}

#pragma mark - Helpers

- (NSIndexPath*)previousIndexPathForIndexPath:(NSIndexPath *)indexPath accountForItems:(BOOL)checkItems
{
    __block NSInteger section = indexPath.section;
    __block NSInteger item = indexPath.item;
    
    [self.removedSectionIndices enumerateObjectsUsingBlock:^(NSNumber *rmSectionIdx, NSUInteger idx, BOOL *stop) {
        if ([rmSectionIdx integerValue] <= section)
        {
            section++;
        }
    }];
    
    if (checkItems)
    {
        [self.deleteIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *rmIndexPath, NSUInteger idx, BOOL *stop) {
            if ([rmIndexPath section] == section && [rmIndexPath item] <= item)
            {
                item++;
            }
        }];
    }
    
    [self.insertSectionIndices enumerateObjectsUsingBlock:^(NSNumber *insSectionIdx, NSUInteger idx, BOOL *stop) {
        if ([insSectionIdx integerValue] < [indexPath section])
        {
            section--;
        }
    }];
    
    if (checkItems)
    {
        [self.insertIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *insIndexPath, NSUInteger idx, BOOL *stop) {
            if ([insIndexPath section] == [indexPath section] && [insIndexPath item] < [indexPath item])
            {
                item--;
            }
        }];
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

////插入collection header or footer 回调
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind
//{
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//    if ([elementKind isEqualToString:CustomerLayoutHeader]) {
//        [self.insertSectionIndices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            UICollectionViewLayoutAttributes *attributes = self.supplementaryHeaderViewAttributes[obj];
//            if (attributes) {
//                [indexPaths addObject:attributes.indexPath];
//            }
//        }];
//    }
//    if ([elementKind isEqualToString:CustomerLayoutFooter]) {
//        [self.insertSectionIndices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            UICollectionViewLayoutAttributes *attributes = self.supplementaryFooterViewAttributes[obj];
//            if (attributes) {
//                [indexPaths addObject:attributes.indexPath];
//            }
//        }];
//    }
//    return indexPaths.copy;
//}
//
////删除collection header or footer 回调
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind
//{
//    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
//    if ([elementKind isEqualToString:CustomerLayoutHeader]) {
//        [self.removedSectionIndices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            UICollectionViewLayoutAttributes *attributes = self.currentDecorationViewAttributes[obj];
//            if (attributes) {
//                [indexPaths addObject:attributes.indexPath];
//            }
//        }];
//    }
//    if ([elementKind isEqualToString:CustomerLayoutFooter]) {
//        [self.removedSectionIndices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            UICollectionViewLayoutAttributes *attributes = self.currentDecorationViewAttributes[obj];
//            if (attributes) {
//                [indexPaths addObject:attributes.indexPath];
//            }
//        }];
//    }
//    return indexPaths.copy;
//}

////插入装饰视图回调
//- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind
//{
//    NSMutableArray *indexPaths = [[super indexPathsToInsertForDecorationViewOfKind:elementKind] mutableCopy];
//    if (!indexPaths) {
//        indexPaths = [[NSMutableArray alloc] init];
//    }
//    if ([elementKind isEqualToString:CollectionViewSectionBackground]) {
//        [self.insertSectionIndices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            CustomerBackgroundAttributes *attributes = self.customBackgroundAttributes[obj];
//            if (attributes) {
//                [indexPaths addObject:attributes.indexPath];
//            }
//        }];
//    }
//    return indexPaths.copy;
//}
//
////删除装饰视图回调
//- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind
//{
//    NSMutableArray *indexPaths = [[super indexPathsToDeleteForDecorationViewOfKind:elementKind] mutableCopy];
//    if (!indexPaths) {
//        indexPaths = [[NSMutableArray alloc] init];
//    }
//    if ([elementKind isEqualToString:CollectionViewSectionBackground]) {
//        [self.removedSectionIndices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            CustomerBackgroundAttributes *attributes = self.customBackgroundAttributes[obj];
//            if (attributes) {
//                [indexPaths addObject:attributes.indexPath];
//            }
//        }];
//    }
//    return indexPaths.copy;
//}

#pragma mark - Property Method

-(NSMutableArray *)sectionAttributesList
{
    if (!_sectionAttributesList) {
        _sectionAttributesList = [[NSMutableArray alloc] init];
    }
    return _sectionAttributesList;
}

-(NSMutableArray *)allAttributesItemList
{
    if (!_allAttributesItemList) {
        _allAttributesItemList = [[NSMutableArray alloc] init];
    }
    return _allAttributesItemList;
}

-(NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [[NSMutableArray alloc] init];
    }
    return _columnHeights;
}

-(NSMutableArray *)visibleItems
{
    if (!_visibleItems) {
        _visibleItems = [[NSMutableArray alloc] init];
    }
    return _visibleItems;
}

-(NSMutableDictionary *)customBackgroundAttributes
{
    if (!_customBackgroundAttributes) {
        _customBackgroundAttributes = [[NSMutableDictionary alloc] init];
    }
    return _customBackgroundAttributes;
}

- (NSMutableArray <NSIndexPath *>*)deleteIndexPaths
{
    if (!_deleteIndexPaths) {
        _deleteIndexPaths = [[NSMutableArray alloc] init];
    }
    return _deleteIndexPaths;
}

- (NSMutableArray *)insertIndexPaths
{
    if (!_insertIndexPaths) {
        _insertIndexPaths = [[NSMutableArray alloc] init];
    }
    return _insertIndexPaths;
}

- (NSMutableArray *)removedSectionIndices
{
    if (!_removedSectionIndices) {
        _removedSectionIndices = [[NSMutableArray alloc] init];
    }
    return _removedSectionIndices;
}

- (NSMutableArray *)insertSectionIndices
{
    if (!_insertSectionIndices) {
        _insertSectionIndices = [[NSMutableArray alloc] init];
    }
    return _insertSectionIndices;
}

- (NSMutableDictionary *)currentCellAttributes
{
    if (!_currentCellAttributes) {
        _currentCellAttributes = [[NSMutableDictionary alloc] init];
    }
    return _currentCellAttributes;
}

- (NSMutableDictionary *)supplementaryHeaderViewAttributes
{
    if (!_supplementaryHeaderViewAttributes) {
        _supplementaryHeaderViewAttributes = [[NSMutableDictionary alloc] init];
    }
    return _supplementaryHeaderViewAttributes;
}

- (NSMutableDictionary *)supplementaryFooterViewAttributes
{
    if (!_supplementaryFooterViewAttributes) {
        _supplementaryFooterViewAttributes = [[NSMutableDictionary alloc] init];
    }
    return _supplementaryFooterViewAttributes;
}

- (NSMutableDictionary *)currentSupplementaryViewAttributes
{
    if (!_currentSupplementaryViewAttributes) {
        _currentSupplementaryViewAttributes = [[NSMutableDictionary alloc] init];
    }
    return _currentSupplementaryViewAttributes;
}

- (NSMutableDictionary *)currentDecorationViewAttributes
{
    if (!_currentDecorationViewAttributes) {
        _currentDecorationViewAttributes = [[NSMutableDictionary alloc] init];
    }
    return _currentDecorationViewAttributes;
}


@end
