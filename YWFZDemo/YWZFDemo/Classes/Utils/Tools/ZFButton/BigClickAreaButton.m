//
//  BigClickAreaButton.m
//  ZZZZZ
//
//  Created by YW on 16/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"

@implementation BigClickAreaButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(self.clickAreaRadious - bounds.size.width, 0);
    CGFloat heightDelta = MAX(self.clickAreaRadious - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
@end




@implementation ZFLimitImageRectButton

/**
 * 限制图片的圆形区域
 */
- (void)setImageMaskRect:(CGRect)imageMaskRect
{
    _imageMaskRect = imageMaskRect;
    
    if (!CGRectIsEmpty(imageMaskRect) && !CGRectEqualToRect(imageMaskRect, CGRectZero)) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = imageMaskRect;
        imageView.image = ZFImageWithName(@"public_user");
        self.imageView.maskView = imageView;
    }
}

/**
 * 限制按钮图标的显示CGRect
 */
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    if (!CGRectIsEmpty(self.imageRect) && !CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    }
    return [super imageRectForContentRect:contentRect];
}

/**
 * 限制按钮标题的显示CGRect
 */
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    
    if (!CGRectIsEmpty(self.titleRect) && !CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    }
    return [super titleRectForContentRect:contentRect];
}

@end
