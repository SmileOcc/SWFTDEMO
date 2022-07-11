//
//  STLSaveSexApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/10/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSavesSexsAip.h"

@implementation OSSVSavesSexsAip
{
    NSString *_sex;
}

- (instancetype)initWithSex:(NSString *)sex {
    if (self = [super init]) {
        _sex = sex;
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
    return [OSSVNSStringTool buildRequestPath:@"user/save-sex"];
}

- (id)requestParameters {
    return @{
             @"sex"            : STLToString(_sex) //  0男 1女 2默认
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
