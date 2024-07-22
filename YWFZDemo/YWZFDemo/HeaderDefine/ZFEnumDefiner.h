//
//  Dynamic.h
//  ZZZZZ
//
//  Created by YW on 2017/3/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef Dynamic_h
#define Dynamic_h
//#import <Foundation/Foundation.h>
//-------------------ENUM DEFINE---------------------------

//订单详情页商品评论按钮状态
//typedef NS_ENUM(NSInteger, btnTag) {
//    WriteReview = 0,
//    CheckReview
//};

//等待的空白页面
//typedef NS_ENUM(NSUInteger,LoadingViewShowType) {
//    LoadingViewIsShow  = 0,
//    LoadingViewNoDataType = 1,
//    LoadingViewNoNetType = 2
//};

//空页面的类型
//typedef NS_ENUM(NSUInteger, EmptyViewShowType){
//    EmptyViewHideType = 0,
//    EmptyShowNoDataType = 1,
//    EmptyShowNoNetType = 2
//};

// 新版分类
//typedef NS_ENUM(NSInteger,SelectViewDataType) {
//    SelectViewDataTypeCategory = 0,
//    SelectViewDataTypeSort,
//    SelectViewDataTypeRefine
//};

//typedef NS_ENUM(NSInteger, ZFCartListBlocksType) {
//    ZFCartListBlocksTypeNormal = 0,
//    ZFCartListBlocksTypeDiscount = 1,
//    ZFCartListBlocksTypeUnavailable = 2,
//    ZFCartListBlocksTypeFreeGift = 9,
//    ZFCartListBlocksTypeCouponDetailsCode
//};

//跳转页面类型 (推送,deeplink)
//typedef NS_ENUM(NSInteger, JumpActionType) {
//    JumpDefalutActionType           =  0,   // 默认备注，后台没有返回
//    JumpHomeActionType              =  1,   // 首页
//    JumpCategoryActionType          =  2,   // 分类列表类
//    JumpGoodDetailActionType        =  3,   // 商品详情页
//    JumpSearchActionType            =  4,   // 搜索结果页
//    JumpInsertH5ActionType          =  5,   // 嵌入H5
//    JumpCommunityActionType         =  6,   // 社区
//    JumpExternalLinkActionType      =  7,   // 外部链接
//    JumpMessageActionType           =  8,   // 消息列表
//    JumpCouponActionType            =  9,   // 优惠券列表
//    JumpOrderListActionType         =  10,  // 订单列表
//    JumpOrderDetailActionType       =  11,  // 订单详情
//    JumpCartActionType              =  12,  // 购物车列表
//    JumpCollectionActionType        =  13,  // 收藏夹列表
//    JumpVirtualCategoryActionType   =  14,  // 虚拟分类
//    JumpNativeBannerActionType      =  15,  // 原生专题
//    JumpAddToCartActionType         =  16,  // 一键加入购物车(针对推送)
//    JumpChannelActionType           =  17,  // 跳转首页某个频道(针对推送)
//    JumpPointsActionType            =  18,  // 积分列表页
//    JumpMyShareActionType           =  19,  // 我的分享页面
//    JumpNewUserActivetType          =  20,  // 新人专享RN
//    JumpLiveChatActionType          =  21,  // 跳转LiveChat客服页面
//    JumpHandpickGoodsListType       =  22,  // 跳转到精选商品列表页面
//};




//用户性别  0 保密 1 男  2 女
//typedef NS_ENUM(NSUInteger, UserEnumSexType){
//    UserEnumSexTypePrivacy = 0,
//    UserEnumSexTypeMale = 1,
//    UserEnumSexTypeFemale = 2
//};


// 注册页网页跳转类型
//typedef NS_ENUM(NSUInteger, FastPaypalCheckType){
//    //未登录&未注册
//    //返回：1.用户信息  2.PP地址信息
//    FastPaypalCheckTypeNoLoginAndNoRegiste = 1,
//    //2.未登录 & PP用户注册过 & 无地址信息
//    //返回：1.用户信息  2.PP地址信息
//    FastPaypalCheckTypeNoLoginAndRegistedAndNoAddress = 2,
//    //3.未登录 & PP用户注册过 & 有地址信息
//    //返回：1.用户信息  2.checkout信息
//    FastPaypalCheckTypeNoLoginAndRegistedAndHasAddress = 3,
//    //4.登录 & 无地址信息
//    //返回：1.PP地址信息
//    FastPaypalCheckTypeLoginAndNoAddress = 4,
//    //5.登录 & 有地址信息
//    //返回：1.checkout信息
//    FastPaypalCheckTypeLoginAndHasAddress = 5
//};

// COD取整方式
//typedef NS_ENUM(NSUInteger, CashOnDeliveryTruncType){
//    //不显示不取整
//    CashOnDeliveryTruncTypeDefault = 0,
//    //向上
//    CashOnDeliveryTruncTypeUp = 1,
//    //向下取整
//    CashOnDeliveryTruncTypeDown = 2
//};

