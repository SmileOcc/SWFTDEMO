//
//  GoodsDetailModel.m
//  Dezzal
//
//  Created by ZJ1620 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "GoodsDetailModel.h"
#import "YWCFunctionTool.h"
#import "ExchangeManager.h"

@implementation GoodsDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"same_cat_goods"        : @"same_cat_goods",
             @"same_goods_spec"       : @"same_goods_spec",
             @"properties"            : @"properties",
             @"specification"         : @"specification",
             @"pictures"              : @"pictures",
             @"goods_name"            : @"goods_name",
             @"goods_number"          : @"goods_number",
             @"is_on_sale"            : @"is_on_sale",
             @"is_promote"            : @"is_promote",
             @"is_cod"                : @"is_cod",
             @"market_price"          : @"market_price",
             @"promote_zhekou"        : @"promote_zhekou",
             @"shop_price"            : @"shop_price",
             @"size_url"              : @"size_url",
             @"model_url"             : @"model_url",
             @"desc_url"              : @"desc_url",
             @"is_collect"            : @"is_collect",
             @"like_count"            : @"like_count",
             @"goods_id"              : @"goods_id",
             @"goods_sn"              : @"goods_sn",
             @"reViewCount"           : @"review_count",
             @"rateAVG"               : @"review_avg_rate",
             @"wp_image"              : @"wp_image",
             @"shipping_tips"         : @"shipping_tips",
             @"reductionModel"        : @"is_bundles_reduction",
             @"goods_mulit_attr"      : @"goods_mulit_attr",
             @"tagsArray"             : @"tags",
             @"activityModel"         : @"floatWindow",
             @"activityIconModel"     : @"activityInfo",
             @"is_full"               : @"is_full",
             @"is_added"              : @"is_added",
             @"instalmentModel"       : @"instalment",
             @"radioMsgModel"         : @"radio_msg",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"pictures"            : [GoodsDetailPictureModel class],
             @"same_cat_goods"      : [GoodsDetailSameModel class],
             @"same_goods_spec"     : [GoodsDetailSizeColorModel class],
             @"reductionModel"      : [GoodsReductionModel class],
             @"goods_mulit_attr"    : [GoodsDetailMulitAttrModel class],
             @"tagsArray"           : [ZFGoodsTagModel class],
             @"activityModel"       : [GoodsDetailActivityModel class],
             @"activityIconModel"   : [ZFGoodsDetailActivityIconModel class],
             @"instalmentModel"     : [InstalmentModel class],
             @"radioMsgModel"       : [ZFRadioMsgModel class],
             @"goods_model_data"    : [GoodsDetailsProductDescModel class]
             };
}

- (NSDictionary *)gainAnalyticsParams
{
    NSString *skuSN = nil;
    if (self.goods_sn.length > 7) {
        skuSN = [self.goods_sn substringWithRange:NSMakeRange(0, 7)];
    }else{
        skuSN = self.goods_sn;
    }
    
    GoodsReductionModel *reductionModel = self.reductionModel;
    __block NSString *marketType = @"";
    
    NSArray *titleArray = [reductionModel.msg componentsSeparatedByString:@"||"];
    if ([titleArray count]) {
        [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *string = obj;
            NSRegularExpression *regularExpretion = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n|&nbsp"
                                                                                              options:0
                                                                                                error:nil];
            string = [regularExpretion stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
            if (idx == 0) {
                marketType = [marketType stringByAppendingFormat:@"%@", string];
            }else{
                marketType = [marketType stringByAppendingFormat:@" | %@", string];
            }
        }];
    }
    
    NSDictionary *params = @{
                             @"goodsName_var" : self.goods_name,  //商品名称
                             @"SKU_var" : self.goods_sn,           //SKU id
                             @"SN_var" : skuSN,                     //SN（取SKU前7位，即为产品SN）
                             @"firstCat_var" : ZFToString(self.cat_level_column[@"first_cat_name"]),       //一级分类
                             @"sndCat_var" : ZFToString(self.cat_level_column[@"snd_cat_name"]),           //二级分类
                             @"thirdCat_var" : ZFToString(self.cat_level_column[@"third_cat_name"]),       //三级分类
                             @"forthCat_var" : ZFToString(self.cat_level_column[@"forth_cat_name"]),       //四级分类
                             @"storageNum_var" : [NSString stringWithFormat:@"%ld", self.goods_number],        //库存数量
                             @"marketType_var" : marketType,        //营销类型
                             };
    return params;
}

