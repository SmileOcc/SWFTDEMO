//
//  UIImage+Compress.m
//  uSmartOversea
//
//  Created by JC_Mac on 2018/10/31.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "UIImage+Compress.h"

@implementation UIImage (Compress)

- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength){
        return data;
    }
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    
    return data;
}

- (UIImage *)compressImageQualityWithMaxLength:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength){
        UIImage *image = [UIImage imageWithData:data];
        return image;
    }
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    
    UIImage *image = [UIImage imageWithData:data];
    return image;
}


- (NSData *)compressQualityLessMaxLength:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength){
        return data;
    }
    
    for (int i = 0; i < 6; ++i) {
        compression = compression / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength) {
            break;
        } else if (data.length > maxLength) {
            continue;
        }
    }

    return data;
}


@end
