//
///  QDCommonUI.h
///  qmuidemo
//
///  Created by QMUI Team on 16/8/8.
///  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+YXColor.h"

#define QMUITheme [YXThemeColor sharedInstance]

NS_ASSUME_NONNULL_BEGIN

extern NSString *const QDSelectedThemeIdentifier;

extern NSString *const QDThemeIdentifierDefault;
extern NSString *const QDThemeIdentifierDark;


//暗黑模式
typedef NS_ENUM(UInt32, SkinType) {
    SkinTypeFollow = 0, //跟随系统
    SkinTypeLight = 1,  //白的
    SkinTypeDark = 2  //暗黑的
};

@interface QDCommonUI : NSObject

+ (void)renderGlobalAppearances;


@end



@interface YXThemeTool: NSObject


+ (instancetype)sharedInstance;

+ (SkinType)currentSkin;

+ (void)setSkinWithType:(SkinType)type;

+ (BOOL)isDarkMode;

+ (UIUserInterfaceStyle)style API_AVAILABLE(ios(13.0));

+ (NSString *)skinName;

#pragma mark - 配色(单例)
/// 主品牌色
@property (nonatomic, strong) UIColor *mainThemeColor;
/// 主题的tint
@property (nonatomic, strong) UIColor *themeTintColor;
//// 背景色
@property (nonatomic, strong) UIColor *backgroundColor;
/// 前景色
@property (nonatomic, strong) UIColor *foregroundColor;
/// 文字主題色 主品牌色
@property (nonatomic, strong) UIColor *themeTextColor;
/// 一级文字
@property (nonatomic, strong) UIColor *textColorLevel1;
/// 二级文字
@property (nonatomic, strong) UIColor *textColorLevel2;
/// 三级文字
@property (nonatomic, strong) UIColor *textColorLevel3;
/// 四级文字
@property (nonatomic, strong) UIColor *textColorLevel4;
/// 提示
@property (nonatomic, strong) UIColor *tipsColor;
/// 错误提示颜色
@property (nonatomic, strong) UIColor *errorTextColor;
/// 卖出
@property (nonatomic, strong) UIColor *sellColor;
/// 买入
@property (nonatomic, strong) UIColor *buyColor;
/// 红色（股票用，红涨）
@property (nonatomic, strong) UIColor *stockRedColor;
/// 绿色（股票用，绿跌）
@property (nonatomic, strong) UIColor *stockGreenColor;
/// 灰色（股票用，灰平）
@property (nonatomic, strong) UIColor *stockGrayColor;
/// 弹层
@property (nonatomic, strong) UIColor *popupLayerColor;
/// 边框
@property (nonatomic, strong) UIColor *itemBorderColor;
/// 遮罩层
@property (nonatomic, strong) UIColor *shadeLayerColor;
/// 强通知背景
@property (nonatomic, strong) UIColor *noticeBackgroundColor;
/// 强通知文本
@property (nonatomic, strong) UIColor *noticeTextColor;
/// 普通的通知背景色
@property (nonatomic, strong) UIColor *normalStrongNoticeBackgroundColor;
/// 分隔线
@property (nonatomic, strong) UIColor *separatorLineColor;
/// 弹层的分割线
@property (nonatomic, strong) UIColor *popSeparatorLineColor;
/// disenable
@property (nonatomic, strong) UIColor *secondButtonDisableColor;
/// UISwitch 打开时的颜色
@property (nonatomic, strong) UIColor *switchOnTintColor;
/// 进度条
@property (nonatomic, strong) UIColor *progressTintColor;
/*线条颜色 */
@property (nonatomic, strong) UIColor *pointColor;
/*阴影颜色 */
@property (nonatomic, strong) UIColor *shadowColor;
/*阴影颜色 */
@property (nonatomic, strong) UIColor *blockColor;
@property (nonatomic, strong) UIColor *alertButtonLayerColor;
/* 持仓小标记的颜色 */
@property (nonatomic, strong) UIColor *holdMarkColor;
/* searchBar 背景颜色 */
@property (nonatomic, strong) UIColor *searchBarBackgroundColor;

@property (nonatomic, strong) UIColor *longPressBgColor;
@property (nonatomic, strong) UIColor *longPressTextColor;


@property (nonatomic, strong) UIImage *navbarImage;

@end

@interface YXThemeColor: NSObject

+ (instancetype)sharedInstance;



/// 主品牌色
- (UIColor *)mainThemeColor;
/// 主题的tint
- (UIColor *)themeTintColor;
//// 背景色
- (UIColor *)backgroundColor;
/// 前景色
- (UIColor *)foregroundColor;

/// 文字主題色 主品牌色
- (UIColor *)themeTextColor;
/// 一级文字
- (UIColor *)textColorLevel1;
/// 二级文字
- (UIColor *)textColorLevel2;
/// 三级文字
- (UIColor *)textColorLevel3;
/// 四级文字
- (UIColor *)textColorLevel4;
/// 提示
- (UIColor *)tipsColor;
/// 错误提示颜色
- (UIColor *)errorTextColor;

/// 卖出
- (UIColor *)sellColor;
/// 买入
- (UIColor *)buyColor;
/// 红色（股票用，红涨）
- (UIColor *)stockRedColor;
/// 绿色（股票用，绿跌）
- (UIColor *)stockGreenColor;
/// 灰色（股票用，灰平）
- (UIColor *)stockGrayColor;


/// 弹层
- (UIColor *)popupLayerColor;
/// 边框
- (UIColor *)itemBorderColor;
/// 遮罩层
- (UIColor *)shadeLayerColor;


/// 强通知背景
- (UIColor *)noticeBackgroundColor;
/// 强通知文本
- (UIColor *)noticeTextColor;
/// 普通的通知背景色
- (UIColor *)normalStrongNoticeBackgroundColor;

/// 分隔线
- (UIColor *)separatorLineColor;
/// 弹层的分割线
- (UIColor *)popSeparatorLineColor;
/// disenable
- (UIColor *)secondButtonDisableColor;

/// UISwitch 打开时的颜色
- (UIColor *)switchOnTintColor;

/// 进度条
- (UIColor *)progressTintColor;

/*线条颜色 */
- (UIColor *)pointColor;
/*阴影颜色 */
- (UIColor *)shadowColor;
/*阴影颜色 */
- (UIColor *)blockColor;

- (UIColor *)alertButtonLayerColor;

/* 持仓小标记的颜色 */
- (UIColor *)holdMarkColor;


/* searchBar 背景颜色 */
- (UIColor *)searchBarBackgroundColor;

/// 长按背景色
- (UIColor *)longPressBgColor;
/// 长按文字色
- (UIColor *)longPressTextColor;
@end

NS_ASSUME_NONNULL_END
