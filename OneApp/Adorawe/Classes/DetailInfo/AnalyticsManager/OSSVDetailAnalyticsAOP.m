//
//  OSSVDetailAnalyticsAOP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVDetailAnalyticsAOP.h"
#import "OSSVDetailsVC.h"
#import "Adorawe-Swift.h"

#import "OSSVDetailFastAddCCell.h"
#import "Adorawe-Swift.h"

@implementation OSSVDetailAnalyticsAOP


- (void)reviewHadLoad:(NSString *)isLoad reviewHadData:(NSString *)hadData {
    self.reviewStateDic = @{@"reviewHadLoad":STLToString(isLoad), @"reviewHadData":STLToString(hadData)}.mutableCopy;
}

- (void)after_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVDetailReviewNewCell class]]) {
        
        if ([self.goodsAnalyticsSet containsObject:[NSString stringWithFormat:@"review_%@",STLToString(self.anyObject)]]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:[NSString stringWithFormat:@"review_%@",STLToString(self.anyObject)]];
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CommentsImpression" parameters:@{@"sku":STLToString(self.anyObject),
                                                                                    @"is_have_comments":@YES}];
        
    } else if([cell isKindOfClass:[OSSVDetailAdvertiseViewCell class]]) {
        
        if (STLJudgeNSDictionary(self.reviewStateDic)) {
            NSString *hadLoad = self.reviewStateDic[@"reviewHadLoad"];
            NSString *hadData = self.reviewStateDic[@"reviewHadData"];
            
            if ([hadLoad boolValue] && ![hadData boolValue]) {
                
                if ([self.goodsAnalyticsSet containsObject:[NSString stringWithFormat:@"review_%@",STLToString(self.anyObject)]]) {
                    return;
                }
                [self.goodsAnalyticsSet addObject:[NSString stringWithFormat:@"review_%@",STLToString(self.anyObject)]];
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"CommentsImpression" parameters:@{@"sku":STLToString(self.anyObject),
                                                                                            @"is_have_comments":@NO}];
            }
        }
    }
    else if ([cell isKindOfClass:[OSSVDetailRecommendCell class]]) {
        OSSVDetailRecommendCell *goodsCell = (OSSVDetailRecommendCell *)cell;
        OSSVGoodsListModel *goodModel = goodsCell.model;
        
        if (![goodModel isMemberOfClass:[OSSVGoodsListModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        STLAppsflyerGoodsSourceType sourceType = STLAppsflyerGoodsSourceDetailRecommendLike;
        if ([goodsCell isKindOfClass:[OSSVDetailFastAddCCell class]]) {
            sourceType = STLAppsflyerGoodsSourceDetailRecommendOften;
        }
        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodModel.goods_sn;
        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:sourceType sourceID:self.sourceKey];
        

        

//        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:sourceType sourceID:@""],
//                                                                                    @"url":STLToString(self.sourecDic[kAnalyticsAOPSourceID]),
//                                                                                    @"goods_sn":STLToString(goodModel.goods_sn),
//                                                                                    @"currency":@"USD",
//                                                                                    @"cat_id":STLToString(goodModel.cat_id)}];
        ///v1.4.4 url当前商品详情sku
        if (self.needLogGoodsImpression) {
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:sourceType sourceID:@""],
                                                                                        kAnalyticsUrl:STLToString(self.sourecDic[kAnalyticsSku]),
                                                                                        @"goods_sn":STLToString(goodModel.goods_sn),
                                                                                        @"currency":@"USD",
                                                                                        @"cat_id":STLToString(goodModel.cat_id),
                                                                                        @"position_number":@(indexPath.row+1),
                                                                                        kAnalyticsKeyWord:STLToString(self.sourecDic[kAnalyticsKeyWord]),
                                                                                        kAnalyticsThirdPartId:STLToString(self.sourecDic[kAnalyticsThirdPartId]),
                                                                                        kAnalyticsRecommendPartId:STLToString(self.sourecDic[kAnalyticsRequestIdFromItem]),
            }];
            
            STLLog(@"GoodsImpression %@ line:%d",goodModel.goods_sn,__LINE__);
        }
        
        
        //数据GA埋点曝光 列表商品曝光
                       
