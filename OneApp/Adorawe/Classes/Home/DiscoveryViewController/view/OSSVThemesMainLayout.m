//
//  OSSVThemesMainLayout.m
//  OSSVThemesMainLayout
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVThemesMainLayout.h"
#import "OSSVWaterrFallViewMould.h"
#import "OSSVMultiColumnsGoodItemsViewMould.h"

#define defaultBottomPadding 20

@interface OSSVThemesMainLayout ()

///按分区存放的attributes
@property (nonatomic, strong) NSMutableArray *attributesListArray;

///所有的attributes
@property (nonatomic, strong) NSMutableArray *allAttributesItemListArray;


///需要显示在屏幕上的
@property (nonatomic, strong) NSMutableArray *visibleItemsArr;

@property (nonatomic, strong) NSMutableDictionary *headerSectionHeightDic;

@property (nonatomic, strong) NSMutableDictionary *footerSectionHeightDic;

@property (nonatomic, assign) NSInteger reloadSection;

@end

@implementation OSSVThemesMainLayout

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.reloadSection = -1;
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
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    NSInteger startSection = 0;
    if (_reloadSection >= 0) {
        __block NSInteger allcount = 0;
        startSection = _reloadSection;
        _reloadSection = -1;
        
        NSMutableArray *temp = [self.attributesListArray mutableCopy];
        [temp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= startSection) {
                NSArray *list = (NSArray *)obj;
                allcount += [list count];
            }
        }];
        
        NSRange removeAllRange = NSMakeRange(self.allAttributesItemListArray.count - allcount, allcount);
        
        NSInteger allListCount = self.allAttributesItemListArray.count;
        NSInteger allDeleteLength = removeAllRange.location + removeAllRange.length;
        if (self.allAttributesItemListArray.count < allDeleteLength) {
            if (removeAllRange.location > allListCount) {
                removeAllRange.location = allListCount;
            }
            removeAllRange = NSMakeRange(removeAllRange.location, allListCount - removeAllRange.location);
        }
        
        [self.allAttributesItemListArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeAllRange]];
        
        NSInteger len = self.attributesListArray.count - startSection;
        NSRange removeRange = NSMakeRange(startSection, len > 0 ? len : 0);
        
        NSInteger listCount = self.attributesListArray.count;
        NSInteger deleteLength = removeRange.location + removeRange.length;
        if (self.attributesListArray.count < deleteLength) {
            if (removeRange.location > listCount) {
                startSection = listCount;
            }
            removeRange = NSMakeRange(startSection, listCount - startSection);
        }
        [self.attributesListArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:removeRange]];
        
        NSRange columnHeightRemoveRange = NSMakeRange(startSection, self.columnHeightsArray.count - startSection);
        
        [self.columnHeightsArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:columnHeightRemoveRange]];
        
        [self.visibleItemsArr removeAllObjects];
    }else{
        [self.attributesListArray removeAllObjects];
        [self.allAttributesItemListArray removeAllObjects];
        [self.columnHeightsArray removeAllObjects];
        [self.visibleItemsArr removeAllObjects];
        [self.headerSectionHeightDic removeAllObjects];
        [self.footerSectionHeightDic removeAllObjects];
    }
    
    NSInteger sections = [self.collectionView numberOfSections];
    
    id lastSectionModule = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(customerLayoutDatasource:sectionNum:)]) {
        for (NSInteger i = startSection; i < sections; i++) {
            
            id <CustomerLayoutSectionModuleProtocol> sectionModule = [self.dataSource customerLayoutDatasource:self.collectionView sectionNum:i];
            
            CGFloat sectionHeight = 0;
            NSMutableArray *sectionAttributes = [[NSMutableArray alloc] init];
            if ([self.dataSource respondsToSelector:@selector(customerLayoutSectionHeightHeight:layout:indexPath:)]) {
                sectionHeight = [self.dataSource customerLayoutSectionHeightHeight:self.collectionView layout:self indexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                if (sectionHeight) {
                    //section header
                    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CustomerLayoutHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                    CGFloat lastSectionHeight = [[self.columnHeightsArray lastObject] floatValue];
                    headerAttributes.frame = CGRectMake(0, lastSectionHeight, self.collectionView.frame.size.width, sectionHeight);
                    [self.allAttributesItemListArray addObject:headerAttributes];
                    self.headerSectionHeightDic[@(i)] = @(sectionHeight);
                    sectionHeight = CGRectGetMaxY(headerAttributes.frame);
                }
            }
            
            //获取上一个section的bottom
            CGFloat lastSectionHeight = MAX(sectionHeight, [[self.columnHeightsArray lastObject] floatValue]);
            
            if (self.showBottomsGoodsSeparate && [sectionModule isMemberOfClass:[OSSVWaterrFallViewMould class]]) {
                if (!lastSectionModule || ![lastSectionModule isMemberOfClass:[OSSVWaterrFallViewMould class]]) {
                    lastSectionHeight += kPadding;
                }
            }
            
            if (self.showBottomsGoodsSeparate && [sectionModule isMemberOfClass:[OSSVMultiColumnsGoodItemsViewMould class]]) {
                if (!lastSectionModule || ![lastSectionModule isMemberOfClass:[OSSVMultiColumnsGoodItemsViewMould class]]) {
                    lastSectionHeight += kPadding;
                }
            }
            
            NSArray *sectionAttributelist = [sectionModule childRowsCalculateFramesWithBottomOffset:lastSectionHeight section:i];
            [sectionAttributes addObjectsFromArray:sectionAttributelist];
            
            // [__NSArrayM setObject:atIndexedSubscript:] + 640 (NSArrayM.m:424) 这个可能触发崩溃
            //self.columnHeightsArray[100] = @([sectionModule sectionBottom]);

            self.columnHeightsArray[i] = @([sectionModule sectionBottom]);
 
            CGFloat sectionFooter = 0;
            if ([self.dataSource respondsToSelector:@selector(customerLayoutSectionFooterHeight:layout:indexPath:)]) {
                sectionFooter = [self.dataSource customerLayoutSectionFooterHeight:self.collectionView layout:self indexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                if (sectionFooter) {
                    //section footer
                    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CustomerLayoutFooter withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
                    CGFloat lastSectionHeight = [[self.columnHeightsArray lastObject] floatValue];
                    headerAttributes.frame = CGRectMake(0, lastSectionHeight, self.collectionView.frame.size.width, sectionFooter);
                    [self.allAttributesItemListArray addObject:headerAttributes];
                    self.footerSectionHeightDic[@(i)] = @(sectionFooter);
                    self.columnHeightsArray[i] = @(CGRectGetMaxY(headerAttributes.frame));
                }
            }
            
            lastSectionHeight = MAX(sectionFooter, [[self.columnHeightsArray lastObject] floatValue]);

            [self.attributesListArray addObject:sectionAttributes];
            [self.allAttributesItemListArray addObjectsFromArray:sectionAttributes];
            
            lastSectionModule = sectionModule;
        }
    }
    
    NSInteger idx = 0;
    NSInteger itemCounts = [self.allAttributesItemListArray count];
    while (idx < itemCounts) {
        CGRect rect1 = ((UICollectionViewLayoutAttributes *)self.allAttributesItemListArray[idx]).frame;
        idx = MIN(idx + defaultBottomPadding, itemCounts) - 1;
        CGRect rect2 = ((UICollectionViewLayoutAttributes *)self.allAttributesItemListArray[idx]).frame;
        [self.visibleItemsArr addObject:[NSValue valueWithCGRect:CGRectUnion(rect1, rect2)]];
        idx++;
    }
    
    if ([self.attributesListArray count]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(customerLayoutDidLayoutDone)]) {
            [self.delegate customerLayoutDidLayoutDone];
        }
    }
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger i;
    NSInteger begin = 0, end = self.visibleItemsArr.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.visibleItemsArr.count; i++) {
        if (CGRectIntersectsRect(rect, [self.visibleItemsArr[i] CGRectValue])) {
            begin = i * defaultBottomPadding;
            break;
        }
    }
    for (i = self.visibleItemsArr.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.visibleItemsArr[i] CGRectValue])) {
            end = MIN((i + 1) * defaultBottomPadding, self.allAttributesItemListArray.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allAttributesItemListArray[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [self.attributesListArray count]) {
        return nil;
    }
    if (indexPath.item >= [self.attributesListArray[indexPath.section] count]) {
        return nil;
    }
    UICollectionViewLayoutAttributes *attributes = self.attributesListArray[indexPath.section][indexPath.item];
    return attributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = nil;
    if ([elementKind isEqualToString:CustomerLayoutHeader]) {
        attributes = self.headerSectionHeightDic[@(indexPath.section)];
    }
    if ([elementKind isEqualToString:CustomerLayoutFooter]) {
        attributes = self.footerSectionHeightDic[@(indexPath.section)];
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
    contentSize.height = [[self.columnHeightsArray lastObject] floatValue];
    
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

-(CGFloat)customerLastSectionFirstViewTop
{    
    NSInteger section = -1;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(customerLayoutThemeMenusSection:)]) {
        section = [self.dataSource customerLayoutThemeMenusSection:self.collectionView];
    }
    if (section < 0) {
        section = 0;
    }
    
    if (self.attributesListArray.count > section) {
        NSArray *attributesRows = self.attributesListArray[section];
        UICollectionViewLayoutAttributes *attributes = [attributesRows firstObject];
        return CGRectGetMinY(attributes.frame);
    }
    return 0;
}

- (CGRect)customerSectionFirstAttribute:(NSInteger)section
{
    if ([self.attributesListArray count]) {
        NSInteger count = [self.attributesListArray count];
        if (section < count) {
            NSArray *attributesRows = self.attributesListArray[section];
            UICollectionViewLayoutAttributes *attributes = [attributesRows firstObject];
            return attributes.frame;
        }
        return CGRectZero;
    }
    return CGRectZero;
}


-(NSMutableArray *)attributesListArray
{
    if (!_attributesListArray) {
        _attributesListArray = [[NSMutableArray alloc] init];
    }
    return _attributesListArray;
}

-(NSMutableArray *)allAttributesItemListArray
{
    if (!_allAttributesItemListArray) {
        _allAttributesItemListArray = [[NSMutableArray alloc] init];
    }
    return _allAttributesItemListArray;
}

-(NSMutableArray *)columnHeightsArray
{
    if (!_columnHeightsArray) {
        _columnHeightsArray = [[NSMutableArray alloc] init];
    }
    return _columnHeightsArray;
}

-(NSMutableArray *)visibleItemsArr
{
    if (!_visibleItemsArr) {
        _visibleItemsArr = [[NSMutableArray alloc] init];
    }
    return _visibleItemsArr;
}

-(NSMutableDictionary *)headerSectionHeightDic
{
    if (!_headerSectionHeightDic) {
        _headerSectionHeightDic = [[NSMutableDictionary alloc] init];
    }
    return _headerSectionHeightDic;
}

-(NSMutableDictionary *)footerSectionHeightDic
{
    if (!_footerSectionHeightDic) {
        _footerSectionHeightDic = [[NSMutableDictionary alloc] init];
    }
    return _footerSectionHeightDic;
}

@end
