//
//  OSSVAnalyticPagesManager.m
// XStarlinkProject
//
//  Created by odd on 2021/1/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAnalyticPagesManager.h"

#import "OSSVHomeMainVC.h"
#import "OSSVCategorysListVC.h"
#import "OSSVDetailsVC.h"
#import "OSSVSearchResultVC.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVAccountsMyOrderVC.h"
#import "OSSVMyCouponsItemVC.h"
#import "OSSVCartVC.h"
#import "OSSVWishListVC.h"
#import "OSSVCategorysVirtualListVC.h"
#import "OSSVAppNewThemeVC.h"
#import "OSSVCategorysNewZeroListVC.h"
#import "OSSVMessageVC.h"
#import "OSSVAccountsOrderDetailVC.h"
#import "OSSVFlashSaleMainVC.h"
#import "OOSVAccountVC.h"
#import "OSSVAccountOrdersPageVC.h"
#import "OSSVSearchResultVC.h"
#import "OSSVCategorysVC.h"

@implementation OSSVAnalyticPagesManager

+ (OSSVAnalyticPagesManager *)sharedManager {
    static OSSVAnalyticPagesManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.pageData = [OSSVAnalyticPagesManager initPageData];
        
        NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
        NSArray *arr = [identifier componentsSeparatedByString:@"_"];
        //NSString *displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
        sharedInstance.systemCountryCode = arr.lastObject;
        sharedInstance.systemLanguage = arr.firstObject;
    });
    return sharedInstance;
}

+ (NSDictionary *)currentPageInformDiction {
    NSString *currentPangeName = [OSSVAnalyticPagesManager sharedManager].currentPageName;
    NSDictionary *currentPageDic = [[OSSVAnalyticPagesManager sharedManager].pageData objectForKey:currentPangeName];
    
    if (!STLJudgeNSDictionary(currentPageDic)) {
        currentPageDic = @{@"pageType":@"0",@"pageCode":@""};
    }
    
    return currentPageDic;
}
+ (NSDictionary *)lastPageInformDiction {
    
    NSString *lastPangeName = [OSSVAnalyticPagesManager sharedManager].lastPageName;
    NSDictionary *currentPageDic = [[OSSVAnalyticPagesManager sharedManager].pageData objectForKey:lastPangeName];
    
    if (!STLJudgeNSDictionary(currentPageDic)) {
        currentPageDic = @{@"pageType":@"0",@"pageCode":@""};
    }
    
    return currentPageDic;
}

//所有也对应的按钮key
- (NSMutableDictionary *)pageButtonKey {
    if (!_pageButtonKey) {
        _pageButtonKey = [[NSMutableDictionary alloc] init];
    }
    
    return _pageButtonKey;
}

- (NSMutableDictionary *)pageStartEndTimeDic {
    if (!_pageStartEndTimeDic) {
        _pageStartEndTimeDic = [[NSMutableDictionary alloc] init];
    }
    return _pageStartEndTimeDic;
}

- (NSString *)lastButtonKey {
    NSString *pageName = @"";
    if (_currentPageName) {
        pageName = [self.pageButtonKey objectForKey:_currentPageName];
    }
    return STLToString(pageName);
}

- (void)setCurrentButtonKey:(NSString *)currentButtonKey {
    _currentButtonKey = currentButtonKey;
    
    if (_currentPageName) {
        [self.pageButtonKey setObject:STLToString(currentButtonKey) forKey:_currentPageName];
    }
}
- (void)setLastPageName:(NSString *)lastPageName {
    _lastPageName = lastPageName;
}



- (void)setCurrentPageName:(NSString *)currentPageName {
    if (_currentPageName && ![_currentPageName isEqualToString:currentPageName]) {
        self.lastPageName = _currentPageName;
    }
    _currentPageName = currentPageName;
}

- (void)pageStartTime:(NSString *)pageName {
    if (STLIsEmptyString(pageName)) {
        return;
    }
    //新增当前时间的时间戳
    double timeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *startKey = [NSString stringWithFormat:@"%@_time_start",pageName];
    [self.pageStartEndTimeDic setObject:[NSString stringWithFormat:@"%.0f", timeInterval] forKey:startKey];
}

- (NSString *)startPageTime:(NSString *)pageName {
    NSString *startKey = [NSString stringWithFormat:@"%@_time_start",pageName];

    NSString *time = [self.pageStartEndTimeDic objectForKey:startKey];
    return  time;
}

- (NSString *)endPageTime:(NSString *)pageName {
    
    //新增当前时间的时间戳
    double timeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *endKey = [NSString stringWithFormat:@"%@_time_end",pageName];
    [self.pageStartEndTimeDic setObject:[NSString stringWithFormat:@"%.0f", timeInterval] forKey:endKey];
    NSString *time = [NSString stringWithFormat:@"%.0f", timeInterval];
    return  time;
}

