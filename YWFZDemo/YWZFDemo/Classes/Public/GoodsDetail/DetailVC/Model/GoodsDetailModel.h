//
//  GoodsDetailModel.h
//  Dezzal
//
//  Created by ZJ1620 on 16/8/1.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetialSizeModel.h"
#import "GoodsDetialColorModel.h"
#import "GoodsDetailPictureModel.h"
#import "GoodsDetailSameModel.h"
#import "GoodsDetailSizeColorModel.h"
#import "GoodsDetailFirstReviewModel.h"
#import "GoodsReductionModel.h"
#import "GoodsDetailMulitAttrModel.h"
#import "ZFGoodsTagModel.h"
#import "ZFCollocationBuyModel.h"
#import "GoodsDetailActivityModel.h"
#import "ZFGoodsDetailActivityIconModel.h"
#import "ZFBTSModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGoodsDetailProductModelDescCell.h"

@class ZFGoodsDetailGroupBuyModel, AFparams, InstalmentModel,
    ZFRadioMsgModel, GoodsShowExploreModel, ZFGoodsDetailOutfitsModel,
    GoodsDetailsProductDescModel;

@interface GoodsDetailModel : NSObject<YYModel>

@property (nonatomic, strong) NSMutableArray<GoodsDetailSameModel *> *same_cat_goods; //推荐商品[{size_list},{color_list}]
@property (nonatomic, strong) GoodsDetailSizeColorModel *same_goods_spec;//同款商品属性
@property (nonatomic, copy) NSString                    *properties;// 商品属性
@property (nonatomic, copy) NSString                    *specification;//商品规格（属性、规格只有一个有值）
@property (nonatomic, strong) NSArray<GoodsDetailPictureModel*> *pictures; //商品图片[{picture},{picture}]
@property (nonatomic, copy) NSString                    *goods_name;// 商品名称
@property (nonatomic, assign) NSInteger                 goods_number;// 商品库存
@property (nonatomic, copy) NSString                    *is_on_sale;//商品上架状态{1：上架，0：下架}
@property (nonatomic, copy) NSString                    *is_promote;//促销{1是0否}
@property (nonatomic, assign) BOOL                      is_cod;
@property (nonatomic, copy) NSString                    *market_price;//| 商品市场价
@property (nonatomic, copy) NSString                    *promote_zhekou;//商品折扣百分数
@property (nonatomic, copy) NSString                    *shop_price;//
@property (nonatomic, copy) NSString                    *size_url;// 尺码表H5 URL
@property (nonatomic, copy) NSString                    *model_url;//模特信息H5 URL
@property (nonatomic, copy) NSString                    *desc_url;  // 产品描述H5 URL
@property (nonatomic, copy) NSString                    *is_collect; //收藏{1：是，0：否}
@property (nonatomic, copy) NSString                    *like_count;
@property (nonatomic, copy) NSString                    *goods_id;//商品Id
@property (nonatomic, copy) NSString                    *goods_sn;
@property (nonatomic, copy) NSString                    *shipping_tips;
@property (nonatomic, copy) NSString                    *wp_image;//webpImage
@property (nonatomic, assign) NSInteger                 price_type;

// 此两个字段在商详重构后不需要了
@property (nonatomic, copy) NSString                    *reViewCount; // 评论数
@property (nonatomic, copy) NSString                    *rateAVG; // 总星星平均数

@property (nonatomic, copy) NSString                    *long_cat_name; // 用于AF统计
@property (nonatomic, copy) NSString                    *seid; // 
@property (nonatomic, copy) NSString                    *seid_url;//登录后的分享地址
@property (nonatomic, copy) NSString                    *lucky_draw_url;//分享后抽奖地址;
@property (nonatomic, assign) BOOL                      is_full; // 满足满赠条件  1满足 0 不满足
@property (nonatomic, assign) BOOL                      is_added; // 是否已经添加购物车  1满足 0 不满足
@property (nonatomic, copy) NSString                    *manzeng_id; // 满赠商品 id
@property (nonatomic, assign) BOOL                      cache_cdn; // 是否为cdn数据,  1:cdn,  0:非cdn
@property (nonatomic, copy) NSString                    *stock_tips;//库存提醒 V4.8.0 add

@property (nonatomic, copy) NSString                    *goods_desc_data;//产品描述V5.5.0 add
@property (nonatomic, strong) GoodsDetailsProductDescModel *goods_model_data;//产品模特描述

@property (nonatomic, strong) InstalmentModel                               *instalmentModel; //巴西分期付款信息
@property (nonatomic, strong) GoodsReductionModel                           *reductionModel;
@property (nonatomic, strong) NSArray<GoodsDetailMulitAttrModel *>          *goods_mulit_attr;
@property (nonatomic, strong) NSArray<ZFGoodsTagModel *>                    *tagsArray;
@property (nonatomic, strong) ZFGoodsDetailActivityIconModel                *activityIconModel; // 活动氛围
@property (nonatomic, strong) GoodsDetailActivityModel                      *activityModel;     // 秒杀活动
@property (nonatomic, strong) ZFGoodsDetailGroupBuyModel                    *groupBuyActivityModel; // 拼团活动
@property (nonatomic, strong) ZFRadioMsgModel                               *radioMsgModel;


