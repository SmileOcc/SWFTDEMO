//
//  STLThemeSpecialApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVThemesSpecialsAip.h"

@interface OSSVThemesSpecialsAip ()

@property (nonatomic, copy) NSString *specialID;
@property (nonatomic, copy) NSString *deepLinkID;

@end

@implementation OSSVThemesSpecialsAip

-(instancetype)initWithCustomeId:(NSString *)specialID
{
    self = [super init];
    
    if (self) {
        self.specialID = specialID;
    }
    return self;
}
-(instancetype)initWithCustomeId:(NSString *)specialID deepLinkId:(NSString *)deepLinkId{
    self = [super init];
    
    if (self) {
        self.specialID = specialID;
        self.deepLinkID = deepLinkId;
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
    return [OSSVNSStringTool buildRequestPath:kApi_SpecialIndex];
}

- (id)requestParameters {
    if ([OSSVNSStringTool isEmptyString:self.deepLinkID]) {
        return @{
                 @"commparam" : [OSSVNSStringTool buildCommparam],
                 @"specialId" : self.specialID
                 };
    }
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"specialId" : self.specialID,
             @"deep_link_id" : self.deepLinkID
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
