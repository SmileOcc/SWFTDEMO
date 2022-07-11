//
//  ThemeColorManager.m
// XStarlinkProject
//
//  Created by odd on 2020/6/29.
//  Copyright © 2020 XStarlinkProject. All rights reserved.
//

#import "OSSVThemesColors.h"



@implementation OSSVThemesColors


+ (BOOL)isIos13 {
    if (@available(iOS 13.0, *)) {
        return YES;
    } else {
        return NO;
    }
}

+ (UIColor *)stlClearColor {
    return  [UIColor clearColor];
}
+ (UIColor *)stlBlackColor {
    if (@available(iOS 13.0, *)) {
        UIColor *currentColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) { //浅色模式
                return [UIColor blackColor];
            } else { //暗黑模式
                return [UIColor blackColor];
            }
        }];
        return currentColor;
    } else {
        return [UIColor blackColor];
    }
    
}

+ (UIColor *)stlWhiteColor {
    if (@available(iOS 13.0, *)) {
        UIColor *currentColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) { //浅色模式
                return [UIColor whiteColor];
            } else { //暗黑模式
                return [UIColor whiteColor];
            }
        }];
        return currentColor;
    } else {
        return [UIColor whiteColor];
    }
}
+ (UIColor *)stlBlackOrWhiteColor {
    
    if (@available(iOS 13.0, *)) {
        UIColor *currentColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) { //浅色模式
                return [UIColor blackColor];
            } else { //暗黑模式
                return [UIColor whiteColor];
            }
        }];
        return currentColor;
    } else {
        return [UIColor blackColor];
    }
    
}
+ (UIColor *)stlWhiteOrBlackColor {
    if (@available(iOS 13.0, *)) {
        UIColor *currentColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) { //浅色模式
                return [UIColor whiteColor];
            } else { //暗黑模式
                return [UIColor blackColor];
            }
        }];
        return currentColor;
    } else {
        return [UIColor whiteColor];
    }
}

+ (UIColor *)col_ffffff:(CGFloat)a {
    return STLCOLOR_HEXAlpha(0xFFFFFF,a);
}

+ (UIColor *)col_000000:(CGFloat)a {
    return STLCOLOR_HEXAlpha(0x000000,a);
}

+ (UIColor *)col_333333 {
    return STLCOLOR_HEX(0x333333);
}

+ (UIColor *)col_666666 {
    return STLCOLOR_HEX(0x666666);
}
+ (UIColor *)col_666666:(CGFloat)a {
    return STLCOLOR_HEXAlpha(0x666666,a);
}

+ (UIColor *)col_999999 {
    return STLCOLOR_HEX(0x999999);
}

+ (UIColor *)col_808080 {
    return STLCOLOR_HEX(0x808080);
}

+ (UIColor *)col_262626 {
    return STLCOLOR_HEX(0x262626);
}


+ (UIColor *)col_262626:(CGFloat)a {
    return STLCOLOR_HEXAlpha(0x262626,a);
}

+ (UIColor *)col_454545 {
    return STLCOLOR_HEX(0x454545);
}
+ (UIColor *)col_131313 {
    return STLCOLOR_HEX(0x131313);
}

+ (UIColor *)col_F5F5F5 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xF8F8F8);
    }
    return STLCOLOR_HEX(0xF5F5F5);
}

+ (UIColor *)col_B3B3B3 {
    return STLCOLOR_HEX(0xB3B3B3);
}

+ (UIColor *)col_FFF5DF {
    return STLCOLOR_HEX(0xFFF5DF);
}
+ (UIColor *)col_FF6734 {
    return STLCOLOR_HEX(0xFF6734);
}

+ (UIColor *)col_FF624F {
    return STLCOLOR_HEX(0xFF624F);
}

+ (UIColor *)col_FDF1F0 {
    return STLCOLOR_HEX(0xFDF1F0);
}

+ (UIColor *)col_FF4E6A {
    return STLCOLOR_HEX(0xFF4E6A);
}

+ (UIColor *)col_FF4E6A:(CGFloat)a{
    return STLCOLOR_HEXAlpha(0xFF4E6A,a);
}


+ (UIColor *)col_FFE9ED {
    return STLCOLOR_HEX(0xFFE9ED);
}

+ (UIColor *)col_E6E6E6 {
    return STLCOLOR_HEX(0xE6E6E6);
}

