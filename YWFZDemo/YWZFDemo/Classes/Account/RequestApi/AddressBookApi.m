//
//  AddressListApi.m
//  Yoshop
//
//  Created by Qiu on 16/6/6.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "AddressBookApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation AddressBookApi


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
    
    return @{
              @"action"     :   @"address/get_address_list",
              @"token"      :   TOKEN
             };
    
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
