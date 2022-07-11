//
//  OSSVCategorysSpecialListsAip.m
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
// ----此API 不用老的0元购商品列表的api 了

#import "OSSVCategorysSpecialListsAip.h"

@interface OSSVCategorysSpecialListsAip()

@property (nonatomic, copy) NSString    *specialId;
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation OSSVCategorysSpecialListsAip

- (instancetype)initCategorySpecial:(NSString *)specialId {
    if (self = [super init]) {
//        _specialId = specialId;
    }
    return self;
}

-(instancetype)initWithCustomeId:(NSString *)customId type:(NSString *)type page:(NSInteger)pageIndex {
    self = [super init];
    
    if (self) {
        self.specialId = customId;
        self.pageIndex = pageIndex;
        self.type = type;
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
//    return [OSSVNSStringTool buildRequestPath:kApi_SpecialGetExchangeGoods];
    return [OSSVNSStringTool buildRequestPath:kApi_SpecialGetChannelGoods];

    
}

- (id)requestParameters {
    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"specialId"   : STLToString(self.specialId),
             @"type"        : STLToString(self.type),
             @"pageSize"    : @(20),
             @"page"        : @(self.pageIndex)
             };
}

//- (id)requestParameters
//{
//    return @{
//             @"commparam"     : [OSSVNSStringTool buildCommparam],
//             @"specialId"     : @"402",
//             @"type"          : @"12",
//             @"page"          : @(1),
//             @"pageSize"      : @(20),
//             @"channelSort"   : @""
//             };
//}

- (STLRequestMethod)requestMethod
{
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType
{
    return STLRequestSerializerTypeJSON;
}

@end
