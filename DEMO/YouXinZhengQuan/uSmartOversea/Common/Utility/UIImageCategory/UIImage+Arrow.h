//
//  UIImage+Arrow.h
//  uSmartOversea
//
//  Created by ellison on 2018/10/18.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Arrow)

+ (UIImage *)arrowWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)image:(UIImage *)image
          rotation:(UIImageOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
