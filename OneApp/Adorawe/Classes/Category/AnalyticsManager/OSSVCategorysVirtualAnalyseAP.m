//
//  OSSVCategorysVirtualAnalyseAP.m
// XStarlinkProject
//
//  Created by odd on 2020/10/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorysVirtualAnalyseAP.h"

@implementation OSSVCategorysVirtualAnalyseAP

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVCategoryListsCCell class]]) {
        OSSVCategoryListsCCell *goodsCell = (OSSVCategoryListsCCell *)cell;
        OSSVCategoriyDetailsGoodListsModel *goodModel = goodsCell.model;
        
        if (![goodModel isMemberOfClass:[OSSVCategoriyDetailsGoodListsModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        
        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodModel.goods_sn;
//        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceCategoryList sourceID:self.sourceKey];
        

    }
}


-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
