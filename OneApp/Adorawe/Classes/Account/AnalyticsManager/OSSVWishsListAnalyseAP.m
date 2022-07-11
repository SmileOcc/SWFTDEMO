//
//  OSSVWishsListAnalyseAP.m
// XStarlinkProject
//
//  Created by odd on 2020/9/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVWishsListAnalyseAP.h"

@implementation OSSVWishsListAnalyseAP

- (void)after_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[OSSVWishListsTableCell class]]) {
        OSSVWishListsTableCell *goodsCell = (OSSVWishListsTableCell *)cell;
        OSSVAccountMysWishsModel *goodModel = goodsCell.model;
        
        if (![goodModel isMemberOfClass:[OSSVAccountMysWishsModel class]] || [self.goodsAnalyticsSet containsObject:STLToString(goodModel.goods_sn)]) {
            return;
        }
        [self.goodsAnalyticsSet addObject:STLToString(goodModel.goods_sn)];

        
        OSSVDetailsBaseInfoModel *model = [[OSSVDetailsBaseInfoModel alloc] init];
        model.goods_sn = goodModel.goods_sn;
        [OSSVAnalyticsTool appsFlyerTrackGoodsList:@[model] inSourceType:STLAppsflyerGoodsSourceWishlist sourceID:self.sourceKey];
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsImpression" parameters:@{@"action":[OSSVAnalyticsTool sensorsSourceStringWithType:STLAppsflyerGoodsSourceWishlist sourceID:@""],
                                                                                    @"url":@"",
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

-(void)after_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[OSSVWishListsTableCell class]]) {
        OSSVWishListsTableCell *goodsCell = (OSSVWishListsTableCell *)cell;
        OSSVAccountMysWishsModel *goodModel = goodsCell.model;
        
        if (![goodModel isMemberOfClass:[OSSVAccountMysWishsModel class]]) {
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
            @"screen_group":[NSString stringWithFormat:@"ProductList_%@",@"RegularProduct"],
            @"position": @"ProductList_RegularProduct"
        } mutableCopy];
        
        // Add items array
        itemList[kFIRParameterItems] = @[item];
        
        // Log select item event
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectItem parameters:itemList];
    }
    
}




- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:)) :
                             NSStringFromSelector(@selector(after_tableView:didSelectRowAtIndexPath:)),
                             @"tableView:willDisplayCell:forRowAtIndexPath:" :
                             @"after_tableView:willDisplayCell:forRowAtIndexPath:",
                             };
    return params;
}


@end
