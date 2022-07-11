//
//  STLHomeCouponApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomesCouponsAip.h"

@interface OSSVHomesCouponsAip ()

@property (nonatomic, copy) NSString *couponCode;
@property (nonatomic, copy) NSString *specialId;

@end

@implementation OSSVHomesCouponsAip

-(instancetype)initWithCouponCode:(NSString *)code specialID:(NSString *)specialId
{
    self = [super init];
    
    if (self) {
        self.couponCode = code;
        self.specialId = specialId;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CouponGetCoupon];
}

- (id)requestParameters {
    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"couponCode"  : STLToString(self.couponCode),
             @"specialId"   : STLToString(self.specialId),
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
