//
//  OSSVHomeMainAnalyseAP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVHomeMainAnalyseAP.h"
#import "OSSVCollectCCellProtocol.h"
#import "OSSVDiscoverBlocksModel.h"
#import "NSObject+Swizzling.h"
#import "WMMenuView.h"

@interface OSSVHomeMainAnalyseAP ()
@end

@implementation OSSVHomeMainAnalyseAP

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVPrGoodsSPecialCCell class]]) {
        OSSVPrGoodsSPecialCCell *goodsCell = (OSSVPrGoodsSPecialCCell *)cell;
        OSSVProGoodsCCellModel *productCellModel = goodsCell.model;
        OSSVHomeGoodsListModel *goodModel = (OSSVHomeGoodsListModel *)productCellModel.dataSource;
        if (![goodModel isMemberOfClass:[OSSVHomeGoodsListModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        
        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodModel.goods_sn;
        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceHomeRecommend sourceID:nil];
        
        
        NSInteger tabIndex = [self.sourecDic[kHomeDiscoverSubTabIndex] integerValue];
        NSString *actionString = @"home-other";
        if (tabIndex == 0) {
            actionString = @"home-like";
        }
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":actionString,
                                                                                    @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
                                                                                    @"goods_sn":STLToString(goodModel.goods_sn),
                                                                                    @"currency":@"USD",
                                                                                    @"cat_id":STLToString(goodModel.cat_id),
                                                                                    kAnalyticsRecommendPartId:STLToString(self.sourecDic[kAnalyticsRequestId])
                                                                                  }];
        
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
        item[kFIRParameterIndex] = @(indexPath.row);

        // Prepare ecommerce parameters
        NSMutableDictionary *itemList = [@{
          kFIRParameterItemListID: STLToString(goodModel.cat_id),
          kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
          @"screen_group":[NSString stringWithFormat:@"%@",@"Home"],
          @"position":STLToString(self.sourecDic[kAnalyticsAOPSourceKey])
        } mutableCopy];

        // Add items array
        itemList[kFIRParameterItems] = @[item];

        // Log view item list event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
        
    } else if([cell isKindOfClass:[OSSVAsinglesAdvCCell class]]) {// 1
        
        OSSVAsinglesAdvCCell *asingleCCell = (OSSVAsinglesAdvCCell *)cell;
        if ([asingleCCell.model isKindOfClass:[OSSVAsingleCCellModel class]]) {
            OSSVAsingleCCellModel *cellModel = (OSSVAsingleCCellModel *)asingleCCell.model;
            
            if (cellModel.dataSource && [cellModel.dataSource isKindOfClass:[OSSVAdvsEventsModel class]]) {
                OSSVAdvsEventsModel *advEventModel = (OSSVAdvsEventsModel *)cellModel.dataSource;
                
                if (STLIsEmptyString(advEventModel.name) || [self.goodsAnalyticsSet containsObject:STLToString(advEventModel.name)]) {
                    return;
                }
                [self.goodsAnalyticsSet addObject:STLToString(advEventModel.name)];
                
                //        NSIndexPath *currentIndex = [scrollCell indexPathForCell:goodsItemCell];
                //        NSInteger index = currentIndex ? (currentIndex.row + 1) : 0;
                //NSString *channel_name = [NSString stringWithFormat:@"home_channel_%@",STLToString(cellModel.channelName)];
                NSString *attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(self.sourecDic[kAnalyticsAOPSourceKey])];

                NSString *attr_node_3 = [NSString stringWithFormat:@"home_channel_venue_block_%@",STLToString(advEventModel.name)];
                NSString *pageName = [UIViewController currentTopViewControllerPageName];
                NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                             @"attr_node_1":STLToString(attr_node_1),
                                             @"attr_node_2":@"home_channel_venue",
                                             @"attr_node_3":attr_node_3,
                                             @"position_number":@(0),
                                             @"venue_position":@(0),
                                             @"action_type":@([advEventModel advActionType]),
                                             @"url":[advEventModel advActionUrl],
                };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerImpression" parameters:sensorsDic];
                
                //数据GA埋点曝光 广告
                
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
                
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
            }
        }
        
    } else if([cell isKindOfClass:[OSSVHomeAdvBannerCCell class]]) {//循环广告 下面方法曝光 1
        
    } else if([cell isKindOfClass:[OSSVScrollCCell class]]) { //滑动商品
        
    } else if([cell isKindOfClass:[OSSVHomeTopiicCCell class]]) {
        
    } else if([cell isKindOfClass:[OSSVScrollTitlesCCell class]]) {
        
    } else if([cell isKindOfClass:[OSSVThemesChannelsCCell class]]) {
        
    } else if([cell isKindOfClass:[OSSVHomeCycleSysTipCCell class]]) {//1
        
    } else if([cell isKindOfClass:[OSSVScrollAdvBannerCCell class]]) {//1
        
    } else if([cell isKindOfClass:[OSSVSevenAdvBannerCCell class]]) {//1
        
    } else if([cell isKindOfClass:[OSSVFastSalesCCell class]]) {//1
        
        OSSVFastSalesCCell *asingleCCell = (OSSVFastSalesCCell *)cell;
        if (asingleCCell.model && [asingleCCell.model isKindOfClass:[OSSVFlasttSaleCellModel class]]) {
            OSSVFlasttSaleCellModel *cellModel = (OSSVFlasttSaleCellModel *)asingleCCell.model;
            
            if (cellModel.dataSource && [cellModel.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
                //STLSecondKillModel *advEventModel = (STLSecondKillModel *)cellModel.dataSource;

                //闪购是跟频道走的
                NSString *uidString = [NSString stringWithFormat:@"STLFastSaleCollectionViewCell_%@",@"flast"];
                if ([self.goodsAnalyticsSet containsObject:uidString]) {
                    return;
                }
                [self.goodsAnalyticsSet addObject:uidString];

                NSString *attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(self.sourecDic[kAnalyticsAOPSourceKey])];

                NSString *pageName = [UIViewController currentTopViewControllerPageName];
                NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                             @"attr_node_1":STLToString(attr_node_1),
                                             @"attr_node_2":@"home_channel_flash",
                                             @"attr_node_3":@"",
                                             @"position_number":@(0),
                                             @"venue_position":@(0),
                                             @"action_type":@(0),
                                             @"url":@"",
                };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerImpression" parameters:sensorsDic];
                
                //数据GA埋点曝光 广告
                
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
                
                [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
            }
        }
        
    } else if([cell isKindOfClass:[OSSVScrolllGoodsCCell class]]) {
        OSSVScrolllGoodsCCell *scrollCell = (OSSVScrolllGoodsCCell *)cell;
        OSSVDiscoverBlocksModel *blockModel = scrollCell.dataSourceModels;
        
        if (blockModel && [blockModel isKindOfClass:[OSSVDiscoverBlocksModel class]]) {
            
            STLDiscoveryBlockSlideGoodsModel *model = blockModel.slide_data.firstObject;


            //闪购是跟频道走的
            NSString *uidString = [NSString stringWithFormat:@"STLScrollerGoodsCCell_%@",STLToString(model.special_id)];
            if ([self.goodsAnalyticsSet containsObject:uidString]) {
                return;
            }
            [self.goodsAnalyticsSet addObject:uidString];

            //NSString *attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(self.sourecDic[kAnalyticsAOPSourceKey])];

            NSString *pageName = [UIViewController currentTopViewControllerPageName];
            NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                         @"attr_node_1":@"other",
                                         @"attr_node_2":@"collection_banner",
                                         @"attr_node_3":@"",
                                         @"position_number":@(0),
                                         @"venue_position":@(0),
                                         @"action_type":@(0),
                                         @"url":@"",
            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerImpression" parameters:sensorsDic];
            
            //数据GA埋点曝光 广告
            
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
            
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
        }
        
    }
}

