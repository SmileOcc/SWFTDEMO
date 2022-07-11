//
//  QDCommonUI.m
//  qmuidemo
//
//  Created by QMUI Team on 16/8/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QDCommonUI.h"
#import "QDUIHelper.h"
#import <YXKit/YXKit-Swift.h>
#import <MMKV/MMKV.h>
#import "uSmartOversea-Swift.h"

NSString *const QDThemeIdentifierDefault = @"Default";
NSString *const QDThemeIdentifierDark = @"Dark";
NSString *const QDSelectedThemeIdentifier = @"selectedThemeIdentifier";


@implementation QDCommonUI

+ (void)renderGlobalAppearances {
    [QDUIHelper customMoreOperationAppearance];
    [QDUIHelper customAlertControllerAppearance];
    [QDUIHelper customDialogViewControllerAppearance];
    [QDUIHelper customImagePickerAppearance];
    [QDUIHelper customEmotionViewAppearance];
    
    
    QMUICMI.navBarBackgroundImage = [UIImage imageNamed:@"nav_bg"];
    
    UISearchBar *searchBar = [UISearchBar appearance];
    searchBar.searchTextPositionAdjustment = UIOffsetMake(4, 0);
    
    YXAlertView.defaultTextColor = [QMUITheme mainThemeColor];
    YXAlertView.defaultTintColor = [QMUITheme themeTintColor];    
//    YXAlertView.disableColor = [QMUITheme controlDisableColor];
    YXAlertView.textColorLevel1 = [QMUITheme textColorLevel1];
    YXAlertView.textColorLevel2 = [QMUITheme textColorLevel2];
    YXAlertView.separatorLineColor = [QMUITheme pointColor];
    YXAlertView.backgroundColor = QMUITheme.popupLayerColor;
    YXAlertView.cancelBorderColor = QMUITheme.alertButtonLayerColor;
    
    [QDUIHelper customAlertControllerAppearance];
    
    [self renderQMUIGlobalAppearances];
        
    [self renderNavBarAppearances];
}


+ (void)renderNavBarAppearances {
}


+ (void)renderQMUIGlobalAppearances {
}

@end

static SkinType currentSkin = SkinTypeFollow;

@implementation YXThemeTool

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static YXThemeTool *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        
        instance.mainThemeColor = [UIColor themeColorWithNormalHex:@"#414FFF" andDarkColor:@"#6671FF"];
        instance.themeTintColor = [UIColor themeColorWithNormalHex:@"#414FFF" andDarkColor:@"#6671FF"];
        instance.backgroundColor = [UIColor themeColorWithNormalHex:@"#F8F9FC" andDarkColor:@"#000000"];
        instance.foregroundColor = [UIColor themeColorWithNormalHex:@"#FFFFFF" andDarkColor:@"#101014"];
        instance.themeTextColor = [UIColor themeColorWithNormalHex:@"#414FFF" andDarkColor:@"#6671FF"];
        instance.textColorLevel1 = [UIColor themeColorWithNormalHex:@"#2A2A34" andDarkColor:@"#D3D4E6"];
        instance.textColorLevel2 = [UIColor themeColorWithNormalHex:@"#555665" andDarkColor:@"#A3A5B3"];
        instance.textColorLevel3 = [UIColor themeColorWithNormalHex:@"#888996" andDarkColor:@"#8C8D99"];
        instance.textColorLevel4 = [UIColor themeColorWithNormalHex:@"#C4C5CE" andDarkColor:@"#5D5E66"];
        instance.tipsColor = [UIColor themeColorWithNormalHex:@"#FF7127" andDarkColor:@"#FF7127"];
        instance.errorTextColor = [UIColor themeColorWithNormalHex:@"#ee3d3d" andDarkColor:@"#ee3d3d"];
        instance.sellColor = [UIColor themeColorWithNormalHex:@"#FF6933" andDarkColor:@"#E05C2D"];
        instance.buyColor = [UIColor themeColorWithNormalHex:@"#00C767" andDarkColor:@"#00994F"];
        instance.stockRedColor = [UIColor themeColorWithNormalHex:@"#00C767" andDarkColor:@"#00994F"];
        instance.stockGreenColor = [UIColor themeColorWithNormalHex:@"#FF6933" andDarkColor:@"#E05C2D"];
        instance.stockGrayColor = [UIColor themeColorWithNormalHex:@"#B0B6CB" andDarkColor:@"#858999"];
        instance.popupLayerColor = [UIColor themeColorWithNormalHex:@"#FFFFFF" andDarkColor:@"#292933"];
        instance.itemBorderColor = [UIColor themeColorWithNormalHex:@"#999999" andDarkColor:@"#212129"];
        instance.shadeLayerColor = [UIColor themeColorWithNormal:[[UIColor qmui_colorWithHexString:@"#2A2A34"] colorWithAlphaComponent:0.4] andDarkColor:[[UIColor qmui_colorWithHexString:@"#000000"] colorWithAlphaComponent:0.8]];
        instance.noticeBackgroundColor = [instance.themeTextColor colorWithAlphaComponent:0.1];
        instance.noticeTextColor = instance.themeTextColor;
        instance.normalStrongNoticeBackgroundColor = [UIColor themeColorWithNormalHex:@"#6788FF" andDarkColor:@"#6788FF"];
        instance.separatorLineColor = [UIColor themeColorWithNormalHex:@"#DDDDDD" andDarkColor:@"#292933"];
        instance.popSeparatorLineColor = [UIColor themeColorWithNormalHex:@"#DDDDDD" andDarkColor:@"#555665"];
        instance.secondButtonDisableColor = [UIColor themeColorWithNormal:[[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.2] andDarkColor:[[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.2]];
        instance.switchOnTintColor = [UIColor themeColorWithNormalHex:@"#0186FF" andDarkColor:@"#0186FF"];
        instance.progressTintColor = [UIColor themeColorWithNormalHex:@"#285AC8" andDarkColor:@"#285AC8"];
        instance.pointColor = [UIColor themeColorWithNormalHex:@"#EAEAEA" andDarkColor:@"#212129"];
        instance.shadowColor = [UIColor themeColorWithNormalHex:@"#DDECFF" andDarkColor:@"#DDECFF"];
        instance.blockColor = [UIColor themeColorWithNormalHex:@"#F8F9FC" andDarkColor:@"#19191F"];
        instance.alertButtonLayerColor = [UIColor themeColorWithNormalHex:@"#EAEAEA" andDarkColor:@"#3D3D4D"];
        instance.holdMarkColor = [UIColor themeColorWithNormalHex:@"#1E93F3" andDarkColor:@"#1E93F3"];
        instance.searchBarBackgroundColor = [UIColor themeColorWithNormalHex:@"#F8F8F8" andDarkColor:@"#F8F8F8"];
        
        instance.longPressBgColor = [UIColor themeColorWithNormal:[[UIColor qmui_colorWithHexString:@"#2A2A34"] colorWithAlphaComponent:0.8] andDarkColor:[UIColor qmui_colorWithHexString:@"#292933"]];
        instance.longPressTextColor = [UIColor themeColorWithNormalHex:@"#FFFFFF" andDarkColor:@"#D3D4E6"];
        
    });
    return instance;
}