- (NSString *)pageEndTimeLength:(NSString *)pageName {
    if (STLIsEmptyString(pageName)) {
        return @"";
    }
    //新增当前时间的时间戳
//    double timeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *startKey = [NSString stringWithFormat:@"%@_time_start",pageName];
    NSString *endKey = [NSString stringWithFormat:@"%@_time_end",pageName];
    NSString *endTimeStr = [self.pageStartEndTimeDic objectForKey:endKey];
    double timeInterval = 0;
    
    if (STLIsEmptyString(endTimeStr)) {
        timeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    } else {
        timeInterval = [endTimeStr doubleValue];
    }
    double startTime = [[self.pageStartEndTimeDic objectForKey:startKey] doubleValue];
    if (timeInterval > startTime && startTime > 0) {
        [self.pageStartEndTimeDic setObject:@"" forKey:startKey];
        [self.pageStartEndTimeDic setObject:@"" forKey:endKey];

        //[self.pageStartEndTimeDic setObject:[NSString stringWithFormat:@"%.0f", timeInterval] forKey:startKey];

        double length = timeInterval - startTime;
        STLLog(@"----pageTime %@: %.0f",pageName,length);
        return [NSString stringWithFormat:@"%.0f", length];
    }
    return @"";
    
}

+ (NSDictionary *)initPageData {
    
    NSDictionary *dic = @{NSStringFromClass([OSSVHomeMainVC class]):@{@"pageType":@"1",@"pageCode":@"home"},
                          NSStringFromClass([OSSVCategorysVC class]):@{@"pageType":@"2",@"pageCode":@""},
                          NSStringFromClass([OSSVDetailsVC class]):@{@"pageType":@"3",@"pageCode":@""},
                          NSStringFromClass([OSSVSearchResultVC class]):@{@"pageType":@"4",@"pageCode":@""},
                          NSStringFromClass([STLActivityWWebCtrl class]):@{@"pageType":@"5",@"pageCode":@""},
                          NSStringFromClass([OSSVAccountsOrderDetailVC class]):@{@"pageType":@"9",@"pageCode":@""},
                          NSStringFromClass([OSSVMyCouponsItemVC class]):@{@"pageType":@"10",@"pageCode":@""},
                          NSStringFromClass([OSSVCartVC class]):@{@"pageType":@"11",@"pageCode":@"cart"},
                          NSStringFromClass([OSSVWishListVC class]):@{@"pageType":@"12",@"pageCode":@""},
                          NSStringFromClass([OSSVCategorysVirtualListVC class]):@{@"pageType":@"13",@"pageCode":@""},
                          NSStringFromClass([OSSVAppNewThemeVC class]):@{@"pageType":@"14",@"pageCode":@""},
                          NSStringFromClass([OSSVCategorysNewZeroListVC class]):@{@"pageType":@"16",@"pageCode":@"free_gift"},
                          NSStringFromClass([OSSVFlashSaleMainVC class]):@{@"pageType":@"17",@"pageCode":@""},
                          NSStringFromClass([OSSVSearchResultVC class]):@{@"pageType":@"95",@"pageCode":@""},
                          NSStringFromClass([OSSVCategorysListVC class]):@{@"pageType":@"6",@"pageCode":@""},
                          NSStringFromClass([OSSVAccountOrdersPageVC class]):@{@"pageType":@"97",@"pageCode":@""},
                          NSStringFromClass([OOSVAccountVC class]):@{@"pageType":@"98",@"pageCode":@"me"},
                          NSStringFromClass([OSSVMessageVC class]):@{@"pageType":@"99",@"pageCode":@"message"},
    };
    return dic;
}

+ (NSDictionary *)analyticsEvent:(NSString *)event paramsDic:(NSDictionary *)params {
    
    if (!params || ![params isKindOfClass:[NSDictionary class]]) {
        params = @{};
    }
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];
    
//    STLToString([OSSVAccountsManager sharedManager].device_id)
    NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;

    NSDictionary *dic = @{@"time":timeString,
                          @"event": STLToString(event),
                          @"user":@{
                                  @"user_id":USERID_STRING,
                                  @"email":@"",
                                  @"user_type":@"",
                                  @"user_is_login":@"",
                                  @"device_id":STLToString([OSSVAccountsManager sharedManager].device_id),
                                  @"udid":STLToString([OSSVAccountsManager sharedManager].device_id)},
                          @"header":@{
                                  @"brand_id"           : @"",
                                  @"brand_name"         : [OSSVLocaslHosstManager appName].lowercaseString,
                                  @"brand_platform"     : @"ios",
                                  @"app_version"        : kAppVersion,
                                  @"app_channel"        : @"",
                                  @"access"             : @"",
                                  @"client_ip"          : @"",
                                  @"carrier"            : @"",
                                  @"os_name"            : @"ios",
                                  @"os_version"         : STLToString([[STLDeviceInfoManager sharedManager] getDeviceVersion]),
                                  @"language"           : STLToString(currentLang),
                                  @"currency"           : [ExchangeManager localTypeCurrency],
                                  @"sys_language"       : [OSSVAnalyticPagesManager sharedManager].systemLanguage,
                                  @"region"             : @"",
                                  @"sys_region"         : [OSSVAnalyticPagesManager sharedManager].systemCountryCode,
                                  @"country_code"       : @"",
                                  @"device_type"        : @"ios",
                                  @"device_model"       : STLToString([[STLDeviceInfoManager sharedManager] getDeviceType]),
                                  @"device_brand"       : @"Apple",
                                  @"device_manufacturer": @"Apple",
                                  @"device_version"     : STLToString([[STLDeviceInfoManager sharedManager] getDeviceVersion]),
                          },
                          @"params":params
    };
    
    return  dic;
}


+ (NSString *)jsonStringAnalyticsEvent:(NSString *)event paramsDic:(NSDictionary *)params {
    NSDictionary *dict = [OSSVAnalyticPagesManager analyticsEvent:event paramsDic:params];
    NSString *parJson = [dict yy_modelToJSONString];
    
    return parJson;

}
@end
