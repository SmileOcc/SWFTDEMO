//
//  OSSVAsinglViewMould.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAsinglViewMould.h"

@interface OSSVAsinglViewMould ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVAsinglViewMould
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize sectionDataList = _sectionDataList;
@synthesize discoverBlockModel = _discoverBlockModel;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sectionDataList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:1];
    
    id<CollectionCellModelProtocol>cellModel = self.sectionDataList[0];
    
    CGSize customerSize = [cellModel customerSize];
    
    if (CGSizeEqualToSize(CGSizeZero, customerSize)) {
        customerSize = CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH * 200.0 / 375.0));
    }
    
    self.bottomOffset = bottomoffset;
    if (self.isNewBranch) {
        NSInteger row = 0;
        if (self.discoverBlockModel.banner) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(0, bottomoffset, customerSize.width, customerSize.height);
            self.bottomOffset = CGRectGetMaxY(attributes.frame);
            [attributeList addObject:attributes];
            row++;
        }
        if ([self.discoverBlockModel.type integerValue] == 1 && self.discoverBlockModel.images.count > 0) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(0, self.bottomOffset, customerSize.width, customerSize.height);
            self.bottomOffset = CGRectGetMaxY(attributes.frame);
            [attributeList addObject:attributes];
        }
        
        return [attributeList copy];
    }

    
    if (CGSizeEqualToSize(CGSizeZero, customerSize)) {
        customerSize = CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH * 200.0 / 375.0));
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(0, bottomoffset, customerSize.width, customerSize.height);
    
    self.bottomOffset = CGRectGetMaxY(attributes.frame);
    
    [attributeList addObject:attributes];
    
    return [attributeList copy];
}

-(CGFloat)rowsNumInSection {
    return [self.sectionDataList count];
}

-(CGFloat)sectionBottom {
    return self.bottomOffset + self.minimumInteritemSpacing;
}
@end
