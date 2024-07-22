//
//  ZFPubilcKeyDefiner.h
//  ZZZZZ
//
//  Created by YW on 2018/3/30.
//  Copyright © 2018年 YW. All rights reserved.
//

#ifndef ZFPubilcKeyDefiner_h
#define ZFPubilcKeyDefiner_h

#pragma mark -=========================== 预编译第三方库宏 =============================

#define     LeandCloudEnabled
//#undef      LeandCloudEnabled

#define     AppsFlyerAnalyticsEnabled
//#undef      AppsFlyerAnalyticsEnabled

#define     googleAnalyticsV3Enabled
//#undef      googleAnalyticsV3Enabled

#define     BuglyEnabled
//#undef      BuglyEnabled

#define     BranchEnabled
//#undef      BranchEnabled

#pragma mark -=========================== 不区分开发环境第三方库Appkey =============================

// google+登录支持key
static NSString * const kGoogleLoginKey     = @"985806194647-prpmfvlv00igfvdvjic2l23d1mnefdm6.apps.googleusercontent.com";
// 谷歌地图key
static NSString * const kGoogleMapKey       = @"AIzaSyBcAd2G0fQM2XOBS10RtNmL_fRLAIuqqeM";
// Facebook Scheme key
static NSString * const kFacebookSchemeKey  = @"fb1396335280417835";
// PinterestSDK key
static NSString * const kPinterestSDKAppId  = @"4971046097895043971";
// GrowingIO统计 key
static NSString * const kGrowingIOAppId      = @"88bb4e0c99399b41";



#pragma mark -=========================== appsFlyer统计key =============================

//timing test
//启动时间
#define kStartLaunching                     @"startLaunching"
#define kFinishLaunching                    @"finishLaunching"
//首页加载时间
#define kStartLoadingHomeContent            @"startLoadingHomeContent"
#define kFinishLoadingHomeContent           @"finishLoadingHomeContent"
//一级分类页加载时间
#define kStartLoadingCategories             @"startLoadingCategories"
#define kFinishLoadingCategories            @"finishLoadingCategories"
//分类页加载时间
#define kStartLoadingCategory               @"startLoadingCategory"
#define kFinishLoadingCategory              @"finishLoadingCategory"
//搜索列表页加载时间
#define kStartLoadingSearchList             @"startLoadingSearchList"
#define kFinishLoadingSearchList            @"finishLoadingSearchList"
//商详页加载时间
#define kStartLoadingProductDetail          @"startLoadingProductDetail"
#define kFinishLoadingProductDetail         @"finishLoadingProductDetail"
//购物车页加载时间
#define kStartLoadingCartList               @"startLoadingCartList"
#define kFinishLoadingCartList              @"finishLoadingCartList"
//结算页加载时间
#define kStartLoadingOrderDetail            @"startLoadingOrderDetail"
#define kFinishLoadingOrderDetail           @"finishLoadingOrderDetail"
//创建订单加载时间
#define kStartLoadingCreateOrder            @"startLoadingCreateOrder"
#define kFinishLoadingCreateOrder           @"finishLoadingCreateOrder"
//登录加载时间
#define kStartLoadingSignIn                 @"startLoadingSignIn"
#define kFinishLoadingSignIn                @"finishLoadingSignIn"
//注册加载时间
#define kStartLoadingSignUp                 @"startLoadingSignUp"
#define kFinishLoadingSignUp                @"finishLoadingSignUp"
//来自哪个页面的 3DTouch 类型
#define k3DTouchComeFromTypeKey             @"k3DTouchComeFromTypeKey"


#pragma mark -=========================== 偏好设置key =============================
//App版本
#define APPVIERSION                                 @"APPVIERSION"
//系统语言
#define APPLELANGUAGES                              @"AppleLanguages"
#define kLaunchAdvertDataDictiontryKey              @"kLaunchAdvertDataDictiontryKey"
#define kLaunchAdvertImageDataKey                   @"kLaunchAdvertImageDataKey"
#define kLaunchAdvertModelJsonKey                   @"kLaunchAdvertModelJsonKey"
#define kIsFirstLaunching                           @"isFirstLaunching"
#define kAPPInstallTime                             @"kAPPInstallTime"
// 过滤在选择优惠券时不要公共参数
#define ZFTestForbidUserCoupon                      @"ZFTestForbidUserCoupon"

//判断表格数据空白页和分页的字段key
#define kTotalPageKey                               @"pageCount"
#define kCurrentPageKey                             @"curPage"
#define kListKey                                    @"list"

//服务端网络底层公共参数key
#define ZFApiActionKey                              @"action"
#define ZFApiTokenKey                               @"token"
#define ZFApiIsencKey                               @"is_enc"
#define ZFApiVersionKey                             @"version"
#define ZFApiLangKey                                @"lang"
#define ZFApiCountryIdKey                           @"user_country_id"
#define ZFApiCountryCodeKey                         @"user_country_code"
#define ZFApiDeviceId                               @"device_id"
#define ZFApiSessId                                 @"sess_id"
#define ZFApiAppsFlyerUID                           @"appsFlyerUID"
#define ZFApiCommunityCountryId                     @"country_id"
#define ZFApiCurrencySymbol                         @"bizhong"
#define ZFApiBtsUniqueID                            @"bts_unique_id"  // 大数据SDK唯一id

//服务端网络返回result字段key
#define ZFResultKey                                 @"result"
#define ZFDataKey                                   @"data"
#define ZFListKey                                   @"list"
#define ZFMsgKey                                    @"msg"
#define ZFErrorKey                                  @"error"

#define ZFSexSelect                                 @"ZFSexSelect"


