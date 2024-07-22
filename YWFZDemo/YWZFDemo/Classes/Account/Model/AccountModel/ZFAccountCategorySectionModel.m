//
//  ZFAccountCategorySectionModel.m
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountCategorySectionModel.h"
#import "SystemConfigUtils.h"
#import "Constants.h"
#import "ZFCollectionCellProtocol.h"
#import <UIKit/UIKit.h>

@interface ZFAccountCategorySectionModel ()

@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation ZFAccountCategorySectionModel
@synthesize sectionDataSource = _sectionDataSource;
@synthesize registerKeys = _registerKeys;
@synthesize minimumInteritemSpacing = _minimumInteritemSpacing;
@synthesize minimumLineSpacing = _minimumLineSpacing;
@synthesize lineRows = _lineRows;
@synthesize sectionInset = _sectionInset;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isEnableRightToLeft = YES;
    }
    return self;
}

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

- (UIEdgeInsets)sectionInset
{
    return _sectionInset;
}

-(NSArray *)childRowsCalculateFramesWithBottomOffset:(CGFloat)bottomoffset section:(NSInteger)section
{
    NSInteger rows = [self.sectionDataSource count];
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:rows];
    
    CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
    CGFloat width = screenWidth / rows;
    
    CGFloat height = 44;
    
    CGFloat totalLineSpacing = self.minimumLineSpacing * rows;
    
    for (int i = 0; i < rows; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        id<ZFCollectionCellDatasourceProtocol>dataSource = self.sectionDataSource[i];

        if ([dataSource conformsToProtocol:@protocol(ZFCollectionCellDatasourceProtocol)]) {
            Class cell = dataSource.registerClass;
            if ([cell respondsToSelector:@selector(itemSize:protocol:)]) {
                CGSize size = [cell itemSize:rows protocol:dataSource];
                height = size.height;
                width = size.width;
            }
        }
        
        if (self.minimumLineSpacing) {
            CGFloat oldWidth = width;
            width = width - (totalLineSpacing/(rows - 1));
            height = (width / oldWidth) * height;
        }
        
        CGFloat offsetY = bottomoffset;
        CGFloat offsetX = i * width + self.minimumLineSpacing * (i + 1);
        if (width >= screenWidth * 0.5) {
            //实际宽度大于屏幕宽度，居中显示item
            offsetY = (height * i) + bottomoffset;
            offsetX = (screenWidth - width) / 2;
        }
        
        BOOL rightToLeft = [SystemConfigUtils isRightToLeftShow];
        if (rightToLeft && self.isEnableRightToLeft) {
            //从右往左布局
            offsetX = screenWidth - offsetX - width;
        }
        
        attributes.frame = CGRectMake(offsetX, offsetY + self.sectionInset.top, width, height);
        
        self.bottomOffset = CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing;
        [attributeList addObject:attributes];
    }
    
    return attributeList.copy;
}

-(CGFloat)sectionBottom
{
    return self.bottomOffset;
}

@end


@implementation ZFAccountCategoryModel

@end


@implementation ZFAccountDetailTextModel

@end


@implementation ZFAccountRecentlyViewModel

@end


@implementation ZFProductTitleCCellModel

@end
