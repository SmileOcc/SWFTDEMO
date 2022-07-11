//
//  ThemeColorManager.h
// XStarlinkProject
//
//  Created by odd on 2020/6/29.
//  Copyright © 2020 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

// 随机颜色
#define STLCOLOR_RANDOM [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1.0]

// 颜色
#define STLCOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

// 十六进制颜色
#define STLCOLOR_HEX(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]
#define STLCOLOR_HEXAlpha(hex,a) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:a]

@interface OSSVThemesColors : NSObject

+ (UIColor *)stlClearColor;
+ (UIColor *)stlBlackColor;
+ (UIColor *)stlWhiteColor;
+ (UIColor *)stlBlackOrWhiteColor;
+ (UIColor *)stlWhiteOrBlackColor;


+ (UIColor *)col_ffffff:(CGFloat)a;
+ (UIColor *)col_000000:(CGFloat)a;

+ (UIColor *)col_333333;
+ (UIColor *)col_666666;
+ (UIColor *)col_666666:(CGFloat)a;
+ (UIColor *)col_999999;
+ (UIColor *)col_808080;
+ (UIColor *)col_262626;
+ (UIColor *)col_262626:(CGFloat)a;

+ (UIColor *)col_454545;

+ (UIColor *)col_131313;
+ (UIColor *)col_F5F5F5;
+ (UIColor *)col_B3B3B3;
+ (UIColor *)col_FFF5DF;
///亮红
+ (UIColor *)col_FF6734;

///红点色
+ (UIColor *)col_FF4E6A;

+ (UIColor *)col_FF624F;
+ (UIColor *)col_FF4E6A:(CGFloat)a;
+ (UIColor *)col_FFE9ED;

+ (UIColor *)col_FDF1F0;

///边框线
+ (UIColor *)col_E6E6E6;

+ (UIColor *)col_CCCCCC;

///褐色
+ (UIColor *)col_B33B30;

+ (UIColor *)col_7D7D7D;

///褐色 价格
+ (UIColor *)col_C63D3D;
///褐色 边框
+ (UIColor *)col_CC4337;

///绿色
+ (UIColor *)col_60CD8E;


+ (UIColor *)col_EEEEEE;

+ (UIColor *)col_0D0D0D;

+ (UIColor *)col_0D0D0D:(CGFloat)a;

///提示红
+ (UIColor *)col_FF5875;
///背景灰
+ (UIColor *)col_F8F8F8;

///星星黄
+ (UIColor *)col_FFCF60;

+ (UIColor *)col_E63D2E;

+ (UIColor *)col_FAFAFA;

///淡黄
+ (UIColor *)col_FFF0CC;

///淡红
+ (UIColor *)col_FF9318;
///字体灰
+ (UIColor *)col_6C6C6C;
///字体灰
+ (UIColor *)col_B2B2B2;
///淡黄
+ (UIColor *)col_FFFAEA;

///暗红提示点
+ (UIColor *)col_B62B21;

+ (UIColor *)col_FBE9E9;

+ (UIColor *)col_FFF3E4;

+ (UIColor *)col_3FE35C;

+ (UIColor *)col_FDC845;

+ (UIColor *)col_9F5123;

+ (UIColor *)col_F5EEE9;

+(UIColor *)col_FF9522;
+(UIColor *)col_FFFFFF;
+(UIColor *)col_24A600;
+(UIColor *)col_E1F2DA;
+(UIColor *)col_FF9900;
+(UIColor *)col_F1F1F1;
+(UIColor *)col_D1D1D1;
+(UIColor *)col_E1E1E1;
+(UIColor *)col_EDEDED;
+(UIColor *)col_FE6902;
+(UIColor *)col_FDD835;
+(UIColor *)col_F6F6F6;
+(UIColor *)col_D0D1D1;
+(UIColor *)col_2D2D2D;
+(UIColor *)col_212121;
+(UIColor *)col_EFEFEF;
+(UIColor *)col_DDDDDD;
+(UIColor *)col_F67160;
+(UIColor *)col_FEA235;
+(UIColor *)col_F7F7F7;
+(UIColor *)col_C5C5C5;
+(UIColor *)col_E5E5E5;
+(UIColor *)col_2E536B;
+(UIColor *)col_FDF135;
+(UIColor *)col_FF6F00;
+(UIColor *)col_B56B23;
+(UIColor *)col_CC00FF;
+(UIColor *)col_EE4D4D;
+(UIColor *)col_515151;
+(UIColor *)col_FE5269;
+(UIColor *)col_248334;
+(UIColor *)col_FFCC33;
+(UIColor *)col_EB4D3D;
+(UIColor *)col_FA6730;
+(UIColor *)col_7AD06D;
+(UIColor *)col_0B0B0B;
+(UIColor *)col_EC5E4F:(CGFloat)alpha;
+(UIColor *)col_FFFF6F:(CGFloat)alpha;
+(UIColor *)col_EBEBEB;
+(UIColor *)col_C4C4C4;
+(UIColor *)col_E0E0E0;

+ (UIColor *)col_EEBA00;
+ (UIColor *)col_26652C;
+ (UIColor *)col_484848;
+ (UIColor *)col_696969;

+ (UIColor *)col_E34E4E;

+ (UIColor *)col_F2F2F2;
+ (UIColor *)col_9d9d9d;


@end

NS_ASSUME_NONNULL_END
