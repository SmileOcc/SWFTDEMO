//
//  MyOrderGoodListModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/11.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFBaseOrderGoodsModel.h"
#import "ZFHackerPointModel.h"
#import "ZFMultAttributeModel.h"

@interface MyOrderGoodListModel : ZFBaseOrderGoodsModel

@property (nonatomic, copy) NSString *brand_id;

@property (nonatomic, copy) NSString *goods_grid;

@property (nonatomic, copy) NSString *goods_img;

@property (nonatomic, copy) NSString *goods_thumb;

@property (nonatomic, copy) NSString *is_promote;

@property (nonatomic, copy) NSString *promote_price;

@property (nonatomic, copy) NSString *wp_image;

@property (nonatomic, copy) NSString *shop_price;

@property (nonatomic, copy) NSString *attr_color;
@property (nonatomic, copy) NSString *attr_size;
@property (nonatomic,assign) NSInteger is_review;//是否评论
@property (nonatomic, strong) NSArray<ZFMultAttributeModel *>           *multi_attr;

////新增服务器返回的字段goods_price, 发现V3.6.0在订单列表支付成功时统计代码用错字段(shop_price)
//@property (nonatomic, copy) NSString *goods_price;
//新增growingIO 统计代码
//@property (nonatomic, strong) NSDictionary *cat_level_column;

/**
 获取统计数据

 @return 统计数据
 */
- (NSDictionary *)gainAnalyticsParams;

@end