- (void)after_STL_HomeBannerCCell:(OSSVHomeAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model showCellIndex:(NSInteger)index {
    if (!model) {
        return;
    }
    NSString *attr_node_1 = attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(self.sourecDic[kAnalyticsAOPSourceKey])];
    NSString *attr_node_2 = @"";
    NSString *attr_node_3 = @"";
    
    if ([cell isKindOfClass:[OSSVHomeCycleSysTipCCell class]]) {
        if (cell.model && [cell.model isKindOfClass:[OSSVCycleSysCCellModel class]]) {
            
            //STLCycleSystemCCellModel *cellModel = (STLCycleSystemCCellModel *)cell.model;
            
            NSString *uidString = [NSString stringWithFormat:@"STLCycleSystemTipCCell_%@",STLToString(model.name)];
            if (STLIsEmptyString(model.name) || [self.goodsAnalyticsSet containsObject:uidString]) {
                return;
            }
            
            //attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(cellModel.channelName)];
            attr_node_2 = @"home_channel_marquee";
            attr_node_3 = @"";
        }
        
    } else if ([cell isKindOfClass:[OSSVScrollAdvBannerCCell class]]) {
        
        if (cell.model && [cell.model isKindOfClass:[OSSVScrollAdvCCellModel class]]) {
            //STLScrollerBannerCCellModel *cellModel = (STLScrollerBannerCCellModel *)cell.model;
            
            NSString *uidString = [NSString stringWithFormat:@"STLScrollerBannerCCell_%@",STLToString(model.name)];
            if (STLIsEmptyString(model.name) || [self.goodsAnalyticsSet containsObject:uidString]) {
                return;
            }
            
            //attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(cellModel.channelName)];
            attr_node_2 = @"home_channel_sliding";
            attr_node_3 = [NSString stringWithFormat:@"home_channel_sliding_icon_%@",STLToString(model.name)];
        }
    } else if([cell isKindOfClass:[OSSVHomeAdvBannerCCell class]]) {
        
        if ([cell.model isKindOfClass:[OSSVHomeCCellBanneModel class]]) {
            //STLHomeCCellBannerModel *cellModel = (STLHomeCCellBannerModel *)cell.model;
            
            NSString *uidString = [NSString stringWithFormat:@"STLHomeBannerCCell_%@",STLToString(model.name)];
            if (STLIsEmptyString(model.name) || [self.goodsAnalyticsSet containsObject:uidString]) {
                return;
            }
            [self.goodsAnalyticsSet addObject:uidString];
            
            //attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(cellModel.channelName)];
            attr_node_2 = @"home_channel_rolling";
            //attr_node_3 = [NSString stringWithFormat:@"home_channel_venue_block_%@",STLToString(model.name)];
            
            
        }
    } else if([cell isKindOfClass:[OSSVSevenAdvBannerCCell class]]) {
        if (cell.model && [cell.model isKindOfClass:[OSSVSevenAdvCCellModel class]]) {
            //STLSevenBannerCCellModel *cellModel = (STLSevenBannerCCellModel*)cell.model;
            
            NSString *uidString = [NSString stringWithFormat:@"STLSevenBannerCCell_%@",STLToString(model.name)];
            if (STLIsEmptyString(model.name) || [self.goodsAnalyticsSet containsObject:uidString]) {
                return;
            }
            [self.goodsAnalyticsSet addObject:uidString];
            
            //attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(cellModel.channelName)];
            attr_node_2 = @"home_channel_venue";
            attr_node_3 = [NSString stringWithFormat:@"home_channel_venue_block_%@",STLToString(model.name)];
        }
    }
    
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                 @"attr_node_1":STLToString(attr_node_1),
                                 @"attr_node_2":STLToString(attr_node_2),
                                 @"attr_node_3":STLToString(attr_node_3),
                                 @"position_number":@(index+1),
                                 @"venue_position":@(0),
                                 @"action_type":@([model advActionType]),
                                 @"url":[model advActionUrl],
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerImpression" parameters:sensorsDic];
    
    //数据GA埋点曝光 广告
    
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
    
    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
}

