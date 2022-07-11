//
//  STLGoodsBaseModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
@class STLFlashSaleModel;

@interface STLGoodsBaseModel : NSObject

@property (nonatomic, copy) NSString *goodsId;// 商品ID--good_id
@property (nonatomic, copy) NSString *goods_sn;// 商品ID--sku
@property (nonatomic, copy) NSString *virtual_spu;//商品详情里
@property (nonatomic, copy) NSString *spu;// spu
@property (nonatomic, copy) NSString *goodsTitle;
@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *cat_name;
@property (nonatomic,copy) NSString *shop_price;//商品价格 US
@property (nonatomic,copy) NSString *market_price;//商品价格 US


@property (nonatomic,copy) NSString *shop_price_converted;//商品价格带货币
@property (nonatomic,copy) NSString *market_price_converted;//商品价格带货币
@property (nonatomic,copy) NSString *goods_price_converted;//商品价格带货币

@property (nonatomic, copy) NSString *discount;

@property (nonatomic, copy) NSString *show_discount_icon; // 是否显示折扣标 (1显示，0不显示)

//专题活动 0元
@property (nonatomic,copy) NSString *specialId;

@property (nonatomic, strong) STLFlashSaleModel *flash_sale;
//活动水印
@property (nonatomic, strong) NSDictionary       *goods_watermark;

@property (nonatomic, assign) NSInteger goods_img_w; // 图片宽
@property (nonatomic, assign) NSInteger goods_img_h; // 图片高

@property (nonatomic,assign) NSInteger is_new;//1 新品
@property (nonatomic,assign) NSInteger cart_exists;//购物车是否存在


/*
 {
     "code":"UK",
     "cate_id":"8",
     "content":{
         "XXS":"3",
         "XS":"3.5",
         "M":"5",
         "S":"4"
     },
     "is_default":0
}
 */
@property (nonatomic,strong) NSArray <NSDictionary *> *size_mapping_list;

////自定义
@property (nonatomic, copy) NSString *tips_reduction;
///列表价格模块高度
@property (nonatomic, assign) CGFloat goodsListPriceHeight;
///列表满减提示高度
@property (nonatomic, assign) CGFloat goodsListFullActitityHeight;
@property (nonatomic, assign) BOOL hadHandlePriceHeight;

- (BOOL)isShowGoodDetailFlash;

- (BOOL)isShowGoodDetailNew;
@end



@interface STLFlashSaleModel : NSObject

///这个是活动设置的总库存，没什么用，不会变0

@property (nonatomic, copy) NSString *active_stock;
@property (nonatomic, copy) NSString *active_price;

@property (nonatomic, copy) NSString *save;
@property (nonatomic, copy) NSString *save_converted;
@property (nonatomic, copy) NSString *is_can_buy;
@property (nonatomic, copy) NSString *sold_num;
@property (nonatomic, copy) NSString *active_id;
@property (nonatomic, copy) NSString *expire_time;
//活动状态  0未开始  1进行中  2已结束
@property (nonatomic, copy) NSString *active_status;

@property (nonatomic, assign) double flash_start_time;// 闪购开始时间
@property (nonatomic, assign) double flash_end_time;// 闪购结束时间
// 1卖光了
@property (nonatomic, copy) NSString *sold_out;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *active_limit;
@property (nonatomic, copy) NSString *active_discount;
@property (nonatomic, copy) NSString *buy_notice; //新增 商详页闪购商品tip 提示的字段

@property (nonatomic,copy) NSString *active_price_converted;//商品价格带货币
//@property (nonatomic,copy) NSString *market_price_converted;//商品价格带货币

////只是闪购活动
- (BOOL)isOnlyFlashActivity;

////活动进行中 （闪购活动中 不显示满减活动）
- (BOOL)isFlashActiving;
////活动是否进行中，有库存，可购买
- (BOOL)isCanBuyFlashSaleStateing;

////活动是否进行中，可以购买数量判断
- (BOOL)isCanBuyFlashSaleStateingBuyNumber:(NSInteger)number;
@end;
