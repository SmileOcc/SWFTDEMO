//
//  OSSVMessageAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageAip.h"

@implementation OSSVMessageAip{
    NSInteger _page;
    NSString *_type;
}

- (instancetype)initWithPage:(NSInteger)page type:(NSString *)type
{
    if (self = [super init])
    {
        _page = page;
        _type = type;
    }
    return self;
}

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
    return [OSSVNSStringTool buildRequestPath:kApi_MessageListList];
}

- (id)requestParameters
{
    return @{@"commparam"      : [OSSVNSStringTool buildCommparam],
             @"type"           : _type,
             @"page"           : @(_page),
             @"page_size"      :@(kSTLPageSize)};
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
