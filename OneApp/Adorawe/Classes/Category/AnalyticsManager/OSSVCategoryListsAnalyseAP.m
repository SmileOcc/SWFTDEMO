//
//  STLCategoryListAnalyticsAOP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryListsAnalyseAP.h"

@implementation OSSVCategoryListsAnalyseAP

- (void)after_viewDidShow {
    
    STLLog(@" --- STLCategoryListAnalyticsAOP  after_viewDidShow");
    NSString *pageName = [UIViewController lastViewControllerPageName];
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"PageViewAction" parameters:@{@"action":@"category",
                                                                                @"referrer":STLToString(pageName),
                                                                                @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID])}];
}

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
        
        
        
        BOOL isSimilar = [self.sourecDic[@"isSimilar"] boolValue];
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:isSimilar ? STLAppsflyerGoodsSourceDetailSimilar :self.source sourceID:@""],
                                                                                    @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                    @"goods_sn":STLToString(goodModel.goods_sn),
                                                                                    @"currency":@"USD",
                                                                                    @"cat_id":STLToString(goodModel.cat_id)}];
        
        //数据GA埋点曝光 列表商品曝光
                       
                            // item
        NSMutableDictionary *item = [@{
          kFIRParameterItemID: STLToString(goodModel.goods_sn),
          kFIRParameterItemName: STLToString(goodModel.goodsTitle),
          kFIRParameterItemCategory: STLToString(goodModel.cat_id),
          //产品规格
          kFIRParameterItemVariant: @"",
          kFIRParameterItemBrand: @"",
          kFIRParameterPrice: @([STLToString(goodModel.shop_price) doubleValue]),
          kFIRParameterCurrency: @"USD",
          kFIRParameterQuantity: @(1)
        } mutableCopy];


        // Add items indexes
        item[kFIRParameterIndex] = @(indexPath.row+1);

        // Prepare ecommerce parameters
        NSMutableDictionary *itemList = [@{
          kFIRParameterItemListID: STLToString(goodModel.cat_id),
          kFIRParameterItemListName: @"",
          @"screen_group":[NSString stringWithFormat:@"ActivityList_%@",@""],
          @"position": @"ActivityList_CampaignProduct"
        } mutableCopy];

        // Add items array
        itemList[kFIRParameterItems] = @[item];

        // Log view item list event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];

    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[OSSVCategoryListsCCell class]]) {
        
        OSSVCategoryListsCCell *goodsCell = (OSSVCategoryListsCCell *)cell;
        OSSVCategoriyDetailsGoodListsModel *goodModel = goodsCell.model;
        
        if (![goodModel isMemberOfClass:[OSSVCategoriyDetailsGoodListsModel class]]) {
            return;
        }
        //数据GA埋点曝光 列表商品 点击
        // item
        NSMutableDictionary *item = [@{
          kFIRParameterItemID: STLToString(goodModel.goods_sn),
          kFIRParameterItemName: STLToString(goodModel.goodsTitle),
          kFIRParameterItemCategory: STLToString(goodModel.cat_id),
          //产品规格
          kFIRParameterItemVariant: @"",
          kFIRParameterItemBrand: @"",
          kFIRParameterPrice: @([STLToString(goodModel.shop_price) doubleValue]),
          kFIRParameterCurrency: @"USD",
          kFIRParameterQuantity: @(1)
        } mutableCopy];

        // Add items indexes
        item[kFIRParameterIndex] = @(indexPath.row+1);

        // Prepare ecommerce parameters
        NSMutableDictionary *itemList = [@{
          kFIRParameterItemListID: STLToString(goodModel.cat_id),
          kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
          @"screen_group":[NSString stringWithFormat:@"ActivityList_%@",@""],
          @"position": @"ActivityList_CampaignProduct"
        } mutableCopy];

        // Add items array
        itemList[kFIRParameterItems] = @[item];

        // Log select item event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectItem parameters:itemList];
    }
}




- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"viewDidShow" :
                             @"after_viewDidShow",
                             };
    return params;
}


@end
