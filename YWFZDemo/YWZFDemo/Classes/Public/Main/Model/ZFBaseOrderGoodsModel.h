//
//  ZFBaseOrderGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 2019/8/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  各种下单模型中的商品模型基类

#import <Foundation/Foundation.h>
#import "ZFHackerPointModel.h"

@interface ZFBaseOrderGoodsModel : NSObject

///商品id
@property (nonatomic, copy) NSString *goods_id;

///商品sku id
@property (nonatomic, copy) NSString *goods_sn;

///商品数量
@property (nonatomic, copy) NSString *goods_number;

///商品名称
@property (nonatomic, copy) NSString *goods_title;

///商品品牌<只有订单列表接口会返回这个参数>
@property (nonatomic, copy) NSString *goods_brand;

///商品价格
@property (nonatomic, copy) NSString *goods_price;


@property (nonatomic, strong) ZFHackerPointGoodsModel *hacker_point;

//新增growingIO 统计代码
@property (nonatomic, strong) NSDictionary *cat_level_column;

- (NSDictionary *)gainAnalyticsParams;

@end

