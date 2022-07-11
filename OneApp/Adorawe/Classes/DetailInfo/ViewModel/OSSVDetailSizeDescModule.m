//
//  OSSVDetailSizeDescModule.m
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailSizeDescModule.h"
@interface OSSVDetailSizeDescModule ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVDetailSizeDescModule
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
    
    self.bottomOffset = bottomoffset;
    if (rows) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGFloat height = 50;
        if (!CGSizeEqualToSize(self.cellSize, CGSizeZero) && self.cellSize.height > 0) {
            height = self.cellSize.height;
        }
        
        CGFloat yOffset = bottomoffset + kPaddingGoodsDetailSpace;
        attributes.frame = CGRectMake(0, yOffset, SCREEN_WIDTH, height);
        
        self.bottomOffset = CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
        [attributeList addObject:attributes];
    }
    
    return attributeList.copy;
}

-(CGFloat)sectionBottom {
    return self.bottomOffset;
}
@end
