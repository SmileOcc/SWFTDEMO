//
//  SearchResultApi.m
//  Dezzal
//
//  Created by YW on 18/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "SearchResultApi.h"
#import "NSStringUtils.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFAnalytics.h"
#import "ZFBTSManager.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface SearchResultApi ()
{
    NSString  * _searchString;
    NSInteger   _page;
    NSInteger   _size;
    NSString  * _orderby;
    NSString  * _featuring;
}
@end

@implementation SearchResultApi

- (instancetype)initSearchResultApiWithSearchString:(NSString *)searchString withPage:(NSInteger)page withSize:(NSInteger)size withOrderby:(NSString *)orderby featuring:(NSString *)featuring
{
    self = [super init];
    if (self) {
        _searchString = searchString;
        _page = page;
        _size = size;
        _orderby = orderby;
        _featuring = featuring;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    
    return ENCPATH;
}

- (id)requestParameters {
    ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
    NSMutableArray *bts_test = [NSMutableArray array];
    [bts_test addObject:[productPhotoBtsModel getBtsParams]];
    return @{
             @"action"    :@"search/get_list",
             @"keyword"   : _searchString,
             @"page"      : @(_page),
             @"page_size" : @(_size),
             @"order_by"  : _orderby,
             @"is_enc"    : @"0",
             @"appsFlyerUID"        : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
             ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
             @"featuring" : _featuring,
             @"bts_test"  : bts_test
//             @"enable_ab_test" : ZFToString([ZFABTestManager getEnableProductSearch])
             };
             
}
- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end

