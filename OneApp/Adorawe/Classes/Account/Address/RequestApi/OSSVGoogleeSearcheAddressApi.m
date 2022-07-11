//
//  OSSVGoogleeSearcheAddressApi.m
// XStarlinkProject
//
//  Created by Kevin on 2021/2/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVGoogleeSearcheAddressApi.h"

@interface OSSVGoogleeSearcheAddressApi (){
    NSString *_url;
}
@end

@implementation OSSVGoogleeSearcheAddressApi


- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

-(NSString *)domainPath {
    return @"";
}

- (NSString *)baseURL {
    return STLToString(_url);
}

- (NSString *)requestPath {
    return @"";
}

- (id)requestParameters {
    return nil;
}


- (STLRequestMethod)requestMethod {
    return STLRequestMethodGET;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeHTTP;
}

@end
