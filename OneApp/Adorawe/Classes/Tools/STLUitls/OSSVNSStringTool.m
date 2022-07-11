//
//  OSSVNSStringTool.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVNSStringTool.h"
#import "DesEncrypt.h"
#import <CommonCrypto/CommonCrypto.h>
#import "OSSVJSONsSerialization.h"
@implementation OSSVNSStringTool

+ (BOOL)isEmptyString:(id)string {
    return string==nil || string==[NSNull null] || ![string isKindOfClass:[NSString class]] || [(NSString *)string length]==0 || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0;
}

+ (BOOL)isValidEmailString:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z0-9]{1,25}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isIncludeSpecialCharacterString:(NSString *)string {
    
    NSRange validRange = [string rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€"]];
    if (validRange.location == NSNotFound) {
        return NO;
    }
    return YES;
}

// 地址限制
+ (BOOL)streetAddressIsIncludeSpecialCharacterString:(NSString *)string {
    NSRange validRange = [string rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"!@$%^&*"]];
    if (validRange.location == NSNotFound) {
        return NO;
    }
    return YES;
}

// 省份限制
+ (BOOL)stateAddressIsIncludeSpecialCharacterString:(NSString *)string {
    NSRange validRange = [string rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"!@$%^"]];
    if (validRange.location == NSNotFound) {
        return NO;
    }
    return YES;
}

// 城市限制
+ (BOOL)cityAddressIsIncludeSpecialCharacterString:(NSString *)string {
    NSRange validRange = [string rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"!@$%^"]];
    if (validRange.location == NSNotFound) {
        return NO;
    }
    return YES;
}

+ (BOOL)isAllNumberCharacterString:(NSString *)string {
    
    NSString *stringRegex = @"^[0-9]*$";
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
    return [stringTest evaluateWithObject:string];
}

+ (BOOL)isAllLetterCharacterString:(NSString *)string {
    
    NSString *stringRegex = @"^[A-Za-z]+$";
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
    return [stringTest evaluateWithObject:string];
}

+ (BOOL)isAllNumberAndLetterCharacterString:(NSString *)string {
    
    NSString *stringRegex = @"^[A-Za-z0-9]+$";
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
    return [stringTest evaluateWithObject:string];
}

+ (NSString *)breakUpTheString:(NSString *)string point:(NSInteger)point {
    NSString *realyString = string;
    NSRange range = [string rangeOfString:@"."];
    if (range.location != NSNotFound) {
        if (point < (string.length - range.location - 1)) {
            realyString = [string substringToIndex:range.location + point + 1];
        };
    }
    return realyString;
}

+ (BOOL)isIncludeBlankCharacter:(NSString *)string {
    NSRange range = [string rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (NSString *)cutLeadAndTrialBlankCharacter:(NSString *)string {
    // 去掉前后一个空格
//    NSMutableString *resultString = [NSMutableString stringWithString:string];
//    if (string.length > 2) {
//        // 第一个 BlankCharacter
//        if ([[resultString substringToIndex:1] isEqualToString:@" "]) {
//            [resultString deleteCharactersInRange:NSMakeRange(0, 1)];
//        }
//        // 最后一个 BlankCharacter
//        if ([[resultString substringFromIndex:resultString.length - 1] isEqualToString:@" "]) {
//            [resultString deleteCharactersInRange:NSMakeRange(resultString.length - 1, 1)];
//        }
//    }
//    return resultString.copy;
    NSString *resultString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; // 去除前后的空格
    return resultString;
}


+ (NSString *)uniqueUUID {
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *str = [[uuid UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return str;
}

/**
 *  获取当前时间的时间戳（例子：1464326536）
 *
 *  @return 时间戳字符串型
 */
+ (NSString *)getCurrentTimestamp
{
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];
    // 转为字符型
    return timeString;
}

+ (NSString *)buildRequestPath:(NSString *)path {
    return path;
}

+ (NSString *)buildCommparam {
    return [NSString stringWithFormat:@"ver=%@",kAppVersion];
}

+ (NSString *)encryptWithDict:(NSDictionary *)dict {
    NSString *jsonStr = [self jsonStringWithDict:dict];//[dict yy_modelToJSONString];
    
    const char *eChar = [DesEncrypt sharedDesEncrypt]->encryptText([jsonStr UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_key] UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_iv] UTF8String]);
    NSString *result = [NSString stringWithCString:eChar encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *)encryptWithStr:(NSString *)string
{
    const char *eChar = [DesEncrypt sharedDesEncrypt]->encryptText([string UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_key] UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_iv] UTF8String]);
    return [NSString stringWithCString:eChar encoding:NSUTF8StringEncoding];
}