//@objc static func navigationBarBackgroundImage(with size: CGSize = CGSize(width: 23, height: 58)) -> UIImage {
//    var image = UIImage()
//    if #available(iOS 13.0, *) {
//        image.imageAsset?.register(UIImage.qmui_image(with: UIColor.white) ?? UIImage(), with: UITraitCollection.init(userInterfaceStyle: .light))
//        image.imageAsset?.register(UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#101014")) ?? UIImage(), with: UITraitCollection.init(userInterfaceStyle: .dark))
//    } else {
//        image = UIImage.qmui_image(with: UIColor.white) ?? UIImage()
//    }
//    return image
//}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}


+ (void)initialize
{
    if (self == [super class]) {
        currentSkin = [[MMKV defaultMMKV] getUInt32ForKey:QDSelectedThemeIdentifier defaultValue:0];
    }
}

+ (SkinType)currentSkin {
    return currentSkin;
}

+ (void)setSkinWithType:(SkinType)type {
    currentSkin = type;
    [[MMKV defaultMMKV] setUInt32:type forKey:QDSelectedThemeIdentifier];
    if (@available(iOS 13.0, *)) {
        if (type == SkinTypeFollow) {
            [UIApplication sharedApplication].keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
            QMUIModalPresentationViewController.appearance.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
        } else if (type == SkinTypeLight) {
            [UIApplication sharedApplication].keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            QMUIModalPresentationViewController.appearance.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } else if (type == SkinTypeDark) {
            [UIApplication sharedApplication].keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            QMUIModalPresentationViewController.appearance.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }
    }
}

+ (BOOL)isDarkMode {
    
    if (@available(iOS 13.0, *)) {
        
        if ([YXThemeTool currentSkin] == SkinTypeFollow) {
            if ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) {
                return YES;
            }
        }
        
        if ([YXThemeTool currentSkin] == UIUserInterfaceStyleDark) {
            return YES;
        }
    }
    
    return NO;
}

+ (UIUserInterfaceStyle)style API_AVAILABLE(ios(13.0)) {
    
    SkinType type = [YXThemeTool currentSkin];
    if (type == SkinTypeFollow) {
        return UIUserInterfaceStyleUnspecified;
    } else if (type == SkinTypeLight) {
        return UIUserInterfaceStyleLight;
    } else {
        return UIUserInterfaceStyleDark;
    }    
}

+ (NSString *)skinName {
    SkinType type = [YXThemeTool currentSkin];
    if (type == SkinTypeFollow) {
        return [YXLanguageUtility kLangWithKey:@"theme_follow_system"];
    } else if (type == SkinTypeLight) {
        return [YXLanguageUtility kLangWithKey:@"theme_white"];
    } else {
        return [YXLanguageUtility kLangWithKey:@"theme_dark"];
    }
}

