//
//  CheckFbidApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CheckFbidApi.h"

@implementation CheckFbidApi {
    NSString *_fbid;
    NSString *_token;
}

- (instancetype)initWithFbid:(NSString *)fbid token:(NSString *)token{
    
    self = [super init];
    if (self) {
        _fbid = fbid;
        _token = token;
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
    return [OSSVNSStringTool buildRequestPath:kApi_SearchAssociate];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"fb_id"     : STLToString(_fbid),
             @"thirdtoken": STLToString(_token)
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
