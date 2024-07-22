//
//  WriteReviewApi.m
//  ZZZZZ
//
//  Created by YW on 2016/12/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "WriteReviewApi.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation WriteReviewApi{
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
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

- (NSDictionary *)fetchDataJson {
    NSDictionary *dict = @{
                           @"site"            : @"ZZZZZ",
                           @"title"           : _dict[@"title"],
                           @"pros"            : _dict[@"content"],
                           @"rate_overall"    : _dict[@"rate_overall"],
                           @"site_version"    : @"3",
                           @"goods_id"        : _dict[@"goods_id"],
                           @"nickname"        : [AccountManager sharedManager].account.nickname ?: @"",
                           @"sync_community"  : _dict[@"sync_community"],
                           };
    return dict;
}

- (id)requestParameters {
    NSString *jsonStr = [[self fetchDataJson] yy_modelToJSONString];
    
    return @{
             @"action"          : @"review/write_goods_review",
             @"is_enc"          : @"0",
             @"data"            : [jsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@""],
             @"site"            : @"ZZZZZ",
             @"title"           : _dict[@"title"],
             @"pros"            : _dict[@"content"],
             @"rate_overall"    : _dict[@"rate_overall"],
             @"sync_community"  : _dict[@"sync_community"],
             @"site_version"    : @"3",
             @"goods_id"        : _dict[@"goods_id"],
             @"nickname"        : [AccountManager sharedManager].account.nickname ?: @"",
             @"user_id"         : USERID,
             @"height"          : _dict[@"height"],
             @"bust"            : _dict[@"bust"],
             @"waist"           : _dict[@"waist"],
             @"hips"            : _dict[@"hips"],
             @"is_save"         : _dict[@"is_save"],
             @"overall_fit"     : _dict[@"overall_fit"],
             @"attr_strs"       : _dict[@"attr_strs"],
             };
}

- (NSDictionary<NSString *,NSString *> *)requestHeader {
    NSString *dataJson = [[self fetchDataJson] yy_modelToJSONString];
    NSString *jsonStr = [dataJson stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *key = [YWLocalHostManager appPrivateKey];
    NSString *headerKey = [NSStringUtils ZFNSStringMD5:[jsonStr stringByAppendingString:key]];
    NSString *headerValue = [NSStringUtils ZFNSStringMD5:[[jsonStr stringByAppendingString:headerKey] stringByAppendingString:key]];
    return @{
             headerKey:headerValue
             };
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSArray *images = self->_dict[@"images"];
        [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *data = UIImageJPEGRepresentation(obj, 0.99);
            
            NSArray *typeArray = [self typeForImageData:data];
            
            NSString *name = [NSString stringWithFormat:@"pic_%lu.%@",(unsigned long)idx,typeArray[1]];
            NSString *formKey = [NSString stringWithFormat:@"pic_%lu",(unsigned long)idx];
            NSString *type = typeArray[0];
            
            YWLog(@"%@---%@---%@",formKey,name,type);
            
            [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
        }];
    };
}

- (NSArray *)typeForImageData:(NSData *)data {
    
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @[@"image/jpeg",@"jpg"];
            
        case 0x89:
            
            return @[@"image/png",@"png"];
            
        case 0x47:
            
            return @[@"image/gif",@"gif"];
            
        case 0x49:
        case 0x4D:
            
            return @[@"image/tiff",@"tiff"];
            
    }
    
    return nil;
    
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
