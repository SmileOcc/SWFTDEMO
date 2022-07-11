//
//  STLThemeSpecialActivityApi.m
// XStarlinkProject
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemesSpecialActiviyAip.h"

@interface OSSVThemesSpecialActiviyAip ()

@property (nonatomic, copy) NSString *specialID;

@end

@implementation OSSVThemesSpecialActiviyAip

-(instancetype)initWithCustomeId:(NSString *)specialID
{
    self = [super init];
    
    if (self) {
        self.specialID = specialID;
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
//    return @"http://api.adorawe-api.com.dev-v18.fpm.testsdlk.com/v1_18/special/activity";
//}
//
//- (NSString *)requestPath {
//    return @"";
//}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_SpecialActivity];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"specialId" : STLToString(self.specialID)
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
