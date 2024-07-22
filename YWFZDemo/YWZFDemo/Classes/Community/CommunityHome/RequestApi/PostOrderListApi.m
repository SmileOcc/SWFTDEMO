//
//  PostOrderListApi.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "PostOrderListApi.h"
#import "AccountManager.h"

@implementation PostOrderListApi
{
    NSInteger _page;//当前页
    NSInteger _size;//每页显示数量
}

- (instancetype)initWithOrderWithPage:(NSInteger)page pageSize:(NSInteger)pageSize
{
    self = [super init];
    if (self) {
        _page = page;
        _size = pageSize;
    }
    return self;
}

- (id)requestParameters {
    
    return @{
             @"action"  : @"order/get_paid_order_goods_info",
             @"page" : @(_page),
             @"page_size" : @(_size),
             @"token" : [AccountManager sharedManager].account.token
             };
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



- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