+ (UIColor *)col_CCCCCC {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xC4C4C4);
    }
    return STLCOLOR_HEX(0xCCCCCC);
}

+ (UIColor *)col_B33B30 {
    return STLCOLOR_HEX(0xB33B30);
}


+ (UIColor *)col_7D7D7D {
    return STLCOLOR_HEX(0x7D7D7D);
}

+ (UIColor *)col_C63D3D {
    return STLCOLOR_HEX(0xC63D3D);
}

+ (UIColor *)col_CC4337 {
    return STLCOLOR_HEX(0xCC4337);
}
+ (UIColor *)col_60CD8E {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0x26652C);
    }
    return STLCOLOR_HEX(0x60CD8E);
}


+ (UIColor *)col_EEEEEE {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xE1E1E1);
    }
    return STLCOLOR_HEX(0xEEEEEE);
}

+ (UIColor *)col_0D0D0D {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0x000000);
    }
    return STLCOLOR_HEX(0x0D0D0D);
}

+ (UIColor *)col_0D0D0D:(CGFloat)a{
    if (APP_TYPE == 3) {
        return STLCOLOR_HEXAlpha(0x000000,a);
    }
    return STLCOLOR_HEXAlpha(0x0D0D0D,a);
}

+ (UIColor *)col_FF5875 {
    return STLCOLOR_HEX(0xFF5875);
}

+ (UIColor *)col_F8F8F8 {
    return STLCOLOR_HEX(0xF8F8F8);
}

+ (UIColor *)col_FFCF60 {
    return STLCOLOR_HEX(0xFFCF60);
}

+ (UIColor *)col_E63D2E {
    return STLCOLOR_HEX(0xE63D2E);
}

+ (UIColor *)col_FAFAFA {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xF2F2F2);
    }
    return STLCOLOR_HEX(0xFAFAFA);
}

+ (UIColor *)col_FFF0CC {
    return STLCOLOR_HEX(0xFFF0CC);
}

+ (UIColor *)col_FF9318 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xA68F74);
    }
    return STLCOLOR_HEX(0xFF9318);
}

+ (UIColor *)col_6C6C6C {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEXAlpha(0x000000,0.7);
    }
    return STLCOLOR_HEX(0x6C6C6C);
}

+ (UIColor *)col_B2B2B2 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEXAlpha(0x000000,0.5);
    }
    return STLCOLOR_HEX(0xB2B2B2);
}

+ (UIColor *)col_FFFAEA {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xFFF5E5);
    }
    return STLCOLOR_HEX(0xFFFAEA);
}

+ (UIColor *)col_B62B21 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xE34E4E);
    }
    return STLCOLOR_HEX(0xB62B21);
}

+ (UIColor *)col_FBE9E9 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xFCEBEB);
    }
    return STLCOLOR_HEX(0xFBE9E9);
}

+ (UIColor *)col_FFF3E4 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xF6F1E9);
    }
    return STLCOLOR_HEX(0xFFF3E4);
}

+ (UIColor *)col_3FE35C {
    return STLCOLOR_HEX(0x3FE35C);
}


+ (UIColor *)col_FDC845 {
    if (APP_TYPE == 3) {
        return STLCOLOR_HEX(0xEEBA00);
    }
    return STLCOLOR_HEX(0xFDC845);
}

+ (UIColor *)col_9F5123 {
    return STLCOLOR_HEX(0x9F5123);
}

+ (UIColor *)col_F5EEE9 {
    return STLCOLOR_HEX(0xF5EEE9);
}

+ (UIColor *)col_FF9522 {
    return STLCOLOR_HEX(0xFF9522);
}

+ (UIColor *)col_FFFFFF {
    return STLCOLOR_HEX(0xFFFFFF);
}

+ (UIColor *)col_24A600 {
    return STLCOLOR_HEX(0x24A600);
}

+ (UIColor *)col_E1F2DA {
    return STLCOLOR_HEX(0xE1F2DA);
}