+ (id)desEncrypt:(OSSVBasesRequests *)request {
    if (!request) {
        DLog(@"--------------XXXXXX 请求不存在❎");
        return nil;
    }
    id <STLConfigureDomainProtocol> domainModule = [OSSVConfigDomainsManager gainDomainModule:request.domainPath];
    
    if (request.isCacheData) {
        return request.cacheJSONObject;
    }
    
//    if (![domainModule isENC]) return request.responseJSONObject;
    if (![request isNewENC]) return request.responseJSONObject;

    NSString *requestResultString = request.responseString;
    //去掉首尾空字符
    if (!STLIsEmptyString(request.responseString)) {
        requestResultString = [requestResultString replaceBrAndEnterChar];
    }
    //防止返回一句话崩溃如：参数异常
    NSString *responseString = URLENCODING(requestResultString);

    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText([responseString UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_key] UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_iv] UTF8String]);

    if (!dChar) {
        DLog(@"--------------XXXXXX 解析错误❎");
        return  nil;
    }
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    NSError *error;
    NSData *objectData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    return (!json ? nil : json);
}

+(NSString*)desEncryptToString:(OSSVBasesRequests *)request{
    if (!request) {
        DLog(@"--------------XXXXXX 请求不存在❎");
        return nil;
    }
    id <STLConfigureDomainProtocol> domainModule = [OSSVConfigDomainsManager gainDomainModule:request.domainPath];
    
    if (request.isCacheData) {
        return request.cacheJSONObject;
    }
    
//    if (![domainModule isENC]) return request.responseJSONObject;
    if (![request isNewENC]) return request.responseString;

    NSString *requestResultString = request.responseString;
    //去掉首尾空字符
    if (!STLIsEmptyString(request.responseString)) {
        requestResultString = [requestResultString replaceBrAndEnterChar];
    }
    //防止返回一句话崩溃如：参数异常
    NSString *responseString = URLENCODING(requestResultString);

    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText([responseString UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_key] UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_iv] UTF8String]);

    if (!dChar) {
        DLog(@"--------------XXXXXX 解析错误❎");
        return  nil;
    }
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    return result;
}


+ (id)desCacheDataEncrypt:(NSString *)responseString {
    if (!responseString) {
        return nil;
    }
    if (![ISENC boolValue]) return responseString;
    
    //防止返回一句话崩溃如：参数异常
    responseString = URLENCODING(responseString);
    
    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText([responseString UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_key] UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_iv] UTF8String]);
    
    if (!dChar) {
        DLog(@"--------------XXXXXX 解析错误❎");
        return  nil;
    }
    
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    NSError *error;
    NSData *objectData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    return (!json ? nil : json);
}

//没用到
+ (id)desDataEncrypt:(NSString *)responseString {
    
    if (!responseString) {
        return nil;
    }
    const char *c = [responseString UTF8String];
    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText(c,[[OSSVLocaslHosstManager appDesEncrypt_key] UTF8String],[[OSSVLocaslHosstManager appDesEncrypt_iv] UTF8String]);
    if (!dChar) {
        DLog(@"--------------XXXXXX 解析错误❎");
        return  nil;
    }
    
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    NSError *error;
    NSData *objectData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    return (!json ? nil : json);
}

+ (NSString*)timeLapse:(NSInteger)time
{
    NSInteger curTime = [[NSDate date] timeIntervalSince1970];
    NSInteger distance = curTime - time;
    
    NSInteger value       = 0;
    NSString *tag   = (distance<0) ? STLLocalizedString_(@"later", nil) : STLLocalizedString_(@"ago", nil) ;
    NSString *unit  = @"";
    
    distance = labs(distance);
    
    if(distance < sec_per_min)
    {
        value = (NSInteger)distance;
        unit = value >1 ? STLLocalizedString_(@"seconds", nil) : STLLocalizedString_(@"second", nil);
    }else if(distance < sec_per_hour)
    {
        value = (NSInteger)distance/sec_per_min;
        unit = value>1 ? STLLocalizedString_(@"minutes", nil) : STLLocalizedString_(@"minute", nil);
    }else if (distance < sec_per_day)
    {
        value = (NSInteger)distance/sec_per_hour;
        unit = value>1 ? STLLocalizedString_(@"hours", nil) : STLLocalizedString_(@"hour", nil);
    }else if (distance < sec_per_month){
        value = (NSInteger)distance/sec_per_day;
        unit = value>1 ? STLLocalizedString_(@"days", nil) : STLLocalizedString_(@"day", nil);
    }else if (distance < sec_per_year){
        value = (NSInteger)distance/sec_per_month;
        unit = value>1 ? STLLocalizedString_(@"months", nil) : STLLocalizedString_(@"month", nil);
    }else{
        value = (NSInteger)distance/sec_per_year;
        unit = value>1 ? STLLocalizedString_(@"years", nil) : STLLocalizedString_(@"year", nil);
    }
    
    NSString *strTime;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        strTime = [[[tag stringByAppendingString:@" "] stringByAppendingString:[NSString stringWithFormat:@"%@ ",[@(value) stringValue]]] stringByAppendingString:unit];
    } else {
        strTime = [[[[@(value) stringValue] stringByAppendingString:@" "] stringByAppendingString:unit] stringByAppendingString:tag];
    }
    
    return strTime;
}

