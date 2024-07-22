//
//  ZFGrowingIOAnalytics.h
//  ZZZZZ
//
//  Created by YW on 2018/8/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
// growingIO 统计代码集合

#import <Foundation/Foundation.h>
#import <Growing/Growing.h>
#import "ZFOrderCheckDoneDetailModel.h"
#import "ZFGoodsModel.h"
#import "GoodsDetailModel.h"
#import "ZFOrderCheckInfoDetailModel.h"
#import "ZFOrderCheckDoneDetailModel.h"
#import "ZFOrderManager.h"
#import "MyOrdersModel.h"
#import "OrderDetailOrderModel.h"
#import "ZFOrderDeatailListModel.h"
#import "ZFSearchResultModel.h"
#import "ZFCMSSectionModel.h"
#import "ZFGeshopSectionModel.h"

///一级入口名
static NSString *GIOSourceHome              = @"首页";
static NSString *GIOSourceCategory          = @"分类首页";
static NSString *GIOSourceCommunity         = @"社区首页";
static NSString *GIOSourceCommunityPost     = @"社区帖子";
static NSString *GIOSourceAccount           = @"个人中心首页";
static NSString *GIOSourceHomeFloat         = @"首页弹窗";
static NSString *GIOSourceHomeSmallFloat    = @"悬浮广告";
static NSString *GIOSourceSplashScreen      = @"启动页全面屏广告";
static NSString *GIOSourceSearch            = @"搜索";
static NSString *GIOSourceCartRecommend     = @"购物车推荐位";
static NSString *GIOSourcePush              = @"push";
static NSString *GIOSourceDeeplink          = @"deeplink";


///二级入口名
static NSString *GIOSourceCommunityAccount  = @"个人资料页";
static NSString *GIOSourceWishList          = @"心愿单页";
static NSString *GIOSourceWishListRecommend = @"心愿单推荐位";
static NSString *GIOSourceOrder             = @"订单页";
static NSString *GIOSourceOrderRecommend    = @"订单页推荐位";
static NSString *GIOSourceCouponRecommend   = @"Coupon页推荐位";
static NSString *GIOSourceRecenty           = @"最近浏览";
static NSString *GIOSourceAccountRecommend  = @"个人中心推荐位";
static NSString *GIOSourceCartFreeGifts     = @"购物车免费购";
static NSString *GIOSourceCoupon            = @"优惠券";
static NSString *GIOSourceHomeChannel       = @"首页频道";


///商品入口类型
static NSString *GIOGoodsTypeRecommend    = @"推荐相关";
static NSString *GIOGoodsTypeCommunity    = @"社区相关";
static NSString *GIOGoodsTypeSearch       = @"搜索相关";
static NSString *GIOGoodsTypeVirtual      = @"虚拟分类";
static NSString *GIOGoodsTypeNative       = @"原生专题";
static NSString *GIOGoodsTypeOther        = @"其他";

///商品来源key值
static NSString *GIOFistEvar        = @"first_source_evar"; // 一级转化入口名称
static NSString *GIOSndIdEvar       = @"snd_source_id_evar"; // 二级转化入口ID
static NSString *GIOSndNameEvar     = @"snd_source_name_evar"; // 二级转化入口名称
static NSString *GIOThirdIdEvar     = @"third_source_id_evar"; // 三级转化入口ID
static NSString *GIOThirdNameEvar   = @"third_source_name_evar"; // 三级转化入口名称
static NSString *GIOGoodsTypeEvar   = @"goods_source_type_evar"; // 商品列表页入口类型
static NSString *GIOGoodsNameEvar   = @"goods_source_name_evar"; // 商品列表页入口名称



///一级购买入口(转化变量-最近)
static NSString *GIOsourceRecent_evar = @"sourceRecent_evar";
///一级购买入口(转化变量-最初)
static NSString *GIOsourceFirst_evar = @"sourceFirst_evar";
///推荐位类型
static NSString *GIORecommendType_evar = @"recommendType_evar";
///推荐位所在的页面
static NSString *GIORecommendPage_evar = @"recommendPage_evar";
///社区用户类型（转化变量）
static NSString *GIOUserType_evar = @"userType_evar";
///搜索词转化变量
static NSString *GIOSearchWord_evar = @"searchWord_evar";
///帖子id 转化变量
static NSString *GIOPostId_evar = @"postId_evar";
///帖子类型 转化变量
static NSString *GIOPostType_evar = @"postType_evar";
///话题 转化变量
static NSString *GIOTopicId_evar = @"topicId_evar";

@interface ZFGrowingIOAnalytics : NSObject
///上传转化变量
+ (void)ZFGrowingIOSetEvar:(NSDictionary<NSString *,NSObject *> *)dict;

