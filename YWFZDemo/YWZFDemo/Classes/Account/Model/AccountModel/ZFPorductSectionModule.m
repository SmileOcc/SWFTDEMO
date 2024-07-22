//
//  ZFPorductSectionModule.m
//  ZZZZZ
//
//  Created by YW on 2019/6/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFPorductSectionModule.h"
#import "SystemConfigUtils.h"

@interface ZFPorductSectionModule ()

@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, strong) CustomerBackgroundAttributes *customeSetionBackgroundAttributes;

@end

@implementation ZFPorductSectionModule
@synthesize sectionDataSource = _sectionDataSource;
@synthesize registerKeys = _registerKeys;
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize minimumLineSpacing = _minimumLineSpacing;
@synthesize lineRows = _lineRows;
@synthesize sectionInset = _sectionInset;

- (NSMutableArray<id<ZFCollectionCellDatasourceProtocol>> *)sectionDataSource
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

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSInteger rows = [self.sectionDataSource count];
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:rows];
    
    CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
    CGFloat width = floor((screenWidth - (self.lineRows + 1) * self.minimumLineSpacing) / self.lineRows);
    
    CGFloat height = width * 1.35 + 25;
 
    for (int i = 0; i < rows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGFloat offsetY = 0;
        CGFloat offsetX = 0;

        BOOL rightToLeft = [SystemConfigUtils isRightToLeftShow];
        NSInteger ver = i / self.lineRows;
        NSInteger hor = i % self.lineRows;
        offsetX = hor * (width + self.minimumLineSpacing) +  self.minimumLineSpacing;
        offsetY = ver * (height + self.minimumInteritemSpacing) + bottomoffset;
        if (rightToLeft) {
            //从右往左布局
            offsetX = screenWidth - offsetX - width;
        }
        attributes.frame = CGRectMake(offsetX, offsetY, width, height);
        self.bottomOffset = CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
        [attributeList addObject:attributes];
    }
    
    return attributeList.copy;
}

-(CGFloat)sectionBottom
{
    return self.bottomOffset;
}

//获取一个setion的背景视图，用于设置section背景视图颜色
- (CustomerBackgroundAttributes *)gainCustomeSetionBackgroundAttributes:(NSIndexPath *)indexPath
{
    CustomerBackgroundAttributes *attri = [CustomerBackgroundAttributes layoutAttributesForDecorationViewOfKind:@"CollectionViewSectionBackground" withIndexPath:indexPath];
    attri.backgroundColor = [UIColor whiteColor];
    return attri;
}

@end