+(UIColor *)col_FF9900{
    return STLCOLOR_HEX(0xFF9900);
}
+(UIColor *)col_F1F1F1{
    return STLCOLOR_HEX(0xF1F1F1);
}
+(UIColor *)col_D1D1D1{
    return STLCOLOR_HEX(0xD1D1D1);
}
+(UIColor *)col_E1E1E1{
    return STLCOLOR_HEX(0xE1E1E1);
}
+(UIColor *)col_EDEDED{
    return STLCOLOR_HEX(0xEDEDED);
}
+(UIColor *)col_FE6902{
    return STLCOLOR_HEX(0xFE6902);
}
+(UIColor *)col_FDD835{
    return STLCOLOR_HEX(0xFDD835);
}
+(UIColor *)col_F6F6F6{
    return STLCOLOR_HEX(0xF6F6F6);
}
+(UIColor *)col_D0D1D1{
    return STLCOLOR_HEX(0xD0D1D1);
}
+(UIColor *)col_2D2D2D{
    return STLCOLOR_HEX(0x2D2D2D);
}
+(UIColor *)col_212121{
    return STLCOLOR_HEX(0x212121);
}
+(UIColor *)col_EFEFEF{
    return STLCOLOR_HEX(0xEFEFEF);
}
+(UIColor *)col_DDDDDD{
    return STLCOLOR_HEX(0xDDDDDD);
}
+(UIColor *)col_F67160{
    return STLCOLOR_HEX(0xF67160);
}
+(UIColor *)col_FEA235{
    return STLCOLOR_HEX(0xFEA235);
}
+(UIColor *)col_F7F7F7{
    return STLCOLOR_HEX(0xF7F7F7);
}
+(UIColor *)col_C5C5C5{
    return STLCOLOR_HEX(0xC5C5C5);
}
+(UIColor *)col_E5E5E5{
    return STLCOLOR_HEX(0xE5E5E5);
}
+(UIColor *)col_2E536B{
    return STLCOLOR_HEX(0x2E536B);
}
+(UIColor *)col_FDF135{
    return STLCOLOR_HEX(0xFDF135);
}
+(UIColor *)col_FF6F00{
    return STLCOLOR_HEX(0xFF6F00);
}

+(UIColor *)col_B56B23 {
    return STLCOLOR_HEX(0xB56B23);
}

+(UIColor *)col_CC00FF{
    return STLCOLOR_HEX(0xCC00FF);
}
+(UIColor *)col_EE4D4D{
    return STLCOLOR_HEX(0xEE4D4D);
}
+(UIColor *)col_515151{
    return STLCOLOR_HEX(0x515151);
}
+(UIColor *)col_FE5269{
    return STLCOLOR_HEX(0xFE5269);
}
+(UIColor *)col_248334{
    return STLCOLOR_HEX(0x248334);
}
+(UIColor *)col_FFCC33{
    return STLCOLOR_HEX(0xFFCC33);
}
+(UIColor *)col_EB4D3D{
    return STLCOLOR_HEX(0xEB4D3D);
}
+(UIColor *)col_FA6730{
    return STLCOLOR_HEX(0xFA6730);
}
+(UIColor *)col_7AD06D{
    return STLCOLOR_HEX(0x7AD06D);
}

+(UIColor *)col_0B0B0B{
    return STLCOLOR_HEX(0x0B0B0B);
}

+(UIColor *)col_EC5E4F:(CGFloat)alpha{
    return STLCOLOR_HEXAlpha(0xEC5E4F,alpha);
}
+(UIColor *)col_FFFF6F:(CGFloat)alpha{
    return STLCOLOR_HEXAlpha(0xFFFF6F,alpha);
}

+(UIColor *)col_EBEBEB{
    return STLCOLOR_HEX(0xEBEBEB);
}

+(UIColor *)col_C4C4C4{
    return STLCOLOR_HEX(0xC4C4C4);
}

+(UIColor *)col_E0E0E0 {
    return STLCOLOR_HEX(0xE0E0E0);
}

+ (UIColor *)col_EEBA00 {
    return STLCOLOR_HEX(0xEEBA00);
}

+ (UIColor *)col_26652C {
    return STLCOLOR_HEX(0x26652C);
}

+ (UIColor *)col_484848 {
    return STLCOLOR_HEX(0x484848);
}

+ (UIColor *)col_696969{
    return STLCOLOR_HEX(0x696969);
}

+ (UIColor *)col_E34E4E {
    return STLCOLOR_HEX(0xE34E4E);
}

+ (UIColor *)col_F2F2F2 {
    return STLCOLOR_HEX(0xF2F2F2);
}

+ (UIColor *)col_9d9d9d{
    return STLCOLOR_HEX(0x9d9d9d);
}
@end

