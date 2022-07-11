//
//  STLCommonEnum.h
// XStarlinkProject
//
//  Created by 10010 on 20/10/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#ifndef STLCommonEnum_h
#define STLCommonEnum_h


typedef NS_ENUM(NSInteger, STLMainMoudle) {
    STLMainMoudleHome,
    STLMainMoudleCategory,
//    STLMainMoudleNewIn,
    STLMainMoudleCart,
    STLMainMoudleAccount,
};

// 阿语系统下屏蔽社区模块
typedef NS_ENUM(NSInteger, STLNoMoudle) {
    STLNoMoudleHome,
    STLNoMoudleCategory,
    STLNoMoudleCart,
    STLNoMoudleAccount,
};


//广告
typedef NS_ENUM(NSInteger, AdverType) {
    /** 开机*/
    AdverTypeLaunch = 1,
    /** 首页活动*/
    AdverTypeHomeActity,
    /** 首页banner*/
    AdverTypeHomeBanner,
};

// 空页面
typedef NS_ENUM(NSUInteger, EmptyViewShowType){
    EmptyViewShowTypeHide = 0,
    EmptyViewShowTypeNoData = 1,
    EmptyViewShowTypeNoNet = 2
};


//订单详情页取消、支付、西联...
typedef NS_ENUM(NSInteger, OrderDetailBtn) {
    OrderCancel = 0,
    OrderPayNow,
    OrderView,
    OrderSupportCenter,
    OrderMessage
};

//H5页面跳转
typedef NS_ENUM(NSUInteger, SystemURLType){
    SystemURLTypeDefault = 0,
    SystemURLTypeAboutUs = 1,
    SystemURLTypeTermsOfUs = 2,
    SystemURLTypePrivacyPolicy = 3,
} ;

typedef NS_ENUM(NSUInteger, HelpType) {
    HelpTypeReturnPolicy = 0,
    HelpTypeLongReceiveOrider = 1,
    HelpTypeShipping = 2,
    HelpTypeOrders = 3,
    HelpTypeAfterSale = 4,
    HelpTypePromotion = 5,
    HelpTypeProducts = 6,
    HelpTypeContractUs = 7,
    HelpTypeAboutUs,
    HelpTypePrivacyPolicy,
    HelpTypeTermOfUsage,
};
//跳转页面类型
typedef NS_ENUM(NSInteger, AdvEventType) {
    /** 默认备注，没有返回*/
    AdvEventTypeDefault = 0,
    /** 频道首页*/
    AdvEventTypeHomeChannel = 1,
    /** 分页类*/
    AdvEventTypeCategory = 2,
    /** 商品详情页*/
    AdvEventTypeGoodDetail = 3,
    /** 搜索*/
    AdvEventTypeSearch = 4,
    /** 嵌入H5*/
    AdvEventTypeInsertH5 = 5,
    /** 买家秀*/
    AdvEventTypeBuyShow = 6,
    /** 外部链接*/
    AdvEventTypeExternalLink = 7,
    /** 店铺列表*/
    AdvEventTypeStoreList = 8,
    /** 订单详情*/
    AdvEventTypeOrderDetail = 9,
    /** My Coupon*/
    AdvEventTypeOrderCoupon = 10,
    /** Cart*/
    AdvEventTypeCart = 11,
    /** My WishList*/
    AdvEventTypeMyWishList = 12,
    /** 虚拟商品列表*/
    AdvEventTypeVirtualGoodsList = 13,
    /** 原生专题*/
    AdvEventTypeNativeCustom = 14,
    /** 0元商品列表*/
    AdvEventTypeSpecialList = 16,
    /** 闪购活动页*/
    AdvEventTypeFlashActivity = 17,
    /** 订单列表*/
    AdvEventTypeOrderList = 18,
    /** help中的消息*/
    AdvEventTypeHelpMessageList = 19,
    /** 从消息中心跳转到订单详情*/
    AdvEventTypeMsgToOrderDetail = 99,
    /** 100 不跳转*/
    AdvEventTypeNOEvent = 100,
};

//用户性别  0 男  1 女  2 默认
typedef NS_ENUM(int, UserEnumSexType){
    UserEnumSexTypeMale = 0,
    UserEnumSexTypeFemale = 1,
    UserEnumSexTypeDefault = 2
};

//购物车中商品状态
typedef NS_ENUM(NSUInteger, CartGoodsOperateType){
    CartGoodsOperateTypeDefault = 0,
    CartGoodsOperateTypeAdd,
    CartGoodsOperateTypeUpdate,
    CartGoodsOperateTypeDelete
} ;

typedef NS_ENUM(NSUInteger, GoodsDetailEnumType){
    GoodsDetailEnumTypeHeader = 0,
    GoodsDetailEnumTypeAdd = 1,
    GoodsDetailEnumTypeBuy = 2
} ;

typedef NS_ENUM(NSUInteger, SheetEnumType){
    DetailSheetEnumType = 0,
    ActionSheetEnumType = 1,
    DetailSheetServiceEnumType = 2
} ;

