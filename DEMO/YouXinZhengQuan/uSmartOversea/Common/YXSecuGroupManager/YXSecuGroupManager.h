//
//  YXSecuGroupManager.h
//  uSmartOversea
//
//  Created by ellison on 2018/11/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXSecuGroup.h"
#import "YXSecuProtocol.h"

#define kYXMarketHK @"hk"
#define kYXMarketUS @"us"
#define kYXMarketChinaSH @"sh"
#define kYXMarketChinaSZ @"sz"
#define kYXMarketChinaHS @"hs"
#define kYXMarketChina @"cn"
#define kYXMarketHS @"hs"
#define kYXMarketUsOption @"usoption"
#define kYXMarketCryptos @"cryptos"
#define kYXMarketSG @"sg"

#define kYXAllMarket @[kYXMarketHK, kYXMarketUS, kYXMarketChinaSH, kYXMarketChinaSZ, kYXMarketUsOption,kYXMarketSG]
#pragma mark - A股
#define kYXIndexSSE @"000001" //上证指数
#define kYXIndexHSSSE [kYXMarketChinaSH stringByAppendingString:kYXIndexSSE] //上证指数

#define kYXIndexSZSE @"399001" //深证指数
#define kYXIndexHSSZSE [kYXMarketChinaSZ stringByAppendingString:kYXIndexSZSE] //深证指数

#define kYXIndexGEM @"399006" //创业板指
#define kYXIndexHSGEM [kYXMarketChinaSZ stringByAppendingString:kYXIndexGEM] //创业板指

#define kYXAllChinaSecuDefault @[kYXIndexHSSSE] // A股默认自选股
#define kYXAllChinaIndex @[kYXIndexHSSSE, kYXIndexHSSZSE, kYXIndexHSGEM]    // A股市场指数

#pragma mark - 港股
#define kYXIndexHSI @"HSI" //恒生指数
#define kYXIndexHKHSI [kYXMarketHK stringByAppendingString:kYXIndexHSI] //恒生指数

#define kYXIndexHSCEI @"HSCEI" //国企指数
#define kYXIndexHKHSCEI [kYXMarketHK stringByAppendingString:kYXIndexHSCEI] //国企指数

#define kYXIndexHSCCI @"HSCCI" //红筹指数
#define kYXIndexHKHSCCI [kYXMarketHK stringByAppendingString:kYXIndexHSCCI] //红筹指数

#define kYXIndexHSTECH @"HSTECH" //红筹指数
#define kYXIndexHKHSTECH [kYXMarketHK stringByAppendingString:kYXIndexHSTECH] //红筹指数

#define kYXAllHKSecuDefault @[kYXIndexHKHSI, kYXIndexHKHSTECH,kYXIndexHKHSCEI] // 港股默认自选股
#define kYXAllHKIndex @[kYXIndexHKHSI, kYXIndexHKHSCEI, kYXIndexHKHSCCI]    // 港股市场指数

#pragma mark - 美股
#define kYXIndexDIA @"DIA" //道琼斯指数
#define kYXIndexUSDIA [kYXMarketUS stringByAppendingString:kYXIndexDIA] //道琼斯指数

#define kYXIndexIXIC @".IXIC" //纳斯达克指数
#define kYXIndexUSIXIC [kYXMarketUS stringByAppendingString:kYXIndexIXIC] //纳斯达克指数
#define kYXIndexIXICETF @".IXIC_ETF" //纳斯达克指数

#define kYXIndexQQQ @"QQQ"  // 纳指100ETF
#define kYXIndexUSQQQ [kYXMarketUS stringByAppendingString:kYXIndexQQQ] // 纳指100ETF

#define kYXIndexSPY @"SPY"  // 标普500指数
#define kYXIndexUSSPY [kYXMarketUS stringByAppendingString:kYXIndexSPY] // 标普500指数
#define kYXIndexARKK [kYXMarketUS stringByAppendingString:@"ARKK"]

#define kYXAllUSSecuDefault @[kYXIndexUSQQQ,kYXIndexUSSPY,kYXIndexARKK]    // 美股默认自选股
#define kYXAllUSIndex @[kYXIndexUSDIA, kYXIndexUSQQQ, kYXIndexUSSPY]    //美股市场指数


#define kYXAllSGSecuDefault @[kYXIndexES3,kYXIndex087]    // 新加坡默认自选股
#define kYXIndexES3 [kYXMarketSG stringByAppendingString:@"ES3"]
#define kYXIndex087 [kYXMarketSG stringByAppendingString:@"O87"]
#define kYXIndexEVS [kYXMarketSG stringByAppendingString:@"EVS"]


#pragma mark - 期权 (暂时只有美股）
#define kYXAllOptionSecuDefault  @[]