+ (NSString *)bannerScreenKeyWithBannerName:(NSString *)name screenName:(NSString *)screenName
{
    return [NSString stringWithFormat:@"%@ - %@",screenName,name];
}

// 取出不同屏幕对应的图片
+(NSString*)retinaDifferentScreenUrlFromUrl:(NSString*)strUrl
{
    if ([strUrl isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    return  strUrl;
    
//    if ([strUrl rangeOfString:@"."].location != NSNotFound) {
//
//        NSString *fileName = @"";
//
//        NSMutableArray *arrTemp = [NSMutableArray array];
//        [arrTemp addObjectsFromArray:[strUrl componentsSeparatedByString:@"."]];
//
//        if (arrTemp.count>1) {
//
//            fileName = arrTemp[arrTemp.count-2];
//
//            int screenHeight = SCREEN_HEIGHT;
//
//            switch (screenHeight) {
//                case 480:  // 4/4S
//                case 960:
//                    fileName = [fileName stringByAppendingString:@"@1"];
//                    break;
//                case 568:  // 5/5S
//                case 1136:
//                    fileName = [fileName stringByAppendingString:@"@2"];
//                    break;
//                case 667:  // 6/6S
//                case 1334:
//                    fileName = [fileName stringByAppendingString:@"@3"];
//                    break;
//                case 736:  // 6+/6S+
//                case 2208:
//                    fileName = [fileName stringByAppendingString:@"@4"];
//                    break;
//                case 812:  // iphoneX
//                    fileName = [fileName stringByAppendingString:@"@5"];
//                    break;
//                default:
//                    break;
//            }
//
//            [arrTemp replaceObjectAtIndex:arrTemp.count-2 withObject:fileName];
//
//            strUrl = [arrTemp componentsJoinedByString:@"."];
//        }
//
//        arrTemp = nil;
//    } else {
//        strUrl = @"";
//        return strUrl;
//    }
//
//    return strUrl;
}

+ (NSString*)jsonStringWithDict:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [OSSVJSONsSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        STLLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

// ===============Appflyer推广参数==============
+ (NSString *)getMediaSource {
    // 当前时间截
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger installTime = [us integerForKey:@"kAPPInstallTimeYS"];
    NSString *str = [us objectForKey:MEDIA_SOURCE];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - installTime > sec_per_month) str = @"";
    return str;
}

+ (NSString *)getCampaign {
    // 当前时间截
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger installTime = [us integerForKey:@"kAPPInstallTimeYS"];
    NSString *str = [us objectForKey:CAMPAIGN];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - installTime > sec_per_month) str = @"";
    return str;
}

+ (NSString *)getLkid {
    // 当前时间截
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger installTime = [us integerForKey:@"kAPPInstallTimeYS"];
    NSString *str = [us objectForKey:LKID];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - installTime > sec_per_month) str = @"";
    return str;
}
// =================================================

// ＝＝＝＝＝＝＝＝＝＝＝＝推送催付参数＝＝＝＝＝＝＝＝＝＝＝＝
+ (NSString *)getPid {
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"pid"];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getPush_id {
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"push_id"];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getPush_campaign {
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"campaign"];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getPush_Channel {
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"channel"];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getC {
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"c"];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getIsRetargeting {
    NSString *currTimeStr = [OSSVNSStringTool getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"is_retargeting"];
    if ([OSSVNSStringTool isEmptyString:str] || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}
// ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝


/// 获取推送token
/// @param data 推送token二进制参数
+ (NSString *)hexadecimalStringFromData:(NSData *)data {
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02.2hhx", dataBuffer[i]];
    }
    return [hexString copy];
}



+ (NSString *)stringMD5:(NSString *)string {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
