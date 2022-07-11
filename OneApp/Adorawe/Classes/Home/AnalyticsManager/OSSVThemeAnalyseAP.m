//
//  OSSVThemeAnalyseAP.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemeAnalyseAP.h"

#import "OSSVAPPThemeHandleMangerView.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVThemeZeorsActivyCCell.h"
#import "OSSVPrGoodsSPecialCCell.h"
#import "OSSVThemeGoodsItesRankCCell.h"

@implementation OSSVThemeAnalyseAP


- (void)after_viewDidShow {
    
    STLLog(@" --- STLThemeAnalyticsAOP  after_viewDidShow");
    
    NSString *pageName = [UIViewController lastViewControllerPageName];
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"PageViewAction" parameters:@{@"action":@"topic",
                                                                                @"referrer":STLToString(pageName),
                                                                                @"url":STLToString(self.sourceKey)}];
}


- (void)after_stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView didSelectItemCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)after_stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVPrGoodsSPecialCCell class]]) {
        OSSVPrGoodsSPecialCCell *goodsCell = (OSSVPrGoodsSPecialCCell *)cell;
        
        if ([goodsCell.model.dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) { // 这是那个数据呢
            
            OSSVHomeGoodsListModel *goodsModel = (OSSVHomeGoodsListModel *)goodsCell.model.dataSource;

            
            if ([self.goodsAnalyticsSet containsObject:STLToString(goodsModel.goods_sn)]) {
                return;
            }
            [self.goodsAnalyticsSet addObject:STLToString(goodsModel.goods_sn)];
            
            OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
            model.goods_sn = goodsModel.goods_sn;
            [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceSearchResult sourceID:self.sourceKey];
            
            ///// ？？？？？ 这是那个数据呢
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                        @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                        @"goods_sn":STLToString(goodsModel.goods_sn),
                                                                                        @"currency":@"USD",
                                                                                        @"cat_id":STLToString(goodsModel.cat_id)}];
            
            
            //数据GA埋点曝光 列表商品曝光
                           
                                // item
            NSMutableDictionary *item = [@{
              kFIRParameterItemID: STLToString(goodsModel.goods_sn),
              kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
              kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
              //产品规格
              kFIRParameterItemVariant: @"",
              kFIRParameterItemBrand: @"",
              kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
              kFIRParameterCurrency: @"USD",
              kFIRParameterQuantity: @(1)
            } mutableCopy];


            // Add items indexes
            item[kFIRParameterIndex] = @(indexPath.row+1);

            // Prepare ecommerce parameters
            NSMutableDictionary *itemList = [@{
              kFIRParameterItemListID: STLToString(goodsModel.cat_id),
              kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
              @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
              @"position": @"ProductList_RegularProduct"
            } mutableCopy];

            // Add items array
            itemList[kFIRParameterItems] = @[item];

            // Log view item list event
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
        }
        
        if ([goodsCell.model.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
            STLHomeCGoodsModel *goodsModel = (STLHomeCGoodsModel *)goodsCell.model.dataSource;
            
            if ([self.goodsAnalyticsSet containsObject:STLToString(goodsModel.goods_sn)]) {
                return;
            }
            [self.goodsAnalyticsSet addObject:STLToString(goodsModel.goods_sn)];
            
            OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
            model.goods_sn = goodsModel.goods_sn;
            [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceSearchResult sourceID:self.sourceKey];
            
            
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                        @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                        @"goods_sn":STLToString(goodsModel.goods_sn),
                                                                                        @"currency":@"USD",
                                                                                        @"cat_id":STLToString(goodsModel.cat_id)}];
            
            //数据GA埋点曝光 列表商品曝光
                           
                                // item
            NSMutableDictionary *item = [@{
              kFIRParameterItemID: STLToString(goodsModel.goods_sn),
              kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
              kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
              //产品规格
              kFIRParameterItemVariant: @"",
              kFIRParameterItemBrand: @"",
              kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
              kFIRParameterCurrency: @"USD",
              kFIRParameterQuantity: @(1)
            } mutableCopy];


            // Add items indexes
            item[kFIRParameterIndex] = @(indexPath.row);

            // Prepare ecommerce parameters
            NSMutableDictionary *itemList = [@{
              kFIRParameterItemListID: STLToString(goodsModel.cat_id),
              kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
              @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
              @"position": @"ProductList_RegularProduct"
            } mutableCopy];

            // Add items array
            itemList[kFIRParameterItems] = @[item];

            // Log view item list event
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];

        }
 
    } else if([cell isKindOfClass:[OSSVThemeGoodsItesRankCCell class]]) {//排行商品列表
        OSSVThemeGoodsItesRankCCell *goodsCell = (OSSVThemeGoodsItesRankCCell *)cell;
        
        STLHomeCGoodsModel *goodsModel = nil;
        if ([goodsCell.model isKindOfClass:[OSSVThemeItemsGoodsRanksCCellModel class]]) {
            
            OSSVThemeItemsGoodsRanksCCellModel *rankModel = (OSSVThemeItemsGoodsRanksCCellModel *)goodsCell.model;
            if ([rankModel.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
                goodsModel = (STLHomeCGoodsModel *)rankModel.dataSource;
            }
        }
        
        if (goodsModel) {
            
            if ([self.goodsAnalyticsSet containsObject:STLToString(goodsModel.goods_sn)]) {
                return;
            }
            [self.goodsAnalyticsSet addObject:STLToString(goodsModel.goods_sn)];
            
            OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
            model.goods_sn = goodsModel.goods_sn;
            [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceSearchResult sourceID:self.sourceKey];
            
            
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                        @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                        @"goods_sn":STLToString(goodsModel.goods_sn),
                                                                                        @"currency":@"USD",
                                                                                        @"cat_id":STLToString(goodsModel.cat_id)}];
            
            //数据GA埋点曝光 列表商品曝光
                           
                                // item
            NSMutableDictionary *item = [@{
              kFIRParameterItemID: STLToString(goodsModel.goods_sn),
              kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
              kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
              //产品规格
              kFIRParameterItemVariant: @"",
              kFIRParameterItemBrand: @"",
              kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
              kFIRParameterCurrency: @"USD",
              kFIRParameterQuantity: @(1)
            } mutableCopy];


            // Add items indexes
            item[kFIRParameterIndex] = @(indexPath.row+1);

            // Prepare ecommerce parameters
            NSMutableDictionary *itemList = [@{
              kFIRParameterItemListID: STLToString(goodsModel.cat_id),
              kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
              @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
              @"position": @"ProductList_RegularProduct"
            } mutableCopy];

            // Add items array
            itemList[kFIRParameterItems] = @[item];

            // Log view item list event
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
        }
        
    } else if([cell isKindOfClass:[OSSVThemeGoodsItesRankModuleCCell class]]) {//排行商品集合
        OSSVThemeGoodsItesRankModuleCCell *moduleCell = (OSSVThemeGoodsItesRankModuleCCell *)cell;
        
        OSSVHomeCThemeModel *goodsModels = moduleCell.dataSourceModels;
        

        if (STLJudgeNSArray(goodsModels.goodsList)) {

            for (STLHomeCGoodsModel *goodsModel in goodsModels.goodsList) {
                if ([self.goodsAnalyticsSet containsObject:STLToString(goodsModel.goods_sn)]) {
                    return;
                }
                [self.goodsAnalyticsSet addObject:STLToString(goodsModel.goods_sn)];

                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                            @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                            @"goods_sn":STLToString(goodsModel.goods_sn),
                                                                                            @"currency":@"USD",
                                                                                            @"cat_id":STLToString(goodsModel.cat_id)}];
                
                //数据GA埋点曝光 列表商品曝光
                               
                                    // item
                NSMutableDictionary *item = [@{
                  kFIRParameterItemID: STLToString(goodsModel.goods_sn),
                  kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
                  kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
                  //产品规格
                  kFIRParameterItemVariant: @"",
                  kFIRParameterItemBrand: @"",
                  kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
                  kFIRParameterCurrency: @"USD",
                  kFIRParameterQuantity: @(1)
                } mutableCopy];


                // Add items indexes
                item[kFIRParameterIndex] = @(indexPath.row+1);

                // Prepare ecommerce parameters
                NSMutableDictionary *itemList = [@{
                  kFIRParameterItemListID: STLToString(goodsModel.cat_id),
                  kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
                  @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
                  @"position": @"ProductList_RegularProduct"
                } mutableCopy];

                // Add items array
                itemList[kFIRParameterItems] = @[item];

                // Log view item list event
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
            }
        }
    } else if([cell isKindOfClass:[OSSVScrolllGoodsCCell class]]) {
        OSSVScrolllGoodsCCell *moduleCell = (OSSVScrolllGoodsCCell *)cell;
        if (moduleCell.dataSourceThemeModels && STLJudgeNSArray(moduleCell.dataSourceThemeModels.slideList)) {
            
            for (OSSVHomeGoodsListModel *goodsModel in moduleCell.dataSourceThemeModels.slideList) {
                if ([self.goodsAnalyticsSet containsObject:STLToString(goodsModel.goods_sn)]) {
                    return;
                }
                [self.goodsAnalyticsSet addObject:STLToString(goodsModel.goods_sn)];

                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:self.source sourceID:@""],
                                                                                            @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                            @"goods_sn":STLToString(goodsModel.goods_sn),
                                                                                            @"currency":@"USD",
                                                                                            @"cat_id":STLToString(goodsModel.cat_id)}];
                
                //数据GA埋点曝光 列表商品曝光
                               
                                    // item
                NSMutableDictionary *item = [@{
                  kFIRParameterItemID: STLToString(goodsModel.goods_sn),
                  kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
                  kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
                  //产品规格
                  kFIRParameterItemVariant: @"",
                  kFIRParameterItemBrand: @"",
                  kFIRParameterPrice: @([STLToString(goodsModel.shop_price) doubleValue]),
                  kFIRParameterCurrency: @"USD",
                  kFIRParameterQuantity: @(1)
                } mutableCopy];


                // Add items indexes
                item[kFIRParameterIndex] = @(indexPath.row+1);

                // Prepare ecommerce parameters
                NSMutableDictionary *itemList = [@{
                  kFIRParameterItemListID: STLToString(goodsModel.cat_id),
                  kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
                  @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
                  @"position": @"ProductList_RegularProduct"
                } mutableCopy];

                // Add items array
                itemList[kFIRParameterItems] = @[item];

                // Log view item list event
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
            }
        }

    }
}


