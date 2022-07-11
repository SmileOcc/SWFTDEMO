//
//  CartEditApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CartEditApi.h"

@implementation CartEditApi {
    NSString *_wid;
    NSString *_goodsId;
    NSInteger _goodsNum;
}

//- (instancetype)initWithWid:(NSString *)wid goodsId:(NSString *)goodsId goodsNum:(NSInteger)goodsNum {
//    if (self = [super init]) {
//        _wid = wid;
//        _goodsId = goodsId;
//        _goodsNum = goodsNum;
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
//    return [OSSVNSStringTool buildRequestPath:@"cart/edit"];
//}
//
//- (id)requestParameters {
//    return @{
//             @"commparam" : [OSSVNSStringTool buildCommparam],
//             @"wid"      : STLToString(_wid),
//             @"goods_id"      : STLToString(_goodsId),
//             @"goods_number" : @(_goodsNum),
//             @"last_modify" : [NSString stringWithFormat:@"%ld",time(NULL)]
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
