//
//  OSSVAccounteGoodseReviewsAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteGoodseReviewsAip.h"

@implementation OSSVAccounteGoodseReviewsAip
{
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return kApi_UserMyReviews;
}

-(NSString *)domainPath
{
    return masterDomain;
}

- (id)requestParameters {
    return @{
             @"reviewed"            : _dict[@"reviewed"] ? _dict[@"reviewed"] : @0,
             @"type"                : _dict[@"type"] ? _dict[@"type"] : @0,
             @"page"                : _dict[@"page"] ? _dict[@"page"] : @0,
             @"page_size"           : _dict[@"page_size"] ? _dict[@"page_size"] : @20,
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
