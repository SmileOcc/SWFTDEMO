//
//  OSSVNSStringTool.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVBasesRequests.h"

@interface OSSVNSStringTool : NSObject


/**
 *  判断参数是否为空
 *
 *  @param string 需要判断的参数
 *
 *  @return YES表示参数为空,NO表示参数不为空
 */
+ (BOOL)isEmptyString:(id)string;

/**
 *  判断字符串是否为合法邮箱
 *
 *  @ eamil 需要判断的参数
 *
 *  @return YES表示参数为合法邮箱,NO表示参数为不合法邮箱
 */
+ (BOOL)isValidEmailString:(NSString *)email;
/**
 *  判断是否包含特殊字符（^%&',;=?$\”）
 *
 *  @param string 需要判断的参数
 *
 *  @return YES表示里面包含该字符，否则没有包含
 */
+ (BOOL)isIncludeSpecialCharacterString:(NSString *)string;
/**
 *  判断是否全是数字
 *
 *  @param string 需要判断的参数
 *
 *  @return YES表示全是数字，否则含有别的
 */
+ (BOOL)isAllNumberCharacterString:(NSString *)string;
/**
 *  判断是否全是字母（26个英文字母）
 *
 *  @param string 需要判断的参数
 *
 *  @return YES表示全是字母，否则含有别的
 */
+ (BOOL)isAllLetterCharacterString:(NSString *)string;
/**
 *  判断字符串是否全是（26个英文字母 或 0-9 的数字）组成
 *
 *  @param string 需要判断的参数
 *
 *  @return YES 表示是只有字母和数字，否则没有
 */
+ (BOOL)isAllNumberAndLetterCharacterString:(NSString *)string;
/**
 *  获取字符串的小数点后几位
 *
 *  @param string 所需要改变的字符串---举例：23.545
 *  @param point  字符串保留几位---举例：2
 *
 *  @return 表示获取到的字符串--举例按上： 23.54
 */
+ (NSString *)breakUpTheString:(NSString *)string point:(NSInteger)point;
/**
 *  判断字符串是否包含空格
 *
 *  @param string 需要的判断的
 *
 *  @return 有则YES，没有则NO
 */
+ (BOOL)isIncludeBlankCharacter:(NSString *)string;
/**
 *  切除收尾的 空格
 *
 *  @param string 需要的判断的
 *
 *  @return 返回切除后的空格
 */

+ (NSString *)cutLeadAndTrialBlankCharacter:(NSString *)string;
// 地址限制符号
+ (BOOL)streetAddressIsIncludeSpecialCharacterString:(NSString *)string;
// 省份限制符号
+ (BOOL)stateAddressIsIncludeSpecialCharacterString:(NSString *)string;
// 城市限制符号
+ (BOOL)cityAddressIsIncludeSpecialCharacterString:(NSString *)string;

/**
 *  获取当前时间的时间戳（例子：1464326536）
 *
 *  @return 时间戳字符串型
 */
+ (NSString *)getCurrentTimestamp;


+ (NSString *)uniqueUUID;

+ (NSString *)buildRequestPath:(NSString *)path;

+ (NSString *)buildCommparam;

+ (NSString *)encryptWithDict:(NSDictionary *)dict;

+ (NSString *)encryptWithStr:(NSString *)string;


+ (id)desEncrypt:(OSSVBasesRequests *)request;
+(NSString*)desEncryptToString:(OSSVBasesRequests *)request;
+ (id)desCacheDataEncrypt:(NSString *)responseString;
+ (id)desDataEncrypt:(NSString *)responseString;
+ (NSString*)timeLapse:(NSInteger)time;

// Banner统计名称
+ (NSString *)bannerScreenKeyWithBannerName:(NSString *)name screenName:(NSString *)screenName;
// 取出不同屏幕对应的图片
+ (NSString*)retinaDifferentScreenUrlFromUrl:(NSString*)strUrl;

// ===============Appflyer推广参数==============
+ (NSString *)getMediaSource;
+ (NSString *)getCampaign;
+ (NSString *)getLkid;

// ＝＝＝＝＝＝＝＝＝＝＝＝推送催付参数＝＝＝＝＝＝＝＝＝＝＝＝

+ (NSString *)getPid;
+ (NSString *)getC;
+ (NSString *)getIsRetargeting;
+ (NSString *)getPush_id;
+ (NSString *)getPush_campaign;
+ (NSString *)getPush_Channel;

/// 获取推送token
/// @param data 推送token二进制参数
+ (NSString *)hexadecimalStringFromData:(NSData *)data;


+ (NSString *)stringMD5:(NSString *)string;

+ (NSString*)jsonStringWithDict:(NSDictionary *)dict;
@end