#pragma mark - 活动展示统计
+ (void)ZFGrowingIOBannerImpWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                        page:(NSString *)page;
+ (void)ZFGrowingIOBannerImpWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                        page:(NSString *)page
                                   channelID:(NSString *)channelID
                                    floorVar:(NSString *)floorVar;
+ (void)ZFGrowingIOBannerImpWithBannerModel:(ZFBannerModel *)bannerModel
                                       page:(NSString *)page;
+ (void)ZFGrowingIOBannerImpWithBannerModel:(ZFBannerModel *)bannerModel
                                       page:(NSString *)page
                                  channelID:(NSString *)channelID
                                   floorVar:(NSString *)floorVar;
/// 原生专题轮播banner
+ (void)ZFGrowingIOBannerImpWithThemeSectionListModel:(ZFGeshopSectionListModel *)model
                              nativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                             pageName:(NSString *)pageName
                                        nativeThemeId:(NSString *)nativeThemeId;
/// 原生专题文本banner
+ (void)ZFGrowingIOBannerImpWithnativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                               pageName:(NSString *)pageName
                                          nativeThemeId:(NSString *)nativeThemeId;
#pragma mark - 活动点击统计
+ (void)ZFGrowingIObannerClickWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                          page:(NSString *)page
                                  sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams;
+ (void)ZFGrowingIObannerClickWithCMSItemModel:(ZFCMSItemModel *)cmsModel
                                          page:(NSString *)page
                                     channelID:(NSString *)channelID
                                      floorVar:(NSString *)floorVar
                                  sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams;
+ (void)ZFGrowingIObannerClickWithBannerModel:(ZFBannerModel *)bannerModel
                                         page:(NSString *)page
                                 sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams;
+ (void)ZFGrowingIObannerClickWithBannerModel:(ZFBannerModel *)bannerModel
                                         page:(NSString *)page
                                    channelID:(NSString *)channelID
                                     floorVar:(NSString *)floorVar
                                 sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams;
/// 原生专题轮播banner
+ (void)ZFGrowingIOBannerClickWithThemeSectionListModel:(ZFGeshopSectionListModel *)model
                                nativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                               pageName:(NSString *)pageName
                                          nativeThemeId:(NSString *)nativeThemeId;
/// 原生专题文本banner
+ (void)ZFGrowingIOBannerClickWithnativeThemeSectionModel:(ZFGeshopSectionModel *)nativeThemeSectionModel
                                                 pageName:(NSString *)pageName
                                            nativeThemeId:(NSString *)nativeThemeId;


/////商品活动曝光 key = activityImp
//+(void)ZFGrowingIOActivityImp:(NSString *)activityName floor:(NSString *)floor position:(NSString *)position page:(NSString *)page;
//
/////CMS商品活动曝光 key = activityImp
//+(void)ZFGrowingIOActivityImpByCMS:(ZFCMSItemModel *)cmsModel channelId:(NSString *)channelId;
//
/////CMS商品活动曝光 ZFBannerModel
//+(void)ZFGrowingIOActivityImpByCMS:(ZFBannerModel *)cmsModel;
//
/////商品活动点击 key = activityClick
//+(void)ZFGrowingIOActivityClick:(NSString *)activityName floor:(NSString *)floor position:(NSString *)position page:(NSString *)page;

///社区活动点击
+(void)ZFGrowingIOCommunityActivityClick;

//+(void)ZFGrowingIOActivityClickByCMS:(ZFCMSItemModel *)cmsModel channelId:(NSString *)channelId;
//
/////商品活动点击 key = activityClick
//+(void)ZFGrowingIOActivityClickByCMS:(ZFBannerModel *)cmsModel;

///商品显示的收集 key = goodsImp page是当前调用页面
+(void)ZFGrowingIOProductShow:(ZFGoodsModel *)model page:(NSString *)page;

///商品点击的收集 key = goodsClick page是当前调用页面
+(void)ZFGrowingIOProductClick:(ZFGoodsModel *)model page:(NSString *)page sourceParams:(NSDictionary<NSString *,NSObject *> *)sourceParams;

///商品详情浏览 key = goodsDetailPageView
+(void)ZFGrowingIOProductDetailShow:(GoodsDetailModel *)model;

///添加到购物车 key = addToBag
+(void)ZFGrowingIOAddCart:(GoodsDetailModel *)model;

///在购物车CHECKOUT订单的次数 key = checkOutOrder
+(void)ZFGrowingIOCartCheckOut:(ZFOrderCheckInfoDetailModel *)model;

///订单支付的次数 key = payOrder
///paySource 支付来源 取值包括订单详情页支付、我的订单列表支付、购物车页面直接点击PayPal按钮支付
+(void)ZFGrowingIOPayOrder:(ZFOrderCheckDoneDetailModel *)model
              orderManager:(ZFOrderManager *)manager
                 paySource:(NSString *)paySource;