- (void)after_aopMenuView:(WMMenuView *)menuView willShowItemView:(WMMenuItem *)itemView index:(NSInteger)index {
    
    NSString *uidString = [NSString stringWithFormat:@"channel_%@_%li",STLToString(itemView.text),(long)index];
    if (STLIsEmptyString(itemView.text) || [self.goodsAnalyticsSet containsObject:uidString]) {
        return;
    }
    [self.goodsAnalyticsSet addObject:uidString];
    
    NSString *attr_node_1 = [NSString stringWithFormat:@"home_channel_%@",STLToString(self.sourecDic[kAnalyticsAOPSourceKey])];
    NSString *attr_node_2 = @"home_channel_stream";
    NSString *attr_node_3 = [NSString stringWithFormat:@"home_channel_stream_tab_%@",itemView.text];
    
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                 @"attr_node_1":STLToString(attr_node_1),
                                 @"attr_node_2":STLToString(attr_node_2),
                                 @"attr_node_3":STLToString(attr_node_3),
                                 @"position_number":@(index+1),
                                 @"venue_position":@(0),
                                 @"action_type":@(0),
                                 @"url":@"",
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerImpression" parameters:sensorsDic];
    
    //数据GA埋点曝光 广告
    
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
    
    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        
        BOOL isConform = [cell conformsToProtocol:@protocol(OSSVCollectCCellProtocol)];
        if (isConform) {
            
            OSSVDiscoverBlocksModel *blockModel;

            if (self.dataSourceList.count > indexPath.section) {//分guan
                id <CustomerLayoutSectionModuleProtocol> module = self.dataSourceList[indexPath.section];
                
                if (module && [[module class] stl_hasVarName:@"discoverBlockModel"]) {
                    blockModel = module.discoverBlockModel;
                }
            }
            
            id<OSSVCollectCCellProtocol> proctCell = (id<OSSVCollectCCellProtocol>)cell;
            id<CollectionCellModelProtocol>model = proctCell.model;
            
            if ([cell isKindOfClass:[OSSVPrGoodsSPecialCCell class]]) {
                if ([model.dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) {
                    
                    OSSVHomeGoodsListModel *goodsModel = (OSSVHomeGoodsListModel *)model.dataSource;

                    //数据GA埋点曝光 列表商品 点击
                    // item
                    NSMutableDictionary *item = [@{
                      kFIRParameterItemID: STLToString(goodsModel.goods_sn),
                      kFIRParameterItemName: STLToString(goodsModel.goodsTitle),
                      kFIRParameterItemCategory: STLToString(goodsModel.cat_id),
                      //产品规格
                      kFIRParameterItemVariant: @"",
                      kFIRParameterItemBrand: @"",
                      kFIRParameterPrice: @([STLToString(goodsModel.shop_price) floatValue]),
                      kFIRParameterCurrency: @"USD",
                      kFIRParameterQuantity: @(1)
                    } mutableCopy];

                    // Add items indexes
                    item[kFIRParameterIndex] = @(indexPath.row+1);

                    // Prepare ecommerce parameters
                    NSMutableDictionary *itemList = [@{
                      kFIRParameterItemListID: STLToString(goodsModel.cat_id),
                      kFIRParameterItemListName: STLToString(@""),
                      @"screen_group":[NSString stringWithFormat:@"%@",@"Home"],
                      @"position":STLToString(self.sourecDic[kAnalyticsAOPSourceKey])
                    } mutableCopy];

                    // Add items array
                    itemList[kFIRParameterItems] = @[item];

                    // Log select item event
                    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectItem parameters:itemList];
                }

                
            } else {
                
                
                if ([model.dataSource isKindOfClass:[OSSVAdvsEventsModel class]]) {
                    
                    //OSSVAdvsEventsModel *advEventModel = (OSSVAdvsEventsModel *)model.dataSource;
                    
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
    }
}

- (void)after_stl_discoverView:(UICollectionView *)collectionView discoverCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell isMore:(BOOL)isMore {
    
    if (cell && [cell isKindOfClass:[OSSVScrolllGoodsCCell class]]) {
        if (itemCell && [itemCell isKindOfClass:[STLScrollerGoodsItemCell class]]) {
            STLScrollerGoodsItemCell *goodsItemCell = (STLScrollerGoodsItemCell *)itemCell;

            STLDiscoveryBlockSlideGoodsModel *slideGoodsModel = goodsItemCell.model;
            NSString *pageName = [UIViewController currentTopViewControllerPageName];
            NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                             @"attr_node_1":@"other",
                                         @"attr_node_2":@"collection_banner",
                                         @"attr_node_3":@"",
                                         @"position_number":@(0),
                                         @"venue_position":@(0),
                                         @"action_type":@(14),
                                         @"url":STLToString(slideGoodsModel.special_id),
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

- (NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"STL_HomeBannerCCell:advEventModel:showCellIndex:" :
                             @"after_STL_HomeBannerCCell:advEventModel:showCellIndex:",
                             @"aopMenuView:willShowItemView:index:" :
                             @"after_aopMenuView:willShowItemView:index:",
                             @"stl_discoverView:discoverCell:itemCell:isMore:" :
                             @"after_stl_discoverView:discoverCell:itemCell:isMore:",
                             };
    return params;
}

@end
