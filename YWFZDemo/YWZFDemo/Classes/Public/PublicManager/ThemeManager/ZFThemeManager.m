//
//  ZFThemeManager.m
//  ZZZZZ
//
//  Created by YW on 2018/12/25.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFThemeManager.h"

@interface ZFThemeManager()

@property (nonatomic, strong) NSString *test;

@end

@implementation ZFThemeManager

+ (ZFThemeManager *)themeManager {
    static ZFThemeManager *themeManagerInstance = nil; 
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        themeManagerInstance = [[self alloc] init];
    });
    
    return themeManagerInstance;
}

UIColor* ZFCThemeColor(void){
    return ColorHex_Alpha(0xCE0E61, 1.0);
}

UIColor* ZFCThemeColorHex(NSString *ColorHex, CGFloat alpha) {
    return ColorHex_Alpha(0xCE0E61, 1.0);
}
UIColor* ZFCThemeColor_A(CGFloat alpha){
    return ColorHex_Alpha(0xCE0E61, alpha);
}

UIColor* ZFC0xCE0E61_02(void) {
    return ColorHex_Alpha(0xCE0E61, 0.2);
}

UIColor* ZFC0xCE0E61_04(void) {
    return ColorHex_Alpha(0xCE0E61, 0.4);
}

UIColor* ZFC0xEE0024(void) {
    return ColorHex_Alpha(0xEE0024, 1.0);
}

UIColor* ZFC0xCCCCCC(void) {
    return ColorHex_Alpha(0xCCCCCC, 1.0);
}

UIColor* ZFC0x999999(void) {
    return ColorHex_Alpha(0x999999, 1.0);
}

UIColor* ZFC0xDDDDDD(void) {
    return ColorHex_Alpha(0xDDDDDD, 1.0);
}

UIColor* ZFC0x2D2D2D(void) {
    return ColorHex_Alpha(0x2D2D2D, 1.0);
}

UIColor* ZFC0x2D2D2D_04(void) {
    return ColorHex_Alpha(0x2D2D2D, 0.4);
}

UIColor* ZFC0x2D2D2D_05(void) {
    return ColorHex_Alpha(0x2D2D2D, 0.5);
}

UIColor* ZFC0x2D2D2D_06(void) {
    return ColorHex_Alpha(0x2D2D2D, 0.6);
}

UIColor* ZFC0x2D2D2D_08(void) {
    return ColorHex_Alpha(0x2D2D2D, 0.8);
}
UIColor* ZFC0x666666(void) {
    return ColorHex_Alpha(0x666666, 1.0);
}

UIColor* ZFC0x333333(void) {
    return ColorHex_Alpha(0x333333, 1.0);
}

UIColor* ZFC0x030303(void) {
    return ColorHex_Alpha(0x030303, 1.0);
}

UIColor* ZFC0xF1F1F1(void) {
    return ColorHex_Alpha(0xF1F1F1, 1.0);
}

UIColor* ZFC0xEEEEEE(void) {
    return ColorHex_Alpha(0xEEEEEE, 1.0);
}
/** app主题颜色 */
+ (UIColor *)appThemeColor {
    return ColorHex_Alpha(0xCE0E61, 1.0);
}
+ (UIColor *)appThemeTextColor {
    return ColorHex_Alpha(0xCE0E61, 1.0);
}
/** 点击状态 */
+ (UIColor *)clickColor {
    return ColorHex_Alpha(0xD74C85, 1.0);
}
/** 提示文案 */
+ (UIColor *)pointOutColor {
    return ColorHex_Alpha(0xEE0024, 1.0);
}
/** 置灰状态 */
+ (UIColor *)disableColor {
    return ColorHex_Alpha(0xCCCCCC, 1.0);
}

UIColor* ZFC0xFFA800(void) {
    return ColorHex_Alpha(0xFFA800, 1.0);
}

UIColor* ZFC0xFFA0AE(void) {
    return ColorHex_Alpha(0xFFA0AE, 1.0);
}
UIColor* ZFC0xB8004F(void) {
    return ColorHex_Alpha(0xB8004F, 1.0);
}

UIColor* ZFC0xFFFFFF(void) {
    return ColorHex_Alpha(0xFFFFFF, 1.0);
}

UIColor* ZFC0xFFFFFF_A(CGFloat alpha){
    return ColorHex_Alpha(0xFFFFFF, alpha);
}

UIColor* ZFC0xFFFFFF_03(void) {
    return ColorHex_Alpha(0xFFFFFF, 0.3);
}

UIColor* ZFC0xF4394F(void) {
    return ColorHex_Alpha(0xF4394F, 1.0);
}

UIColor* ZFC0xFF827A(void) {
    return ColorHex_Alpha(0xFF827A, 1.0);
}

UIColor* ZFCClearColor(void){
    return [UIColor clearColor];
}

UIColor* ZFC0x000000(void) {
    return ColorHex_Alpha(0x000000, 1.0);
}

UIColor* ZFC0x000000_A(CGFloat alpha){
    return ColorHex_Alpha(0x000000, alpha);
}
UIColor* ZFC0x000000_04(void) {
    return ColorHex_Alpha(0x000000, 0.4);
}

UIColor* ZFC0x000000_05(void) {
    return ColorHex_Alpha(0x000000, 0.5);
}

UIColor* ZFC0x000000_06(void) {
    return ColorHex_Alpha(0x000000, 0.6);
}


UIColor* ZFC0xF7F7F7(void) {
    return ColorHex_Alpha(0xF7F7F7, 1.0);
}

UIColor* ZFC0xF4F4F4(void) {
    return ColorHex_Alpha(0xF4F4F4, 1.0);
}

