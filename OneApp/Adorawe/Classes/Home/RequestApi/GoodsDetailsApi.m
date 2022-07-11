//
//  GoodsDetailsApi.m
//  Yoshop
//
//  Created by huangxieyue on 16/5/30.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsApi.h"

@implementation GoodsDetailsApi {
    NSString *_goodsId;
    NSString *_wid;
}

- (instancetype)initWithGoodsDetailGoodsId:(NSString *)goodsId Wid:(NSString*)wid {
    if (self = [super init]) {
        _goodsId = goodsId;
        _wid = wid;
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
    return @"item/index";
}

- (id)requestParameters {
    return @{
             @"goods_id" : _goodsId,
             @"wid" : _wid,
             @"commparam" : [NSString stringWithFormat:@"ver=%@&pf=ios",kAppVersion]
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

/// 请求的SerializerType
- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
