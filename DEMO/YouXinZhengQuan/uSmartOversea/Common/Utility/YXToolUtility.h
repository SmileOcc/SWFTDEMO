//
//  YXToolUility.h
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/5.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//
#import <Photos/Photos.h>

#define APPS_FLYER_MMKV_KEY @"kAppsFlyerMMKVKey"

@interface YXToolUtility : NSObject

/**
 本地存储
 */
+ (BOOL)saveToLocalWithObject:(id)obj forKey:(NSString *)key;
+ (id)getLocalObjectForKey:(NSString *)key;


/**
 规则校验
 */
+ (BOOL)isValidPassword:(NSString *)password; //验证是否为有效密码
+ (BOOL)isNumber:(NSString*)number; //验证是否为数字

/**
 AttributedString
 */
+ (NSMutableAttributedString *)attributedStringWithText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor lineSpacing:(CGFloat)lineSpacing;

/**
 时间戳转换对应时间
 */
+ (NSString *)dateStringWithTimeIntervalSince1970:(NSInteger)interval;


/**
 获取字符串的size
 */
+ (CGSize)getStringSizeWith:(NSString *)string andFont:(UIFont *)font andlimitWidth:(float)width andLineSpace:(float)lineSpace;

+ (CGSize)getStringSizeWith:(NSString *)string andFont:(UIFont *)font andlimitWidth:(float)width;

+ (CGSize)getStringSizeWith:(NSString *)string andFont:(UIFont *)font andlimitWidth:(float)width andLineHeight:(float)lineHeight;



/**
 纯股票价格参数(股价, 今开, 昨收, 最高, 最低....)

 @param data 股票价格
 @param deciPoint 小数位数(2,3)
 @param priceBase 除数位
 @return 数据
 */
+ (NSString *)stockPriceData:(double)data deciPoint:(NSInteger)deciPoint priceBase:(NSInteger)priceBase;

/**
 带单位的股票参数(成交量, 成交额, 总市值, 每手...) --- 萬, 萬億, 股, 億股...
 @param data 数据(除以priceBase之前的)
 @param deciPoint 小数位数(2,3)
 @param unit 单位: "股"或者"手", 没有时传入""
 @param priceBase 除数位(2或者3)
 @return 股票参数 数据
 */
+ (NSString *)stockData:(double)data deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase;

/**
 股票百分数(振幅, 量比, 股息率....))
 @param data 数据
 @param priceBasic 除数位
 @param deciPoint 需要保留的小数位数
 */
+ (NSString *)stockPercentData:(double)data priceBasic:(NSInteger)priceBasic deciPoint:(NSInteger)deciPoint;

+ (NSString *)stockPercentDataNoPositive:(double)data priceBasic:(NSInteger)priceBasic deciPoint:(NSInteger)deciPoint;
/**
 交易量单位(K, M, B)
 
 @param num 交易量
 @return 带单位的交易量
 */
+ (NSString *)stockVolumeUnit:(NSInteger)num;

+ (UIColor *)priceTextColor:(double)data comparedData:(double)compareData;

+ (UIColor *)changeColor:(double)change;




/**
 判断字符串是否是纯int类型

 @param string
 @return YES/NO
 */
+ (BOOL)isPureInt:(NSString *)string;

/**
 红涨绿跌, 不变为灰色
 
 @param data 股票数值
 @param comparedData 被比较的数值
 @return 颜色
 */
+ (UIColor *)stockColorWithData:(double)data compareData:(double)comparedData;

/**
 通过涨跌幅来确定颜色

 @param change 涨跌幅
 @return 颜色
 */
+ (UIColor *)stockChangeColor:(double)change;

/**
 判断字符串是否是纯Float类型
 
 @param string
 @return YES/NO
 create date: 2019-08-12
 auth: huang sengoln
 */
+ (BOOL)isPureFloat:(NSString *)string;

/**
 货币单位
 @return 包含目前货币单位的数组
 */
+ (NSArray<NSString *> * _Nonnull)moneyUnitArray;


/**
 数字带逗号

 @param value 数字
 @return 返回带逗号的字符串
 */
+ (NSString *)formatNumberDecimalValue:(double)value;