UIColor* ZFC0xB7602A(void) {
    return ColorHex_Alpha(0xB7602A, 1.0);
}

UIColor* ZFC0x979797(void) {
    return ColorHex_Alpha(0x979797, 1.0);
}

UIColor* ZFC0xFF6E81(void) {
    return ColorHex_Alpha(0xFF6E81, 1.0);
}

UIColor* ZFC0xAAAAAA(void) {
    return ColorHex_Alpha(0xAAAAAA, 1.0);
}

UIColor* ZFC0xF8A802(void) {
    return ColorHex_Alpha(0xF8A802, 1.0);
}

UIColor* ZFC0xFF5C9C(void) {
    return ColorHex_Alpha(0xFF5C9C, 1.0);
}

UIColor* ZFC0x0080F3_07(void) {
    return ColorHex_Alpha(0x0080F3, 0.7);
}

/** 背景淡红*/
UIColor* ZFC0xFFE4E4(void) {
    return ColorHex_Alpha(0xFFE4E4, 1.0);
}

/** 背景淡黄*/
UIColor* ZFC0xFFF3E4(void) {
    return ColorHex_Alpha(0xFFF3E4, 1.0);
}

/** 背景淡绿*/
UIColor* ZFC0xE0FFD6(void) {
    return ColorHex_Alpha(0xE0FFD6, 1.0);
}

/** 文字天蓝*/
UIColor* ZFC0x2DA4FF(void) {
    return ColorHex_Alpha(0x2DA4FF, 1.0);
}

/** 文字青蓝*/
UIColor* ZFC0x31CCE3(void) {
    return ColorHex_Alpha(0x31CCE3, 1.0);
}

/** 文字橙黄*/
UIColor* ZFC0xFB9139(void) {
    return ColorHex_Alpha(0xFB9139, 1.0);
}

/** 文字粉红*/
UIColor* ZFC0xF75DCA(void) {
    return ColorHex_Alpha(0xF75DCA, 1.0);
}

/** 文字橙红*/
UIColor* ZFC0xFF6B6B(void) {
    return ColorHex_Alpha(0xFF6B6B, 1.0);
}

/** 文字亮绿*/
UIColor* ZFC0x21CB0D(void) {
    return ColorHex_Alpha(0x21CB0D, 1.0);
}

/** 文字褐黄*/
UIColor* ZFC0xE3A321(void) {
    return ColorHex_Alpha(0xE3A321, 1.0);
}

UIColor* ZFC0x3D76B9(void)
{
    return ColorHex_Alpha(0x3D76B9, 1.0);
}

UIColor* ZFC0x3D76B9_01(void)
{
    return ColorHex_Alpha(0x3D76B9, 0.1);
}


//////////

UIColor* ZFC0x06B190(void) {
    return ColorHex_Alpha(0x06B190, 1.0);
}

UIColor* ZFC0xFE5269(void) {
    return ColorHex_Alpha(0xFE5269, 1.0);
}

UIColor* ZFC0xFE5269_A(CGFloat alpha){
    return ColorHex_Alpha(0xFE5269, alpha);
}

UIColor* ZFC0xFFC439(void) {
    return ColorHex_Alpha(0xFFC439, 1.0);
}

UIColor* ZFC0xF2F2F2(void) {
    return ColorHex_Alpha(0xF2F2F2, 1.0);
}

UIColor* ZFC0xFFBCBC(void) {
    return ColorHex_Alpha(0xFFBCBC, 1.0);
}

UIColor* ZFC0xFFEFF1(void) {
    return ColorHex_Alpha(0xFFEFF1, 1.0);
}


UIColor* ZFC0xE5FCFF(void) {
    return ColorHex_Alpha(0xE5FCFF, 1.0);
}

UIColor* ZFC0xFFE8E8(void) {
    return ColorHex_Alpha(0xFFE8E8, 1.0);
}

UIColor* ZFC0xE7EDFF(void) {
    return ColorHex_Alpha(0xE7EDFF, 1.0);
}

UIColor* ZFC0xFFF6DB(void) {
    return ColorHex_Alpha(0xFFF6DB, 1.0);
}

UIColor* ZFC0xF3E8FF(void) {
    return ColorHex_Alpha(0xF3E8FF, 1.0);
}

UIColor* ZFC0xE5F6DD(void) {
    return ColorHex_Alpha(0xE5F6DD, 1.0);
}

UIColor* ZFC0xFFEFE8(void) {
    return ColorHex_Alpha(0xFFEFE8, 1.0);
}

UIColor* ZFC0xE7F1FF(void) {
    return ColorHex_Alpha(0xE7F1FF, 1.0);
}

+ (NSString *)randomColorString:(NSArray *)forbidColorStirngs {
    
    NSInteger index = arc4random() % 8;
    __block NSString *colorString = @"E5FCFF";
    switch (index) {
        case 0:
            colorString = @"E5FCFF";
            break;
        case 1:
            colorString = @"FFE8E8";
            break;
        case 2:
            colorString = @"E7EDFF";
            break;
        case 3:
            colorString = @"FFF6DB";
            break;
        case 4:
            colorString = @"F3E8FF";
            break;
        case 5:
            colorString = @"E5F6DD";
            break;
        case 6:
            colorString = @"FFEFE8";
            break;
        case 7:
            colorString = @"E7F1FF";
            break;
        default:
            break;
    }
    
    if (forbidColorStirngs) {
        [forbidColorStirngs enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:colorString]) {
                colorString = [ZFThemeManager randomColorString:forbidColorStirngs];
                *stop = YES;
            }
        }];
    }
    return colorString;
}
@end