@end




@implementation YXThemeColor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static YXThemeColor *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}


/// 主品牌色
- (UIColor *)mainThemeColor {
    return YXThemeTool.sharedInstance.mainThemeColor;
}
/// 主题的tint
- (UIColor *)themeTintColor {
    return YXThemeTool.sharedInstance.mainThemeColor;
}
//// 背景色
- (UIColor *)backgroundColor {
    return YXThemeTool.sharedInstance.backgroundColor;
}
/// 前景色
- (UIColor *)foregroundColor {
    return YXThemeTool.sharedInstance.foregroundColor;
}

/// 文字主題色 主品牌色
- (UIColor *)themeTextColor {
    return YXThemeTool.sharedInstance.mainThemeColor;
}
/// 一级文字
- (UIColor *)textColorLevel1 {
    return YXThemeTool.sharedInstance.textColorLevel1;
}
/// 二级文字
- (UIColor *)textColorLevel2 {
    return YXThemeTool.sharedInstance.textColorLevel2;
}
/// 三级文字
- (UIColor *)textColorLevel3 {
    return YXThemeTool.sharedInstance.textColorLevel3;
}
/// 四级文字
- (UIColor *)textColorLevel4 {
    return YXThemeTool.sharedInstance.textColorLevel4;
}
/// 提示
- (UIColor *)tipsColor {
    return YXThemeTool.sharedInstance.tipsColor;
}

/// 错误提示颜色
- (UIColor *)errorTextColor {
    return YXThemeTool.sharedInstance.errorTextColor;
}

/// 卖出
- (UIColor *)sellColor {
    return YXThemeTool.sharedInstance.sellColor;
}
/// 买入
- (UIColor *)buyColor {
    return YXThemeTool.sharedInstance.buyColor;
}
/// 红色（股票用，红涨）
- (UIColor *)stockRedColor {
    return YXThemeTool.sharedInstance.stockRedColor;
}
/// 绿色（股票用，绿跌）
- (UIColor *)stockGreenColor {
    return YXThemeTool.sharedInstance.stockGreenColor;
}
/// 灰色（股票用，灰平）
- (UIColor *)stockGrayColor {
    return YXThemeTool.sharedInstance.stockGrayColor;
}


/// 弹层
- (UIColor *)popupLayerColor {
    return YXThemeTool.sharedInstance.popupLayerColor;
}
/// 边框
- (UIColor *)itemBorderColor {
    return YXThemeTool.sharedInstance.itemBorderColor;
}
/// 遮罩层
- (UIColor *)shadeLayerColor {
    return YXThemeTool.sharedInstance.shadeLayerColor;
}


/// 强通知背景
- (UIColor *)noticeBackgroundColor {
    return YXThemeTool.sharedInstance.noticeBackgroundColor;
}
/// 强通知文本
- (UIColor *)noticeTextColor {
    return YXThemeTool.sharedInstance.noticeTextColor;
}
/// 普通的通知背景色
- (UIColor *)normalStrongNoticeBackgroundColor {
    return YXThemeTool.sharedInstance.normalStrongNoticeBackgroundColor;
}

/// 分隔线
- (UIColor *)separatorLineColor {
    return YXThemeTool.sharedInstance.separatorLineColor;
}

/// 弹层的分割线
- (UIColor *)popSeparatorLineColor {
    return YXThemeTool.sharedInstance.popSeparatorLineColor;
}

/// disenable
- (UIColor *)secondButtonDisableColor {
    return YXThemeTool.sharedInstance.secondButtonDisableColor;
}

/// UISwitch 打开时的颜色
- (UIColor *)switchOnTintColor {
    return YXThemeTool.sharedInstance.switchOnTintColor;
}

/// 进度条
- (UIColor *)progressTintColor {
    return YXThemeTool.sharedInstance.progressTintColor;
}

/*线条颜色 */
- (UIColor *)pointColor {
    return YXThemeTool.sharedInstance.pointColor;
}
/*阴影颜色 */
- (UIColor *)shadowColor {
    return YXThemeTool.sharedInstance.shadowColor;
}
/*阴影颜色 */
- (UIColor *)blockColor {
    return YXThemeTool.sharedInstance.blockColor;
}

- (UIColor *)alertButtonLayerColor {
    return YXThemeTool.sharedInstance.alertButtonLayerColor;
}


/* 持仓小标记的颜色 */
- (UIColor *)holdMarkColor {
    return YXThemeTool.sharedInstance.holdMarkColor;
}


/* searchBar 背景颜色 */
- (UIColor *)searchBarBackgroundColor {
    return YXThemeTool.sharedInstance.searchBarBackgroundColor;
}

- (UIColor *)longPressBgColor {
    return YXThemeTool.sharedInstance.longPressBgColor;
}

- (UIColor *)longPressTextColor {
    return YXThemeTool.sharedInstance.longPressTextColor;
}

@end
