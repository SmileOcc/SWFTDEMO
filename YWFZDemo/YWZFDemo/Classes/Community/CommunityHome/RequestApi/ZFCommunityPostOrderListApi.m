
//
//  ZFCommunityPostOrderListApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostOrderListApi.h"
#import "AccountManager.h"

@interface ZFCommunityPostOrderListApi () {
    NSInteger _page;//当前页
    NSInteger _size;//每页显示数量
}

@end

@implementation ZFCommunityPostOrderListApi
- (instancetype)initWithOrderWithPage:(NSInteger)page pageSize:(NSInteger)pageSize {
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
             @"user_id" : [[AccountManager sharedManager] userId],
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
