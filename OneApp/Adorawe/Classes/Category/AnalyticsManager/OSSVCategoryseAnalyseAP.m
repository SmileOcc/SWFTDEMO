//
//  STLCategoryAnalyticsAOP.m
// XStarlinkProject
//
//  Created by odd on 2021/9/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCategoryseAnalyseAP.h"
#import "OSSVCategroysCollectionView.h"
#import "OSSVCategoyScrollrViewCCell.h"

@implementation OSSVCategoryseAnalyseAP


- (void)after_categoryCollection:(OSSVCategroysCollectionView *)collectionView willShowCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[OSSVCategoyScrollrViewCCell class]]) {
        OSSVCategoyScrollrViewCCell *scrollCell = (OSSVCategoyScrollrViewCCell *)cell;
        OSSVCategorysModel *cateModel = scrollCell.model;
        
        if (![cateModel isMemberOfClass:[OSSVCategorysModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(cateModel.selfCategoryId)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(cateModel.selfCategoryId)];
        
        for (OSSVAdvsEventsModel *advModel in cateModel.banner) {
            
            //数据GA埋点曝光
                                
                                // item
                                NSMutableDictionary *item = [@{
                            //          kFIRParameterItemID: $itemId,
                            //          kFIRParameterItemName: $itemName,
                            //          kFIRParameterItemCategory: $itemCategory,
                            //          kFIRParameterItemVariant: $itemVariant,
                            //          kFIRParameterItemBrand: $itemBrand,
                            //          kFIRParameterPrice: $price,
                            //          kFIRParameterCurrency: $currency
                                } mutableCopy];


                                // Prepare promotion parameters
                                NSMutableDictionary *promoParams = [@{
                            //          kFIRParameterPromotionID: $promotionId,
                            //          kFIRParameterPromotionName:$promotionName,
                            //          kFIRParameterCreativeName: $creativeName,
                            //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                                        @"screen_group":@"Category",
                                        @"position": @"ProductCategory"
                                } mutableCopy];

                                // Add items
                                promoParams[kFIRParameterItems] = @[item];
                                
                                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
            
        }
        
    }
}
- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             @"categoryCollection:willShowCell:forItemAtIndexPath:" :
                             @"after_categoryCollection:willShowCell:forItemAtIndexPath:",
                             };
    return params;
}

@end
