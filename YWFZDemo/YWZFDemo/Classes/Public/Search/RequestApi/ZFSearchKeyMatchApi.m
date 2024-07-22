//
//  ZFSearchKeyMatchApi.m
//  ZZZZZ
//
//  Created by YW on 2017/12/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchKeyMatchApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@interface ZFSearchKeyMatchApi() {
    NSString            *_searchKey;
}

@end

@implementation ZFSearchKeyMatchApi
- (instancetype)initSearchResultApiWithSearchString:(NSString *)searchString
{
    self = [super init];
    if (self) {
        _searchKey = searchString;
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
    return @{
             @"action"    : @"search/association_keyword",
             @"keyword"   : _searchKey ?: @"",
             @"is_enc"    : @"0",
             };
}
- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
