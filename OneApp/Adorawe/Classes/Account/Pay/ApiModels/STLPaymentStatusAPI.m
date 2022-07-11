//
//  OSSVPaymentsStatusAip.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/22.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVPaymentsStatusAip.h"

@implementation OSSVPaymentsStatusAip
-(instancetype)initWithParam:(NSDictionary *)param{
    if(self = [super init]){
        self.params = param;
    }
    return self;
}

-(NSString *)requestPath{
    return kApi_paymentStatus;
}

-(NSString *)domainPath{
    return masterDomain;
}


-(id)requestParameters{
    return self.params;
}

-(STLRequestMethod)requestMethod{
    return STLRequestMethodPOST;
}

- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
