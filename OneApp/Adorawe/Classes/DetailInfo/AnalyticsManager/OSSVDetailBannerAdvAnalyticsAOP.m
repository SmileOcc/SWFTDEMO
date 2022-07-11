//
//  OSSVDetailBannerAdvAnalyticsAOP.m
// XStarlinkProject
//
//  Created by odd on 2020/12/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDetailBannerAdvAnalyticsAOP.h"
#import "OSSVDetailsHeaderScrollverAdvView.h"

@implementation OSSVDetailBannerAdvAnalyticsAOP

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[GoodsHeaderScrollerItemCCell class]]) {
        GoodsHeaderScrollerItemCCell *advCell = (GoodsHeaderScrollerItemCCell *)cell;
        OSSVAdvsEventsModel *advModel = advCell.model;
        
        if (![advModel isMemberOfClass:[OSSVAdvsEventsModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(advModel.bannerId)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(advModel.bannerId)];


    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[GoodsHeaderScrollerItemCCell class]]) {
        GoodsHeaderScrollerItemCCell *advCell = (GoodsHeaderScrollerItemCCell *)cell;
        OSSVAdvsEventsModel *advModel = advCell.model;
        
        
    }
}



- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             };
    return params;
}

@end
