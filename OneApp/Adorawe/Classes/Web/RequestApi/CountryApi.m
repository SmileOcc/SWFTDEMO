//
//  CountryApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CountryApi.h"

@implementation CountryApi {
    NSDictionary *_dict;
}

- (instancetype)initWithDict: (NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_CountryList];
}

//
- (id)requestParameters {
    return @{
//             @"code_name" : STLToString(_dict[@"code_name"]),
             @"commparam" : [OSSVNSStringTool buildCommparam]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
