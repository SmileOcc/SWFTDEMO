//
//  OSSVFlashSaleChannelAip.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleChannelAip.h"

@implementation OSSVFlashSaleChannelAip {
    NSString *_channelId;
}

- (instancetype)initWithHomeChannelId:(NSString *)channelId {
    if (self = [super init]) {
        _channelId = channelId;
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
    return NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
}


- (NSString *)requestPath {
    return kApi_FlashSaleRecentActive;
}

-(NSString *)domainPath{
    return masterDomain;
}

- (id)requestParameters {
    return @{@"channel_id":STLToString(_channelId)};
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
