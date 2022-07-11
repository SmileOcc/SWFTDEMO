//
//  OSSVSavesMysSizesAip.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSavesMysSizesAip.h"

@implementation OSSVSavesMysSizesAip{
    NSInteger _size_type;
    NSInteger _gender;
    NSString *_height;
    NSString  *_weight;
}

- (instancetype)initWithSizeType:(NSInteger)sizeType gender:(NSInteger)gender height:(NSString *)height weight:(NSString *)weight{
    if (self = [super init]) {
        _size_type = sizeType;
        _gender = gender;
        _height = height;
        _weight = weight;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_SaveSizeOption];
}

- (id)requestParameters {
    return @{
        @"size_type"    :   @(_size_type),
        @"gender"       :   @(_gender),
        @"height"       :   _height,
        @"weight"       :   _weight
    };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
