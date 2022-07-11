//
//  OSSVHomeCThemeModel.h
// OSSVHomeCThemeModel
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAdvsEventsModel.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVNewUserPrGoodsModel.h"
#import "OSSVThemeZeroPrGoodsModel.h"

@class STLHomeCGoodsModel;
@class STLHomeCThemeChannelModel;
@class Coupon_item;
@interface OSSVHomeCThemeModel : NSObject

@property (nonatomic, copy) NSString *sort;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *colour;

@property (nonatomic, copy) NSString *bg_color;

@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger currentPage;

//old用户
@property (nonatomic, copy) NSString *oldUserCartTips;

//频道type:7
@property (nonatomic, strong) NSArray *channel;

//商品type:1
@property (nonatomic, strong) NSArray *goodsList;

//单行type:2
@property (nonatomic, strong) NSArray<STLAdvEventSpecialModel*> *modeImg;

//单行type:2
@property (nonatomic, strong) STLAdvEventSpecialModel *couponButton;

//滑动商品type:10
@property (nonatomic, strong) NSArray *slideList;
//滑动商品专题ID
@property (nonatomic, copy) NSString *specialId;

//new用户滑动礼包type:11
@property (nonatomic, strong) NSArray <OSSVNewUserPrGoodsModel * > *giftList;

// 0元活动商品
@property (nonatomic, strong) NSArray <OSSVThemeZeroPrGoodsModel *> *exchange;
@property (nonatomic, assign) NSInteger cart_exists;

///自定义
////自定义 (type=101)滑动组件商品图片比例 3/4  或1/1 默认3/4
@property (nonatomic, assign) CGFloat                     imageScale;

// 1.4.0  优惠券

@property (nonatomic , copy) NSString                               * get_type;
@property (nonatomic , copy) NSString                               * coupon_str;
@property (nonatomic , assign) NSInteger                            received;
@property (nonatomic , copy) NSString                               * coupon_real_str;
@property (nonatomic , copy) NSString                               * theme;
@property (nonatomic , copy) NSString                               * bg_image;
@property (nonatomic , copy) NSString                               * bg_color_val;
@property (nonatomic , strong) NSDictionary                         * btn_multi;
@property (nonatomic , strong) NSDictionary                         * btn;
@property (nonatomic , strong) NSArray <Coupon_item *>              * coupon_items;

@end

@interface Coupon_item :NSObject
@property (nonatomic , copy)   NSString              * coupon_id;
@property (nonatomic , copy)   NSString              * coupon_code;
@property (nonatomic , copy)   NSString              * type;
@property (nonatomic , copy)   NSString              * type_name;
@property (nonatomic , copy)   NSString              * day_time;
@property (nonatomic , copy)   NSString              * title;
@property (nonatomic , strong) NSArray <NSString *>  * content;
@property (nonatomic , copy)   NSString              * expiry_date_str;
@property (nonatomic , assign) NSInteger              is_received;

@end


@interface STLHomeCGoodsModel : STLGoodsBaseModel

@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *wid;
//@property (nonatomic, copy) NSString *goodsSn;
//@property (nonatomic, copy) NSString *marketPrice;
//@property (nonatomic, copy) NSString *shopPrice;
@property (nonatomic, copy) NSString *url_title;
@property (nonatomic, copy) NSString *goods_img;
@property (nonatomic, copy) NSString *goods_original;
//@property (nonatomic, copy) NSString *imgHeight;
//@property (nonatomic, copy) NSString *imgWidth;
@property (nonatomic, copy) NSString *mark_img;

//@property (nonatomic, copy) NSString *marketPriceConverted;
//@property (nonatomic, copy) NSString *shopPriceConverted;

@property (nonatomic,copy) NSString *goods_number;
@property (nonatomic,copy) NSString *goods_title;

@property (nonatomic,assign) NSInteger is_collect;// 此商品是否收藏
@property (nonatomic,copy) NSString *collect_count;// 此商品收藏人数数量

///专题 排行商品 销量
@property (nonatomic, copy) NSString *sale_num;

///自定义 是否显示排行角标 排行角标是多少
@property (nonatomic, assign) NSInteger  ranking;
@property (nonatomic, assign) NSInteger  rankIndex;
///自定义  排行类型（销量排行，收藏排行）
@property (nonatomic, assign) NSInteger rankType;
///自定义
@property (nonatomic, copy) NSMutableAttributedString *lineMarketPrice;


////v1.1.2版本 不知道怎么谁动了后台，goods_id改成了goodsId
-(OSSVHomeGoodsListModel *)exchangeHomeGoodsListModel;

@end


@interface STLHomeCThemeChannelModel : NSObject

@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *channelSort;
@property (nonatomic, copy) NSString *cat_id;
@property (nonatomic, strong) NSArray *goodsList;


//首页底部菜单
//(注释：集合数据中，channel_id，第一个才是有效的，后面无效的）
@property (nonatomic, copy) NSString *category_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *channel_id;

@end

