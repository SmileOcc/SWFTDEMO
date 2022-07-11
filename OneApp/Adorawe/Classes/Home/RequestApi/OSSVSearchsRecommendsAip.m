//
//  STLSearchRecommendApi.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/5/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSearchsRecommendsAip.h"

@implementation OSSVSearchsRecommendsAip{
    NSString *_keyword;
    NSInteger _page;
    NSInteger _pageSize;
}

- (instancetype)initWithSearchRecommendWithKeyword:(NSString *)keyword  Page:(NSInteger)page pageSize:(NSInteger)pageSize {
    
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
    return [OSSVNSStringTool buildRequestPath:kApi_SearchResultRecommeds];
}

- (id)requestParameters {
    return @{
             @"page"        : @(_page),
             @"page_size"   : @(_pageSize),
             @"keyword"     : _keyword,
             @"commparam"   : [OSSVNSStringTool buildCommparam]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
