//
//  STLCustomerThemeChannelGoodsApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCustomThemesChannelsGoodsAip.h"

@interface OSSVCustomThemesChannelsGoodsAip ()

@property (nonatomic, copy) NSString    *customeId;
@property (nonatomic, copy) NSString    *channelSort;
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation OSSVCustomThemesChannelsGoodsAip

-(instancetype)initWithCustomeId:(NSString *)customId sort:(NSString *)sort type:(NSString *)type page:(NSInteger)pageIndex {
    self = [super init];
    
    if (self) {
        self.customeId = customId;
        self.channelSort = sort;
        self.pageIndex = pageIndex;
        self.type = type;
    }
    return self;
}
-(instancetype)initWithCustomeId:(NSString *)customId sort:(NSString *)sort page:(NSInteger)pageIndex {
    self = [super init];
    
    if (self) {
        self.customeId = customId;
        self.channelSort = sort;
        self.pageIndex = pageIndex;
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
    return [OSSVNSStringTool buildRequestPath:kApi_SpecialGetChannelGoods];
}

- (id)requestParameters {
    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"specialId"   : STLToString(self.customeId),
             @"type"   : STLToString(self.type),
             @"pageSize"    : @"20",
             @"channelSort" : self.channelSort.length> 0 ?self.channelSort : @"0",
             @"page"        : [NSString stringWithFormat:@"%ld",self.pageIndex]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
