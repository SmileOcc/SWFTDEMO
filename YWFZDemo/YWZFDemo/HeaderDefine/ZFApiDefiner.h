//
//  ZFApiDefiner.h
//  ZZZZZ
//
//  Created by YW on 2018/5/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef ZFApiDefiner_h
#define ZFApiDefiner_h

#pragma mark -===========AppStore地址相关===========

//App store写评论界面地址
#define ZFAppStoreCommentUrl                    [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review",kZZZZZAppId]

//AppStore版本信息地址
#define ZFAppStoreVersionUrl                    [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", kZZZZZAppId]

//AppStore下载地址
#define ZFAppStoreUrl                           [NSString stringWithFormat:@"https://itunes.apple.com/us/app/ZZZZZ/id%@?l=zh&ls=1&mt=8",kZZZZZAppId]


/***
并非每个YouTube视频都包含所有九个缩略图，但每个视频都有七个缩略图。他们是：（图像大小取决于视频。）

播放器背景缩略图（480x360像素） https://i1.ytimg.com/vi/G0wGs3useV8/0.jpg
开始缩略图（120x90像素） https://i1.ytimg.com/vi/G0wGs3useV8/1.jpg
中间缩略图（120x90像素） https://i1.ytimg.com/vi/G0wGs3useV8/2.jpg
结束缩略图（120x90像素） https://i1.ytimg.com/vi/G0wGs3useV8/3.jpg
高品质缩略图（480x360像素） https://i1.ytimg.com/vi/G0wGs3useV8/hqdefault.jpg
中等质量缩略图（320x180像素） https://i1.ytimg.com/vi/G0wGs3useV8/mqdefault.jpg
普通质量缩略图（120x90像素） https://i1.ytimg.com/vi/G0wGs3useV8/default.jpg
此外，接下来的两个缩略图可能存在也可能不存在。对于HQ视频，他们存在。

标准清晰度缩略图（640x480像素） https://i1.ytimg.com/vi/G0wGs3useV8/sddefault.jpg
最大分辨率缩略图（1920x1080像素） https://i1.ytimg.com/vi/G0wGs3useV8/maxresdefault.jpg
*/

// 获取视频第一帧图片(需要拼接视频ID)
#define ZFCommunityVideoImageUrl                @"https://img.youtube.com/vi/%@/hqdefault.jpg"

// 社区首页获取视频展示大图片(需要拼接视频ID)
#define ZFCommunityVideoMaxImageUrl             @"https://img.youtube.com/vi/%@/maxresdefault.jpg"

// 公司内部默认上传请求日志的接口地址(每次换位置后可能会换)
#define ZZZZZUploadRequestLogUrl                @"http://:8090/pullLogcat"


#pragma mark -=========================== 分享相关 ====================================

//分享默认图片地址
#define ZFShareImageDefaultUrl                  @"https://uidesign.ywzf.com/YW/image/app/20180828_4801/zhuantishare.png"

// 社区分享默认图地址
#define ZFCommutryShareImageUrl                 @"https://uidesign.ywzf.com/YW/image/other/20170802_440/ZZZZZ-app-invite.jpg"

// 社区个人中心分享默认图地址
#define ZFCommutryAccountShareImageUrl          @"https://uidesign.ywzf.com/YW/image/app/20180828_4801/shequtuiguangtumoren.png"

///join-commission/me.html  个人中心分享地址
#define ZFCommunityAccountJoinMe                @"join-commission/me.html"

///join-commission/join.html   获取博主分佣
#define ZFCommunityAccountJoinJoin              @"join-commission/join.html"

/// 社区荣耀称号帮助
#define ZFCommunityAccountUserRank              @"https://sg-m.ZZZZZ.com/index.php?m=article&id=127"

/// 抽奖 测试地址
#define ZFCommunityAccountDebugLotteries        @"http://uploads.review.com.a.php5.egomsl.com/upload/lotteries/201812041528/index.html"
/// 抽奖 线上地址
#define ZFCommunityAccountReleaseLotteries      @"https://elf.ZZZZZ.com/lotteries/201901212201/index.html"

