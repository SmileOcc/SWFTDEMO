//
//  GoodsModel.h
//  ZZZZZ
//
//  Created by YW on 18/9/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailModel.h"
#import "ZFCollectionCellDatasourceProtocol.h"

@class ZFGoodsTagModel;

//We Recommend、Your Recent history
static NSString *GIORecommYour = @"We Recommend"; //商品详情推荐位
static NSString *GIORecommHistory = @"Your Recent history"; //首页底部商品推荐位
static NSString *GIORecommCar = @"Cart Recommend"; //购物车底部商品推荐位

//shows、outfits、videos
static NSString *GIOPostShows = @"shows";
static NSString *GIOPostOutfits = @"outfits";
static NSString *GIOPostVideos = @"videos";

@interface ZFGoodsModel : NSObject
<
    ZFCollectionCellDatasourceProtocol
>
/**
 * 活动图标
 */
@property (nonatomic, copy) NSString  *activityIcon;
/**
 * 分类名称
 */
@property (nonatomic, copy) NSString  *cat_name;
/**
 * 商品id
 */
@property (nonatomic, copy) NSString  *goods_id;
/**
 * 商品sku
 */
@property (nonatomic, copy) NSString  *goods_sn;
/**
 * 商品spu，同款id
 */
@property (nonatomic, copy) NSString  *goods_spu;
/**
 * 商品名称
 */
@property (nonatomic, copy) NSString  *goods_title;
/**
 * 商品上架状态{1：上架，0：下架}
 */
@property (nonatomic, copy) NSString  *is_on_sale;


/**
 * 是否收藏
 */
@property (nonatomic, copy) NSString  *is_collect;
/**
 * 商品库存
 */
@property (nonatomic, copy) NSString  *goods_number;
/**
 * 商品打标(最多显示3个)
 */
@property (nonatomic, strong) NSArray<ZFGoodsTagModel *>   *tagsArray;
/**
 * 商品图片(原图)
 */
@property (nonatomic, copy) NSString  *wp_image;
/**
 * 商品图片(小图,用于3d touch)
 */
@property (nonatomic, copy) NSString  *goods_thumb;
/**
 * 市场价格(带中划线的)
 */
@property (nonatomic, copy) NSString  *market_price;
/**
 * 当前售价,有折扣的话,则为折扣价
 */
@property (nonatomic, copy) NSString  *shop_price;


/********* 下面是自定义参数 *********/
/**
 * 判断是否需要显示收藏按钮
 * 首页推荐商品,收藏夹显示
 */
@property (nonatomic, assign) BOOL   isShowCollectButton;
/**
 * 判断是否需要隐藏市场价格
 * 首页推荐商品需要隐藏
 */
@property (nonatomic, assign) BOOL   isHideMarketPrice;
/**
 * 是否选中,用在社区post页面那里
 */
@property (nonatomic,assign) BOOL isSelected;

/********* 数据库操作 *********/
// 添加数据
+ (BOOL)insertDBWithModel:(ZFGoodsModel *)goodsModel;
// 更新数据
+ (BOOL)updateDBWithModel:(ZFGoodsModel *)goodsModel;
// 查询单条数据
+ (ZFGoodsModel *)selectDBWithGoodsID:(NSString *)goodsID;
// 删除数据
+ (BOOL)deleteDBWithGoodsID:(NSString *)goodsID;
// 删除所有数据
+ (BOOL)deleteAllGoods;
// 查询所有数据
+ (void)selectAllGoods:(void(^)(NSArray<ZFGoodsModel *> *))block;
// 同步查询所有数据
+ (NSArray<ZFGoodsModel *> *)selectAllGoods;


/** v3.6.0新增字段  折扣比例*/
@property (nonatomic, copy) NSNumber *promote_zhekou;
/** v3.6.0新增字段 自营销商品:1.热卖品 2.潜力品 3.新品 */
@property (nonatomic, copy) NSNumber *channel_type;
/** v3.6.0新增字段 0正常商品 1失效商品 */
@property (nonatomic, assign) BOOL is_disabled;
/** v3.6.0新增字段 0没有相似商品 1有相似商品，和 is_disabled 配合使用 */
@property (nonatomic, assign) BOOL is_similar;

/** v3.6.0 新增自定义字段,后台没返回,为了让收藏界面的数据不显示折扣/自营销标签/活动氛围 */
@property (nonatomic, assign) BOOL hiddenTag;

/// V370新增growingIO 上传字段
@property (nonatomic, strong) NSDictionary *cat_level_column;
/// V370新增GA统计原生专题banner名称，非后台接口返回
@property (nonatomic, copy) NSString *nativeBannerName;

/// v391新增grwingIO 字段，非后台接口返回，仅用于赋值传值
///推荐位类型 取值包括We Recommend、Your Recent history、Customers also viewed
@property (nonatomic, copy) NSString *recommentType;
///帖子类型 取值包括shows、outfits、videos
@property (nonatomic, copy) NSString *postType;

/**v4.1.0新增图片组（包含纯背景的.png图) （不一定有这个数据)*/
@property (nonatomic, strong) NSArray   *pictures;

//自定义
@property (nonatomic, copy) NSString    *pureImageName;
// 自定义分类id
@property (nonatomic, copy) NSString    *cateMenuId;


// v440 增加
// 多色标，0 为否 1 为是
@property (nonatomic, assign) BOOL same_color;
// 营销类型名
@property (nonatomic, copy) NSString *sale_type;


///保存模型在视图中的位置，用于af统计上传，需要从1开始，所以赋值的时候都 +1
@property (nonatomic, assign) NSInteger af_rank;

//自定义
@property (nonatomic, assign) NSInteger selectSkuCount;

/// 4.5.7添加   巴西站分期付款字段
@property (nonatomic, assign) BOOL isInstallment;
// 巴西分期对象
@property (nonatomic, strong) InstalmentModel *instalMentModel;

// v4.5.7  剩余倒计时
@property (nonatomic, copy) NSString *countDownTime;

// 是否为打板商品
@property (nonatomic, assign) BOOL is_making;

/**
 * 同款商品数据 v4.6.0
 */
@property (nonatomic, strong) NSArray <ZFGoodsModel *> *groupGoodsList;

/**
 * 商品颜色，列表页色块值 v4.6.0
 */
@property (nonatomic, copy) NSString *color_code;
/**
 * 商品颜色图，列表页色块 v4.6.0
 */
@property (nonatomic, copy) NSString *color_img;
/**
 * 当前选中的商品颜色图 v4.6.0
 */
@property (nonatomic, assign) NSInteger selectedColorIndex;

/** 标识主页推荐位数据来源于大数据 */
@property (nonatomic, assign) BOOL isBigCommendDataType;

- (NSDictionary *)gainAnalyticsParams;

///获取市场价格划线富文本
- (NSAttributedString *)gainMarkPriceAttributedString;

///商品促销价类型 1=秒杀价 2=新用户专享价 3=App专享价 4=清仓价 5=促销价
@property (nonatomic, assign) NSInteger price_type;

@property (nonatomic, copy) NSAttributedString *RRPAttributedPriceString;

///显示价格是否需要换行
@property (nonatomic, assign) BOOL priceNeedWrapLine;

- (BOOL)handleRRPPrice;

- (BOOL)showMarketPrice;
@end
