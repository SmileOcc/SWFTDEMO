//
//  OrderDetailGoodModel.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "OrderDetailGoodModel.h"
#import "ZFMultAttributeModel.h"
#import "YWCFunctionTool.h"

@implementation OrderDetailGoodModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cat_level_column = [NSDictionary new];
        self.hacker_point = [ZFHackerPointGoodsModel new];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"multi_attr" : [ZFMultAttributeModel class],
             @"hacker_point" : [ZFHackerPointGoodsModel class]
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
    
    NSDictionary *params = @{
                             @"goodsName_var" : self.goods_title,  //商品名称
                             @"SKU_var" : self.goods_sn,           //SKU id
                             @"SN_var" : skuSN,                     //SN（取SKU前7位，即为产品SN）
                             @"firstCat_var" : ZFToString(self.cat_level_column[@"first_cat_name"]),       //一级分类
                             @"sndCat_var" : ZFToString(self.cat_level_column[@"snd_cat_name"]),           //二级分类
                             @"thirdCat_var" : ZFToString(self.cat_level_column[@"third_cat_name"]),       //三级分类
                             @"forthCat_var" : ZFToString(self.cat_level_column[@"forth_cat_name"]),       //四级分类
                             @"storageNum_var" : ZFToString(self.goods_number),        //库存数量
                             @"marketType_var" : @"",        //营销类型
                             };
    return params;
}

@end
