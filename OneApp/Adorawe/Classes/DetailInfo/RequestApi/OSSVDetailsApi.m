//
//  OSSVDetailsApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsApi.h"
#import "STLKeychainDataManager.h"

@implementation OSSVDetailsApi {
    NSString *_goodsId;
    NSString *_wid;
    NSString *_specialId;
    NSInteger _page;
    NSString *_is_cart_recommend;
    NSString *_token;
}

- (instancetype)initWithGoodsDetailGoods:(NSDictionary *)params {
    if (self = [super init]) {
        _goodsId = STLToString(params[@"goods_id"]);
        _wid = STLToString(params[@"wid"]);
        _specialId = STLToString(params[@"specialId"]);
        _page = [params[@"page"] integerValue];
        _is_cart_recommend = STLToString(params[@"is_cart_recommend"]);
        _token = STLToString(params[@"token"]);
        //is_cart_recommend 1 点击推荐商品，不获取推荐商品数据
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
    return [OSSVNSStringTool buildRequestPath:kApi_ItemIndex];
}

- (id)requestParameters {
    
    NSString *specialidStr = @"0";
    if (!STLIsEmptyString(_specialId) && ![STLToString(_specialId) isEqualToString:@"0"]) {
        specialidStr = @"1";
    }
    
    NSMutableDictionary *dict = [@{
        @"goods_id" : STLToString(_goodsId),
        @"wid" : STLToString(_wid),
        @"exchange_active_goods":specialidStr,
        @"is_cart_recommend":_is_cart_recommend.length > 0 ? _is_cart_recommend : @"0",
//             @"page_size" : @(10),
//             @"page" : @(_page),
        @"commparam" : [OSSVNSStringTool buildCommparam]
        
    } mutableCopy];
    
    if (![OSSVNSStringTool isEmptyString:_token]) {
        [dict setObject:_token forKey:@"token"];
    }
    
    if (_specialId.length > 0) {
        [dict setObject:_specialId forKey:@"specialId"];
    }
    if (_is_cart_recommend.length > 0) {
        [dict setObject:_is_cart_recommend forKey:@"is_cart_recommend"];
    }
    
    return dict;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