// 快捷支付状态类型
//typedef NS_ENUM(NSUInteger, FastPaypalOrderType){
//    //快速支付成功
//    FastPaypalOrderTypeSuccess = 1,
//    //快速支付失败
//    FastPaypalOrderTypeFail = 2,
//    //普通支付
//    FastPaypalOrderTypeCommon = 3,
//    //SOA 快捷支付重新跳转
//    FastPayPalOrderTypeRestJump = 4
//};

//typedef NS_ENUM(NSInteger, PaymentStatus) {
//    PaymentStatusUnknown,
//    PaymentStatusDone,
//    PaymentStatusCancel,
//    PaymentStatusFail,
//};

//typedef NS_ENUM(NSInteger, TabBarIndex) {
//    TabBarIndexHome,
//    TabBarIndexCommunity,
//    TabBarIndexAccount,
//};

//社区用户类型
//typedef NS_ENUM(NSInteger, ZFUserListType) {
//    ZFUserListTypeLike = 5,
//    ZFUserListTypeFollowing = 0,
//    ZFUserListTypeFollowed = 1,
//};

//社区页面三个列表
//typedef NS_ENUM(NSInteger, ZFCommunityHomeSelectType) {
//    ZFCommunityHomeSelectTypeExplore = 0,
//    ZFCommunityHomeSelectTypeOutfits,
//    ZFCommunityHomeSelectTypeVideo
//};

//社区首页Popular四个按钮Tag值
//typedef NS_ENUM(NSInteger, PopularBtnTag) {
//    likeBtnTag = 9852,
//    reviewBtnTag,
//    integralBtnTag,
//    shareBtnTag,
//    followBtnTag,
//    mystyleBtnTag,
//    deleteBtnTag
//};

//typedef NS_ENUM(NSInteger, CommunityGoodsType) {
//    CommunityGoodsTypeHot,
//    CommunityGoodsTypeWish,
//    CommunityGoodsTypeBag,
//    CommunityGoodsTypeOrder,
//    CommunityGoodsTypeRecent
//};

// 社区消息类型
//typedef NS_ENUM(NSInteger, MessageListType) {
//    /** 1.关注 */
//    MessageListFollowTag = 1,
//    /** 2.评论 */
//    MessageListCommendTag,
//    /** 3.点赞 */
//    MessageListLikeTag,
//    /** 4.置顶 */
//    MessageListGainedPoints,
//    /** 5.发帖 */
//    MessageListTypePost,
//};

// 支付流程状态
//typedef NS_ENUM(NSUInteger, PaymentProcessType){
//    // 老的支付流程
//    PaymentProcessTypeOld   = 1,
//    // 拆单支付流程
//    PaymentProcessTypeNew   = 2,
//    //标示没有商品可以下单
//    PaymentProcessTypeNoGoods = -1,
//};

// 组合支付状态
//typedef NS_ENUM(NSUInteger, PaymentStateType){
//    // 支付失败
//    PaymentStateTypeFailure   = 1,
//    // 等待支付
//    PaymentStateTypeWaite     = 2
//};

// 支付类型
//typedef NS_ENUM(NSUInteger, PayCodeType){
//    // cod
//    PayCodeTypeCOD        = 1,
//    // online
//    PayCodeTypeOnline     = 2,
//    // combine
//    PayCodeTypeCombine    = 3,
//    // 老接口
//    PayCodeTypeOld        = 9
//};

// 当前支付方式
//typedef NS_ENUM(NSUInteger, CurrentPaymentType){
//    // cod 支付
//    CurrentPaymentTypeCOD      = 1,
//    // online 支付
//    CurrentPaymentTypeOnline   = 2
//};

//分享类型
//typedef NS_ENUM(NSUInteger, ZFShareType) {
//    /**
//     *  Messenger 分享
//     */
//    ZFShareTypeMessenger,
//    /**
//     *  WhatsApp 分享
//     */
//    ZFShareTypeWhatsApp,
//    /**
//     *  Facebook 分享
//     */
//    ZFShareTypeFacebook,
//    /**
//     *  copy link
//     */
//    ZFShareTypeCopy,
//    /**
//     *  Pinterest 分享
//     */
//    ZFShareTypePinterest
//};

// 商详页活动类型
//typedef NS_ENUM(NSUInteger, GoodsDetailActivityType){
//    // 无浮窗
//    GoodsDetailActivityTypeNormal      = 0,
//    // 秒杀进行时
//    GoodsDetailActivityTypeFlashing    = 1,
//    // 秒杀预告
//    GoodsDetailActivityTypeFlashNotice = 2,
//    // 新人专享价
//    GoodsDetailActivityTypeNewMember   = 3
//};

//typedef NS_ENUM(NSInteger, OrderFinishActionType) {
//    OrderFinishActionTypeOrderList = 0,
//    OrderFinishActionTypeHome
//};
//typedef NS_ENUM(NSUInteger, GoodsDetailActivityType){
//    // 无浮窗
//    GoodsDetailActivityTypeNormal      = 0,
//    // 秒杀进行时
//    GoodsDetailActivityTypeFlashing    = 1,
//    // 秒杀预告
//    GoodsDetailActivityTypeFlashNotice = 2,
//    // 新人专享价
//    GoodsDetailActivityTypeNewMember   = 3,
//    // 拼团 V4.5.1
//    GoodsDetailActivityTypeGroupBuy    = 4
//};
//typedef NS_ENUM(NSInteger, OrderFinishActionType) {
//    OrderFinishActionTypeOrderList = 0,
//    OrderFinishActionTypeHome
//};

