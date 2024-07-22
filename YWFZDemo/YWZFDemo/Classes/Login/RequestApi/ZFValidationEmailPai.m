//
//  ZFValidationEmailPai.m
//  ZZZZZ
//
//  Created by YW on 2018/4/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFValidationEmailPai.h"
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"

@implementation ZFValidationEmailPai {
    NSString *_email;
}

- (instancetype)initWithEmail:(NSString *)email {
    
    self = [super init];
    if (self) {
        _email = email;
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
    return [NSStringUtils buildRequestPath:@""];
}

- (id)requestParameters {
    return @{
             @"action"  : @"user/validation_email",
             @"email"   : ZFToString(_email),
             @"is_enc"  : @"0"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