///订单支付SKU统计， key = paySKU
+(void)ZFGrowingIOPayOrderSKU:(ZFOrderCheckDoneDetailModel *)model
          checkInfoOderDetail:(ZFOrderCheckInfoDetailModel *)checkModel
                 orderManager:(ZFOrderManager *)manager
                    paySource:(NSString *)paySource;

///订单支付成功，key = payOrderSuccess
+(void)ZFGrowingIOPayOrderSuccess:(ZFOrderCheckDoneDetailModel *)model
                     orderManager:(ZFOrderManager *)manager
                        paySource:(NSString *)paySource;

///订单支付成功SKU，key = paySKUSuccess
+(void)ZFGrowingIOPayOrderSKUSuccess:(ZFOrderCheckDoneDetailModel *)model
                 checkInfoOderDetail:(ZFOrderCheckInfoDetailModel *)checkModel
                        orderManager:(ZFOrderManager *)manager
                           paySource:(NSString *)paySource;
///支付成功的growingIO统计
+(void)ZFGrowingIOPayOrderSuccessWithBaseOrderModel:(ZFBaseOrderModel *)model
                                          paySource:(NSString *)paySource;

///订单列表发起支付的growingIO统计
+(void)ZFGrowingIOPayOrderWithOrderList:(MyOrdersModel *)model;

///订单列表支付成功的growingIO统计
//+(void)ZFGrowingIOPayOrderSuccessWithOrderList:(MyOrdersModel *)model;

///订单详情发起支付的growingIO统计
+(void)ZFGrowingIOPayOrderWithOrderDetail:(OrderDetailOrderModel *)model listModel:(ZFOrderDeatailListModel *)listModel;

///订单详情支付成功的growingIO统计
//+(void)ZFGrowingIOPayOrderSuccessWithOrderDetail:(OrderDetailOrderModel *)model listModel:(ZFOrderDeatailListModel *)listModel;

/*搜索结果浏览
 @pragma key = searchResultView
 @pragma searchkey 搜索关键字
 @pragma searchType 搜索类型，区分文字搜索，图片搜索
 @pragma searchAmount 搜索总条数
 @pragma page 所属页面
 */
+(void)ZFGrowingIOSearchResult:(ZFGoodsModel *)model
                     searchKey:(NSString *)searchKey
                    searchType:(NSString *)searchType
                  searchAmount:(NSInteger)amount
                          page:(NSString *)page;

/* 搜索结果点击
 * @pragma key = searchResultClck
 * @pragma searchkey 搜索关键字
 * @pragma searchType 搜索类型，区分文字搜索，图片搜索
 * @pragma page 所属页面
 */
+(void)ZFGrowingIOSearchResultClick:(ZFGoodsModel *)model
                          searchKey:(NSString *)searchKey
                         searchType:(NSString *)searchType
                               page:(NSString *)page;


/*
 *  推送展示统计
 *  @pragma pushType  区分推送类型，推送类型包括系统触发、运营触发
 *  @pragma pushName  推送名称
 *  v4.3.1 经产品决定去掉这个统计 （殷铨均）
 **/
+(void)ZFGrowingIOShowPush:(NSString *)pushType pushName:(NSString *)pushName;

/*
 *  推送点击统计
 *  @pragma pushType  区分推送类型，推送类型包括系统触发、运营触发
 *  @pragma pushName  推送名称
 **/
+(void)ZFGrowingIOClickPush:(NSString *)pushType pushName:(NSString *)pushName;

/*
 *  优惠券曝光
 *  key = couponImp
 *  @pragma couponName
 *  @pragma goodsPage
 **/
+(void)ZFGrowingIOCouponShow:(NSString *)couponName page:(NSString *)page;

/*
 *  优惠券点击
 *  key = couponClck
 *  @pragma couponName
 *  @pragma goodsPage
 **/
+(void)ZFGrowingIOCouponClick:(NSString *)couponName page:(NSString *)page;

/*
 *  优惠券领取成功
 *  key = couponGet
 *  @pragma couponName
 *  @pragma goodsPage
 **/
+(void)ZFGrowingIOCouponGetSuccess:(NSString *)couponName page:(NSString *)page;

/*  发帖成功
 *  key = postSuccess
 *  @pragma postId 帖子id
 *  @pragma postType 帖子详情页中的推荐商品所属的帖子类型，取值包括shows、outfits、videos；
 **/
+(void)ZFGrowingIOPostTopic:(NSString *)postId postType:(NSString *)postType;

/*  帖子详情浏览
 *  key = communityTopicDetailView
 *  @pragma postId 帖子id
 *  @pragma postType 帖子详情页中的推荐商品所属的帖子类型，取值包括shows、outfits、videos；
 **/
+(void)ZFGrowingIOPostTopicShow:(NSString *)postId postType:(NSString *)postType;

@end
