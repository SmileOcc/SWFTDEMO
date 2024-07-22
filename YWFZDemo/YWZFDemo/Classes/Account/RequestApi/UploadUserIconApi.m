//
//  UploadIconApi.m
//  Dezzal
//
//  Created by 7FD75 on 16/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "UploadUserIconApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation UploadUserIconApi
{
    NSString *_imageData;
}

-(instancetype)initWithImageData:(NSString *)imageData {
    
    self = [super init];
    if (self) {
        _imageData = imageData;
    }
    return self;
}
 - (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    
    return @{
             @"action"      :   @"user/update_picture",
             @"token"       :   TOKEN,
             @"image"       :   _imageData,
              @"is_enc"     :  @"0"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
