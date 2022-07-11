//
//  OSSVCategorysAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategorysAip.h"

@interface OSSVCategorysAip() {
}

@end
@implementation OSSVCategorysAip


- (instancetype)initCategory {
    if (self = [super init]) {

    }
    return self;
}
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
    return [OSSVNSStringTool buildRequestPath:kApi_CategoryIndex];
}

- (id)requestParameters
{
    //请求分类接口，不用传入性别
//    int sex = [OSSVAccountsManager sharedManager].account == nil ? 1 : [OSSVAccountsManager sharedManager].account.sex;
    NSMutableDictionary *params = @{
                                    @"commparam"   : [OSSVNSStringTool buildCommparam],
                                }.mutableCopy;
    
            if ([OSSVAccountsManager sharedManager].isSignIn && USERID) {
                NSString* tokenString = [NSString stringWithFormat:@"%@",STLToString(USER_TOKEN)];
                [params setObject:tokenString forKey:@"token"];
            }
    
    return params;
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