#warning 埋点数据注意 YW
- (NSMutableArray<GoodsDetailSameModel *> *)same_cat_goods {
    if (!_same_cat_goods) {
        _same_cat_goods = [NSMutableArray array];
    }
    return _same_cat_goods;
}

/// 防止异常
- (NSInteger)buyNumbers {
    if (_buyNumbers <= 0 || _buyNumbers > 100) {
        _buyNumbers = 1;
    }
    return _buyNumbers;
}

- (BOOL)showMarketPrice {
    if (self.price_type == 1 || self.price_type == 2 || self.price_type == 3 || self.price_type == 4 || self.price_type == 5) {
        return YES;
    }
    return NO;
}

@end

#pragma mark - ==========================================================================================

@implementation GoodsShowExploreModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"reviewsId"        : @"id",
             };
}

@end


#pragma mark - ==========================================================================================


@implementation AFparams

- (ZFBTSModel *)exChangeBTSModel
{
    ZFBTSModel *btsModel = [[ZFBTSModel alloc] init];
    btsModel.planid = self.planid;
    btsModel.plancode = self.plancode;
    btsModel.versionid = self.versionid;
    btsModel.bucketid = self.bucketid;
    btsModel.policy = self.policy;
    
    return btsModel;
}

@end

#pragma mark - ==========================================================================================


@implementation InstalmentModel


// 配置分期付款标签模型
- (ZFGoodsTagModel *)instalmentTagModel {
    if (!_instalmentTagModel) {
        _instalmentTagModel = [[ZFGoodsTagModel alloc] init];
        NSString *price = [ExchangeManager transforPrice:self.per];
        _instalmentTagModel.tagTitle = [NSString stringWithFormat:@"%@ x %@ %@",self.instalments, price, ZFToString(self.installment_str)];
        _instalmentTagModel.tagColor = @"#666666";
        _instalmentTagModel.borderColor = @"#FFFFFF";
        _instalmentTagModel.fontSize = 14;
    }
    return _instalmentTagModel;
}

@end


@implementation ZFRadioMsgModel


- (NSString *)detailVCAllTipText {
    if (!_detailVCAllTipText) {
        NSString *allTipText = self.cartRadioHint;
        NSString *replaceText = self.cart_shipping_free_amount_replace;
        // BOOL showArrow = [self.cart_shipping_free_amount floatValue]>0; 是否显示箭头
        NSString *price = nil;
        if (!ZFIsEmptyString(replaceText) && replaceText.length > 1) {
            price = [replaceText substringFromIndex:1];
        }
        
        if (price && [allTipText containsString:replaceText]) {
            NSString *amount = [ExchangeManager transforPrice:price];
            NSInteger priceLocation = [[allTipText componentsSeparatedByString:replaceText] firstObject].length;
            NSRange range = NSMakeRange(priceLocation, replaceText.length);
            if (!ZFIsEmptyString(amount)) {
                allTipText = [allTipText stringByReplacingCharactersInRange:range withString:amount];
            }
        }
        _detailVCAllTipText = allTipText;
    }
    return _detailVCAllTipText;
}

@end


#pragma mark - ==========================================================================================


@implementation GoodsDetailsModelInfo
@end


@implementation GoodsDetailsProductDescModel

- (CGFloat)contentViewHeight {
    if (_contentViewHeight < 63) {
        _contentViewHeight = 63;
    }
    return _contentViewHeight;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list" : [GoodsDetailsModelInfo class],
             };
}
@end
