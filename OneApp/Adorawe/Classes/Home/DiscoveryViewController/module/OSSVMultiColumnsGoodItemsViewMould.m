//
//  OSSVMultiColumnsGoodItemsViewMould.m
// XStarlinkProject
//
//  Created by odd on 2021/1/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMultiColumnsGoodItemsViewMould.h"

@interface OSSVMultiColumnsGoodItemsViewMould ()

@property (nonatomic, strong) NSMutableArray *columnHeights;

@end

@implementation OSSVMultiColumnsGoodItemsViewMould
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize sectionDataList = _sectionDataList;
@synthesize discoverBlockModel = _discoverBlockModel;

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.sectionDataList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:0];
    
    NSInteger rows = [self rowsNumInSection];
    
    [self.columnHeights removeAllObjects];
    
    for (int i = 0; i < KColumnIndex3; i++) {
        [self.columnHeights addObject:@(bottomoffset)];
    }
    
    BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];

    for (int i = 0; i < rows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        id<CollectionCellModelProtocol>model = self.sectionDataList[i];
        CGFloat width = [model customerSize].width;
        CGFloat height = [model customerSize].height;
        
        NSUInteger columnHeightIndex = [OSSVCustomMathTool shortestColumnIndex:self.columnHeights];
        
        CGFloat xOffset = kPadding + (width + kPadding) * columnHeightIndex;
        
        if (rightToLeft) {
            xOffset = SCREEN_WIDTH - xOffset - width;
        }
        
        CGFloat yOffset = [self.columnHeights[columnHeightIndex] floatValue];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        if (self.isTopSpace && (i < KColumnIndex3)) {
            yOffset += kPadding;
        }
        attributes.frame = CGRectMake(xOffset, yOffset, width, height);
        
        self.columnHeights[columnHeightIndex] = @(CGRectGetMaxY(attributes.frame) + kBottomPadding);
        [attributeList addObject:attributes];
    }
    
    return [attributeList copy];
}

-(CGFloat)rowsNumInSection
{
    return [self.sectionDataList count];
}

-(CGFloat)sectionBottom
{
    NSUInteger columnHeightIndex = [OSSVCustomMathTool longestColumnIndex:self.columnHeights];
    return [self.columnHeights[columnHeightIndex] floatValue] + self.minimumInteritemSpacing;
}

#pragma mark - setter and getter

-(NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [[NSMutableArray alloc] init];
    }
    return _columnHeights;
}


@end
