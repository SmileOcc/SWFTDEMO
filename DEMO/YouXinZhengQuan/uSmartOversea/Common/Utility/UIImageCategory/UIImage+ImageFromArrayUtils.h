//
//  UIImage+ImageFromArrayUtils.h
//  YouXinZhengQuan
//
//  Created by lennon on 2022/1/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ImageFromArrayUtils)
+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
@end

NS_ASSUME_NONNULL_END