/**
 获取当前的货币表示（人民币、港币，美元）

 @param moneyType 类型
 @return 币种
 */
+ (NSString * _Nonnull)moneyUnit:(NSInteger)moneyType;
    
/**
 注意：行情接口返回的货币类型使用
 获取当前的货币表示（1:人民币、2:美元、3:港币）

 @param currency 类型
 @return 币种
 */
+ (NSString *)quoteCurrency:(NSInteger)currency;

/**
 *  获取相簿
 *
 *  @return 获取到的相簿
 */

+ (PHAssetCollection *)assetCollection;


/**
 当前月份的英文简写 (顺序1， 2， 。。。 11， 12)

 @param month 月份索引
 @return 对应月份英文简写
 */
+ (NSString *)shortMonthName:(NSInteger)month;

/**
 当前月份的英文简写 (顺序1， 2， 。。。 11， 12)

 @param month 月份索引
 @return 对应月份英文简写，不带.
 */
+ (NSString *)enMonthName:(NSInteger)month;

/**
 是否是5系列, SE或4s手机
 */
+ (BOOL)is4InchScreenWidth;

+ (nullable NSString *)getIDFA;

// 颜色集合
+ (NSArray<UIColor *> * _Nonnull)stockColorArrays;

/// 强制旋转设备方向到竖屏
+ (void)forceToPortraitOrientation;

/// 强制旋转设备方向到横屏
+ (void)forceToLandscapeRightOrientation;

+ (void)switchNewOrientation:(UIInterfaceOrientationMask)interfaceOrientationMask;

+ (BOOL)JailBreak;

+ (UIImage *_Nullable)imageWithScreenshot;

/// 生成http请求所需要的xToken
/// @param xTransId xTransId
/// @param xTime xTime
/// @param xDt xDt
/// @param xDevId xDevId
/// @param xUid xUid
/// @param xLang xLang
/// @param xType xType
/// @param xVer xVer
+ (NSString * _Nonnull)xTokenGenerateWithXTransId:(NSString * _Nonnull)xTransId xTime:(NSString * _Nonnull)xTime xDt:(NSString * _Nonnull)xDt xDevId:(NSString * _Nonnull)xDevId xUid:(NSString * _Nonnull)xUid xLang:(NSString * _Nonnull)xLang xType:(NSString * _Nonnull)xType xVer:(NSString * _Nonnull)xVer;

/// 将传入的base64String转为UIImage
/// @param base64String 需要转换的base64String
+ (UIImage * _Nullable)conventToImageWithBase64String:(id _Nullable)base64String;
+ (NSMutableAttributedString *)stocKNumberData:(int64_t)value deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase;
+ (NSMutableAttributedString *)stocKNumberData:(int64_t)value deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase numberFont:(UIFont *)numberFont unitFont:(UIFont*)unitFont;
// 带 + - 号的富文本
+ (NSMutableAttributedString *)stocKNumberData:(int64_t)value deciPoint:(NSInteger)deciPoint stockUnit:(NSString *)unit priceBase:(NSInteger)priceBase numberFont:(UIFont *)numberFont unitFont:(UIFont*)unitFont color:(UIColor *)color;

/**
 Converts input value into a string.
 
 @param value The input value.
 @return The textual representation of the value.
 */
+ (NSString *)stringValue:(id)value;

/**
 Converts input value into a boolean with default fallback.
 
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @return The boolean representation of the value or default value otherwise.
 @see boolValue:
 */
+ (BOOL)boolValue:(id)value def:(BOOL)def;

/**
 Converts input value into a boolean.
 
 @param value The input value.
 @return The boolean representation of the value.
 @see boolValue:def:
 */
+ (BOOL)boolValue:(id)value;

/**
 Converts input value into a double.
 
 @param value The input value.
 @return The double representation of the value.
 @see doubleValue:def:
 */
+ (double)doubleValue:(id)value;

/**
 Converts input value into a double with default fallback.
 
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @return The double representation of the value.
 @see doubleValue:
 */
+ (double)doubleValue:(id)value def:(double)def;

