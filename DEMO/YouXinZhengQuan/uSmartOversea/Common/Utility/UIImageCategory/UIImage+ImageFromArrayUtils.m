//
//  UIImage+ImageFromArrayUtils.m
//  YouXinZhengQuan
//
//  Created by lennon on 2022/1/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "UIImage+ImageFromArrayUtils.h"

@implementation UIImage (ImageFromArrayUtils)
+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray
{
    UIImage *unifiedImage = nil;
    CGSize totalImageSize = [self verticalAppendedTotalImageSizeFromImagesArray:imagesArray];
    UIGraphicsBeginImageContextWithOptions(totalImageSize, NO, 0.f);
    // For each image found in the array, create a new big image vertically
    int imageOffsetFactor = 0;
    for (UIImage *img in imagesArray) {
        [img drawAtPoint:CGPointMake(0, imageOffsetFactor)];
        imageOffsetFactor += img.size.height;
    }
    
    unifiedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return unifiedImage;
}

+ (CGSize)verticalAppendedTotalImageSizeFromImagesArray:(NSArray *)imagesArray
{
    CGSize totalSize = CGSizeZero;
    for (UIImage *im in imagesArray) {
        CGSize imSize = [im size];
        totalSize.height += imSize.height;
        // The total width is gonna be always the wider found on the array
        totalSize.width = MAX(totalSize.width, imSize.width);
    }
    return totalSize;
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
