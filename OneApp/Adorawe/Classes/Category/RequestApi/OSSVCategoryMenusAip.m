//
//  OSSVCategoryMenusAip.m
// XStarlinkProject
//
//  Created by odd on 2020/11/3.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryMenusAip.h"

@implementation OSSVCategoryMenusAip


- (BOOL)enableCache
{
    return NO;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CategoryCategoryHeader];
}

- (id)requestParameters
{
    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam]
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
