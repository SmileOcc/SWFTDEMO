//
//  PostApi.m
//  Yoshop
//
//  Created by YW on 16/7/20.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "PostApi.h"
#import "YWLocalHostManager.h"
#import "AccountManager.h"
#import "Constants.h"
#import "ZFApiDefiner.h"
#import "YWCFunctionTool.h"

@implementation PostApi {
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

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

-(BOOL)encryption {
    return YES;
}

-(BOOL)isCommunityRequest{
    return YES;
}

- (NSDictionary *)fetchDataJson {
    NSDictionary *dict = @{
                           @"action" : @"Community/upload",
                           //@"data"   : [jsonStr stringByReplacingOccurrencesOfString:@"\"" withString:@""],
                           @"site" : @"ZZZZZcommunity" ,
                           @"type" : @"1",
                           @"userId" : USERID,
                           @"goodsId" : ZFToString(_dict[@"goodsId"]), // 商品id值
                           @"content":ZFToString(_dict[@"content"]),
                           @"topic" : [_dict[@"topic"] yy_modelToJSONString],
                           @"app_add_time":[NSString stringWithFormat:@"%ld",time(NULL)],
                           @"app_type":@"2",
                           @"review_type": _dict[@"review_type"],
                           @"title": ZFToString(_dict[@"title"]),
                           @"nickEncrypt":_dict[@"nickEncrypt"]
                           };
    return dict;
}

-(NSString *)baseURL{
    
    return [YWLocalHostManager communityNewBaseURL:Port_do_post];
}

- (id)requestParameters {
    ///NSString *jsonStr = [[self fetchDataJson] yy_modelToJSONString];
    
    NSDictionary *tempDic1 = [self fetchDataJson];
    
    return tempDic1;
}

//- (NSDictionary<NSString *,NSString *> *)requestHeader {
//    NSString *dataJson = [[self fetchDataJson] yy_modelToJSONString];
//
//    NSString *jsonStr = [dataJson stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    NSString *key = [YWLocalHostManager appCommunityPrivateKey];
//    NSString *headerKey = [NSStringUtils ZFNSStringMD5:[jsonStr stringByAppendingString:key]];
//    NSString *headerValue = [NSStringUtils ZFNSStringMD5:[[jsonStr stringByAppendingString:headerKey] stringByAppendingString:key]];
//    return @{
//             headerKey:headerValue
//             };
//}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSArray *images = self->_dict[@"images"];
        [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *data = UIImageJPEGRepresentation(obj, 0.99);
            
            NSArray *typeArray = [self typeForImageData:data];
            
            NSString *name = [NSString stringWithFormat:@"pic_%lu.%@",(unsigned long)idx,typeArray[1]];
            NSString *formKey = [NSString stringWithFormat:@"pic_%lu",(unsigned long)idx];
            NSString *type = typeArray[0];
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
