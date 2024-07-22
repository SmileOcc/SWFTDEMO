//
//  GoodsDetailSameModel.h
//  ZZZZZ
//
//  Created by ZJ1620 on 16/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsDetailSameModel : NSObject

@property (nonatomic, copy) NSString *goods_id;//商品编号
@property (nonatomic, copy) NSString *goods_sn; // 商品SKU
@property (nonatomic, copy) NSString *cat_id;//分类ID
@property (nonatomic, copy) NSString *goods_title;//商品标题

@property (nonatomic, copy) NSString *shop_price;// 商品销售价
@property (nonatomic, copy) NSString *market_price;//商品市场价

@property (nonatomic, copy) NSString *wp_image;//webpImage
@property (nonatomic, copy) NSString *goods_img;
@property (nonatomic, copy) NSString *is_collect;
@property (nonatomic, assign) NSInteger goods_number;
@property (nonatomic, copy)  NSString *is_on_sale;//商品上架状态{1：上架，0：下架}

///类型 1=秒杀价 2=新用户专享价 3=App专享价 4=清仓价 5=促销价
@property (nonatomic, assign) NSInteger price_type;

/// V370新增growingIO 上传字段
@property (nonatomic, strong) NSDictionary *cat_level_column;


//occ3.7.0hacker 若放出来，注意修改.m中文件
//@property (nonatomic, copy) NSString *short_name;//简称
//@property (nonatomic, copy) NSString *goods_thumb;// 商品缩略图（100*100）
//@property (nonatomic, copy) NSString *goods_grid;// 商品缩略图（150*150）
//@property (nonatomic, copy) NSString *url_title;//URL使用标题
//@property (nonatomic, copy) NSString *promote_price;// 商品促销价
//@property (nonatomic, copy) NSString *promote_zhekou;//折扣百分数
//@property (nonatomic, copy) NSString *odr;//排序
//@property (nonatomic, copy) NSString *is_promote;//是否促销
//@property (nonatomic, copy) NSString *is_mobile_price;//是否手机专享价
//@property (nonatomic, assign) BOOL   is_cod;

- (BOOL)showMarketPrice;

@end