/** 0元、新用户商品*/
- (void)after_stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell isMore:(BOOL)isMore {
    
    if ([cell isKindOfClass:[OSSVThemeZeorsActivyCCell class]]) {//0元
        if (itemCell && [itemCell isKindOfClass:[STLThemeZeorGoodsItemCell class]]) {
            STLThemeZeorGoodsItemCell *zeorCell = (STLThemeZeorGoodsItemCell *)itemCell;
            
            OSSVThemeZeroPrGoodsModel *productModel = (OSSVThemeZeroPrGoodsModel *)zeorCell.model;
            if (productModel && !isMore) {
                
                
            }
        }
    } else if([cell isKindOfClass:[OSSVScrolllGoodsCCell class]]) {
        OSSVScrolllGoodsCCell *scrollCell = (OSSVScrolllGoodsCCell *)cell;
        if (itemCell && [itemCell isKindOfClass:[STLScrollerGoodsItemCell class]]) {
            STLScrollerGoodsItemCell *goodsItemCell = (STLScrollerGoodsItemCell *)itemCell;
            
            NSIndexPath *currentIndex = [scrollCell indexPathForCell:goodsItemCell];
            NSInteger index = currentIndex ? (currentIndex.row + 1) : 0;
            NSString *pageName = [UIViewController currentTopViewControllerPageName];
            NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                             @"attr_node_1":@"other",
                                         @"attr_node_2":@"",
                                         @"attr_node_3":@"",
                                         @"position_number":@(index),
                                         @"venue_position":@(0),
                                         @"action_type":@(0),
                                         @"url":STLToString(self.sourceKey),
                    };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
            
            //数据GA埋点曝光 广告点击
                                
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
                            //          @"screen_group":@"Home"
                                } mutableCopy];

                                // Add items
                                promoParams[kFIRParameterItems] = @[item];
                                
                                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        }
    }
}

