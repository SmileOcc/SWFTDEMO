//
//  STLSendCodeApi.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLSendCodeApi.h"

@implementation STLSendCodeApi

-(instancetype)initWithParam:(NSDictionary *)param{
    if(self = [super init]){
        self.params = param;
    }
    return self;
}

-(NSString *)requestPath{
    return kApi_SendCode;
}

-(NSString *)domainPath{
    return masterDomain;
}

///测试代码
//-(NSString *)requestURLString{
//    return self.sentPhoneNum ? @"http://ys8s64.natappfree.cc/v1_18/user/bind-phone" : @"http://ys8s64.natappfree.cc/v1_18/country/list-by-show";
//}

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
