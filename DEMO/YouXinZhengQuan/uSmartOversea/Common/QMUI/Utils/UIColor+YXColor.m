//
//  YXColor.m
//  uSmartOversea
//
//  Created by chenmingmao on 2022/3/16.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "UIColor+YXColor.h"
@import QMUIKit;

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

@implementation UIColor (YXColor)

+ (UIColor *)themeColorWithNormalHex:(NSString *)normalHexString andDarkColor: (NSString *)darkHexString {
    
    return [self themeColorWithNormal:[UIColor qmui_colorWithHexString:normalHexString] andDarkColor:[UIColor qmui_colorWithHexString:darkHexString]];
}


+ (UIColor *)themeColorWithNormal:(UIColor *)normalcolor andDarkColor: (UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            UIUserInterfaceStyle style = [YXThemeTool style];
            if (style == UIUserInterfaceStyleUnspecified) {
                style = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            }
            if (style == UIUserInterfaceStyleDark) {
                return darkColor;
            }  else {
                return normalcolor;
            }
            
        }];
    } else {
        return normalcolor;
    }
}

@end


@implementation UIView (YXUIManager)
+ (void)load {
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Method presentM = class_getInstanceMethod(self.class, @selector(traitCollectionDidChange:));
            Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(dy_traitCollectionDidChange:));

            method_exchangeImplementations(presentM, presentSwizzlingM);
        });
    }
}

- (void)dy_traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if (self.didChangeTraitCollection) {
        self.didChangeTraitCollection(self.traitCollection);
    }
    [self dy_traitCollectionDidChange:previousTraitCollection];
}

- (void)setDidChangeTraitCollection:(void (^)(UITraitCollection *))didChangeTraitCollection {
    objc_setAssociatedObject(self, @"YGViewDidChangeTraitCollection", didChangeTraitCollection, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITraitCollection *))didChangeTraitCollection {
    return objc_getAssociatedObject(self, @"YGViewDidChangeTraitCollection");
}


@end

