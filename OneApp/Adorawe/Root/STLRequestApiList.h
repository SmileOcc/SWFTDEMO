//
//  STLRequestApiList.h
// XStarlinkProject
//
//  Created by odd on 2020/12/21.
//  Copyright © 2020 starlink. All rights reserved.
//

#ifndef STLRequestApiList_h
#define STLRequestApiList_h

//user/save-sex 没使用
//site/order-warn 没使用
//order/edit  没使用
//channel/search  没使用
//address/get-auto  没使用
//order/status 没使用

///启动域名配置
#define kApi_WebsiteConfig @"website/config"
///货币汇率
#define kApi_ExchangeIndex @"exchange/index"
///国家列表
#define kApi_CountryList @"country/list"
///首页氛围
#define kApi_HomeAtmosphereList @"home-atmosphere/list"
///启动页广告
#define kApi_BannerStart @"banner/start"

///用户信息
#define kApi_UserGetinfo @"user/getinfo"
///用户登录
#define kApi_UserLogin @"user/login"
///用户注册
#define kApi_UserSignup @"user/signup"
///FB登录检测
#define kApi_UserCheckfbid @"user/checkfbid"
///第三方登录
#define kApi_UserApilogin @"user/apilogin"
///用户忘记密码
#define kApi_UserForgotpassword @"user/forgotpassword"
///用户修改密码
#define kApi_UserChangepassword @"user/changepassword"
///编辑用户信息
#define kApi_UserEditprofile @"user/editprofile"

///搜索关键词
#define kApi_SearchAssociate @"search/associate"
///搜索
#define kApi_SearchSearch @"search/search"
#define kApi_SearchResultRecommeds @"search/recommends"
///热搜词请求
#define kApi_SearchTrendsWord @"search/trends-word"
///搜索词
#define kApi_SearchSaveTrends @"search/save-trends"

///消息中心
#define kApi_MessageListIndex @"message-list/index"
#define kApi_MessageListList @"message-list/list"

///首页频道菜单
#define kApi_ChannelIndex @"channel/index"
///首页频道列表
#define kApi_BannerList @"banner/list"

///首页弹窗广告
#define kApi_BannerPopupWindow @"banner/popup-window"
///首页浮窗广告
#define kApi_BannerHomeFloat @"banner/home-float"
///更新
#define kApi_SystemUpdate @"system/update"
///系统通知弹窗
#define kApi_SystemInit @"system/init"

///国家校验
#define kApi_CountryCheck @"country/check"
///国家电话号码校验
#define kApi_CountryCheckCountryPhone @"country/check-country-phone"
///地址列表
#define kApi_AddressList @"address/list"

///原生专题
#define kApi_SpecialIndex @"special/index"
///原生专题 新
#define kApi_SpecialActivity @"special/activity"
///原生专题商品 新
#define kApi_SpecialActivityGoodsList @"special/activity-goods-list"
///原生专题导航商品
#define kApi_SpecialGetChannelGoods @"special/get-channel-goods"


///闪购活动菜单
#define kApi_FlashSaleRecentActive @"flash-sale/recent-active"
///闪购活动列表
#define kApi_FlashSaleGetGoods @"flash-sale/get-goods"
///切换提醒状态
#define kApi_FlashSaleFollowSwitch @"flash-sale/follow-switch"

///领取优惠券
#define kApi_CouponGetCoupon @"coupon/get-coupon"
///首页底部导航商品列表
#define kApi_BannerTabGoodsList @"banner/tab-goods-list"



//country/current-country   ？？？？

///商品详情
#define kApi_ItemIndex @"item/index"
///商品详情--商品购物车cunzai  1.4.6 与其他不需要缓存的信息合并
//#define kApi_GoodsCartExit @"cart/exists-free-goods"
#define kApi_GoodsCartExit @"item/no-cache"

///商品详情推荐商品数据
#define kApi_ItemRecommend @"item/recommend"

