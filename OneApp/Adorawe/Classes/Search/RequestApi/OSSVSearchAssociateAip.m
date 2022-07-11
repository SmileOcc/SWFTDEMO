//
//  OSSVSearchAssociateAip.m
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchAssociateAip.h"


@interface OSSVSearchAssociateAip()

@property (nonatomic, copy) NSString    *keyword;
@end

@implementation OSSVSearchAssociateAip

- (instancetype)initWithKeyWord:(NSString *)keyword {
    self = [super init];
    if (self) {
        _keyword = keyword;
    }
    return self;
}
- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_SearchAssociate];
}

- (id)requestParameters {
    return @{
             @"keyword"            : STLToString(_keyword),
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
