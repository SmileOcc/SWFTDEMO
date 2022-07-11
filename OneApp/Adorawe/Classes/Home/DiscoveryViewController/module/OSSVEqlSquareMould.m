//
//  OSSVEqlSquareMould.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVEqlSquareMould.h"

@interface OSSVEqlSquareMould ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVEqlSquareMould
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize sectionDataList = _sectionDataList;
@synthesize discoverBlockModel = _discoverBlockModel;

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.sectionDataList = [[NSMutableArray alloc] init];
        self.customerColumn = 4;
    }
    return self;
}

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSInteger rows = [self rowsNumInSection];
    
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:rows];

    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat width = screenWidth / self.customerColumn;
    
    BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];
    
    //总行数
    int tempRow = 0;
    for (int i = 0; i < rows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        id<CollectionCellModelProtocol>cellModel = self.sectionDataList[i];
        CGFloat height = [cellModel customerSize].height;
        if (i % self.customerColumn == 0) {
            tempRow++;
        }
        float x = 0.0;
        if (tempRow * self.customerColumn <= rows) {
            NSInteger tempRowCount = rows <= self.customerColumn ? rows : self.customerColumn;
            x = SCREEN_WIDTH / 2.0 - (tempRowCount / 2.0 * width) + i % tempRowCount * width;
        }else{
            NSInteger tempRowCount = self.customerColumn - (tempRow * self.customerColumn - rows);
            x = SCREEN_WIDTH / 2.0 - (tempRowCount / 2.0 * width) + i % tempRowCount * width;
        }
        if (rightToLeft) {
            x = SCREEN_WIDTH - x - width;
        }
        attributes.frame = CGRectMake(x, (i / self.customerColumn) * height + bottomoffset, width, height);

        self.bottomOffset = CGRectGetMaxY(attributes.frame);
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
    return self.bottomOffset + self.minimumInteritemSpacing;
}

@end