//                            // item
//        NSMutableDictionary *item = [@{
//          kFIRParameterItemID: STLToString(goodModel.goods_sn),
//          kFIRParameterItemName: STLToString(goodModel.goodsTitle),
//          kFIRParameterItemCategory: STLToString(goodModel.cat_id),
//          //产品规格
//          kFIRParameterItemVariant: @"",
//          kFIRParameterItemBrand: @"",
//          kFIRParameterPrice: @([STLToString(goodModel.shop_price) doubleValue]),
//          kFIRParameterCurrency: @"USD",
//          kFIRParameterQuantity: @(0)
//        } mutableCopy];
//
//
//        // Add items indexes
//        item[kFIRParameterIndex] = @1;
//
//        // Prepare ecommerce parameters
//        NSMutableDictionary *itemList = [@{
//          kFIRParameterItemListID: STLToString(self.sourecDic[kAnalyticsSku]),
//          kFIRParameterItemListName: @"",
//          @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@""],
//        } mutableCopy];
//
//        // Add items array
//        itemList[kFIRParameterItems] = @[item];
//
//        // Log view item list event
//        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItemList parameters:itemList];
        
        OSSVDetailsBaseInfoModel *baseModel = self.sourecDic[@"baseModel"];
        [GATools logEventWithGoodsListWithEventName:@"view_item_list"
                                        screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(baseModel.goodsTitle)]
                                           position:@"ProductDetail"
                                              value:@""
                                              items:@[
            [[GAEventItems alloc] initWithItem_id:STLToString(goodModel.goodsId)
                                        item_name:STLToString(goodModel.goodsTitle)
                                       item_brand:[OSSVLocaslHosstManager appName]
                                    item_category:STLToString(goodModel.cat_name)
                                     item_variant:@""
                                            price:STLToString(goodModel.shop_price)
                                         quantity:@(1) currency:@"USD" index:@(indexPath.row)]
        ]];
    }
}

-(void)after_collectionView:(UICollectionView *)collectionView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[OSSVDetailRecommendCell class]]) {
        
        OSSVDetailRecommendCell *goodsCell = (OSSVDetailRecommendCell *)cell;
        OSSVGoodsListModel *goodModel = goodsCell.model;
        
        if ([goodModel isMemberOfClass:[OSSVGoodsListModel class]]) {
            
            //数据GA埋点曝光 列表商品 点击
            // item
//            NSMutableDictionary *item = [@{
//              kFIRParameterItemID: STLToString(goodModel.goods_sn),
//              kFIRParameterItemName: STLToString(goodModel.goodsTitle),
//              kFIRParameterItemCategory: STLToString(goodModel.cat_id),
//              //产品规格
//              kFIRParameterItemVariant: @"",
//              kFIRParameterItemBrand: @"",
//              kFIRParameterPrice: @([STLToString(goodModel.shop_price) floatValue]),
//              kFIRParameterCurrency: @"USD",
//              kFIRParameterQuantity: @(0)
//            } mutableCopy];
//
//            // Add items indexes
//            item[kFIRParameterIndex] = @1;
//
//            // Prepare ecommerce parameters
//            NSMutableDictionary *itemList = [@{
//              kFIRParameterItemListID: STLToString(goodModel.cat_id),
//              kFIRParameterItemListName: STLToString([UIViewController currentTopViewController].title),
//              @"screen_group":[NSString stringWithFormat:@"ProductDetail__+%@",STLToString(goodModel.goodsTitle)],
//            } mutableCopy];
//
//            // Add items array
//            itemList[kFIRParameterItems] = @[item];

            // Log select item event
            //[OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectItem parameters:itemList];
            
            OSSVDetailsBaseInfoModel *baseModel = self.sourecDic[@"baseModel"];
            [GATools logEventWithGoodsListWithEventName:@"select_item"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(baseModel.goodsTitle)]
                                               position:@"ProductDetail"
                                                  value:@""
                                                  items:@[
                [[GAEventItems alloc] initWithItem_id:STLToString(goodModel.goodsId)
                                            item_name:STLToString(goodModel.goodsTitle)
                                           item_brand:[OSSVLocaslHosstManager appName]
                                        item_category:STLToString(goodModel.cat_name)
                                         item_variant:@""
                                                price:STLToString(goodModel.shop_price)
                                             quantity:@(1) currency:@"USD" index:@(indexPath.row)]
            ]];

            
            return;
        }
    }
}

