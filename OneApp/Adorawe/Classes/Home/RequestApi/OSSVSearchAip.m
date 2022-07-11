//
//  SeachApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchAip.h"
@import RangersAppLog;

@implementation OSSVSearchAip {
    NSString *_keyword;
    NSInteger _page;
    NSInteger _pageSize;
    
}

- (instancetype)initWithSearchKeyWord:(NSString *)keyword page:(NSInteger)page pageSize:(NSInteger)pageSize {
    
    self = [super init];
    if (self) {
        _keyword = keyword;
        _page = page;
        _pageSize = pageSize;
    }
    return self;
}

- (BOOL)enableCache {
    if (_page == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_SearchSearch];
}

- (id)requestParameters {
    NSString *newSearch_engine = [BDAutoTrack ABTestConfigValueForKey:@"search_engine" defaultValue:@("")];
    
    NSMutableDictionary *params = [@{
        @"keyword"     : _keyword,
        @"page"        : @(_page),
        @"page_size"   : @(_pageSize),
        @"commparam"   : [OSSVNSStringTool buildCommparam],
        @"deep_link_id" : STLToString(self.deepLinkId),
    } mutableCopy];
    if (OSSVAccountsManager.sharedManager.sysIniModel.abtest_switch){
        [params setObject:STLToString(newSearch_engine) forKey:@"search_engine"];
    }
    return params;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
