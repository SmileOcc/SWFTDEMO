//
//  GoodsDetailsBaseInfoModel.m
//  Yoshop
//
//  Created by huangxieyue on 16/6/2.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsBaseInfoModel.h"

@implementation GoodsDetailsBaseInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"goodsId" : @"goods_id",
             @"goodsSku" : @"goods_sn",
             @"goodsSmallImg": @"goods_thumb",
             @"goodsImg" : @"goods_img",
             @"goodsBigImg" : @"goods_original",
             @"goodsUrlTitle" : @"url_title",
             @"goodsBrand" : @"brand",
             @"goodsGroupId" : @"group_goods_id",
             @"goodsTitle" : @"goods_title",
             @"goodsWeight": @"goods_weight",
             @"goodsVolumeWeight" : @"goods_volume_weight",
             @"goodsDeliveryTime" : @"delivery_time",
             @"goodsImgType" : @"img_type",
             @"goodsImgWidth" : @"img_width",
             @"goodsImgHeight" : @"img_height",
             @"goodsDeliveryLevel" : @"delivery_level",
             @"goodsSupplierCode" : @"supplier_code",
             @"goodsDiscount": @"discount",
             @"goodsWid" : @"wid",
             @"goodsMarketPrice" : @"market_price",
             @"goodsShopPrice" : @"shop_price",
             @"goodsNumber" : @"goods_number",
             
             @"promoteLv" : @"promote_lv",
             @"promotePrice" : @"promote_price",
             @"promoteStartDate" : @"promote_start_date",
             @"promoteEndDate": @"promote_end_date",
             @"promoteRemark" : @"promote_remark",
             
             @"catName" : @"cat_name",
             @"catId" : @"cat_id",
             
             @"isPromote" : @"is_promote",
             @"isDelete": @"is_delete",
             @"isOnSale" : @"is_on_sale",
             @"isFreeShipping" : @"is_free_shipping",
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return @[
             @"goodsId",
             @"goodsSku",
             @"goodsSmallImg",
             @"goodsImg",
             @"goodsBigImg",
             @"goodsUrlTitle",
             @"goodsBrand",
             @"goodsGroupId",
             @"goodsTitle",
             @"goodsWeight",
             @"goodsVolumeWeight",
             @"goodsDeliveryTime",
             @"goodsImgType",
             @"goodsImgWidth",
             @"goodsImgHeight",
             @"goodsDeliveryLevel",
             @"goodsSupplierCode",
             @"goodsDiscount",
             @"goodsWid",
             @"goodsMarketPrice",
             @"goodsShopPrice",
             @"goodsNumber",
             
             @"promoteLv",
             @"promotePrice",
             @"promoteStartDate",
             @"promoteEndDate",
             @"promoteRemark",
             
             @"catName",
             @"catId",
             
             @"isPromote",
             @"isDelete",
             @"isOnSale",
             @"isFreeShipping",
             ];
}

@end

