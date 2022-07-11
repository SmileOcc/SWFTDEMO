//
//  OSSVWriteeRevieweAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWriteeRevieweAip.h"

@implementation OSSVWriteeRevieweAip {
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
    return kApi_ItemWriteComment;

}

-(NSString *)domainPath{
    return masterDomain;
}

- (id)requestParameters {
    
    
    return @{
             @"type"         : @"1",
             @"site"         : [OSSVLocaslHosstManager appName],
             @"order_id"     : STLToString(_dict[@"order_id"]),
             @"goods_id"     : STLToString(_dict[@"goods_id"]),
             @"site_version" : @"3",
             @"title"        : STLToString(_dict[@"title"]),
             @"content"      : STLToString(_dict[@"content"]),
             @"rate_overall" : _dict[@"rate_overall"] ? _dict[@"rate_overall"] : 0,
             @"review_pic_1"  : STLToString(_dict[@"review_pic1"]),
             @"review_pic_2"  : STLToString(_dict[@"review_pic2"]),
             @"review_pic_3"  : STLToString(_dict[@"review_pic3"]),
             };
}

//- (AFConstructingBlock)constructingBodyBlock {
//    return ^(id<AFMultipartFormData> formData) {
//        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
//        NSString *name = @"image";
//        NSString *formKey = @"image";
//        NSString *type = @"image/jpeg";
//        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
//    };
//}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