/** 领取优惠券*/
- (void)after_stl_themeManagerView:(OSSVAPPThemeHandleMangerView *)managerView collectionView:(UICollectionView *)collectionView themeCell:(UICollectionViewCell *)cell getCoupons:(NSString *)couponsString {
    
    NSIndexPath *currentIndexPath = [collectionView indexPathForCell:cell];
    
    if (managerView && managerView.dataSourceList.count > currentIndexPath.section) {
        
        id<CustomerLayoutSectionModuleProtocol>module = managerView.dataSourceList[currentIndexPath.section];
        id<CollectionCellModelProtocol>model = module.sectionDataList[currentIndexPath.row];
        if ([model.dataSource isKindOfClass:[STLAdvEventSpecialModel class]]) {
            STLAdvEventSpecialModel *modelSpecial = (STLAdvEventSpecialModel *)model.dataSource;
            
            if (modelSpecial.hasRule) {
                return;
            }
            if (modelSpecial.pageType == 15 || modelSpecial.pageType == 8) {///当前页面领取优惠券
                
                
                
            }
        }
    }
}
- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             @"viewDidShow" :
                             @"after_viewDidShow",
                             @"stl_themeManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:" :
                             @"after_stl_themeManagerView:collectionView:didSelectItemCell:forItemAtIndexPath:",
                             @"stl_themeManagerView:collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_stl_themeManagerView:collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"stl_themeManagerView:collectionView:themeCell:itemCell:isMore:":
                             @"after_stl_themeManagerView:collectionView:themeCell:itemCell:isMore:",
                             @"stl_themeManagerView:collectionView:themeCell:getCoupons:":
                             @"after_stl_themeManagerView:collectionView:themeCell:getCoupons:",
                             };
    return params;
}
@end
