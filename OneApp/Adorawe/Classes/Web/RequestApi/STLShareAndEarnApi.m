//
//  STLShareAndEarnApi.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLShareAndEarnApi.h"

@implementation STLShareAndEarnApi{
    NSString *_type;
    NSString *_h_url;
    NSString *_sku;
}

- (instancetype)initWithType:(NSString *)type h_url:(NSString *)h_url sku:(NSString *)sku{
    self = [super init];
    if (self) {
        _type = type;
        _h_url = h_url;
        _sku = sku;
    }
    return self;
}

- (STLRequestMethod)requestMethod{
    return  STLRequestMethodPOST;
}

- (id)requestParameters{
    NSString *currentLanagure = [STLLocalizationString shareLocalizable].currentLanguageName;
    if (_type && [_type integerValue] == 1) {
        // 详情
        return @{@"lang":currentLanagure,
                 @"type":_type,
                 @"sku" :_sku
        };
    }
    
    return @{@"lang":currentLanagure,
             @"type":_type,
             @"h5_url" :_h_url
    };
}


- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_ShareUrl];
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