/// 拼团
#define ZFCommunityAccountGroupBuying           @"group-buying/active-10108bac5acaa1f3.html"

///join-commission/posts-detail.html   社区帖子详情分享地址
#define ZFCommunityPostsDetail                  @"join-commission/posts-detail.html"

/// 穿搭规则 outfit rule
#define ZFCommunityOutfitRuleUrl                 @"https://m.ZZZZZ.com/index.php?m=article&id=126"

// CMS 转换Deeplink地址
#define ZFCMSConvertDeepLinkString              @"ZZZZZ://action?actiontype=%@&url=%@&name=%@&source=deeplink"

/**
 * 服务端网络请求url统一拼接Action接口名
 */
/** ZZZZZ后台接口基地址 */
#define API(action)                             [[YWLocalHostManager appBaseUR] stringByAppendingString:(action)]

/** CMS后台接口基地址 */
#define CMS_API(action)                         [[YWLocalHostManager cmsAppBaseURL] stringByAppendingString:(action)]

/** 社区后台 <老> 接口基地址 */
#define CommunityAPI                            [YWLocalHostManager communityAppBaseURL]

/** 社区后台 <新> 接口基地址 */
#define Community_API(PortName)                 [YWLocalHostManager communityNewBaseURL:PortName]

/** 社区后台 <新> 接口基地址 */
#define Community_Live_API(PortName)                 [YWLocalHostManager communityNewLiveBaseURL:PortName]

#pragma mark -=========================== 模块接口 ====================================

/**
 * 所有接口名以 Port_ 开头,后面拼接具体模块名
 * 举例: 首页接口   Port_home  分类接口 Port_category
 */

#pragma mark -=========================== 首页相关接口 ====================================
/** 首页浮窗接口 */
static NSString *const Port_float               =  @"index/get_data";
/** 首页频道接口 */
static NSString *const Port_channel             =  @"channel/get_channel_data";
/** 首页/Tabbar换肤接口 */
static NSString *const Port_skin                =  @"skin/index";
/** 导航换肤接口 */
static NSString *const Port_navigationBarSkin   =  @"skin/navigation_bar";
/** 启动页广告接口 */
static NSString *const Port_launchAD            =  @"index/get_start_page";
/** 强制更新接口 */
static NSString *const Port_get_upgrade_data    =  @"setting/get_upgrade_data";
/** 快抢接口 */
static NSString *const Port_get_board_goods     =  @"fast_seckill/get_board_goods";
/** 主页提示有未支付订单接口 */
static NSString *const Port_order_index_prompt  =  @"user/get_order_index_prompt";


#pragma mark -=========================== 分类相关接口 ====================================
/** 分类接口 */
static NSString *const Port_category            =  @"common/get_children_category";
/** 父分类接口 */
static NSString *const Port_superCategory       =  @"common/get_index_category";
/** 实体分类列表接口 */
static NSString *const Port_categoryList       =  @"category/get_list";

/** ELF分类接口 */
static NSString *const Port_get_elf_nav         =  @"index/get_elf_nav";

