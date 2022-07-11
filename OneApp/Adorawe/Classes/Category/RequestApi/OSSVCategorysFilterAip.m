//
//  OSSVCategorysFilterAip.m
// XStarlinkProject
//
//  Created by odd on 2021/4/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCategorysFilterAip.h"

@implementation OSSVCategorysFilterAip{
    NSString *_catId;
}

- (instancetype)initWithCategoriesFilterCatId:(NSString *)catId {
    self = [super init];
    if (self) {
        _catId    = catId;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CategoryItemFilter];
}

- (id)requestParameters
{
    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"cat_id"       : STLToString(_catId)
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
