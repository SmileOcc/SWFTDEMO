//
//  CartAddApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CartAddApi.h"

@implementation CartAddApi {
    NSString *_wid;
    NSString *_goodsId;
    NSString *_specialId;
    NSInteger _goodsNum;
    NSInteger _flag;
    NSInteger _isChecked;
    NSString *_activeId;
    NSInteger _replace_free;
}

- (instancetype)initWithWid:(NSString *)wid goodsId:(NSString *)goodsId goodsNum:(NSInteger)goodsNum isChecked:(NSInteger)checked flag:(NSInteger)flag specialId:(NSString *)specialId activeId:(NSString *)activeId{
    if (self = [super init]) {
        _wid = wid;
        _goodsId = goodsId;
        _specialId = specialId;
        _goodsNum= goodsNum;
        _flag = flag;
        _isChecked = checked;
        _activeId = activeId;
    }
    return self;
}


- (instancetype)initWithWid:(NSString *)wid goodsId:(NSString *)goodsId goodsNum:(NSInteger)goodsNum isChecked:(NSInteger)checked flag:(NSInteger)flag specialId:(NSString *)specialId activeId:(NSString *)activeId replace_free:(NSInteger)replace_free{
    if (self = [super init]) {
        _wid = wid;
        _goodsId = goodsId;
        _specialId = specialId;
        _goodsNum= goodsNum;
        _flag = flag;
        _isChecked = checked;
        _activeId = activeId;
        _replace_free = replace_free;
    }
    return self;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_CartAdd];
}

- (id)requestParameters {
    
    NSString *specialidStr = @"";
    if (!STLIsEmptyString(_specialId) && ![STLToString(_specialId) isEqualToString:@"0"]) {
        specialidStr = @"1";
    }
    return @{
             @"commparam"     : [OSSVNSStringTool buildCommparam],
             @"wid"           : STLToString(_wid),
             @"specialId"     : STLToString(_specialId),
             @"goods_id"      : STLToString(_goodsId),
             @"goods_number"  : @(_goodsNum),
             @"flag"          : @(_flag),
             @"is_checked"    : @(_isChecked),
             @"exchange_active_goods" : specialidStr,
             @"flash_sale_active_id" :STLToString(_activeId),
             @"replace_free_goods" : @(_replace_free),
             @"size_country_code": STLToString(_size_country_code)
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
