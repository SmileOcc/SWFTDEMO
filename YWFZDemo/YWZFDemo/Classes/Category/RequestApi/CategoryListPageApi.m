//
//  CategoryListPageApi.m
//  ListPageViewController
//
//  Created by YW on 23/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryListPageApi.h"
#import "NSStringUtils.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFBTSManager.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@implementation CategoryListPageApi {
    NSDictionary *_dict;
    bool         _isVirtual;
}

-(instancetype)initListPageApiWithParameter:(id)parameter virtual:(BOOL)isVirtual{
    self = [super init];
    if (self) {
        _dict = parameter;
        _isVirtual = isVirtual;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

-(BOOL)encryption {
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
    NSDictionary *baseDict = @{
                               @"cat_id"              : [NSStringUtils emptyStringReplaceNSNull:_dict[@"cat_id"]],
                               @"page"                : [NSStringUtils emptyStringReplaceNSNull:_dict[@"page"]] ,
                               @"page_size"           : @(20),
                               @"order_by"            : [NSStringUtils emptyStringReplaceNSNull:_dict[@"order_by"]],
                               @"price_min"           : [NSStringUtils emptyStringReplaceNSNull:_dict[@"price_min"]],
                               @"price_max"           : [NSStringUtils emptyStringReplaceNSNull:_dict[@"price_max"]],
                               @"is_enc"              : @"0",
                               @"keyword"             : [NSStringUtils emptyStringReplaceNSNull:_dict[@"keyword"]],
                               @"outfit"              : ZFToString(_dict[@"outfit"]),
                               @"appsFlyerUID"        : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                               ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
                               @"featuring"           : ZFToString(_dict[@"featuring"]),
                               @"bts_test"            : bts_test,
                               };
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:baseDict];
    
    if (self->_isVirtual) {
        [resultDict setValue:@"category/get_promotion_goods" forKey:@"action"];
        [resultDict setValue:[NSStringUtils emptyStringReplaceNSNull:_dict[@"type"]] forKey:@"type"];
        [resultDict setValue:[NSStringUtils emptyStringReplaceNSNull:_dict[@"price_id"]] forKey:@"price_id"];
        
        // ABTest: 新品
        if ([[resultDict valueForKey:@"type"] isEqualToString:@"new"] ||
            [[resultDict valueForKey:@"type"] isEqualToString:@"newarrivals"]) {
        }
        
    }else{
        [resultDict setValue:@"category/get_list" forKey:@"action"];
        [resultDict setValue:[NSStringUtils emptyStringReplaceNSNull:_dict[@"selected_attr_list"]] forKey:@"selected_attr_list"];
    }
    
    return resultDict;
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end

