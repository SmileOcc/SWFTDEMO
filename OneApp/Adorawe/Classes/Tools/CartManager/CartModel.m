//
//  CartModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CartModel.h"

@implementation CartModel

/**
 *  此处方法做数据校验，可以设置默认值
 *
 *  @param dic 需要解析的字典
 *
 *  @return 是否符合条件
 */

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSString *specialId = dic[@"specialId"];
    if (specialId == nil || [specialId isKindOfClass:[NSNull class]]) {
        self.specialId = @"";
    }
    
    NSString *is_exchange = dic[@"is_exchange"];
    if (is_exchange == nil || [is_exchange isKindOfClass:[NSNull class]]) {
        self.is_exchange = @"";
    }
    
    NSString *exchange_label = dic[@"exchange_label"];
    if (exchange_label == nil || [exchange_label isKindOfClass:[NSNull class]]) {
        self.exchange_label = @"";
    }
    
    NSString *goodsId = dic[@"goods_id"];
    if (goodsId == nil || [goodsId isKindOfClass:[NSNull class]]) {
        self.goodsId = @"";
    }
    NSString *goods_sn = dic[@"goods_sn"];
    if (goods_sn == nil || [goods_sn isKindOfClass:[NSNull class]]) {
        self.goods_sn = @"";
    }
    NSString *catName = dic[@"cat_name"];
    if (catName == nil || [catName isKindOfClass:[NSNull class]]) {
        self.cat_name = @"";
    }
    NSString *goodsName = dic[@"goods_name"];
    if (goodsName == nil || [goodsName isKindOfClass:[NSNull class]]) {
        self.goodsName = @"";
    }
    NSString *goodsPrice = dic[@"goods_price"];
    if (goodsPrice == nil || [goodsPrice isKindOfClass:[NSNull class]]) {
        self.goodsPrice = @"0";
    }

    NSString *goodsAttr = dic[@"goods_attr"];
    if (goodsAttr == nil || [goodsAttr isKindOfClass:[NSNull class]]) {
        self.goodsAttr = @"";
    }
    NSString *marketPrice = dic[@"market_price"];
    if (marketPrice == nil || [marketPrice isKindOfClass:[NSNull class]]) {
        self.marketPrice = @"0";
    }
    NSString *goodsThumb = dic[@"goods_thumb"];
    if (goodsThumb == nil || [goodsThumb isKindOfClass:[NSNull class]]) {
        self.goodsThumb = @"";
    }
    NSString *modify = dic[@"modify"];
    if (modify == nil || [modify isKindOfClass:[NSNull class]]) {
        self.modify = @"";
    }
    NSString *store = dic[@"store"];
    if (store == nil || [store isKindOfClass:[NSNull class]]) {
        self.store = @"";
    }
//    NSString *warehouseCode = dic[@"warehouse_code"];
//    if (warehouseCode == nil || [warehouseCode isKindOfClass:[NSNull class]]) {
//        self.warehouseCode = @"";
//    }
    NSString *warehouseName = dic[@"warehouse_name"];
    if (warehouseName == nil || [warehouseName isKindOfClass:[NSNull class]]) {
        self.warehouseName = @"";
    }
    NSString *wid = dic[@"wid"];
    if (wid == nil || [wid isKindOfClass:[NSNull class]]) {
        self.wid = @"";
    }
//    NSString *freeGiftType = dic[@"free_gift_type"];
//    if (freeGiftType == nil || [freeGiftType isKindOfClass:[NSNull class]]) {
//        self.freeGiftType = @"";
//    }
    
//    NSString *userid = dic[@"user_id"];
//    if (userid == nil || [userid isKindOfClass:[NSNull class]]) {
//        self.userid = @"";
//    }
    
    NSString *show_discount_icon = dic[@"show_discount_icon"];
    if (show_discount_icon == nil || [show_discount_icon isKindOfClass:[NSNull class]]) {
        self.show_discount_icon = @"";
    }
    
    NSString *discount = dic[@"discount"];
    if (discount == nil || [discount isKindOfClass:[NSNull class]]) {
        self.discount = @"";
    }
    
    NSString *flash_sale_active_id = dic[@"flash_sale_active_id"];
    if (flash_sale_active_id == nil || [flash_sale_active_id isKindOfClass:[NSNull class]]) {
        self.flash_sale_active_id = @"";
    }
    
    NSString *goodsStock = dic[@"goods_stock"];
    if (goodsStock == nil || [goodsStock isKindOfClass:[NSNull class]]) {
        self.goodsStock = @"";
    }
    
    NSString *is_flash_sale = dic[@"is_flash_sale"];
    if (is_flash_sale == nil || [is_flash_sale isKindOfClass:[NSNull class]]) {
        self.is_flash_sale = @"";
    }
    NSString *cat_name = dic[@"cat_name"];
    if (cat_name == nil || [cat_name isKindOfClass:[NSNull class]]) {
        self.cat_name = @"";
    }
    
    NSString *cat_id = dic[@"cat_id"];
    if (cat_id == nil || [cat_id isKindOfClass:[NSNull class]]) {
        self.cat_id = @"";
    }
    return YES;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsId" : @"goods_id",
             @"goods_sn" : @"goods_sn",
             @"specialId" : @"specialId",
             @"cat_name" : @"cat_name",
             @"goodsName" : @"goods_name",
             @"goodsNumber" : @"goods_number",
             @"goodsAttr" : @"goods_attr",
             @"goodsPrice" : @"goods_price",
             @"marketPrice" : @"market_price",
//             @"warehouseCode" : @"warehouse_code",
             @"warehouseName" : @"warehouse_name",
             @"goodsThumb" : @"goods_thumb",
             @"isFavorite" : @"is_collect",
