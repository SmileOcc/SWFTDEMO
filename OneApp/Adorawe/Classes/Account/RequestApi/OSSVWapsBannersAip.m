//
//  OSSVWapsBannersAip.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVWapsBannersAip.h"

@implementation OSSVWapsBannersAip
- (NSString *)requestPath{
    return [OSSVNSStringTool buildRequestPath:kApi_UserCenterBanner];
}

-(STLRequestMethod)requestMethod{
    return STLRequestMethodPOST;
}

-(STLRequestSerializerType)requestSerializerType{
    return STLRequestSerializerTypeJSON;
}
@end
