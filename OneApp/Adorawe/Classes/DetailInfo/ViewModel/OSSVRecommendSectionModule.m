//
//  OSSVRecommendSectionModule.m
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVRecommendSectionModule.h"
#import "OSSVDetailRecommendCell.h"
#import "OSSVCustomMathTool.h"

@interface OSSVRecommendSectionModule ()

@property (nonatomic, assign) CGFloat bottomOffset;

@property (nonatomic, strong) NSMutableArray *columnHeights;

@end

@implementation OSSVRecommendSectionModule
@synthesize sectionDataSource = _sectionDataSource;
@synthesize registerKeys = _registerKeys;
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize minimumLineSpacing = _minimumLineSpacing;
@synthesize lineRows = _lineRows;
@synthesize sectionInset = _sectionInset;
@synthesize sectionType = _sectionType;
- (NSMutableArray<id<OSSVCollectionCellDatasourceProtocol>> *)sectionDataSource
{
    if (!_sectionDataSource) {
        _sectionDataSource = [[NSMutableArray alloc] init];
    }
    return _sectionDataSource;
}

- (NSMutableArray *)registerKeys
{
    if (!_registerKeys) {
        _registerKeys = [[NSMutableArray alloc] init];
    }
    return _registerKeys;
}

- (CGFloat)minimumLineSpacing
{
    if (_minimumLineSpacing) {
        return _minimumLineSpacing;
    }
    return 0;
}

- (CGFloat)minimumInteritemSpacing
{
    if (_minimumInteritemSpacing) {
        return _minimumInteritemSpacing;
    }
    return 0;
}
- (STLGoodsDetailSectionType)sectionType {
    return _sectionType;
}
-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSInteger rows = [self.sectionDataSource count];
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:rows];
    
    
    
    [self.columnHeights removeAllObjects];
    
    for (int i = 0; i < KColumnIndex2; i++) {
        [self.columnHeights addObject:@(bottomoffset)];
    }
    
//    CGFloat width = floor((screenWidth - (self.lineRows + 1) * self.minimumLineSpacing) / self.lineRows);
//
//    CGFloat height = width * 1.35 + 25;
 
    CGFloat width = kGoodsWidth;
    
    CGFloat height = width * 1.35 + 25;
    
    BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];
    CGFloat emptyContentH = rows > 0 ? 0 : self.contentHeight;
    self.bottomOffset = bottomoffset + emptyContentH;//init value
    for (int i = 0; i < rows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        OSSVGoodsListModel *oneModel = self.sectionDataSource[indexPath.item];
        OSSVGoodsListModel *twoModel = nil;
        NSInteger count = indexPath.row % 2;
        if (count == 0) {
            if (self.sectionDataSource.count > indexPath.item+1) {
                twoModel = self.sectionDataSource[indexPath.row+1];
            }
        } else {
            if (indexPath.row > 0) {
                twoModel = self.sectionDataSource[indexPath.item-1];
            }
        }
        
        height = [OSSVDetailRecommendCell recommendItemRowHeightForGoodsDetailsOneModel:oneModel twoModel:twoModel];

//        height = [OSSVDetailRecommendCell recommendItemRowHeightForGoodsDetailsRecommendArrayModel:self.sectionDataSource[indexPath.item]];
//        return CGSizeMake(kGoodsWidth, height);
        
//        CGFloat offsetY = 0;
//        CGFloat offsetX = 0;
//
//        BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];
//        NSInteger ver = i / self.lineRows;
//        NSInteger hor = i % self.lineRows;
//        offsetX = hor * (width + self.minimumLineSpacing) +  self.minimumLineSpacing;
//        offsetY = ver * (height + self.minimumInteritemSpacing) + bottomoffset;
//        if (rightToLeft) {
//            //从右往左布局
//            offsetX = screenWidth - offsetX - width;
//        }
//        attributes.frame = CGRectMake(offsetX, offsetY, width, height);
//        self.bottomOffset = CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
//        [attributeList addObject:attributes];
                
        NSUInteger columnHeightIndex = [OSSVCustomMathTool shortestColumnIndex:self.columnHeights];
        
        CGFloat xOffset = kPadding + (width + kPadding) * columnHeightIndex;
        
        if (rightToLeft) {
            xOffset = SCREEN_WIDTH - xOffset - width;
        }
        
        CGFloat yOffset = [self.columnHeights[columnHeightIndex] floatValue];
        
        if (self.isTopSpace && (i < KColumnIndex2)) {
            yOffset += kPadding;
        }
        attributes.frame = CGRectMake(xOffset, yOffset, width, height);
        
        self.columnHeights[columnHeightIndex] = @(CGRectGetMaxY(attributes.frame) + kBottomPadding);
        CGFloat targetH =  CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
        self.bottomOffset = MAX(self.bottomOffset,targetH);
        [attributeList addObject:attributes];
    }
    
    return attributeList.copy;
}

-(CGFloat)sectionBottom
{
    return self.bottomOffset;
}


-(NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [[NSMutableArray alloc] init];
    }
    return _columnHeights;
}
//获取一个setion的背景视图，用于设置section背景视图颜色
//- (CustomerBackgroundAttributes *)gainCustomeSetionBackgroundAttributes:(NSIndexPath *)indexPath
//{
//    CustomerBackgroundAttributes *attri = [CustomerBackgroundAttributes layoutAttributesForDecorationViewOfKind:@"CollectionViewSectionBackground" withIndexPath:indexPath];
//    attri.backgroundColor = [UIColor whiteColor];
//    return attri;
//}
@end
