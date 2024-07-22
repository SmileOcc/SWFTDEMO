//
//  CheckOutGoodListModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/6.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsTagModel.h"
#import "ZFBaseOrderGoodsModel.h"

@interface CheckOutGoodListModel : ZFBaseOrderGoodsModel

@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *attr_color;
@property (nonatomic, copy) NSString *attr_size;
@property (nonatomic, copy) NSString *can_handsel;
@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *cat_name;
@property (nonatomic, copy) NSString *coupon_amount;
@property (nonatomic, copy) NSString *custom_size;
@property (nonatomic, copy) NSString *g_goods_number;
@property (nonatomic, copy) NSString *goods_attr_id;
@property (nonatomic, copy) NSString *goods_img;
@property (nonatomic, copy) NSString *goods_name;
@property (nonatomic, copy) NSString *goods_off;
@property (nonatomic, copy) NSString *goods_weight;
@property (nonatomic, copy) NSString *is_24h_ship;
@property (nonatomic, copy) NSString *is_delete;
@property (nonatomic, copy) NSString *is_free_shipping;
@property (nonatomic, copy) NSString *is_on_sale;
@property (nonatomic, copy) NSString *is_presale;
@property (nonatomic, copy) NSString *is_promote;
@property (nonatomic, copy) NSString *is_selected;
@property (nonatomic, copy) NSString *last_modified;
@property (nonatomic, copy) NSString *lmt_num;
@property (nonatomic, copy) NSString *market_price;
@property (nonatomic, copy) NSString *old_shop_price;
@property (nonatomic, copy) NSString *promote_end_date;
@property (nonatomic, copy) NSString *promote_price;
@property (nonatomic, copy) NSString *promote_start_date;
@property (nonatomic, copy) NSString *rec_id;
@property (nonatomic, copy) NSString *save_one_month;
@property (nonatomic, copy) NSString *session_id;
@property (nonatomic, copy) NSString *shelf_down_type;
@property (nonatomic, copy) NSString *shipping_method;
@property (nonatomic, copy) NSString *shop_price;
@property (nonatomic, copy) NSString *subtotal;
@property (nonatomic, copy) NSString *subtotal_yuan;
@property (nonatomic, copy) NSString *url_title;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *wj_linkid;
@property (nonatomic, copy) NSString *wj_linkid_source;
@property (nonatomic, copy) NSString *wp_image; //webp_image
@property (nonatomic, copy) NSString *real_time_number;
@property (nonatomic, assign) NSInteger     is_cod;
@property (nonatomic, strong) NSArray       *multi_attr;
@property (nonatomic, strong) NSArray<ZFGoodsTagModel *>   *tagsArray;

@property (nonatomic, strong) NSDictionary *cat_level_column;


/**
 获取统计数据
 */
- (NSDictionary *)gainAnalyticsParams;

@end