//             @"userid" : @"user_id",
             @"isOnSale" : @"is_on_sale",
             @"goodsStock" : @"goods_stock",
             @"isChecked" : @"is_checked",
             @"stateType" : @"flag",
//             @"freeGiftType" : @"free_gift_type",
             @"is_flash_sale" : @"is_flash_sale",
             @"cat_id" : @"cat_id",
             @"cat_name" : @"cat_name",
             };
}


+(NSString*)tableName
{
    return kCartTableName;
}

+(NSDictionary*)tableEntityMapping
{
    return @{
             @"rowid"     :BCSqliteTypeMakeTextPrimaryKey(@"rowid", NO),
             @"goodsId"     :BCSqliteTypeMakeText(@"goodsId", YES),
             @"goods_sn"     :BCSqliteTypeMakeText(@"goods_sn", YES),
             @"specialId"     :BCSqliteTypeMakeText(@"specialId", YES),
             @"is_exchange"     :BCSqliteTypeMakeText(@"is_exchange", YES),
             @"exchange_label"     :BCSqliteTypeMakeText(@"exchange_label", YES),
             @"cat_name"     :BCSqliteTypeMakeText(@"cat_name", YES),
             @"goodsName"   :BCSqliteTypeMakeText(@"goodsName", YES),
             @"goodsNumber"   :BCSqliteTypeMakeInt(@"goodsNumber", NO),
             @"goodsPrice"   :BCSqliteTypeMakeText(@"goodsPrice", YES),
             @"marketPrice"   :BCSqliteTypeMakeText(@"marketPrice", YES),
             @"goodsAttr"   :BCSqliteTypeMakeText(@"goodsAttr", YES),
             @"goodsThumb"   :BCSqliteTypeMakeText(@"goodsThumb", YES),
             @"isFavorite"   :BCSqliteTypeMakeIntDefault(@"isFavorite", YES, @"0"),
             @"modify"   :BCSqliteTypeMakeText(@"modify", YES),
             @"store"   :BCSqliteTypeMakeText(@"store", YES),
             @"warehouseName"   :BCSqliteTypeMakeText(@"warehouseName", YES),
             @"wid"   :BCSqliteTypeMakeText(@"wid", YES),
             @"selected"   :BCSqliteTypeMakeIntDefault(@"selected", YES, @"0"),
             @"totalPrice"   :BCSqliteTypeMakeText(@"totalPrice", YES),
             @"isOnSale"  :BCSqliteTypeMakeIntDefault(@"isOnSale", YES, @"0"),
             @"goodsStock" : BCSqliteTypeMakeInt(@"goodsStock", YES),
             @"isChecked" : BCSqliteTypeMakeInt(@"is_checked", NO),
//             @"freeGiftType"   :BCSqliteTypeMakeText(@"freeGiftType", YES),
             @"show_discount_icon"   :BCSqliteTypeMakeText(@"show_discount_icon", YES),
             @"discount"   :BCSqliteTypeMakeText(@"discount", YES),
             @"flash_sale_active_id"   :BCSqliteTypeMakeText(@"flash_sale_active_id", YES),
             @"is_flash_sale"   :BCSqliteTypeMakeText(@"is_flash_sale", YES),
             };
}

- (NSString *)description {
//    return [NSString stringWithFormat:@"goodsId = %@/n,goodsSn = %@/n,specialId = %@/n,is_exchange = %@/n,exchange_label = %@/n,catName = %@/n,goodsName = %@/n,goodsNumber = %ld/n,goodsAttr = %@/n,goodsPrice = %@/n,marketPrice = %@/n,modify = %@/n,store = %@/n,warehouseName = %@/n,wid = %@/n,goodsThumb = %@/n,isFavorite = %ld/n,isOnSold = %ld/n,goodsStock = %@/n,isChecked = %ld/n,freeGiftType = %@/n,show_discount_icon = %@/n,discount = %@/n,flash_sale_active_id = %@/n,is_flash_sale = %@/n",self.goodsId,self.goodsSn,self.specialId,self.is_exchange,self.exchange_label,self.catName,self.goodsName,(long)self.goodsNumber,self.goodsAttr,self.goodsPrice,self.marketPrice,self.modify,self.store,self.warehouseName,self.wid,self.goodsThumb,(long)self.isFavorite,(long)self.isOnSale,self.goodsStock,(long)self.isChecked,self.freeGiftType,self.show_discount_icon,self.discount,self.flash_sale_active_id,self.is_flash_sale];
    
    // freeGiftType 无
    return [NSString stringWithFormat:@"goodsId = %@/n,goods_sn = %@/n,specialId = %@/n,is_exchange = %@/n,exchange_label = %@/n,catName = %@/n,goodsName = %@/n,goodsNumber = %ld/n,goodsAttr = %@/n,goodsPrice = %@/n,marketPrice = %@/n,modify = %@/n,store = %@/n,warehouseName = %@/n,wid = %@/n,goodsThumb = %@/n,isFavorite = %ld/n,isOnSold = %ld/n,goodsStock = %@/n,isChecked = %ld/n,show_discount_icon = %@/n,discount = %@/n,flash_sale_active_id = %@/n,is_flash_sale = %@/n",self.goodsId,self.goods_sn,self.specialId,self.is_exchange,self.exchange_label,self.cat_name,self.goodsName,(long)self.goodsNumber,self.goodsAttr,self.goodsPrice,self.marketPrice,self.modify,self.store,self.warehouseName,self.wid,self.goodsThumb,(long)self.isFavorite,(long)self.isOnSale,self.goodsStock,(long)self.isChecked,self.show_discount_icon,self.discount,self.flash_sale_active_id,self.is_flash_sale];
}

@end
