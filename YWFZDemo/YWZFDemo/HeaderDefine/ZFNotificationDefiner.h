//
//  ZFNotificationDefiner.h
//  ZZZZZ
//
//  Created by YW on 2018/5/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef ZFNotificationDefiner_h
#define ZFNotificationDefiner_h

#pragma mark -==================================通知相关====================================
//注册通知相关keyation
#define ZFAddNotificationObserver(notifyObserver, notifySelector, notifyName, notifyObject)     [[NSNotificationCenter defaultCenter] addObserver:notifyObserver selector:notifySelector name:notifyName object:notifyObject]

#define ZFRemoveNotification(notifyObserver, notifyName, notifyObject)           [[NSNotificationCenter defaultCenter] removeObserver:notifyObserver name:notifyName object:notifyObject]

#define ZFRemoveAllNotification(observer)                        [[NSNotificationCenter defaultCenter] removeObserver:observer]

#define ZFPostNotification(name, postObject)                    [[NSNotificationCenter defaultCenter] postNotificationName:name object:postObject]

#define ZFPostNotificationInfo(name, postObject, postUserInfo)  [[NSNotificationCenter defaultCenter] postNotificationName:name object:postObject userInfo:postUserInfo]


/**刷新购物车通知*/
static NSString *const kCartNotification                    = @"kCartNotification";
/**登陆通知*/
static NSString *const kLoginNotification                   = @"kLoginNotification";
/**退出通知*/
static NSString *const kLogoutNotification                  = @"kLogoutNotification";
/**改变货币类型通知*/
static NSString *const kCurrencyNotification                = @"kCurrencyNotification";
/**刷新收藏商品通知*/
static NSString *const kCollectionGoodsNotification         = @"kCollectionGoodsNotification";
/**刷新收藏帖子通知*/
static NSString *const kCollectionPostsNotification         = @"kCollectionPostsNotification";
/**改变用户信息通知*/
static NSString *const kChangeUserInfoNotification          = @"kChangeUserInfoNotification";
/**关注数量变化通知*/
static NSString *const kFollowStatusChangeNotification      = @"kFollowStatusChangeNotification";
/**点攒数量变化通知(旧的)*/
static NSString *const kLikeStatusChangeNotification        = @"kLikeStatusChangeNotification";
/**帖子点攒数量变化通知(新的)*/
static NSString *const kTopicLikedChangeNotification        = @"kTopicLikedChangeNotification";
/**评论数量变化通知*/
static NSString *const kReviewCountsChangeNotification      = @"kReviewCountsChangeNotification";
/**帖子收藏首次显示红点*/
static NSString *const kPostFirstCollectRedDotNotification  = @"kPostFirstCollectRedDotNotification";
/**删除变化通知*/
static NSString *const kDeleteStatusChangeNotification      = @"kDeleteStatusChangeNotification";
/**发送完照片Popular数据变化通知*/
static NSString *const kRefreshPopularNotification          = @"kRefreshPopularNotification";
/**基本发帖添加商品数量变化*/
static NSString *const kPostSelectGoodsCountNotification    = @"kPostSelectGoodsCountNotification";
/**发帖成功通知*/
static NSString *const kCommunityPostSuccessNotification    = @"kCommunityPostSuccessNotification";
/**发布话题，刷新话题详情页*/
static NSString *const kRefreshTopicNotification            = @"kRefreshTopicNotification";
/**分享成功通知*/
static NSString *const ZFShareCompleteNotification          = @"ZFShareCompleteNotification";
/** 没有网络通知key */
static NSString *const kNetWorkStatusChangeNotification     = @"kNetWorkStatusChangeNotification";
/**登录注册页面动画通知*/
static NSString *const kShowPlaceholderAnimationNotification = @"kShowPlaceholderAnimationNotification";
/**换肤通知*/
static NSString *const kChangeSkinNotification              = @"kChangeSkinNotification";
/**穿搭增加操作选项*/
static NSString *const kAddOutfitItem                       = @"kAddOutfitItem";
/**穿搭数量改变*/
static NSString *const kOutfitItemCountChange               = @"kOutfitItemCountChange";
/**需要重新登录通知*/
static NSString *const kNeedLoginNotification               = @"kNeedLoginNotification";
/** 全局系统导航栏换肤通知 */
static NSString *const kRefreshShowsFirstPageNotification     = @"kRefreshShowsFirstPageNotification";
static NSString *const kRefreshOutftisFirstPageNotification   = @"kRefreshOutftisFirstPageNotification";
static NSString *const kRefreshVideosFirstPageNotification    = @"kRefreshVideosFirstPageNotification";

/** 刷新当前国家信息 initialization接口 */
static NSString *const kRefreshCountryExchangeInfo          = @"kRefreshCountryExchangeInfo";
/** 刷新社区首页子频道通知 */
static NSString *const kRefreshCommunityChannelRefreshNotification = @"kRefreshCommunityChannelRefreshNotification";
static NSString *const kCommunityExploreScrollStatus        = @"setDiscoverViewScrollStatus";
static NSString *const kCommunityExploreNestViewScrollStatus = @"setNestViewCanScrollStatus";
/** 社区首页子频道滚动方向通知 */
static NSString *const kCommunityHomeChannelScrollDirectionUP = @"kCommunityHomeChannelScrollDirection";

/** 从后台进入前台活动*/
static NSString *const kAppDidBecomeActiveNotification        = @"kAppDidBecomeActiveNotification";
/** 同步 adgroup 广告数据*/
static NSString *const kAdGroupGoodsKey                       = @"kAdGroupGoodsKey";
/** 测试: 触发CMS请求测试数据*/
static NSString *const kCMSTestSiftDataNotification           = @"kCMSTestSiftDataNotification";
/** 测试: 触发主页请求切换到S3备份数据 */
static NSString *const kConvertToBackupsDataNotification      = @"kConvertToBackupsDataNotification";

static NSString *const kGoodsShowsDetailViewSuperScrollStatus = @"kGoodsShowsDetailViewSuperScrollStatus";
static NSString *const kGoodsShowsDetailViewSubScrollStatus   = @"kGoodsShowsDetailViewSubScrollStatus";

static NSString *const kGoodsDetailFooterSuperScrollStatus    = @"kGoodsDetailFooterSuperScrollStatus";
static NSString *const kGoodsDetailFooterSubScrollStatus      = @"kGoodsDetailFooterSubScrollStatus";

/** 从购物车页面通知商详页面刷新凑单提示 */
static NSString *const kRefreshGoodsDetailCartInfoNotification = @"kRefreshGoodsDetailCartInfoNotification";

/** 选择搭配购商品 */
static NSString *const kSetCollocationStatusNotification       = @"kSetCollocationStatusNotification";

/** 个人中心未支付订单倒计时完成 */
static NSString *const kAccountUnpaidCountDownStopNotify       = @"kAccountUnpaidCountDownStopNotify";

static NSString *const kRefreshWaitCommentListData              = @"kRefreshWaitCommentListData";

static NSString *const kZFReloadOrderListData = @"kZFReloadOrderListData";

/** Geshop原生专题 */
static NSString *const kNativeThemeRecoverArrowNotification = @"kNativeThemeRecoverArrowNotification";
static NSString *const kRefreshNativeThemeNavigationItem    = @"kRefreshNativeThemeNavigationItem";
static NSString *const kCheckScrollItemIsShow               = @"kCheckScrollItemIsShow";

#endif /* ZFNotificationDefiner_h */