/**
 Converts input value into a double with default fallback.
 
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @param isValid The optional output parameter indicating the status of the convertion. If not _NULL_, its value is set to _YES_ if the value was converted successfully and _NO_ otherwise.
 @return The double representation of the value.
 @see doubleValue:
 */
+ (double)doubleValue:(id)value def:(double)def valid:(BOOL *)isValid;

/**
 Converts input value into an int with default fallback.
 
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @param isValid The optional output parameter indicating the status of the convertion. If not _NULL_, its value is set to _YES_ if the value was converted successfully and _NO_ otherwise.
 @return The int representation of the value.
 @see intValue:
 */
+ (int)intValue:(id)value def:(int)def valid:(BOOL *)isValid;

/**
 Converts input value into an int with default fallback.
 
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @return The int representation of the value.
 @see intValue:
 */
+ (int)intValue:(id)value def:(int)def;

/**
 Converts input value into an int.
 
 @param value The input value.
 @return The int representation of the value.
 @see intValue:def:
 */
+ (int)intValue:(id)value;

/**
 Converts input value into a float with default fallback.
 
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @return The float representation of the value.
 @see floatValue:
 */
+ (CGFloat)floatValue:(id)value def:(CGFloat)def;

/**
 Converts input value into a float with default fallback.
 @param value The input value.
 @param def The default value if the input value cannot be converted.
 @param isValid The optional output parameter indicating the status of the convertion. If not _NULL_, its value is set to _YES_ if the value was converted successfully and _NO_ otherwise.
 @return The float representation of the value.
 @see floatValue:
 */
+ (CGFloat)floatValue:(id)value def:(CGFloat)def valid:(BOOL *)isValid;

/**
 Converts input value into a float.
 
 @param value The input value.
 @return The float representation of the value.
 @see floatValue:def:
 */
+ (CGFloat)floatValue:(id)value;

///保留小数
+ (float)yx_roundFloat:(float)price andDeciPoint:(NSInteger)deciPoint;


+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;

//保存图片到相册
+ (void)saveImageToAlbum:(UIImage *)image completionHandler:(void (^ _Nullable)(BOOL result))completionHandler;

//去除html格式 返回attributeString
+ (NSString  * _Nullable)reverseTransformHtmlString:(NSString * _Nullable)htmlString;

#pragma mark ---- 时间的处理
+(NSString * _Nullable)compareCurrentTime:(NSString * _Nullable)timeStr;

+ (void)showCommentShareViewWithIsShowTopStatus:(BOOL)isShowTopStatus bizId:(NSString *)bizId shortUrl:(NSString * _Nullable)shortUrl image:(UIImage *) image;

/**
 *  检测相册权限
 *
 *
 */
+ (BOOL)checkPhotoAlbumPermissions;

/**
 *  检测相机权限
 *
 *
 */
+ (BOOL)checkCameraAlbumPermissions;

/**
 *  相机权限弹框
 *
 *
 */
+ (void)showCameraPermissionsAlertInVc:(UIViewController *)vc;

+ (NSArray *)getWidgetGroupData;


//得到字节数函数
+ (int)stringConvertToInt:(NSString * _Nullable)strtemp;

// 获得个股讨论图片尺寸
+ (CGSize)findStockDiscussImageSizeWithUrl:(NSString *_Nonnull)url;

+(NSString *)moveEnterSymbol:(NSString *) text withString:(NSString *) value ;
/**
 *
 *
 *  @return 获取不超过maxCount字节长度的字符串
 */
+ (NSString *)maxCharacterWithString:(NSString*)string maxCount:(NSInteger)count;


+ (void)alertNoFullScreen:(UIViewController *)viewController;


/// 对指定的视图进行截图，转换成UIImage
/// @param layer 需要截图的视图的layer
+ (UIImage * _Nullable)normalSnapShotImage:(CALayer * _Nonnull)layer;

+ (UIImage *_Nullable)createCodeImage:(NSString *_Nullable)codeString;

+(BOOL) needFinishQuoteNotify;

//是否跳过行情声明
+(BOOL) isJumpOverQuoteNotify;

/// 获取交易所的英文简写
+ (NSString *)getQuoteExchangeEnName:(int64_t)exchangeId;
@end
