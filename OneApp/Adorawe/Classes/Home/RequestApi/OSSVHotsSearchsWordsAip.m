//
//  HotSearchWordApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHotsSearchsWordsAip.h"

@implementation OSSVHotsSearchsWordsAip
{
    NSString *_groupId;
    NSString *_cateId;
}

- (instancetype)initWithGroupId:(NSString *)groupId cateId:(NSString *)cateId
{
    self = [super init];
    if (self) {
        _groupId = groupId;
        _cateId = cateId;
    }
    return self;
}

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
    return [OSSVNSStringTool buildRequestPath:kApi_SearchTrendsWord];
}

- (id)requestParameters {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[OSSVNSStringTool buildCommparam] forKey:@"commparam"];
    [dic setObject:STLToString(_groupId) forKey:@"group_id"];
    [dic setObject:STLToString(_cateId) forKey:@"cat_id"];
    
    return dic;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}



@end
