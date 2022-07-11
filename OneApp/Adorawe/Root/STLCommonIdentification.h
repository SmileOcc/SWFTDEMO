//
//  STLCommonIdentification.h
// XStarlinkProject
//
//  Created by 10010 on 20/10/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#ifndef STLCommonIdentification_h
#define STLCommonIdentification_h

/**用户信息本地存储*/
static NSString *const kArchiverDataKey             = @"kArchiverDataKey";
static NSString *const kUserFileName                = @"kUserFileName";
static NSString *const kUserFileToken                = @"kUserFileName";

// 数据库名称
static NSString *const kCartDataBaseName            = @"cartdatabase.db";
// 数据库购物车表名称
static NSString *const kCartTableName               = @"t_cart";
// 数据库购物车表名称
static NSString *const kCommendTableName            = @"t_commend";

//Collection--->ContentOffset
static NSString *const kColletionContentOffsetName       = @"contentOffset";
// DZNEmptyDataSetView 类名
static NSString *const DZNEmptyDataSetViewName           = @"DZNEmptyDataSetView";
static NSString *const kUserFacebookLogin                = @"kUserFacebookLogin";

static const NSUInteger kSTLPageSize                     = 20;

static NSString *const kSTLCurrentAppIdentifier          = @"kSTLCurrentAppIdentifier";

/**推送、注册弹窗时间戳*/
static NSString *const kShowNotificationAlertTimestamp   = @"kShowNotificationAlertTimestamp";
/**推送通知弹窗显示时间戳*/
static NSString *const kShowAppNotificationAlertTimestamp   = @"kShowAppNotificationAlertTimestamp";
/** 从后台进入前台活动*/
static NSString *const kAppDidBecomeActiveNotification        = @"kAppDidBecomeActiveNotification";

#define kAddressProvinceCell                @"kAddressProvinceCell"
#define kAddressCityCell                    @"kAddressCityCell"

//成功发送SMS
#define SEND_SMS_SUCCESS                    @"sendSMSSuccess"
//发送失败
#define SEND_SMS_FAIL                       @"sendSMSFail"

//显示使用优惠券顶部文案的标识
static NSString *const kAppShowCouponHeadTitle    = @"kAppShowCouponHeadTitle";

/** 显示图层开关标识*/
static NSString *const kAppShowFLEXManager        = @"kAppShowFLEXManager";

/** 埋点开关标识*/
static NSString *const kAppShowTrackingManager        = @"kAppShowTrackingManager";

//判断表格数据空白页和分页的字段key
#define kTotalPageKey                               @"pageCount"
#define kCurrentPageKey                             @"curPage"
#define kListKey                                    @"list"

// 间距
#define kMarginSpace8                   8.0
#define kMarginSpace12                  12.0
#define kMarginSpace16                  16.0


#endif /* STLCommonIdentification_h */
