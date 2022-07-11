//
//  OSSVMessageListAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageListAip.h"

@implementation OSSVMessageListAip

- (BOOL)enableCache
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

- (NSString *)requestPath
{
    return [OSSVNSStringTool buildRequestPath:kApi_MessageListIndex];
}

- (id)requestParameters
{
    return @{@"commparam"      : [OSSVNSStringTool buildCommparam],             
             };
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
