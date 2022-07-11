//
//  YYAnimatedImageView+STLSwizzling.m
// XStarlinkProject
//
//  Created by odd on 2020/9/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "YYAnimatedImageView+STLSwizzling.h"
#import <objc/runtime.h>

@implementation YYAnimatedImageView (STLSwizzling)

+ (void)load
{
    Method a = class_getInstanceMethod(self, @selector(displayLayer:));
    Method b = class_getInstanceMethod(self, @selector(swizzing_displayLayer:));
    method_exchangeImplementations(a, b);
}

- (void)swizzing_displayLayer:(CALayer *)layer
{
    //通过变量名称获取类中的实例成员变量
    Ivar ivar = class_getInstanceVariable(self.class, "_curFrame");
    UIImage *_curFrame = object_getIvar(self, ivar);

    if (_curFrame) {
        layer.contents = (__bridge id)_curFrame.CGImage;
    } else {
        if (@available(iOS 14.0, *)) {
            [super displayLayer:layer];
        }
    }
}

@end
