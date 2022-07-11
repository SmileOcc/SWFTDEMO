//
//  UIImage+SHCorner.h
//  DailyRead
//
//  Created by sengoln huang on 2019/3/28.
//  Copyright © 2019 爱阅读. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SHCorner)
//绘制图片圆角
- (UIImage *)drawCornerInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
