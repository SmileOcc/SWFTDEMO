//
//  AddressAddApi.m
//  Yoshop
//
//  Created by YW on 16/6/7.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "AddressAddApi.h"
#import "AddressBookModel.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation AddressAddApi
{
    NSDictionary *_addressDic;
}

- (instancetype)initWithDic:(NSDictionary *)addressDic
{
    self = [super init];
    if (self) {
        _addressDic = addressDic;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}


- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_addressDic];
    [dic setValue:@"address/edit_address" forKey: @"action"];
    [dic setValue:TOKEN forKey: @"token"];
    return dic;
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
