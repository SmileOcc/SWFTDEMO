//
//  OSSVThreeCViewMould.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVThreeCViewMould.h"

@interface OSSVThreeCViewMould ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVThreeCViewMould
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
    NSInteger rows = [self rowsNumInSection];
    
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:rows];
    
    CGFloat screenWidth = SCREEN_WIDTH;
    CGFloat firstWidth = SCREEN_WIDTH * 175.0 / 375.0;
    CGFloat secondWidth = screenWidth - firstWidth;
    
    CGFloat height = firstWidth * 252.0 / 175.0;
    
    CGFloat x = 0;
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        x = screenWidth - firstWidth;
    }

    UICollectionViewLayoutAttributes *firstAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    firstAttributes.frame = CGRectMake(x, bottomoffset, screenWidth / 2, height);
    
    UICollectionViewLayoutAttributes *secondAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:section]];
    CGFloat firstRight = CGRectGetMaxX(firstAttributes.frame);
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        firstRight = screenWidth - firstRight;
    }
    secondAttributes.frame = CGRectMake(firstRight, bottomoffset, secondWidth, secondWidth * 120.0 / 200.0);
    
    UICollectionViewLayoutAttributes *threeAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:section]];
    CGFloat secondBottom = CGRectGetMaxY(secondAttributes.frame);
    threeAttributes.frame = CGRectMake(firstRight, secondBottom, secondWidth, secondWidth * 132.0 / 200.0);
    
    [attributeList addObjectsFromArray:@[firstAttributes, secondAttributes, threeAttributes]];
    
    self.bottomOffset = CGRectGetMaxY(firstAttributes.frame);
    
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