#pragma mark - 全部
#define kYXAllIndex @[kYXIndexHKHSI, kYXIndexHKHSCEI, kYXIndexHKHSCCI, kYXIndexHKHSTECH, kYXIndexUSDIA, kYXIndexUSQQQ, kYXIndexUSSPY, kYXIndexHSSSE, kYXIndexHSSZSE, kYXIndexHSGEM]

#define kYXIndexNameDict @{kYXIndexHKHSI: @"恒生指数", kYXIndexHKHSCEI: @"国企指数", kYXIndexHKHSCCI: @"红筹指数", kYXIndexHKHSTECH: @"恒生科技指数", kYXIndexUSDIA: @"道琼斯ETF", kYXIndexUSQQQ: @"纳指100ETF", kYXIndexUSSPY: @"标普500ETF", kYXIndexHSSSE: @"上证指数", kYXIndexHSSZSE: @"深证指数", kYXIndexHSGEM: @"创业板指"}

#define kSecuGroupRemoveSecuNotification @"kSecuGroupRemoveSecuNotification"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXSecuGroupState) {
    YXSecuGroupStateUnLogin,
    YXSecuGroupStateLogined,
};

typedef  void (^SynchroGroupBlock)(dispatch_block_t _Nullable complete);

@interface YXSecuGroupManager : NSObject

@property (nonatomic, assign) YXSecuGroupState state;

@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger sortflag;
@property (nonatomic, assign) NSInteger loginedSecuGroupVersion;
@property (nonatomic, assign) NSInteger unloginSecuGroupVersion;

@property (nonatomic, assign) NSInteger loginedSecuGroupSortflag;
@property (nonatomic, assign) NSInteger unloginSecuGroupSortflag;

@property (nonatomic, assign) NSInteger stockMaxNum;

@property (nonatomic, strong, readonly) NSArray<YXSecuGroup *> *allGroupsForPostToServer;
@property (nonatomic, strong, readonly) NSArray<YXSecuGroup *> *allGroupsForShow;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *,YXSecuGroup *> *defaultGroupPool;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *,YXSecuGroup *> *customGroupPool;

@property (nonatomic, strong, readonly) YXSecuGroup *allSecuGroup;
@property (nonatomic, strong) YXSecuGroup *holdSecuGroup;
@property (nonatomic, strong) YXSecuGroup *latestSecuGroup; // 自选股分组中的“近期交易”
@property (nonatomic, strong, readonly) YXSecuGroup *hkSecuGroup; // 自选股分组中的“港股”

@property (nonatomic, copy) SynchroGroupBlock getGroupIfNeed;
@property (nonatomic, copy) SynchroGroupBlock postGroupIfNeed;
@property (nonatomic, copy) SynchroGroupBlock synchroHoldGroup;


+ (instancetype)shareInstance;

- (void)updateAllGroupListWithList:(NSArray *)list;
- (void)userSetSortflag:(NSInteger)flag;

- (void)transactCheckHold;
- (void)invalidCheckHold;

- (void)checkLatestTrade;

- (void)getGroup;
- (void)postGroup;

- (void)_update;

- (void)login:(BOOL)isFirst;
- (void)logout;
- (void)guessLogin;

- (BOOL)containsSecu:(id<YXSecuIDProtocol>)secu;

- (NSArray<YXSecuGroup *> *)customGroupListWithSecu:(id<YXSecuIDProtocol>)secu;

- (NSArray<YXSecuGroup *> *)allCustomGroupList;

#pragma mark - group methods
- (void)removeGroupWithGroupID:(NSUInteger)groupID;

- (BOOL)createGroup:(NSString *)name;

- (void)change:(YXSecuGroup *)secuGroup name:(NSString *)name;

- (void)exchange:(YXSecuGroup *)secuGroup to:(NSInteger)index;

#pragma mark - remove methods
- (void)remove:(id<YXSecuIDProtocol>)secu;

- (void)removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus;

- (void)removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup;

- (void)remove:(id<YXSecuIDProtocol>)secu secuGroup:(YXSecuGroup *)secuGroup;

#pragma exchange methods
- (void)stick:(YXSecuGroup *)secuGroup secu:(id<YXSecuIDProtocol>)secu;

- (void)exchange:(YXSecuGroup *)secuGroup secu:(id<YXSecuIDProtocol>)secu to:(NSInteger)index;

#pragma mark - append methods
- (BOOL)append:(id<YXSecuProtocol>)secu;

- (BOOL)appendArray:(NSArray<id<YXSecuProtocol>> *)secus;

- (BOOL)append:(id<YXSecuProtocol>)secu secuGroup:(YXSecuGroup *)secuGroup;

- (BOOL)appendArray:(NSArray<id<YXSecuProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup;

- (BOOL)_appendArray:(NSArray<id<YXSecuProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup needPost:(BOOL)needPost;

- (void)_removeArray:(NSArray<id<YXSecuIDProtocol>> *)secus secuGroup:(YXSecuGroup *)secuGroup needPost:(BOOL)needPost;



@end

NS_ASSUME_NONNULL_END