//=================================以下字段: 非服务端返回================================================

/** Appflyer统计 */
@property (nonatomic, strong) AFparams *af_recommend_params;

/** GA电子商务加入购物车数量参数 不是接口返回的*/
@property (nonatomic, assign) NSInteger buyNumbers;

/** GrowingIO统计需要的参数*/
@property (nonatomic, strong) NSDictionary *cat_level_column;

/// 获取统计数据
- (NSDictionary *)gainAnalyticsParams;

/// 价格是否显示红色
- (BOOL)showMarketPrice;


/**
 * ========== 以下字段: 非服务端返回 V4.9.0 商详重构时添加 ==========
 *
 * 以下几个接口数据是单独接口返回跟商详主要接口走, 切换规格后需要全部重新请求
 */

/** 在cdn场景下是否返回了真实价格 */
@property (nonatomic, assign) BOOL  detailCdnPortSuccess;
/** 商详主要信息(banner,属性,尺码等信息)接口是否已返回 */
@property (nonatomic, assign) BOOL  detailMainPortSuccess;

/** banner数据 */
@property (nonatomic, strong) NSArray<NSString *> *bannerPicturesUrlArray;
/** 社区关联商品Shows帖子数据 */
@property (nonatomic, strong) NSArray<GoodsShowExploreModel *> *showExploreModelArray;
/** 搭配购数据 */
@property (nonatomic, strong) ZFCollocationBuyModel *collocationBuyModel;
/** 大数据 或 找相似推荐接口数据 */
@property (nonatomic, strong) NSArray<GoodsDetailSameModel *> *recommendModelArray;

/** 此商品关联的穿搭接口数据 */
@property (nonatomic, strong) NSArray<ZFGoodsDetailOutfitsModel *> *outfitsModelArray;
/** 推荐接口第一次是否已返回 */
@property (nonatomic, assign) BOOL recommendPortSuccess;

@end


#pragma mark - ==========================================================================================

@interface AFparams: NSObject
@property (nonatomic, copy) NSString *bucketid;
@property (nonatomic, copy) NSString *versionid;
@property (nonatomic, copy) NSString *planid;
@property (nonatomic, copy) NSString *policy;
@property (nonatomic, copy) NSString *plancode;

/// 统计参数 非服务端返回, V4.6.0在购物车推荐位用到
@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;
- (ZFBTSModel *)exChangeBTSModel;
@end


#pragma mark - ==========================================================================================


@interface GoodsShowExploreModel :NSObject
@property (nonatomic, copy) NSString *bigPic;
@property (nonatomic, copy) NSString *bigPicHeight;
@property (nonatomic, copy) NSString *bigPicWidth;
@property (nonatomic, copy) NSString *reviewsId;
@property (nonatomic, copy) NSString *likeNumbers;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, assign) NSInteger type; // 1: 视频, 其他都是帖子
@property (nonatomic, assign) BOOL   isShowLikeNumber; // AB 测试
@property (nonatomic, assign) BOOL   isViewAllFlag; //是否为ViewALL
@end


#pragma mark - ==========================================================================================


/// 巴西需要显示分期付款信息
@interface InstalmentModel :NSObject
@property (nonatomic, copy) NSString *instalments;//分期数
@property (nonatomic, copy) NSString *per; //每期的分期价格 美元
@property (nonatomic, copy) NSString *rate;
@property (nonatomic, copy) NSString *total;
@property (nonatomic, copy) NSString *installment_str;  // 免息文案

// 配置分期付款标签模型 (非服务端返回)
@property (nonatomic, strong) ZFGoodsTagModel *instalmentTagModel;
@end


@interface ZFRadioMsgModel :NSObject
@property (nonatomic, copy) NSString *cart_shipping_free_amount;//免邮差价，如果大于0，可以去凑单商品列表页
@property (nonatomic, copy) NSString *cart_shipping_free_amount_replace;//提示中的价格
@property (nonatomic, copy) NSString *cartRadioHint;//购物车底部提示文案
@property (nonatomic, copy) NSString *detailVCAllTipText; //商详懒加载的提示信息

/** 以下字段非服务端返回 */
@property (nonatomic, copy) NSString *cartVCAllTipText; //从购物车返回的所有需要刷新商详的提示信息
@property (nonatomic, assign) BOOL showTipTextArrow;    //从购物车返回的所有需要刷新是否显示箭头
@end



@interface GoodsDetailsModelInfo : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@end

@interface GoodsDetailsProductDescModel : NSObject
@property (nonatomic, strong) NSArray<GoodsDetailsModelInfo *> *list;
@property (nonatomic, copy) NSString *model_pic;
@property (nonatomic, copy) NSString *model_name;

/** 非服务端返回选中哪个类型 */
@property (nonatomic, assign) BOOL isEmptyModelData;//是否有模特数据
@property (nonatomic, assign) ZFGoodsDetailProductDescCellActionType selectedMenuType;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat contentViewHeight;
@property (nonatomic, assign) BOOL selectedShowMoreFlag;
@property (nonatomic, strong) NSAttributedString *goodsDescAttriText;
@end
