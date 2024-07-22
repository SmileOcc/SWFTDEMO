//
//  MyOrdersListApi.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/11.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "MyOrdersListApi.h"
#import "NSStringUtils.h"
#import "AccountManager.h"
#import "Constants.h"

@implementation MyOrdersListApi {
    NSInteger _page;
    NSInteger _pageSize;
}

- (instancetype)initWithPage:(NSInteger )page{
    self = [super init];
    if (self) {
        _page = page;
    }
    return self;
}
- (BOOL)enableCache {
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
             @"action"      :   @"order/index",
             @"token"       :   TOKEN,
             @"page"        :   @(_page),
             @"page_size"   :   @(10),
             @"is_enc"      : @"0"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
