//
//  STLThemeActivityGoodsApi.m
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemesActivtyGoodAip.h"

@interface OSSVThemesActivtyGoodAip ()
{
    NSInteger _page;
    NSInteger _pageSize;
    NSString  *_specialID;
    NSString  *_type;
}


@end

@implementation OSSVThemesActivtyGoodAip

-(instancetype)initWithCustomeId:(NSString *)specialID type:(NSString *)type page:(NSInteger)page pageSize:(NSInteger)pageSize
{
    self = [super init];
    if (self) {
        _specialID = specialID;
        _type = type;
        _page = page;
        _pageSize = pageSize;
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

//- (NSString *)baseURL {
//    return @"http://api.adorawe-api.com.dev-v18.fpm.testsdlk.com/v1_18/special/activity-goods-list";
//}
//
//- (NSString *)requestPath {
//    return @"";
//}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_SpecialActivityGoodsList];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"specialId" : STLToString(_specialID),
             @"type" : STLToString(_type),
             @"page"        : @(_page),
             @"page_size"   : @(20),
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
