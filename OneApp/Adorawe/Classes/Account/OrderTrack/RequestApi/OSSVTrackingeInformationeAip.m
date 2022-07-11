//
//  OSSVTrackingeInformationeAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingeInformationeAip.h"

@implementation OSSVTrackingeInformationeAip {
    NSString *_orderNumber;
    NSString *_trackVal;
    NSString *_trackType;
}

//- (instancetype)initWithOrderNumber:(NSString *)orderNumber {
//
//    self = [super init];
//    if (self) {
//        _orderNumber = orderNumber;
//    }
//    return self;
//}

- (instancetype)initWithTrackVal:(NSString *)trackVal trackType:(NSString *)trackType {
    self = [super init];
    if (self) {
        _trackVal = trackVal;
        _trackType = trackType;
    }
    return self;
}

- (BOOL)isNewENC {
    if ([OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveTrunk ||
        [OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return YES;
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

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_OrderGetOrderTrackList];
}

- (id)requestParameters {
    NSLog(@"userId == %@",[OSSVAccountsManager sharedManager].account.userid);
    return @{
             @"commparam"        : [OSSVNSStringTool buildCommparam],
             @"trackVal"         : STLToString(_trackVal),
             @"trackType"        : STLToString(_trackType)
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
