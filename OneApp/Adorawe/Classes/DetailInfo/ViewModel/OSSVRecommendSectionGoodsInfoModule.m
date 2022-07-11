//
//  OSSVRecommendSectionGoodsInfoModule.m
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVRecommendSectionGoodsInfoModule.h"


@interface OSSVRecommendSectionGoodsInfoModule ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVRecommendSectionGoodsInfoModule
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
    
    if (!CGSizeEqualToSize(self.cellSize, CGSizeZero) && self.cellSize.height > 0) {
        
        if (rows) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            attributes.frame = CGRectMake(0, bottomoffset, self.cellSize.width, self.cellSize.height);
            self.bottomOffset = CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
            [attributeList addObject:attributes];
        }
    }
    
    
    return attributeList.copy;
}

-(CGFloat)sectionBottom
{
    return self.bottomOffset;
}


- (void)updateBottomOffset:(CGFloat)offsetY {
    self.bottomOffset = offsetY;
}
@end
