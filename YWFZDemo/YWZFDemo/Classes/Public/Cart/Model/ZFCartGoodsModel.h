//
//  ZFCartGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFGoodsTagModel.h"

@interface ZFCartGoodsModel : NSObject
@property (nonatomic, copy) NSString *wp_image; //webp_image
@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *attr_color;
@property (nonatomic, copy) NSString *attr_size;
@property (nonatomic, assign) NSInteger buy_number;
@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, copy) NSString *cat_name;
@property (nonatomic, copy) NSString *custom_size;
@property (nonatomic, copy) NSString *goods_attr_id;
@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_img;
@property (nonatomic, copy) NSString *goods_name;
@property (nonatomic, assign) NSInteger goods_number;
@property (nonatomic, copy) NSString *goods_off;
@property (nonatomic, copy) NSString *goods_sn;
@property (nonatomic, copy) NSString *goods_title;
@property (nonatomic, copy) NSString *goods_volume_weight;
@property (nonatomic, copy) NSString *goods_weight;
@property (nonatomic, assign) BOOL if_collect;
@property (nonatomic, assign) BOOL is_cod;
@property (nonatomic, copy) NSString *is_dinghuo_goods;
@property (nonatomic, assign) NSInteger is_mobile_price;
@property (nonatomic, copy) NSString *is_free_shipping;
@property (nonatomic, assign) NSInteger is_promote;
@property (nonatomic, assign) NSInteger is_selected;
@property (nonatomic, copy) NSString *last_modified;
@property (nonatomic, copy) NSString *market_price;
@property (nonatomic, copy) NSString *promote_end_date;
@property (nonatomic, copy) NSString *promote_price;
@property (nonatomic, copy) NSString *promote_start_date;
@property (nonatomic, copy) NSString *rec_id;
@property (nonatomic, copy) NSString *session_id;
@property (nonatomic, copy) NSString *shipping_method;
@property (nonatomic, copy) NSString *shop_price;
@property (nonatomic, copy) NSString *subtotal;
@property (nonatomic, copy) NSString *url_title;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *manzeng_id;
@property (nonatomic, assign) BOOL   is_full; //是否达到满赠金额
@property (nonatomic, assign) BOOL   is_valid; //是否为有效商品 1:有效 0:失效
@property (nonatomic, assign) BOOL   is_added;
@property (nonatomic, copy) NSString *giftLeftMsg; //赠品剩余件数多语言提示文案

@property (nonatomic, assign) NSInteger goods_state;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic, strong) NSArray           *multi_attr;
@property (nonatomic, strong) NSArray<ZFGoodsTagModel *>                    *tagsArray;

// v3.6.0
@property (nonatomic, assign) BOOL is_similar;

@property (nonatomic, copy) NSString *cartSizeAttrTitle;

///商品折扣类型
@property (nonatomic, assign) NSInteger price_type;

- (BOOL)showMarketPrice;

@end
