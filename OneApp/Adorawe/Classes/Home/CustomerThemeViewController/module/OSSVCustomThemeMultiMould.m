//
//  OSSVCustomThemeMultiMould.m
// OSSVCustomThemeMultiMould
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCustomThemeMultiMould.h"

@interface OSSVCustomThemeMultiMould ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation OSSVCustomThemeMultiMould
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize sectionDataList = _sectionDataList;

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
    
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    CGFloat screenWidth = SCREEN_WIDTH;
    
    for (int i = 0; i < rows; i++) {
        id<CollectionCellModelProtocol>cellmodel = self.sectionDataList[i];
        CGSize size = [cellmodel customerSize];
        width = width + size.width;
        height = size.height;
    }
    if (width <= 0) {
        width = 0.01;
    }
    CGFloat widhtHeightScale = SCREEN_WIDTH / width;
    
    CGFloat heightScale = height * widhtHeightScale;
    
    BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];
    
    CGFloat totalWidth = 0.0;
    for (int i = 0; i < rows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        id<CollectionCellModelProtocol>cellmodel = self.sectionDataList[i];
        CGSize size = [cellmodel customerSize];
        
        CGFloat reallyWidth = (size.width / width) * SCREEN_WIDTH;
        if (i == rows - 1 && rows > 1) {
            reallyWidth = screenWidth - totalWidth;
        }
        totalWidth += reallyWidth;
        CGFloat reallyHeight = heightScale;
        
        CGFloat x = 0.0;
        if (i == 0) {
            x = 0;
            if (rightToLeft) {
                x = screenWidth - reallyWidth;
            }
        }else{
            UICollectionViewLayoutAttributes *lastattributes = attributeList[i - 1];
            x = CGRectGetMaxX(lastattributes.frame);
            if (rightToLeft) {
                x = screenWidth - totalWidth;
            }
        }
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(x, bottomoffset, reallyWidth, floorf(reallyHeight));
        self.bottomOffset = floorf(CGRectGetMaxY(attributes.frame));
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