typedef NS_ENUM(NSUInteger, CartCheckOutResultEnumType){
    //成功
    CartCheckOutResultEnumTypeSuccess = 0,
    //没有地址
    CartCheckOutResultEnumTypeNoAddress,
    //购物车没有此商品
    CartCheckOutResultEnumTypeNoGoods,
    //没有物流
    CartCheckOutResultEnumTypeNoShipping,
    //不支持此支付
    CartCheckOutResultEnumTypeNoPayment,
    //此商品已下架
    CartCheckOutResultEnumTypeShelvesed,
    //库存不足
    CartCheckOutResultEnumTypeNoStock,
    //国家地址 不支持 Sorry,your country currently can not support payment method you selected.
    CartCheckOutResultEnumTypeNoSupportPayment = 404,
} ;

//订单状态
typedef NS_ENUM(NSUInteger, OrderStateType){
    /** 未付款*/
    OrderStateTypeWaitingForPayment = 0,
    /** 已付款*/
    OrderStateTypePaid = 1,
    /** 备货*/
    OrderStateTypeProcessing = 2,
    /** 完全发货*/
    OrderStateTypeShippedOut = 3,
    /** 已收到货*/
    OrderStateTypeDelivered = 4,
    /** 付款中*/
    OrderStateTypePaying= 6,
    /** 部分付款*/
    OrderStateTypePartialOrderPaid= 8,
    /** 退款*/
    OrderStateTypeRefunded = 10,
    /** 取消*/
    OrderStateTypeCancelled = 11,
    /** 扣款失败*/
    OrderStateTypeDeductionFailed = 12,
    /** 待审核*/
    OrderStateTypeWatingAudit = 13,
    /** 部分配货*/
    OrderStateTypePartialOrderDispatched = 15,
    /** 完全配货*/
    OrderStateTypeDispatched = 16,
    /** 部分发货*/
    OrderStateTypePartialOrderShipped = 20,
    /** cod待确认*/
    OrderStateTypeWaitConfirm = 21
} ;

//订单状态
typedef NS_ENUM(NSUInteger, OrderOperateType){
    /** 取消订单*/
    OrderOperateTypeCancel = 0,
    /** 支付订单*/
    OrderOperateTypePaying = 1,
    /** 再次购买*/
    OrderOperateTypeBuyAgain = 2,
    /** 订单评论*/
    OrderOperateTypeReview = 3,
    /** 订单物流*/
    OrderOperateTypeShipment = 4,
    /** 订单挽留加购*/
    OrderOperateTypeBuyAddCart = 5,
};

// 进入地址列表处进入方式 0 由accountVC 进入 1 =由orderVC 进入
typedef NS_ENUM(NSUInteger, AddressListSourceFromType) {
    AddressListSourceFromTypeAccount = 0,
    AddressListSourceFromTypeOrder  = 1
};

typedef NS_ENUM(NSInteger, STLEventLinkType) {
    STLEventLinkTypeNone,
    STLEventLinkTypeCategory,
    STLEventLinkTypeProduct,
    STLEventLinkTypeCart,
    STLEventLinkTypeSearch,
    STLEventLinkTypeArticle,    // 文章页
    STLEventLinkTypeEmbedPage,  // H5
    STLEventLinkTypeEmbedPageWithUserInfo,  // H5 需要登录
};

typedef NS_ENUM(NSInteger, STLOrderPayStatus) {
    STLOrderPayStatusUnknown = 0,   //未知状态
    STLOrderPayStatusDone,      //完成
    STLOrderPayStatusCancel,    //取消
    STLOrderPayStatusFailed,    //失败
    STLOrderPayStatusPaypalFast, //快捷支付
    STLOrderPayStatusError,       //错误
};


//单选按钮图片
typedef NS_ENUM(NSInteger, RadioButtonType) {
    DefaultImage,
    BackgroundImage,
};

typedef NS_ENUM(NSInteger, STLUserListsType) {
    STLUserListsTypeLike = 5,
    STLUserListsTypeFollowing = 0,
    STLUserListsTypeFollowed = 1,
};


//
typedef NS_ENUM(NSInteger, AvaliableViewTag) {
    AvaliableViewTagSpecial = 9999,
    AvaliableViewTagDefault,
    AvaliableViewTagBtnSpecial,
    AvaliableViewTagBtnDefault
};

//页面加载数据为空的类型
typedef NS_ENUM(NSInteger, STLFBRegisterType) {
    STLFBRegisterTypeHadRegister,
    STLFBRegisterTypeSuccess
};

// 推送引导页入口区分
typedef NS_ENUM(NSInteger, STLNotificationType) {
    STLNotificationTypeLaunch,
    STLNotificationTypeSetting,
    STLNotificationTypeOrderFinish
};


// 个人中心MENU区分
typedef NS_ENUM(NSInteger, AccountGoodsListType) {
    AccountGoodsListTypeHistory,
    AccountGoodsListTypeRecommend,
};

#endif /* STLCommonEnum_h */
