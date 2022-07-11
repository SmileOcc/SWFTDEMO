//
//  OSSVRecommendHeaderModule.m
// XStarlinkProject
//
//  Created by odd on 2021/4/14.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVRecommendHeaderModule.h"
#import "OSSVDetailRecommendHeaderCell.h"

@interface OSSVRecommendHeaderModule ()

@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, assign) CGFloat topOffset;

@end

@implementation OSSVRecommendHeaderModule

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
    self.topOffset = bottomoffset;
    if (rows) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGFloat height = [OSSVDetailRecommendHeaderCell heightGoodsRecommendView:YES];
        CGFloat yOffset = bottomoffset + kPaddingGoodsDetailSpace;
        self.topOffset = yOffset;
        attributes.frame = CGRectMake(0, yOffset, SCREEN_WIDTH, height);
        
        self.bottomOffset = CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
        [attributeList addObject:attributes];
    }
    
    return attributeList.copy;
}
- (CGFloat)sectionTop {
    return self.topOffset;
}

-(CGFloat)sectionBottom {
    return self.bottomOffset;
}

@end