/** 子分类接口 */
static NSString *const Port_subCategory         =  @"common/get_sub_category";
/** 以图搜图: 根据SKU查询商品全量信息接口 */
static NSString *const Port_categorySearch      =  @"goods/get_goods_list";
/** 推荐搜索词接口 */
static NSString *const Port_recommendSearch     =  @"search/get_keyword_hint";
/** 是否清除App缓存数据 */
static NSString *const Port_update_cache        =  @"app/update_cache";
/** 汇率接口 */
static NSString *const Port_rate                =  @"common/get_exchange_rate";
/** 基础信息接口 */
static NSString *const Port_initialization      =  @"common/initialization";
/** 用户信息定位 */
static NSString *const Port_locationInfo      =  @"common/location_info";
/** 获取cod支持国家 */
static NSString *const Port_currency            =  @"common/get_cp_currency";
/** 热词接口 */
static NSString *const Port_getHotWord          =  @"search/getHotWord";
/** 个人信息接口 */
static NSString *const Port_userInfo            =  @"user/get_user_info";
/** 编辑个人信息接口 */
static NSString *const Port_editUserInfo        =  @"user/edit_user_info";
/** 获取个人中心banner接口 */
static NSString *const Port_userCoreBanner      =  @"user/get_user_core_banner";
/** 社区接口 */
static NSString *const Port_communityIndex      =  @"Community/index";
/** App 切换Icon接口 */
static NSString *const Port_changeAppIcon       =  @"skin/desk";
/** 收藏列表接口 */
static NSString *const Port_collect             =  @"collection/get_collection";
/** 基本发帖热门商品 */
static NSString *const Port_communityHotList    =  @"communityHot/get_hot_list";
/** 添加/取消收藏接口 */
static NSString *const Port_operationCollection =  @"collection/operation_collection";
/** 上传图片string接口 */
static NSString *const Port_updatePicture       =  @"user/update_picture";
/** 获取购物车列表接口*/
static NSString *const Port_getCartList         =  @"cart/get_group_cart_info";
/** 购物车-凑单商品列表接口*/
static NSString *const Port_getShippingGoods    =  @"cart/get_shipping_goods";
/** 增品列表FreeGift接口*/
static NSString *const Port_freeGift            =  @"fullsales/get_list";
/** 加入商品到购物车接口*/
static NSString *const Port_addCart             =  @"cart/add_to_cart";
/** 快捷支付接口*/
static NSString *const Port_fastPayCart         =  @"cart/quick_checkout";
/** 选择支付流程接口*/
static NSString *const Port_GetCheckoutFlow     =  @"cart/get_checkout_flow";
/** 新的获取快捷支付的接口*/
static NSString *const Port_NewGetCheckoutFlow  =  @"cart/exp_check_cart";
/** checkout 接口*/
static NSString *const Port_checkout            =  @"cart/checkout_info";
/** 删除购物车商品接口*/
static NSString *const Port_DeleteGoodCart      =  @"cart/del_cart";
/** 修改购物车商品数量接口*/
static NSString *const Port_editCartGoodsNumber =  @"cart/edit_cart";
/** 勾选购物车商品接口*/
static NSString *const Port_selectGoodsCart     =  @"cart/select_cart_goods";
/** 加入赠品到购物车接口*/
static NSString *const Port_freeGiftAddCart     =  @"fullsales/add_goods";
/** 删除购物车赠品接口*/
static NSString *const Port_freeGiftDelCart     =  @"cart/del_gift_goods";
/** 购物车底部推荐商品*/
static NSString *const Prot_cartRecommendGoods  =  @"recommend/get_cart_goods";
/** 购物车结算 */
static NSString *const Prot_CartDone            =  @"cart/done";
/** 编辑购物车商品接口 */
static NSString *const Port_UpdateCartGoods     =  @"cart/update_cart_goods";
/** 获取评论列表接口*/
static NSString *const Port_GoodsReviews        =  @"review/get_goods_review_list";

/** 获取已评论列表接口*/
static NSString *const Port_UserReviewedList    =  @"review/get_user_reviewed_list";

/** 获取待评论列表接口*/
static NSString *const Port_UserNotReviewList   =  @"review/get_user_not_reviewed_list";

/** 获取商品详情页接口*/
static NSString *const Port_GoodsDetail         =  @"goods/detail";
/** 获取商品详情页CDN缓存接口*/
static NSString *const Port_GoodsDetailCdn      =  @"goods/detail_cache";
/** 获取CDN商品详情后 再获取商详实时信息接口 */
static NSString *const Port_GoodsDetailRealTime =  @"goods/detail_real_time";
/** 获取商品详情推荐商品数据接口 */
static NSString *const Port_GoodsSameCate       =  @"goods/same_cate_goods";
/** 获取详情页coupon列表 */
static NSString *const Port_GoodsDetailGetCouponList = @"goods/get_goods_coupon_list";
/** 获取详情页满减活动列表商品列表 */
static NSString *const Port_GoodsActivity_list  = @"goods/goods_activity_list";
/** 获取商品是否为拼团商品 */
static NSString *const Port_isJoinedActivity    = @"groupActivity/is_joined_activity";
/** 获取商品搭配购数据接口 */
static NSString *const Port_collocationBuy      =  @"goods/get_collocation_buy";

