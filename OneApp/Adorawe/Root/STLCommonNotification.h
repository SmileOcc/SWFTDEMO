//
//  STLCommonNotification.h
// XStarlinkProject
//
//  Created by 10010 on 20/10/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#ifndef STLCommonNotification_h
#define STLCommonNotification_h


static NSString *const kNotif_OnlineAddressUpdate  = @"kNotif_OnlineAddressUpdate";


/**强制更新*/
static NSString *const kNotif_UpdateApp                 = @"kNotif_UpdateApp";
/**首页广告*/
static NSString *const kNotif_HomeAdv                   = @"kNotif_HomeAdv";

/**通知设置*/
static NSString *const kNotif_NotificationSuccess                   = @"kNotif_NotificationSuccess";

/**通知设置*/
static NSString *const kNotif_NetWorkStatusChange     = @"kNotif_NetWorkStatusChange";
/**刷新购物车*/
static NSString *const kNotif_Cart                      = @"kNotif_Cart";
static NSString *const kNotif_CartBadge                 = @"kNotif_CartBadge";

/**收藏或者取消收藏*/
static NSString *const kNotif_Favorite                = @"kNotif_Favorite";

static NSString *const kNotif_Login                     = @"kNotif_Login";
static NSString *const kNotif_Logout                    = @"kNotif_Logout";

static NSString *const kNotif_ChangeUserInfo            = @"kNotif_ChangeUserInfo";
static NSString *const kNotif_RefrshUserInfo            = @"kNotif_RefrshUserInfo";
static NSString *const kNotif_ChangeAccountRedDot       = @"kNotif_ChangeAccountRedDot";
static NSString *const kNotif_ChangeMessageCountDot     = @"kNotif_ChangeMessageCountDot";
static NSString *const kNotif_Currency                  = @"kNotif_Currency";

/**商品详情推荐列表*/
static NSString *const kNotif_GoodsDetailCommend        = @"kNotif_GoodsDetailCommend";
/**更新频道*/
static NSString *const kNotif_HomeChannel               = @"kNotif_HomeChannel";
static NSString *const kNotif_HomeDataRefresh           = @"kNotif_HomeDataRefresh";
static NSString *const kNotif_ChangeGender              = @"kNotif_ChangeGender";
static NSString *const kNotif_RefreshOrderList          = @"kNotif_RefreshOrderList";

/**下载完成气氛*/
static NSString *const kNotif_LoadFinishTabbarIcon      = @"kNotif_LoadFinishTabbarIcon";
//首页上下滑动的通知
static NSString *const kNotif_HomeScroll                = @"kNotif_HomeScroll";

//商品详情页 闪购活动倒计时结束后的通知
static NSString *const kNotif_GoodsDetailReloadData     =  @"kNotif_GoodsDetailReloadData";
//商品详情页 size属性外露点击的通知
static NSString *const kNotif_GoodsDetailSizeTap     =  @"kNotif_GoodsDetailSizeTap";
//商品详情页 color属性外露点击的通知
static NSString *const kNotif_GoodsDetailColorTap     =  @"kNotif_GoodsDetailColorTap";

static NSString *const kNotif_AccountGoodsSupScrollStatus = @"kNotif_AccountGoodsSupScrollStatus";
/**个人中心商品*/
static NSString *const kNotif_AccountGoodsSubScrollStatus  = @"kNotif_AccountGoodsSubScrollStatus";

//提交订单--身份证信息正确通知
static NSString *const kNotif_orderCreateWithIdCard     = @"kNotif_orderCreateWithIdCard";

/**输入框动画通知*/
static NSString *const kNotif_ShowPlaceholderAnimation = @"kNotif_ShowPlaceholderAnimation";

//*****无支付方式选中的通知*****//
static NSString *const kNotif_changePaymentSelectedRedIcon = @"kNotif_changePaymentSelectedRedIcon";

//*****选中一种支付方式的通知*****//
static NSString *const kNotif_changePaymentSelectedIcon = @"kNotif_changePaymentSelectedIcon";

//*****打开系统推送的通知******//
static NSString *const kNotif_openPushSuccess =  @"kNotif_openPushSuccess";

//*****登录成功更新首页悬浮数据的通知******//
static NSString *const kNotif_updateHomeFloatBannerData = @"kNotif_updateHomeFloatBannerData";
//*****删除地址与订单页的地址ID相同时，发送通知***********//

static NSString *const kNotif_updateCheckOrder = @"kNotif_updateCheckOrder";

//*****优惠券组件领取成功通知***********//
static NSString *const kNotif_getCouponsSuccess = @"kNotif_getCouponsSuccess";
//*****首页banner获取成功通知***********//
static NSString *const kNotif_getHomeBottomBannerSuccess = @"kNotif_getHomeBottomBannerSuccess";
#endif /* STLCommonNotification_h */
