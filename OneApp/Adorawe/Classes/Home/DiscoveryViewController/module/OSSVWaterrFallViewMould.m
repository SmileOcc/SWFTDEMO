//
//  OSSVWaterrFallViewMould.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWaterrFallViewMould.h"
#import "OSSVProGoodsCCellModel.h"

@interface OSSVWaterrFallViewMould ()

@property (nonatomic, strong) NSMutableArray *columnHeights;

@end

@implementation OSSVWaterrFallViewMould
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
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:0];
    
    NSInteger rows = [self rowsNumInSection];
    
    [self.columnHeights removeAllObjects];
    
    for (int i = 0; i < KColumnIndex2; i++) {
        [self.columnHeights addObject:@(bottomoffset)];
    }
    
    BOOL rightToLeft = [OSSVSystemsConfigsUtils isRightToLeftShow];

    for (int i = 0; i < rows; i++) {
        
        if (APP_TYPE == 3) {//STLProductCCellModel
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            id<CollectionCellModelProtocol>model = self.sectionDataList[i];
            id<CollectionCellModelProtocol>twoModel = nil;
            NSInteger count = indexPath.row % 2;
            if (count == 0) {
                if (self.sectionDataList.count > indexPath.row+1) {
                    twoModel = self.sectionDataList[indexPath.row+1];
                }
            } else {
                if (indexPath.row > 0) {
                    twoModel = self.sectionDataList[indexPath.row-1];
                }
            }
            
            CGFloat width = [model customerSize].width;
            CGFloat height = [model customerSize].height;
            
            CGFloat twoWidth = 0;
            CGFloat twoHeight = 0;
            if (twoModel) {
                twoWidth = [twoModel customerSize].width;
                twoHeight = [twoModel customerSize].height;
            }
            
            CGFloat maxHeight = 0;
            if ([model.dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) {
                OSSVHomeGoodsListModel *oneGoodsModel =(OSSVHomeGoodsListModel *)model.dataSource;
                OSSVHomeGoodsListModel *twoGoodsModel = nil;
                
                CGFloat activityHeight = oneGoodsModel.goodsListFullActitityHeight;
                CGFloat onefullHeight = oneGoodsModel.goodsListPriceHeight;
                
                CGFloat twofullHeight = 0;
                if (twoModel) {
                    twoGoodsModel = (OSSVHomeGoodsListModel *)twoModel.dataSource;
                    twofullHeight = twoGoodsModel.goodsListPriceHeight;
                    CGFloat twoActivityHeight = twoGoodsModel.goodsListFullActitityHeight;
                    
                    if (twofullHeight > onefullHeight) {
                        oneGoodsModel.goodsListPriceHeight = twofullHeight;
                        oneGoodsModel.goodsListFullActitityHeight = twoActivityHeight;
                    } else {
                        twoGoodsModel.goodsListPriceHeight = onefullHeight;
                        twoGoodsModel.goodsListFullActitityHeight = activityHeight;
                    }
                }
                


            } else if([model.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
                
                STLHomeCGoodsModel *oneGoodsModel =(STLHomeCGoodsModel *)model.dataSource;
                STLHomeCGoodsModel *twoGoodsModel = nil;
                
                CGFloat activityHeight = oneGoodsModel.goodsListFullActitityHeight;
                CGFloat onefullHeight = oneGoodsModel.goodsListPriceHeight;
                
                CGFloat twofullHeight = 0;
                if (twoModel) {
                    twoGoodsModel = (STLHomeCGoodsModel *)twoModel.dataSource;
                    twofullHeight = twoGoodsModel.goodsListPriceHeight;
                    CGFloat twoActivityHeight = twoGoodsModel.goodsListFullActitityHeight;
                    
                    if (twofullHeight > onefullHeight) {
                        oneGoodsModel.goodsListPriceHeight = twofullHeight;
                        oneGoodsModel.goodsListFullActitityHeight = twoActivityHeight;
                    } else {
                        twoGoodsModel.goodsListPriceHeight = onefullHeight;
                        twoGoodsModel.goodsListFullActitityHeight = activityHeight;
                    }
                }

            }
            
            
            
            maxHeight = MAX(height, twoHeight);
            NSUInteger columnHeightIndex = [OSSVCustomMathTool shortestColumnIndex:self.columnHeights];
            
            CGFloat xOffset = kPadding + (width + kPadding) * columnHeightIndex;
            
            if (rightToLeft) {
                xOffset = SCREEN_WIDTH - xOffset - width;
            }
            
            CGFloat yOffset = [self.columnHeights[columnHeightIndex] floatValue];
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            if (self.isTopSpace && (i < KColumnIndex2)) {
                yOffset += kPadding;
            }
            attributes.frame = CGRectMake(xOffset, yOffset, width, maxHeight);
            
            self.columnHeights[columnHeightIndex] = @(CGRectGetMaxY(attributes.frame) + kBottomPadding);
            [attributeList addObject:attributes];

        } else {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            id<CollectionCellModelProtocol>model = self.sectionDataList[i];
            CGFloat width = [model customerSize].width;
            CGFloat height = [model customerSize].height;
            
            NSUInteger columnHeightIndex = [OSSVCustomMathTool shortestColumnIndex:self.columnHeights];
            
            CGFloat xOffset = kPadding + (width + kPadding) * columnHeightIndex;
            
            if (rightToLeft) {
                xOffset = SCREEN_WIDTH - xOffset - width;
            }
            
            CGFloat yOffset = [self.columnHeights[columnHeightIndex] floatValue];
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            if (self.isTopSpace && (i < KColumnIndex2)) {
                yOffset += kPadding;
            }
            attributes.frame = CGRectMake(xOffset, yOffset, width, height);
            
            self.columnHeights[columnHeightIndex] = @(CGRectGetMaxY(attributes.frame) + kBottomPadding);
            [attributeList addObject:attributes];
        }
    }
    
    return [attributeList copy];
}

-(CGFloat)rowsNumInSection
{
    return [self.sectionDataList count];
}

-(CGFloat)sectionBottom
{
    NSUInteger columnHeightIndex = [OSSVCustomMathTool longestColumnIndex:self.columnHeights];
    return [self.columnHeights[columnHeightIndex] floatValue] + self.minimumInteritemSpacing;
}

#pragma mark - setter and getter

-(NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [[NSMutableArray alloc] init];
    }
    return _columnHeights;
}

@end