/** 用户开团 */
static NSString *const Port_groupStart_team = @"groupActivity/start_team";
/** 领取coupon */
static NSString *const Port_GoodsDetailGetCoupon = @"goods/get_coupon";
/** 根据coupon获取商品 */
static NSString *const Port_GoodsGet_coupon_goods = @"goods/get_coupon_goods";
/** 根据coupons获取优惠券集合 */
static NSString *const Port_GoodsGet_coupon_lists = @"goods/coupon_data_list";
/** 检查是否进行分享抽奖接口*/
static NSString *const Port_CheckShareGoodsDetail = @"goods/save_share_id";
/** 地址获取城市列表接口*/
static NSString *const Port_CityListAddress     =  @"common/get_city_list_by_province";
/** 地址获取国家列表接口*/
static NSString *const Port_CountryListAddress  =  @"common/get_country_list";
/** 地址库动态接口*/
static NSString *const Port_AreaLinkage  =  @"address/get_area_linkage";
/** 个人中心获取国家地址接口 (v3.4.0及以上支持)  */
static NSString *const Port_getMemberCountryList = @"common/get_member_country_list";
/** 获取当前国家地址信息 */
static NSString *const Port_get_cur_country_info = @"address/get_cur_country_info";
/** 获取修改订单oms地址配置信息 */
static NSString *const Port_get_oms_order_address = @"address/get_oms_order_address";
/** 保存修改订单地址配置信息 */
static NSString *const Port_order_Detail_Change_Address = @"address/orderDetailChangeAddress";
/** 查询输入的国家信息地址列表 */
static NSString *const Port_get_google_state     = @"address/get_google_state";
/** 查询搜索地址详情 */
static NSString *const Pro_get_state_detail      = @"address/get_state_detail";
/** 地址获取省份地区列表接口*/
static NSString *const Port_StateListAddress    =  @"common/get_city_list";
/** 修改地址信息接口*/
static NSString *const Port_AddressEdit         =  @"address/edit_address";
/** 获取地址列表信息接口*/
static NSString *const Port_AddressList         =  @"address/get_address_list";
/** 删除地址接口*/
static NSString *const Port_DeleteAddress       =  @"address/del_address";
/** 选择默认地址接口*/
static NSString *const Port_ChooseDefaulAddress =  @"address/default_address";
/** 获取定位信息接口*/
static NSString *const Port_GetMapAreaList      =  @"common/get_map_areaList";
/** 获取积分接口*/
static NSString *const Port_GetPointsRecord     =  @"user/get_points_record";
/** 获取个人中心推荐商品*/
static NSString *const Port_GetAccountProduct   =  @"recommend/get_member_center_goods";

#pragma mark -=========================== 订单确认页相关接口 ====================================
/** 支付打点接口*/
static NSString *const Port_orderPayTag         =  @"order/pay_monitor";
/** 优惠券校验接口*/
static NSString *const Port_checkCoupon         =  @"cart/check_coupon";


#pragma mark -=========================== 付款成功页相关接口 ====================================
/** 支付成功接口*/
static NSString *const Port_paySuccess          =  @"cart/payok";

#pragma mark -=========================== 订单列表页相关接口 ====================================
/** 催付接口*/
static NSString *const Port_orderRushPay        =  @"order/update_order_info";