///商品详情评论
#define kApi_ItemGetGoodsComment @"item/get-goods-comment"
#define kApi_ItemGetGoodsCommentNew @"goods/review-list"
///订单商品评论
#define kApi_ItemUserGoodsComment @"item/user-goods-comment"
///订单商品评论
#define kApi_ItemWriteComment @"item/write-comment"
///个人中心推荐商品
#define kApi_ItemUserRecommend @"item/userrecommend"
///买了又买
#define kApi_ItemUserBuyAndBuy @"item/often-bought"
///我的商品评论
#define kApi_UserMyReviews @"user/my-reviews"
///我的优惠券
#define kApi_UserCoupon @"user/coupon"
///订单评论
#define kApi_OrderReview @"order/review"
///订单写评论
#define kApi_OrderWriteOrderReview @"order/write-order-review"
///订单列表
#define kApi_OrderList @"order/list"
///订单列表中，WhatsApp 号码收集 和物流通知订阅
#define kApi_WhatsAppSubscribe @"user/what-apps-subscribe"

///订单详情
#define kApi_OrderDetail @"order/detail"
///订单取消
#define kApi_OrderCancel @"order/cancel"
///订单再次购买
#define kApi_OrderBuyAgain @"order/buy-again"
///订单地址
#define kApi_OrderGetOrderAddressinfo @"order/get-order-addressinfo"
///订单COD短信确认
#define kApi_OrderCodSmsConfirm @"order/cod-sms-confirm"
///订单COD状态确认
#define kApi_OrderCodOrderChangeStatus @"order/cod-order-change-status"
///订单物流
#define kApi_OrderGetOrderTrackList @"order/get-order-track-list"
///订单物流
#define kApi_OrderOrderSplitList @"order/order-split-list"
///订单支付
#define kApi_PaySubmit @"pay/submit"

///个人中心反馈
#define kApi_FeedbackAdd @"feedback/add"

//反馈原因
#define kApi_FeedbackReason @"feedback/feedback-reason"
//反馈列表
#define kApi_FeedbackReplyList @"feedback/feedback-reply-list"

/// 个人中心尺码信息获取
#define kApi_GetSizeOption @"user-size/view"

// 保存尺码信息
#define kApi_SaveSizeOption @"user-size/store"

///google地址数据收集
#define kApi_googleMapAddressCollect @"address/collect-google-address"
//通过国家简码获取区号
#define kApi_GetPhoneAreaCode  @"country/get-country-phone-code"

///地址删除
#define kApi_AddressDelete @"address/delete"
///地址添加
#define kApi_AddressAdd @"address/add"
///地址编辑
#define kApi_AddressEdit @"address/edit"

///商品收藏
#define kApi_CollectAdd @"collect/add"
///商品取消收藏
#define kApi_CollectDel @"collect/del"
///商品收藏列表
#define kApi_CollectList @"collect/list"


///购物车订单结算
#define kApi_OrderCheck @"order/check"
///订单创建
#define kApi_OrderCreate @"order/create"
///订单cod 取消
#define kApi_CodCancelCancelCodOrder @"cod-cancel/cancel-cod-order"
///发送验证码
#define kApi_SmsSendSmsCode @"sms/send-sms-code"

///优惠券选择
#define kApi_CouponSelect @"coupon/select"

///分类菜单
#define kApi_CategoryCategoryHeader @"category/category-header"
///分类 
//#define kApi_CategoryIndex @"category/index"

#define kApi_CategoryIndex @"category/category-tab-list"

///分类 筛选
#define kApi_CategoryItemFilter @"category/filter"
///分类列表
#define kApi_CategorySearch @"category/search"
///虚拟列表
#define kApi_CategoryVirtual @"category/virtual"
///0元活动列表 ----此接口 V1.3.2版本用 special/get-channel-goods 代替
#define kApi_SpecialGetExchangeGoods @"special/get-exchange-goods"

///APP发生异常崩溃上报接口
#define kApi_AppCrashReport  @"default/app-exception"
///添加购物车
#define kApi_CartAdd @"cart/add"
///更新购物车
#define kApi_CartUpload @"cart/upload"
///取消购物车选中
#define kApi_CartUncheck @"cart/uncheck"

///APP获取文案接口
#define kApi_GetAPPCopywriting @"system/copywriting"
///绑定手机号相关
#define kApi_BindCellCountryList @"country/list-by-show"
#define kApi_BindPhone @"user/bind-phone"
/// 绑定手机号验证码
#define kApi_SendCode @"user/verif-phone-send"
#define kApi_VerifiCode @"user/verif-phone-verif"
///支付成功页获取订单信息
#define kApi_paymentStatus @"order/payment-status"
/// 获取带归因分享的链接
#define kApi_ShareUrl @"invite/share-url"
/// 个人中心广告位
#define kApi_UserCenterBanner @"banner/personal-center"
#endif /* STLRequestApiList_h */

