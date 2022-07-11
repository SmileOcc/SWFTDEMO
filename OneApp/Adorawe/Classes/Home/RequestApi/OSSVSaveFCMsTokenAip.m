//
//  STLSaveFCMTokenApi.m
// XStarlinkProject
//
//  Created by odd on 2020/11/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSaveFCMsTokenAip.h"

@interface OSSVSaveFCMsTokenAip()

@property (nonatomic, strong) NSDictionary *fcmDic;

@end


@implementation OSSVSaveFCMsTokenAip

-(instancetype)initWithFCMParams:(NSDictionary *)fcmDic{
    self = [super init];
    
    if (self) {
        self.fcmDic = fcmDic;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    
    
    return @"http://happkv.natappfree.cc/api/sync-fcmtoken";
}

- (id)requestParameters {
    return STLJudgeNSDictionary(self.fcmDic) ? self.fcmDic : @{};
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