- (void)after_addCartEventSuccess:(OSSVDetailsBaseInfoModel *)viewModel status:(BOOL)flag {
    
    if (!STLIsEmptyString(viewModel.specialId) && ![STLToString(viewModel.specialId) isEqualToString:@"0"]) {
        
    }
}

- (void)after_baseViewChangePV:(OSSVDetailsBaseInfoModel *)detailModel first:(BOOL)isFirst{
    
    if (!isFirst) {//说明是切换属性，需要曝光一下商品详情
        
        if (![detailModel isMemberOfClass:[OSSVDetailsBaseInfoModel class]]) {
            return;
        }
        
        NSDictionary *sensorsDic = @{
                    @"cat_id":STLToString(detailModel.cat_id),
                    @"currency":@"USD",
                    @"goods_sn":STLToString(detailModel.goods_sn),
                                             kAnalyticsAction: STLToString(self.sourecDic[kAnalyticsAction]),
                                             kAnalyticsUrl: STLToString(self.sourecDic[kAnalyticsUrl]),
                                             kAnalyticsKeyWord: STLToString(self.sourecDic[kAnalyticsKeyWord]),
                                             kAnalyticsPositionNumber: self.sourecDic[kAnalyticsPositionNumber] ?: @(0),
                                             kAnalyticsThirdPartId: STLToString(self.sourecDic[kAnalyticsThirdPartId]),
                        };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:sensorsDic];
    }
    if (detailModel && [detailModel isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
        
        //0元活动
        if (!STLIsEmptyString(detailModel.specialId) && ![STLToString(detailModel.specialId) isEqualToString:@"0"]) {
            
        }
        
        // Appsflyer 内部事件统计 每次查看商品详情页时做统计
        //NSString *code = [ExchangeManager localTypeCurrency];
        NSDictionary *valueDic = @{@"af_content_id"        : STLToString(detailModel.goods_sn),
                                   @"af_content_type"      : STLToString(detailModel.cat_name),
                                   @"af_currency"          : @"USD",
                                   @"af_price"             : STLToString(detailModel.shop_price),
                                   //@"af_inner_mediasource" : [OSSVAnalyticsTool sourceStringWithType:self.sourceType sourceID:self.detailModel.goodsSku],
                                   };
        
        [OSSVAnalyticsTool appsFlyerProducts:valueDic];
        
        
        
        //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
        //GA
        CGFloat price = [detailModel.shop_price floatValue];;
        // 0 > 闪购 > 满减
        if (!STLIsEmptyString(detailModel.specialId)) {//0元
            price = [detailModel.shop_price floatValue];
            
        } else if (STLIsEmptyString(detailModel.specialId) && detailModel.flash_sale &&  [detailModel.flash_sale.is_can_buy isEqualToString:@"1"] && [detailModel.flash_sale.active_status isEqualToString:@"1"]) {//闪购
            price = [detailModel.flash_sale.active_price floatValue];
        }
        CGFloat allPrice = 1 * price;

        //数据GA埋点曝光 商品详情曝光
        NSDictionary *items = @{
            kFIRParameterItemID: STLToString(detailModel.goods_sn),
            kFIRParameterItemName: STLToString(detailModel.goodsTitle),
            kFIRParameterItemCategory: STLToString(detailModel.cat_name),
            //产品规格
            kFIRParameterItemVariant: @"",
            kFIRParameterItemBrand: @"",
            kFIRParameterPrice: @(price),
            //kFIRParameterQuantity: @(1),

        };
        
        NSDictionary *itemsDic = @{kFIRParameterItems:@[items],
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(allPrice),
                                   @"screen_group":[NSString stringWithFormat:@"ProductList_%@",STLToString(detailModel.goodsTitle)],
        };
        
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewItem parameters:itemsDic];
        
        //referrer    前向地址    STRING    需要代码手动开启
        NSString *lastPageName = @"";
        UIViewController *topCtrl = [UIViewController currentTopViewController];
        if (topCtrl.navigationController) {
            NSArray *viewCtrls = topCtrl.navigationController.viewControllers;
            
            if (viewCtrls.count > 1) {
                UIViewController *lastCtrl = viewCtrls[viewCtrls.count-2];
                lastPageName = NSStringFromClass(lastCtrl.class);
            }
        }
        
        NSDictionary *sensorsDic = @{@"referrer":lastPageName,
                                     @"goods_sn"        :STLToString(detailModel.goods_sn),
                                     @"goods_name"      :STLToString(detailModel.goodsTitle),
                                     @"cat_id"          :STLToString(detailModel.cat_id),
                                     @"cat_name"          :STLToString(detailModel.cat_name),
                                     @"original_price"  :@([STLToString(detailModel.goodsMarketPrice) floatValue]),
                                     @"present_price"   :@(price),
                                     @"goods_attr"   :STLToString(detailModel.goodsAttr),
                                     @"currency"   :@"USD",
                                     kAnalyticsAction: STLToString(self.sourecDic[kAnalyticsAction]),
                                     kAnalyticsUrl: STLToString(self.sourecDic[kAnalyticsUrl]),
                                     kAnalyticsKeyWord: STLToString(self.sourecDic[kAnalyticsKeyWord]),
                                     kAnalyticsPositionNumber: self.sourecDic[kAnalyticsPositionNumber] ?: @(0),
                                     kAnalyticsThirdPartId: STLToString(self.sourecDic[kAnalyticsThirdPartId]),
                                     kAnalyticsRecommendPartId: STLToString(self.sourecDic[kAnalyticsRequestId]),
                };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsDetail" parameters:sensorsDic];
        [OSSVAnalyticsTool analyticsSensorsEventFlush];

        if([self.sourecDic[kAnalyticsAction] isEqualToString:@"search"]){
            [ABTestTools.shared goodsDetailWithKeyWord:STLToString(self.sourecDic[kAnalyticsKeyWord])
                                           positionNum:self.sourecDic[kAnalyticsPositionNumber] ? [self.sourecDic[kAnalyticsPositionNumber] integerValue] : 0
                                               goodsSn:STLToString(detailModel.goods_sn)
                                             goodsName:STLToString(detailModel.goodsTitle)
                                                 catId:STLToString(detailModel.cat_id)
                                               catName:STLToString(detailModel.cat_name)
                                           originPrice:[STLToString(detailModel.goodsMarketPrice) floatValue]
                                          presentPrice:price];
        }
        ///Branch 浏览商品详情
        [OSSVBrancshToolss logViewItem:sensorsDic];
        
        [DotApi productDetailPage];
    }
}

//- (void)after_OSSVDetailsHeaderViewDidClick:(GoodsDetailsHeaderEvent)event {
//    if (self.anyObject && [self.anyObject isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
//    }
//}

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(collectionView:didSelectItemAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_collectionView:didSelectItemAtIndexPath:)),
                             @"collectionView:willDisplayCell:forItemAtIndexPath:" :
                             @"after_collectionView:willDisplayCell:forItemAtIndexPath:",
                             @"baseViewChangePV:first:" :
                             @"after_baseViewChangePV:first:",
                             @"addCartEventSuccess:status:" :
                             @"after_addCartEventSuccess:status:",
//                             @"OSSVDetailsHeaderViewDidClick:" :
//                             @"after_OSSVDetailsHeaderViewDidClick:",
                             };
    return params;
}

@end
