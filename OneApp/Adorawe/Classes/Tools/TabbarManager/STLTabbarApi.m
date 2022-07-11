//
//  STLTabbarApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTabbarApi.h"

@implementation STLTabbarApi

-(BOOL)enableCache
{
    return YES;
}

- (BOOL)enableAccessory
{
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy
{
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)baseURL
{
    return nil;
}

- (NSString *)requestPath
{
    return [OSSVNSStringTool buildRequestPath:kApi_HomeAtmosphereList];
}

- (id)requestParameters
{
    return @{@"commparam" : [OSSVNSStringTool buildCommparam]};
}

- (STLRequestMethod)requestMethod
{
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType
{
    return STLRequestSerializerTypeJSON;
}

@end
