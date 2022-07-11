//
//  OSSVDetailsBaseInfoModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsBaseInfoModel.h"

@implementation OSSVDetailsBaseInfoModel

- (BOOL)isHasSizeItem{
    for (OSSVSpecsModel *specModel in self.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 2) {
            if(specModel.brothers.count){
                return true;
            }
        }
    }
    return false;
}

-(BOOL)isHasColorItem{
    for (OSSVSpecsModel *specModel in self.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 1) {
            if(specModel.brothers.count){
                return true;
            }
        }
    }
    return false;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"goodsId"         : @"goods_id",
             @"goods_sn"        : @"goods_sn",
             @"goodsSmallImg"   : @"goods_thumb",
             @"goodsImg"        : @"goods_img",
             @"goodsBigImg"     : @"goods_original",
             @"goodsUrlTitle"   : @"url_title",
             @"goodsBrand"      : @"brand",
             @"goodsGroupId"    : @"group_goods_id",
             @"goodsTitle"      : @"goods_title",
             @"goodsWeight"     : @"goods_weight",
             @"goodsVolumeWeight" : @"goods_volume_weight",
             @"goodsDeliveryTime" : @"delivery_time",
             @"goodsImgType"    : @"img_type",
             @"goodsImgWidth"   : @"img_width",
             @"goodsImgHeight"  : @"img_height",
             @"goodsDeliveryLevel" : @"delivery_level",
             @"goodsSupplierCode" : @"supplier_code",
             @"goodsDiscount"   : @"discount",
             @"goodsWid"        : @"wid",
             @"goodsMarketPrice" : @"market_price",
             @"shop_price"  : @"shop_price",
             @"goodsNumber"     : @"goods_number",
             @"goodsAttr"       : @"GoodsAttr",
             @"warehouseCode"   : @"warehouse_code",
             @"promoteLv"       : @"promote_lv",
             @"promotePrice" : @"promote_price",
             @"promoteStartDate" : @"promote_start_date",
             @"promoteEndDate": @"promote_end_date",
             @"promoteRemark" : @"promote_remark",
             @"cat_name" : @"cat_name",
             @"cat_id" : @"cat_id",
             @"isPromote"       : @"is_promote",
             @"isDelete"        : @"is_delete",
             @"isOnSale"        : @"is_on_sale",
             @"isFreeShipping"  : @"is_free_shipping",
             @"pictureListArray" : @"PicList",
             @"nowAttrArray"    : @"NowAttr",
             @"isCollect"       : @"is_Collect",
             @"reviewCount"     : @"reviewCount",
             @"reviewAvgRateAll" : @"avg_rate_all",
             @"changeAttrList" : @"ChangeAttrList",
             @"bundleActivity" : @"bundledActivity",
             @"warehouseName" : @"warehouse_name",
             @"showDiscountIcon" : @"show_discount_icon",
             @"urlmdesc"        :@"url_mdesc",
             @"isMobileOnly"        : @"is_app_price",
             @"appSavePrice"        : @"app_save_price",
             @"urlShare"            : @"url_share",
             @"codFreeShippingTip"  : @"cod_fee_shipping_tip",
             @"wishCount"           : @"wish_count",
             @"tips_info"           : @"tips_info",
             @"shop_price_origin"   : @"shop_price_origin",
             @"size_info"           : @"size_info",
             @"goods_watermark"      : @"goods_watermark",
             @"flash_sale"          : @"flash_sale",
             @"specialId"           : @"specialId",
             @"transportTimeModel"  : @"transportTip",
             @"serviceTipModel"     : @"newTipInfo",
             @"spuGoodsNumber"      : @"spu_goods_number",
             @"spuOnSale"           : @"is_spu_on_sale",
             @"return_coin"         : @"return_coin",
             @"return_coin_desc"    : @"return_coin_desc",
             @"GoodsSpecs"          : @"GoodsSpecs"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"pictureListArray"    : [OSSVDetailPictureArrayModel class],
             @"bundleActivity"      : [OSSVBundleActivityModel class],
             @"GoodsSpecs"          : [OSSVSpecsModel class],
             @"tips_info"           : [OSSVTipsInfoModel class],
             @"size_info"           : [OSSVSizeChartModel class],
             @"transportTimeModel"  : [OSSVTransportTimeModel class],
             @"serviceTipModel"     : [OSSVDetailServiceTipModel class],
             @"return_coin_desc"    : [OSSVCoinDescModel class]
             
             };
}

