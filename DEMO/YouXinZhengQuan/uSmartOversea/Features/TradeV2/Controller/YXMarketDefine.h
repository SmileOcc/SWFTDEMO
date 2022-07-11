//
//  YXMarketDefine.h
//  YouXinZhengQuan
//
//  Created by rrd on 2018/7/26.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#ifndef YXMarketDefine_h
#define YXMarketDefine_h

typedef NS_ENUM(NSUInteger, YXStockDetailTabType) {
    YXStockDetailTabTypeNews = 0,
    YXStockDetailTabTypeAnnounce = 1,
    YXStockDetailTabTypeIntroduction = 2,
    YXStockDetailTabTypeFinance = 3,
   
};

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
/// 当前编译使用的 Base SDK 版本为 iOS 13.0 及以上
#define YX_IOS13_SDK_ALLOWED YES
#endif

static NSString *const cellReuseIdentifier_search =  @"cellReuseIdentifier_search";
static NSString *const cellReuseIdentifier_stockPicture =  @"cellReuseIdentifier_stockPicture";
static NSString *const cellReuseIdentifier_stockDetailNews =  @"cellReuseIdentifier_stockDetailNews";
static NSString *const cellReuseIdentifier_stockDetailAnnounce =  @"cellReuseIdentifier_stockDetailAnnounce";
static NSString *const cellReuseIdentifier_stockDealDeatail =  @"cellReuseIdentifier_stockDealDeatail";
static NSString *const cellReuseIdentifier_preMarket =  @"cellReuseIdentifier_preMarket";

static NSString *const cellReuseIdentifier_stockDetailHeader =  @"cellReuseIdentifier_stockDetailHeader";
static NSString *const cellReuseIdentifier_optionRecommend =  @"cellReuseIdentifier_optionRecommend";

/*
 香港交易所交易时间（不含集合竞价）：
 09:30 - 12:00  【交易】
 12:00 - 13:00  【中午休盘】
 13:00 - 16:00  【交易】
 */

// 香港交易所默认交易市场（分钟）
#define K_HKTradeDurations  (330.f)

// 第一个分时分割线，默认设置为120.f；表示在开盘后，120分钟除绘制一根时间参考线，即11点30分。
#define K_HKTimeFrameSeparateOne    (120.f)

// 第一个分时分割线，默认设置为240.f；表示在开盘后，120分钟除绘制一根时间参考线，即14点30分。
#define K_HKTimeFrameSeparateTwo    (240.f)


typedef NS_ENUM(NSInteger, YXAskBidType) {
    YXAskBidTypeOne      =   0,  // 1档
    YXAskBidTypeFive     =   1,  // 5档
    YXAskBidTypeTen      =   2,  // 10档
};

#endif /* YXMarketDefine_h */