/**主要用于用户信息本地存储*/
static NSString *const kDataKey                     = @"kDataKey";
// 文件名称
static NSString *const kFileName                    = @"kFileName";
//数据库名称
static NSString *const kDataBaseName                = @"database.db";
//数据库浏览记录表名称
static NSString *const kCommendTableName            = @"t_commend";
// 数据库商品浏览历史记录表名称
static NSString *const kGoodsHistoryTableName       = @"t_goods_history";


#pragma mark -=========================== 重用Cellkey =============================

// 商品列表cell
static NSString *const kZFCollectionMultipleColumnCellIdentifier = @"kZFCollectionMultipleColumnCellIdentifier";
// 商品列表cell中的颜色块cell
static NSString *const kZFCategoryListColorBlockCellIdentifier = @"kZFCategoryListColorBlockCellIdentifier";

//话题展示页
#define TOPIC_CELL_IDENTIFIER                       @"topicCell"

//社区cell重用标识
#define COMMUNITY_DETAIL_INENTIFIER                 @"CommunityDetailCell"


//社区cell重用标识
#define VIDEO_COMMENTS_CELL_INENTIFIER              @"videoCommentsCell"
#define VIDEO_RECOMMEND_CELL_INENTIFIER             @"videoRecommendCell"


#pragma mark -=========================== 其他key =============================

/**购物车Badge 数量*/
#define kCollectionBadgeKey                         @"kCollectionBadgeKey"
//是否需要显示toast
#define kSuccessNoShowToast                         @"kSuccessNoShowToast"

//登录记录
#define kUserEmail                                  @"kUserEmail"
#define kInitialize                                 @"kInitialize"
//用户信息定位
#define kLocationInfoCountryId                      @"locationInfoCountryId"
#define kLocationInfoCountryCode                    @"locationInfoCountryCode"
#define kLocationInfoPipeline                       @"locationInfoPipeline"
#define kExchangeKey                                @"kExchangeKey"
/**汇率-文件名称*/
#define kRateName                                   @"kRateName"
/**COD-文件名称*/
#define kFilterKey                                  @"kFilterKey"
#define kFilterName                                 @"kFilterName"

/**临时-文件名称*/
#define kTempFilterKey                              @"kTempFilterKey"
#define kTempCODKey                                 @"kTempCODKey"
#define kTempCombCod                                @"kTempCombCod"
#define kTempCombOnline                             @"kTempCombOnline"
/**当前货币*/
#define kNowCurrencyKey                             @"kNowCurrencyKey"
/**国别*/
#define kCountryKey                                 @"kCountryKey"
/**国别-文件名称*/
#define kCountryName                                @"kCountryName"

/**session_id -未登录的sessionId*/
#define kSessionId                                  @"kSessionId"

/**热词搜索*/
#define kSearchHistoryKey                           @"kSearchHistoryKey"

// 加载更多
#define LoadMore                                    @"0"
// 刷新
#define Refresh                                     @"1"
#define NoMoreToLoad                                @"NoMoreToLoad"
#define PageSize                                    @"15"
#define kLoadingView                                @"loadingView"
#define isLoaded                                    999
#define kHomeFloatModelKey                          @"kHomeFloatModelKey"
#define kHasRegisterRemotePush                      @"kHasRegisterRemotePush"
#define kHasShowSystemNotificationAlert             @"kHasShowSystemNotificationAlert"
#define kGroupShowSystemNotificationAlert           @"kGroupShowSystemNotificationAlert"

/**推送通知打开app处理*/
#define kLaunchOptionsRemoteNotificationKey         @"kLaunchOptionsRemoteNotificationKey"
/**推送通知点击打开跳转下一级时,接口添加标识*/
#define ktipRemoteAlertEventNotificationKey         @"ktipRemoteAlertEventNotificationKey"
/**推送通知点击打开跳转下一级时,接口添加标识 IOS*/
#define ktipRemoteAlertEventIOSNotificationKey      @"ktipRemoteAlertEventIOSNotificationKey"
/**推送、注册弹窗时间戳*/
#define kShowNotificationAlertTimestamp             @"kShowNotificationAlertTimestamp"
/**个人中心推送、注册弹窗时间戳*/
#define kAccountShowNotificationAlertTimestamp      @"kAccountShowNotificationAlertTimestamp"
#define DeepLinkModel                               @"ZZZZZDeepLinkModel"
#define kHasChangeCurrencyKey                       @"kHasChangeCurrencyKey"
#define kAccountCountryModelKey                     @"kAccountCountryModelKey"
#define kShowAppStoreReviewTimes                    @"kShowAppStoreReviewTimes"

#define HomeTimerKey                                @"HomeTimerKey"
#define KCarShowMoveToWlishKey                      @"KCarShowMoveToWlishKey"
#define kTestCMSParmaterSiftKey                     @"kTestCMSParmaterSiftKey"

#define kAppUpgradeDataKey                          @"kAppUpgradeDataKey"
#define kUpgradeShowVersion                         @"kUpgradeShowVersion"
#define kUpgradeShowDate                            @"kUpgradeShowDate"
#define kUpgradeShowTimes                           @"kUpgradeShowTimes"

// 杀掉App时记录时间,用在首页二次启动时判断是否显示未支付订单
#define kAlertUnpaidViewUserDefaultKey              @"kAlertUnpaidViewUserDefaultKey"
#define kHasShowUnpaidViewDateKey                   @"kHasShowUnpaidViewDateKey"
#define kHasShowUnpaidViewTimeKey                   @"kHasShowUnpaidViewTimeKey"


#define kLiveZegoCoverStateTimerEnd                   @"kLiveZegoCoverStateTimerEnd"

#define kUserJoinStudentVipSuccessKey               @"kUserJoinStudentVipSuccessKey"
#endif /* ZFPubilcKeyDefiner_h */
