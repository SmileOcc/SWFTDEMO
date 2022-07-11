//
//  CartDelApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CartDelApi.h"

@implementation CartDelApi {
    NSString *_wid;
    NSString *_goodsId;
}

//- (instancetype)initWithWid:(NSString *)wid goodsId:(NSString *)goodsId {
//    if (self = [super init]) {
//        _wid = wid;
//        _goodsId = goodsId;
//    }
//    return self;
//}
//
//- (BOOL)enableAccessory {
//    return YES;
//}
//
//- (NSURLRequestCachePolicy)requestCachePolicy {
//    return NSURLRequestReloadIgnoringCacheData;
//}
//
//- (NSString *)requestPath {
//    return [OSSVNSStringTool buildRequestPath:@"cart/del"];
//}
//
//- (id)requestParameters {
//    return @{
//             @"commparam" : [OSSVNSStringTool buildCommparam],
//             @"wid"      : STLToString(_wid),
//             @"goods_id"      : STLToString(_goodsId),
//             };
//}
//
//- (STLRequestMethod)requestMethod {
//    return STLRequestMethodPOST;
//}
//
//
//- (STLRequestSerializerType)requestSerializerType {
//    return STLRequestSerializerTypeJSON;
//}
@end
