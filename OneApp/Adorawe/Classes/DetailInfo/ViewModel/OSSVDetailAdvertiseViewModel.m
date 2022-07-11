//
//  OSSVDetailAdvertiseViewModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailAdvertiseViewModel.h"
#import "OSSVDetailsListModel.h"

@interface OSSVDetailAdvertiseViewModel ()
@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, assign) CGFloat topOffset;
@end

@implementation OSSVDetailAdvertiseViewModel
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
        
        OSSVDetailsListModel* data =  self.sectionDataSource.firstObject;
        OSSVAdvsEventsModel *advModel = data.banner.firstObject;
        CGFloat height = 100;
        if (advModel.width.floatValue > 0) { ///h / screenWidth = model.h / model.w
            height = [OSSVDetailAdvertiseViewModel heightGoodsScrollerAdvView:data.banner];
        }
        
        CGFloat yOffset = bottomoffset + kPaddingGoodsDetailSpace;
        self.topOffset = bottomoffset;
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



+ (CGFloat)heightGoodsScrollerAdvView:(NSArray<OSSVAdvsEventsModel *> *)advBanners {

    __block CGFloat h = 0;
    if (STLJudgeNSArray(advBanners)) {

        [advBanners enumerateObjectsUsingBlock:^(OSSVAdvsEventsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.width floatValue] > 0) {
                CGFloat tempH = (SCREEN_WIDTH - 12*2) * [obj.height floatValue] / [obj.width floatValue];
                if (tempH > h) {
                    h = tempH;
                }
            }
        }];
    }

    return h;
}

@end