#pragma mark -=========================== 注册登录相关接口 =====================================
/** 谷歌id验证接口*/
static NSString *const Port_googleCheckID       =  @"user/google_check_login";
/** 注册接口 */
static NSString *const Port_register            =  @"user/register";
/** 登录接口 */
static NSString *const Port_login               =  @"user/sign";
/** 游客登录接口*/
static NSString *const Port_GameLogin           =  @"guest/login";
/** 是否新用户*/
static NSString *const Port_IsNewUser           =  @"user/get_new_user_status";
/** 修改密码 */
static NSString *const Port_editPassword        =  @"user/edit_password";


#pragma mark -=========================== 社区相关接口 =========================================
/** 穿搭获取画布背景 */
static NSString *const Port_outfit_border        = @"community/get_outer_border";
/** 穿搭获取画布分类及数据 */
static NSString *const Port_outfit_border_data        = @"community/get_outer_border_data";
/** 穿搭选择商品列表 */
static NSString *const Port_outfit_selecteItem   = @"community/get_outfit_goods";
/** 发帖 */
static NSString *const Port_community_post       =  @"community/upload";

#pragma mark -=========================== 原生专题相关接口 ====================================
static NSString *const Port_NativeBanner          =  @"special/index";
static NSString *const Port_NativeBannerGetCoupon =  @"special/get_coupon";
static NSString *const Port_NativeBannerGoodsList =  @"special/nav_goods_list";


#pragma mark -=========================== 新人优惠相关接口 ====================================
/** 访问用户领取优惠券状态 */
static NSString *const Port_checkReceivingStatus        =  @"newuser/check_receiving_status";
/** 访问新人专享商品列表接口：新人专享商品列表 */
static NSString *const Port_getExclusiveList            =  @"newuser/get_exclusive_list";
/** 访问新人专享商品列表接口：秒杀商品列表 */
static NSString *const Port_GetSecckillList             =  @"newuser/get_secckill_list";


#pragma mark -=========================== CMS数据相关 ====================================

/** 所有的CMS弹窗广告数据接口 */
static NSString *const Port_cms_appAdverts          = @"api/app-adverts/adverts";

/** 首页CMS: 所有频道id接口 */
static NSString *const Port_cms_getMenuList         = @"api/cms-api/get-menu";
/** 首页CMS: 频道对应的列表数据接口 */
static NSString *const Port_cms_getMenuPage         = @"api/cms-api/get-page";
/** 首页CMS: 优惠券组件 */
static NSString *const Port_cms_getCmsCouponList    = @"common/get_cms_coupon_list";

/** 首页网站: 所有频道id接口 */
static NSString *const Port_zf_getMenuList          = @"channel/get_channel_list";
/** 首页网站: 频道对应的列表数据接口 */
static NSString *const Port_zf_getMenuPage          = @"channel/getMenuData";

/** 首页大数据: 推荐商品列表接口 */
static NSString *const Port_bigData_homeRecommendGoods  = @"recommend/get_home_goods";
/** 首页网站: 推荐商品列表接口 */
static NSString *const Port_zf_homeRecommendGoods   = @"channel/getGoodsList";
/** 大数据内部以图搜图: 根据图片查询批量SKU大字符串 */
static NSString *const Port_by_sku_query_list       = @"goods/by_sku_query_list";

/** 社区首页CMS: 列表数据接口 */
static NSString *const Port_cms_community           = @"api/cms-api/community";


#pragma mark -====================== V5.2.0以后社区的所有新接口 ==========================

/** 社区Post发帖接口 */
static NSString *const Port_do_post                 = @"do-post";

/** 商详页面获取商品穿搭信息 */
static NSString *const Port_outfit_goods_review     = @"outfit-goods-review";

/** 商详页面获取商品关联的商品sku信息 */
static NSString *const Port_outfit_review_skus      = @"outfit-review-skus";

/** 穿搭、发帖热门话题列表 */
static NSString *const Port_hot_topic_list      = @"hot-topic-list";

/** 穿搭、发帖关联帖子最多的话题列表 */
static NSString *const Port_review_topic_list      = @"review-topic-list";


#endif /* ZFApiDefiner_h */