- (OSSVSpecsModel *)goodsChartSizeUrl {
    
    __block OSSVSpecsModel * sizeModel = nil;
    if (STLJudgeNSArray(self.GoodsSpecs)) {
        [self.GoodsSpecs enumerateObjectsUsingBlock:^(OSSVSpecsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *chartUrl = [obj goodsChartSizeUrl];
            
            if (!STLIsEmptyString(chartUrl)) {
                sizeModel = obj;
                *stop = YES;
            }
        }];
    }
    return  sizeModel;
}



- (NSMutableAttributedString *)selectSizeDesc:(NSString *)selectSize {
    __block NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
    
    if (!STLIsEmptyString(selectSize) && STLJudgeNSArray(self.size_info)) {
        
        [self.size_info enumerateObjectsUsingBlock:^(OSSVSizeChartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([STLToString(obj.size_name) isEqualToString:selectSize]) {
                
                if (STLJudgeNSArray(obj.position_data)) {
                    [obj.position_data enumerateObjectsUsingBlock:^(OSSVSizeChartItemModel * _Nonnull itemObj, NSUInteger itemIdx, BOOL * _Nonnull itemStop) {
                        if (STLIsEmptyString(desc.string)) {
                            
                            NSString *keyName = STLToString(itemObj.position_name);
                            NSString *keyValue = STLToString(itemObj.measurement_value);
                            NSMutableAttributedString *itemAttri = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@ %@",keyName,keyValue,STLLocalizedString_(@"Goods_cm", nil)]];
                            
                            [itemAttri addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_999999] range:NSMakeRange(0, itemAttri.string.length)];
                            
                            if (!STLIsEmptyString(keyValue)) {
                                NSRange valueRange = [itemAttri.string rangeOfString:keyValue];
                                if (valueRange.location != NSNotFound ) {
                                    [itemAttri addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_0D0D0D] range:valueRange];
                                }
                            }

                            [desc appendAttributedString:itemAttri];
                            
                        } else {
                            
                            NSString *keyName = STLToString(itemObj.position_name);
                            NSString *keyValue = STLToString(itemObj.measurement_value);
                            NSMutableAttributedString *itemAttri = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@:%@ %@",keyName,keyValue,STLLocalizedString_(@"Goods_cm", nil)]];
                            
                            [itemAttri addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_999999] range:NSMakeRange(0, itemAttri.string.length)];
                            
                            if (!STLIsEmptyString(keyValue)) {
                                NSRange valueRange = [itemAttri.string rangeOfString:keyValue];
                                if (valueRange.location != NSNotFound ) {
                                    [itemAttri addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_0D0D0D] range:valueRange];
                                }
                            }

                            [desc appendAttributedString:itemAttri];

                        }
                    }];
                    *stop = YES;
                } else {
                    *stop = YES;
                }
            }
                    
        }];
    }
    return desc;
}


- (BOOL)isGoodsDetailDiscountOrFlash {
    
    if ([self.showDiscountIcon isEqualToString:@"0"] || [OSSVNSStringTool isEmptyString:self.goodsDiscount] || [self.goodsDiscount isEqualToString:@"0"]) {
        
    } else {// 价格
        return YES;
    }
    
    //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
    if (self.flash_sale &&  [self.flash_sale.is_can_buy isEqualToString:@"1"] && [self.flash_sale.active_status isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

@end




@implementation OSSVBundleActivityModel

@end


@implementation OSSVSpecsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"brothers"    : [OSSVAttributeItemModel class],
             };
}

- (NSString *)goodsChartSizeUrl {
    if ([STLToString(self.spec_type) isEqualToString:@"2"] && !STLIsEmptyString(self.size_chart_url)) {
        return self.size_chart_url;
    }
    return @"";
}

@end

@implementation OSSVAttributeItemModel

@end



@implementation OSSVTipsInfoModel

@end


@implementation OSSVCoinDescModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"return_coin"         : @"return_coin",
        @"about_coin"          : @"about_coin",
        @"desc_list"           : @"desc_list"
    };
}

@end
