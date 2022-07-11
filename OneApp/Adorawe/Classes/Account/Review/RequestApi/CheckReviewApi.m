//
//  OSSVCheckeRevieweAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckeRevieweAip.h"

@implementation OSSVCheckeRevieweAip {
    NSDictionary *_dict;
}

- (instancetype)initWithDict : (NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

//- (NSString *)baseURL {
//    return CommentURL;
//}

- (NSString *)requestPath {
    return kApi_ItemUserGoodsComment;
}

-(NSString *)domainPath{
    return masterDomain;
}

- (id)requestParameters {
    return @{
             @"type"        : @"9",
             @"site"        : [STLLocalHostManager appName],
             @"directory"   : @"31",
             @"commparam" : [NSStringTool buildCommparam],
             @"order_id"    : STLToString(_dict[@"order_id"]),
             @"goods_id"    : STLToString(_dict[@"goods_id"])
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
