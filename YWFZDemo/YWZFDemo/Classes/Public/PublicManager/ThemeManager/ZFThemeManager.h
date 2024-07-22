//
//  ZFThemeManager.h
//  ZZZZZ
//
//  Created by YW on 2018/12/25.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFColorDefiner.h"
#import "UIColor+ExTypeChange.h"

@interface ZFThemeManager : NSObject

+ (ZFThemeManager *)themeManager;

UIColor* ZFCThemeColor(void);

UIColor* ZFCThemeColorHex(NSString *ColorHex, CGFloat alpha);

UIColor* ZFCThemeColor_A(CGFloat alpha);

UIColor* ZFC0xCE0E61_02(void);

UIColor* ZFC0xCE0E61_04(void);

//消息小红点
UIColor* ZFC0xEE0024(void);

UIColor* ZFC0xCCCCCC(void);

UIColor* ZFC0x999999(void);

UIColor* ZFC0xDDDDDD(void);

UIColor* ZFC0x666666(void);

UIColor* ZFC0x333333(void);

UIColor* ZFC0x030303(void);

/** 按钮灰*/
UIColor* ZFC0xF1F1F1(void);
UIColor* ZFC0xEEEEEE(void);

/** app主题颜色 */
+ (UIColor *)appThemeColor;
+ (UIColor *)appThemeTextColor;
/** 点击状态 */
+ (UIColor *)clickColor;
/** 提示文案 */
+ (UIColor *)pointOutColor;
/** 置灰状态 */
+ (UIColor *)disableColor;

UIColor* ZFC0xFFA800(void);
UIColor* ZFC0xFFA0AE(void);

/**这个不要用了*/
UIColor* ZFC0xB8004F(void);

UIColor* ZFC0xFFFFFF(void);

UIColor* ZFC0xFFFFFF_A(CGFloat alpha);

UIColor* ZFC0xFFFFFF_03(void);

UIColor* ZFC0x2D2D2D(void);

UIColor* ZFC0x2D2D2D_04(void);

UIColor* ZFC0x2D2D2D_05(void);

UIColor* ZFC0x2D2D2D_06(void);

UIColor* ZFC0x2D2D2D_08(void);

UIColor* ZFC0xF4394F(void);

UIColor* ZFC0xFF827A(void);

UIColor* ZFCClearColor(void);

UIColor* ZFC0x000000(void);

UIColor* ZFC0x000000_A(CGFloat alpha);
/** 黑色半透明 */
UIColor* ZFC0x000000_04(void);

UIColor* ZFC0x000000_05(void);

UIColor* ZFC0x000000_06(void);

/** 输入框灰色半 */
UIColor* ZFC0xF7F7F7(void);

UIColor* ZFC0xF4F4F4(void);

UIColor* ZFC0xB7602A(void);

UIColor* ZFC0x979797(void);

/** 玫瑰红*/
UIColor* ZFC0xFF6E81(void);
/** 字体灰*/
UIColor* ZFC0xAAAAAA(void);

UIColor* ZFC0xF8A802(void);

/** 背景粉红*/
UIColor* ZFC0xFF5C9C(void);

/** 提示蓝*/
UIColor* ZFC0x0080F3_07(void);

/** 背景淡红*/
UIColor* ZFC0xFFE4E4(void);

/** 背景淡黄*/
UIColor* ZFC0xFFF3E4(void);

/** 背景淡绿*/
UIColor* ZFC0xE0FFD6(void);

/** 文字天蓝*/
UIColor* ZFC0x2DA4FF(void);

/** 文字青蓝*/
UIColor* ZFC0x31CCE3(void);

/** 文字橙黄*/
UIColor* ZFC0xFB9139(void);

/** 文字粉红*/
UIColor* ZFC0xF75DCA(void);

/** 文字橙红*/
UIColor* ZFC0xFF6B6B(void);

/** 文字亮绿*/
UIColor* ZFC0x21CB0D(void);

/** 文字褐黄*/
UIColor* ZFC0xE3A321(void);

/** 文字蓝色*/
UIColor* ZFC0x3D76B9(void);

UIColor* ZFC0x3D76B9_01(void);


////////////////

/**提示天蓝*/
UIColor* ZFC0x06B190(void);


/**点赞、提示淡红*/
UIColor* ZFC0xFE5269(void);

UIColor* ZFC0xFE5269_A(CGFloat alpha);

/**按钮黄*/
UIColor* ZFC0xFFC439(void);

/**全局背景*/
UIColor* ZFC0xF2F2F2(void);

/**背景提示浅红*/
UIColor* ZFC0xFFBCBC(void);

/**背景提示浅淡红*/
UIColor* ZFC0xFFEFF1(void);

/**瀑布流随机色*/

UIColor* ZFC0xE5FCFF(void);

UIColor* ZFC0xFFE8E8(void);

UIColor* ZFC0xE7EDFF(void);

UIColor* ZFC0xFFF6DB(void);

UIColor* ZFC0xF3E8FF(void);

UIColor* ZFC0xE5F6DD(void);

UIColor* ZFC0xFFEFE8(void);

UIColor* ZFC0xE7F1FF(void);

+ (NSString *)randomColorString:(NSArray *)forbidColorStirngs;

@end
