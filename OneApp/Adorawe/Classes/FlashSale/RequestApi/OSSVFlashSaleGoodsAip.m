//
//  OSSVFlashSaleGoodsAip.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleGoodsAip.h"

@implementation OSSVFlashSaleGoodsAip {
    NSString *_activeId;
    NSInteger _page;
    NSInteger _pageSize;
}

- (instancetype)initWithFlashSaleGoodsWithActiveId:(NSString *)ActiveId
                                              page:(NSInteger)page
                                          pageSize:(NSInteger)pageSize {
    if (self = [super init]) {
        _activeId = ActiveId;
        _page     = page;
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


- (NSString *)requestPath {
    switch (self.requestType) {
        case STLFLashRequestTypeGetGoods:
            return kApi_FlashSaleGetGoods;
        case STLFLashRequestTypeFlowSwitch:
            return kApi_FlashSaleFollowSwitch;
    }
    
}

-(NSString *)domainPath{
    return masterDomain;
}

- (id)requestParameters {
    switch (self.requestType) {
        case STLFLashRequestTypeGetGoods:
            return @{@"active_id": _activeId,
                     @"page_size": @(_pageSize),
                     @"page"     : @(_page)
            };
        case STLFLashRequestTypeFlowSwitch:
            return @{@"fs_id": @(_followId),};
    }
    
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
