//
//  OSSVAccountRecomendGoodssAip.m
// XStarlinkProject
//
//  Created by odd on 2020/8/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountRecomendGoodssAip.h"
@import RangersAppLog;

@implementation OSSVAccountRecomendGoodssAip

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [NSStringTool buildRequestPath:kApi_ItemUserRecommend];
}

- (id)requestParameters {
    
    NSString *newRecommand_ab = [BDAutoTrack ABTestConfigValueForKey:@"Recommand_Ab" defaultValue:@("")];

    NSMutableDictionary *params = [@{
        @"commparam" : [NSStringTool buildCommparam]
    } mutableCopy];

    if (AccountManager.sharedManager.sysIniModel.recommend_abtest_switch){
        [params setObject:STLToString(newRecommand_ab) forKey:@"rec_engine"];
    }
#if DEBUG
    ///test recommend
//    [params setObject:@"BT" forKey:@"rec_engine"];
#endif
    return params;
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