// 社区接口类型
//typedef NS_ENUM(NSInteger, ZFCommunityRequestDirect) {
//    ZFCommunityRequestDirectPostTag = 50,  // 发帖的标签
//};


//// 选择地址: 国家, 省份, 城市
//typedef enum : NSUInteger {
//    ZFSelectCountryType,
//    ZFSelectRegionType,
//    ZFSelectCityType,
//} ZFSelectCountryAddressType;


/** 社区首页TableView Section类型 */
//typedef NS_ENUM(NSInteger, ZFDiscoverType) {
//    /** 社区活动分场馆 */
//    ZFDiscoverTypeBranchBanner = 0,
//    /** 主题滑动banner */
//    ZFDiscoverTypeTopScrollBanner,
//    /** Shows/Outfits/Videos */
//    ZFDiscoverTypeShowsOutfitsVidios,
//};

/** 各个列表页显示New, Popular,Hot字段的枚举值 自营销商品：1热卖品 2潜力品3 新品 */
//typedef NS_ENUM(NSInteger, ZFMarketingTagType) {
//    /** 1热卖品 */
//    ZFMarketingTagTypeHot = 1,
//    /** 2潜力品 */
//    ZFMarketingTagTypePopular,
//    /** 3 新品 */
//    ZFMarketingTagTypeNew,
//};

/** 原生专题类型 */
//typedef NS_ENUM(NSInteger, ZFNativeBannerType) {
//    ZFNativeBannerTypeOne    = 1,   // 1分馆
//    ZFNativeBannerTypeBranch = 2,   // 多分馆
//    ZFNativeBannerTypeSlide,        // 滑动Banner
//    ZFNativeBannerTypeSKUBanner,    // skuBanner
//    ZFNativeBannerTypeGoodsList,    // 商品列表(实际不需要用到)
//    ZFNativeBannerTypeVideo         // 视频
//};


/** CMS 主页组件类型 */
//typedef NS_ENUM(NSInteger, ZFHomeCMSModuleType) {
//    ZFCMS_BannerPop_Type        = 101,   // 弹窗
//    ZFCMS_SlideBanner_Type      = 102,   // 滑动banner (此类型需要考虑子类型:ZFHomeCMSModuleSubType)
//    ZFCMS_CycleBanner_Type      = 103,   // 轮播banner
//    ZFCMS_BranchBanner_Type     = 105,   // 多分馆即固定
//    ZFCMS_GridMode_Type         = 106,   // 平铺,格子模式 (此类型需要考虑子类型:ZFHomeCMSModuleSubType)
//    ZFCMS_DropDownBanner_Type   = 107,   // 下拉banner
//    ZFCMS_FloatingGBanner_Type  = 108,   // 浮窗banner
//    ZFCMS_RecommendGoods_Type   = 109,   // 推荐商品栏
//    ZFCMS_TextModule_Type       = 110,   // 纯文本栏目
//};

///** CMS 主页组件子类型 */
//typedef NS_ENUM(NSInteger, ZFHomeCMSModuleSubType) {
//    ZFCMS_SkuBanner_SubType       = 1,   // 商品类型
//    ZFCMS_NormalBanner_SubType    = 2,   // banner类型
//    ZFCMS_HistorSku_SubType       = 3,   // 商品历史浏览记录
//};
//
///** CMS组件对齐方式，1：上左，2：上中，3：上右，4：居左，5：居中，6：居右，7：下左，8：下中，9：下右 */
//typedef NS_ENUM(NSInteger, ZFCMSModulePosition) {
//    /**上左*/
//    ZFCMSModulePositionTopLeft = 1,
//    /**上中*/
//    ZFCMSModulePositionTopCenter,
//    /**上右*/
//    ZFCMSModulePositionTopRight,
//    /**中左*/
//    ZFCMSModulePositionCenterLeft,
//    /**中*/
//    ZFCMSModulePositionCenter,
//    /**中右*/
//    ZFCMSModulePositionCenterRight,
//    /**下左*/
//    ZFCMSModulePositionBottomLeft,
//    /**下中*/
//    ZFCMSModulePositionBottomCenter,
//    /**下右*/
//    ZFCMSModulePositionBottomRight,
//};


/** 操作推送事件类型 */
//typedef NS_ENUM(NSInteger, ZFOperateRemotePushType) {
//    /** 操作页面当前事件 */
//    ZFOperateRemotePush_Default = 0,
//    /**引导页:点击 Yep 次数*/
//    ZFOperateRemotePush_guide_yes,
//    /**引导页:点击 NO 次数*/
//    ZFOperateRemotePush_guide_no,
//    /**系统授权:点击 允许 次数*/
//    ZFOperateRemotePush_sys_yes,
//    /**系统授权:点击 拒绝 次数*/
//    ZFOperateRemotePush_sys_no,
//};


#endif /* Dynamic_h */

