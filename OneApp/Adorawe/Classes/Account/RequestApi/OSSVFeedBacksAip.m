//
//  OSSVFeedBacksAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVFeedBacksAip.h"
#import "UIImage+STLCategory.h"

@implementation OSSVFeedBacksAip {
    
    NSString *_type;
    NSString *_email;
    NSString *_content;
    NSArray  *_images;
}

- (instancetype)initWithFeedBackType:(NSString *)type email:(NSString *)email content:(NSString *)content images:(NSArray *)images {
    
    self = [super init];
    if (self) {
        _type = type;
        _email = email;
        _content = content;
        _images = images;
    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

//- (NSURLRequestCachePolicy)requestCachePolicy {
//    return NSURLRequestReloadIgnoringCacheData;
//}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_FeedbackAdd];
}

- (id)requestParameters {
    return @{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"type"        : _type,
             @"email"       : _email,
             @"content"     : _content,
             @"userId"      : @(USERID)
             };
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSArray *images = _images;
        
        ///后台图片限制最大为2M
        CGFloat maxM = 1.0;
        if (STLJudgeNSArray(images) && images.count > 0) {
            maxM = 1.98 / images.count;
            if (maxM >= 1.0) {
                maxM = 1.0;
            }
            
        }
        [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *data = [UIImage stl_compressImageWithOriginImage:obj maxM:maxM];
            
//            double dataLength = [data length] * 1.0;
//            NSArray *typeArray2 = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
//            NSInteger index = 0;
//            while (dataLength > 1024) {
//                dataLength /= 1024.0;
//                index ++;
//            }
//            STLLog(@" ===========ccccccimage = %.3f %@",dataLength,typeArray2[index]);
            
            NSArray *typeArray = [self typeForImageData:data];
            
            NSString *name = [NSString stringWithFormat:@"pic_%lu.%@",(unsigned long)idx,typeArray[1]];
            NSString *formKey = [NSString stringWithFormat:@"pic_%lu",(unsigned long)idx];
            NSString *type = typeArray[0];
            [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type?:@""];
        }];
    };
}

- (NSArray *)typeForImageData:(NSData *)data {
    
    
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @[@"image/jpeg",@"jpg"];
            
        case 0x89:
            
            return @[@"image/png",@"png"];
            
        case 0x47:
            
            return @[@"image/gif",@"gif"];
            
        case 0x49:
        case 0x4D:
            
            return @[@"image/tiff",@"tiff"];
            
    }
    
    return @[@"",@""];
    
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
