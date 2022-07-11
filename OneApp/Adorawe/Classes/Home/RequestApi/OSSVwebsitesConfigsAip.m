//
//  STLwebsiteConfigApi.m
//  Adorawe
//
//  Created by odd on 2021/9/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVwebsitesConfigsAip.h"

@implementation OSSVwebsitesConfigsAip

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

//- (NSString *)requestPath {
//    return [OSSVNSStringTool buildRequestPath:kApi_BannerHomeFloat];
//}

-(NSString *)requestURLString{
    return [OSSVLocaslHosstManager appSiteLaunchUrl];
}

- (id)requestParameters {

    NSDictionary *params = @{};
    return params;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
