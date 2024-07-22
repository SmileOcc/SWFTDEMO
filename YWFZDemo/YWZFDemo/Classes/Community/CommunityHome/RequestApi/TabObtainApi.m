//
//  TabObtainApi.m
//  ZZZZZ
//
//  Created by YW on 2016/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "TabObtainApi.h"

@implementation TabObtainApi
- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

-(BOOL)encryption {
    return YES;
}

-(BOOL)isCommunityRequest{
    return YES;
}

- (id)requestParameters {
    
    return @{
             @"site" : @"ZZZZZcommunity" ,
             @"type" : @"9",
             @"directory" : @"50",
             @"app_type" : @"2"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end