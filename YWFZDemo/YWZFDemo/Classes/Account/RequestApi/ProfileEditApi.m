//
//  ProfileEditApi.m
//  Yoshop
//
//  Created by Qiu on 16/6/3.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ProfileEditApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation ProfileEditApi {
    
    NSDictionary *_dic;
}

-(instancetype)initWithDic:(NSDictionary *)dic {
    
    self = [super init];
    if (self) {
        _dic = dic;
    }
    return self;
}
- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_dic];
    [dic setValue:@"user/edit_user_info" forKey:@"action"];
    [dic setValue:TOKEN forKey:@"token"];
    [dic removeObjectForKey:kLoadingView];
    return dic;
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
