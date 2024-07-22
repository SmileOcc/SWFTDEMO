//
//  NSStringUtils.m
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "NSStringUtils.h"
#import "DesEncrypt.h"
#import <CommonCrypto/CommonCrypto.h>
#import "Configuration.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation NSStringUtils

+ (NSString *)trimmingStartEndWhitespace:(id)string {
    if ([string isKindOfClass:[NSString class]]) {
        return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return @"";
}

+ (BOOL)isEmptyString:(id)string {
    return string==nil || string==[NSNull null] || ![string isKindOfClass:[NSString class]] || [(NSString *)string length] == 0;
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)isEmptyString:(id)string withReplaceString:(NSString *)replaceString {
    if ([self isEmptyString:string]) {
        return [self isEmptyString:replaceString] ? @"" : replaceString;
    } else {
        return string;
    }
}

+ (BOOL)isValidEmailString:(NSString *)email {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
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


/**
 至少8位数字和字母组成
 */
+(BOOL)checkPassWord:(NSString *)password
{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,100}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
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

/**
 * 限制只能输入指定的字符串
 */
+(BOOL)validateParamter:(NSString *)paramter AdCodeString:(NSString *)codeString {
    if (!paramter.length ||!codeString.length) return YES;
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:codeString];
    int i = 0;
    while (i < paramter.length) {
        NSString * string = [paramter substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
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

+ (NSString *)emptyStringReplaceNSNull:(id)string {
    if ([self isEmptyString:string]) {
        return @"";
    }else{
        return string;
    }
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
+ (NSString *)getCurrentTimestamp {
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];
    // 转为字符型
    return timeString;
}
/**
 *  获取当前时间的时间戳（毫秒级别)
 *
 *  @return 时间戳字符串型
 */
+ (NSString *)getCurrentMSimestamp {
    //获取系统当前的时间戳
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];
    // 转为字符型
    return timeString;
}

+ (NSString *)getStringDateFormatter:(NSString *)formatter timestamp:(NSString *)timestamp {
    
    if (ZFIsEmptyString(timestamp)) {
        return @"";
    }
    if (ZFIsEmptyString(formatter)) {
        formatter = @"MMM.dd,yyyy";
    }
    
    NSTimeInterval time=[timestamp doubleValue];//传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //定义fmt
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
    //设置格式:
    fmt.dateFormat=@"yyyy/MM/dd";

    //得到字符串格式的时间
    NSString *dateString=[fmt stringFromDate:detailDate];
    return dateString;
}


/**
 获取当前时间的前、后天的时间戳

 @param nDay 负数：前n天，正数：后n天
 @return 时间戳字符串型
 */
+ (NSString *)getCurrentTimestampSinceDay:(NSInteger)nDay {
    
    NSDate*nowDate = [NSDate date];
    NSDate* theDate;
    
    if(nDay != 0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [nowDate initWithTimeIntervalSinceNow: oneDay * nDay];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
    }else{
        theDate = nowDate;
    }
    
    //获取系统当前的时间戳
    NSTimeInterval a=[theDate timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];
    return timeString;
}

+ (NSString *)buildRequestPath:(NSString *)path {
    
    return [NSString stringWithFormat:@"%@?isenc=%@",path,ISENC];
}

+ (NSString *)buildCommparam {
    return [NSString stringWithFormat:@"ver=%@&pf=ios",ZFSYSTEM_VERSION];
}

+ (NSString *)encryptWithDict:(NSDictionary *)dict {
    
    NSString *jsonStr =  [dict yy_modelToJSONString];//
    
    if (ZFIsEmptyString(jsonStr)) {
        return @"";
    }
    
    const char *eChar = [DesEncrypt sharedDesEncrypt]->encryptText([jsonStr UTF8String],[kDesEncrypt_key UTF8String],[kDesEncrypt_iv UTF8String]);
    
    if (!eChar) {
        return @"";
    }
    
    return [NSString stringWithCString:eChar encoding:NSUTF8StringEncoding];
}

+ (NSString *)encryptWithStr:(NSString *)string {
    if (ZFIsEmptyString(string)) {
        return @"";
    }
    const char *eChar = [DesEncrypt sharedDesEncrypt]->encryptText([string UTF8String],[kDesEncrypt_key UTF8String],[kDesEncrypt_iv UTF8String]);
    if (!eChar) {
        return @"";
    }
    return [NSString stringWithCString:eChar encoding:NSUTF8StringEncoding];
}

+ (id)desEncrypt:(SYBaseRequest *)request api:(NSString *)api {
    if (!request) {
        return nil;
    }
    
    if (![ISENC boolValue] || !request.encryption) {
#if DEBUG
         NSString *jsonString = @"❌❌❌数据异常❌❌❌";
        if (request.responseJSONObject) {
            if ([api containsString:@"ZFAddressLibraryApi"]) {
                
                jsonString = @"国家地址库数据，太大了";
            } else {
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request.responseJSONObject
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];
                
                if (jsonData) {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:(NSUTF8StringEncoding)];
                }
            }
        }
        YWLog(@"\n--Request result ---\n Api:%@\n接口返回的Json:%@\n ", api, jsonString);
#endif
        return request.responseJSONObject;
    }
    
    if (ZFIsEmptyString(request.responseString)) {
        return nil;
    }
    
    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText([request.responseString UTF8String],[kDesEncrypt_key UTF8String],[kDesEncrypt_iv UTF8String]);
    
    if (!dChar) {
        return nil;
    }
    
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    NSError *error;
    NSData *objectData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];

    YWLog(@"\n-------------------------- Request result --------------------------\n %@ :\n返回的Json %@", api, json);
    
    return (!json ? nil : json);
}

+ (id)desEncrypt:(SYBaseRequest *)request {
    if (!request) {
        YWLog(@"--------------XXXXXX 请求不存在❎");
        return nil;
    }
    
    if (![ISENC boolValue] && !request.encryption) return request.responseJSONObject;
    
    if (ZFIsEmptyString(request.responseString)) {
        return nil;
    }
    
    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText([request.responseString UTF8String],[kDesEncrypt_key UTF8String],[kDesEncrypt_iv UTF8String]);
    
    if (!dChar) {
        return nil;
    }
    
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    NSError *error;
    NSData *objectData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", request.requestURLString, json);
    
    return (!json ? nil : json);
}

+ (id)desEncryptWithString:(NSString *)str {
    if (![ISENC boolValue]) return str;
    
    if (ZFIsEmptyString(str)) {
        return nil;
    }
    
    const char *dChar = [DesEncrypt sharedDesEncrypt]->decryptText([str UTF8String],[kDesEncrypt_key UTF8String],[kDesEncrypt_iv UTF8String]);
    
    if (!dChar) {
        return nil;
    }
    
    NSString *result = [NSString stringWithUTF8String:dChar];
    
    NSError *error;
    NSData *objectData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    return (!json ? nil : json);
}

+ (NSString*)timeLapse:(NSInteger)time {
    NSInteger curTime = [[NSDate date] timeIntervalSince1970];
    NSInteger distance = curTime - time;
    
    NSInteger value       = 0;
    NSString *tag   = (distance<0) ? [NSString stringWithFormat:@" %@",ZFLocalizedString(@"TimeLapse_Later",nil)] : [NSString stringWithFormat:@" %@",ZFLocalizedString(@"TimeLapse_Ago",nil)] ;
    NSString *unit  = @"";
    
    distance = labs(distance);
    
    if(distance < sec_per_min)
    {
        value = (NSInteger)distance;
        unit = value >1 ? ZFLocalizedString(@"TimeLapse_Secs",nil) : ZFLocalizedString(@"TimeLapse_Sec",nil);
    }else if(distance < sec_per_hour)
    {
        value = (NSInteger)distance/sec_per_min;
        unit = value>1 ? ZFLocalizedString(@"TimeLapse_Mins",nil) : ZFLocalizedString(@"TimeLapse_Min",nil);
    }else if (distance < sec_per_day)
    {
        value = (NSInteger)distance/sec_per_hour;
        unit = value>1 ? ZFLocalizedString(@"TimeLapse_Hours",nil) : ZFLocalizedString(@"TimeLapse_Hour",nil);
    }else if (distance < sec_per_month){
        value = (NSInteger)distance/sec_per_day;
        unit = value>1 ? ZFLocalizedString(@"TimeLapse_Days",nil) : ZFLocalizedString(@"TimeLapse_Day",nil);
    }else if (distance < sec_per_year){
        value = (NSInteger)distance/sec_per_month;
        unit = value>1 ? ZFLocalizedString(@"TimeLapse_Months",nil) : ZFLocalizedString(@"TimeLapse_Month",nil);
    }else{
        value = (NSInteger)distance/sec_per_year;
        unit = value>1 ? ZFLocalizedString(@"TimeLapse_Years",nil) : ZFLocalizedString(@"TimeLapse_Year",nil);
    }
    
    NSString *strTime = [[[[@(value) stringValue] stringByAppendingString:@" "] stringByAppendingString:unit] stringByAppendingString:tag];
    
    return strTime;
}

// Branch广告参数
+ (NSString *)getBranchParamsWithKey:(NSString *)key {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    if (!branchParams || ![branchParams isKindOfClass:[NSDictionary class]]) return @"";
    NSString *str = branchParams[key];
    NSString *currTimeStr = [self getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSInteger saveTime = [branchParams[BRANCH_PARAMS_TIME] integerValue];
    if ([self isEmptyString:str] || currTime - saveTime > sec_per_month) {
        str = @"";
    };
    return str;
}

// AF广告参数
+ (NSString *)getAppsflyerParamsWithKey:(NSString *)key {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *afParams = [us objectForKey:APPFLYER_PARAMS];
    if (!afParams && ![afParams isKindOfClass:[NSDictionary class]]) return @"";
    NSString *str = afParams[key];
    if ([self isEmptyString:str])  str = @"";
    return str;
}

+ (NSString *)getAdId {
    // 当前时间截
    NSString *currTimeStr = [self getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSInteger installTime = [[NSUserDefaults standardUserDefaults] integerForKey:kAPPInstallTime];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSString *str = [us objectForKey:ADID];
    if ([self isEmptyString:str] || currTime - installTime > sec_per_month) str = @"";
    return str;
}

// ＝＝＝＝＝＝＝＝＝＝＝＝综合广告参数＝＝＝＝＝＝＝＝＝＝＝＝
+ (NSString *)getLkid {
    NSString *linkid = @"";
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    // af与branch广告参数只存其中一个（只存最后进来的渠道）
    if (branchParams && [branchParams isKindOfClass:[NSDictionary class]]) {
        linkid = [self getBranchParamsWithKey:BRANCH_LINKID];
    } else {
        linkid = [self getAppsflyerParamsWithKey:LKID];
    }
    return linkid;
}

+ (NSString *)getUtmSource {
    NSString *utmSource = @"";
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    // af与branch广告参数只存其中一个（只存最后进来的渠道）
    if (branchParams && [branchParams isKindOfClass:[NSDictionary class]]) {
        utmSource = [self getBranchParamsWithKey:UTM_SOURCE];
    } else {
        utmSource = [self getAppsflyerParamsWithKey:MEDIA_SOURCE];
    }
    return utmSource;
}

+ (NSString *)getUtmCampaign {
    NSString *utmCampaign = @"";
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    // af与branch广告参数只存其中一个（只存最后进来的渠道）
    if (branchParams && [branchParams isKindOfClass:[NSDictionary class]]) {
        utmCampaign = [self getBranchParamsWithKey:UTM_CAMPAIGN];
    } else {
        utmCampaign = [self getAppsflyerParamsWithKey:CAMPAIGN];
    }
    return utmCampaign;
}

+ (NSString *)getUtmMedium {
    NSString *utmMedium = @"";
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    // af与branch广告参数只存其中一个（只存最后进来的渠道）
    if (branchParams && [branchParams isKindOfClass:[NSDictionary class]]) {
        utmMedium = [self getBranchParamsWithKey:UTM_MEDIUM];
    }
    return utmMedium;
}

+ (NSString *)getPostbackId {
    NSString *postbackId = @"";
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    // af与branch广告参数只存其中一个（只存最后进来的渠道）
    if (branchParams && [branchParams isKindOfClass:[NSDictionary class]]) {
        postbackId = [self getBranchParamsWithKey:POSTBACK_ID];
    }
    return postbackId;
}

+ (NSString *)getAffMssInfo {
    NSString *affMssInfo = @"";
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSDictionary *branchParams = [us objectForKey:BRANCH_PARAMS];
    // af与branch广告参数只存其中一个（只存最后进来的渠道）
    if (branchParams && [branchParams isKindOfClass:[NSDictionary class]]) {
        affMssInfo = [self getBranchParamsWithKey:AFF_MSS_INFO];
    }
    return affMssInfo;
}

// ＝＝＝＝＝＝＝＝＝＝＝＝推送催付参数＝＝＝＝＝＝＝＝＝＝＝＝
+ (NSString *)getPid {
    // 当前时间截
    NSString *currTimeStr = [NSStringUtils getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"pid"];
    if (ZFIsEmptyString(str) || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getC {
    // 当前时间截
    NSString *currTimeStr = [NSStringUtils getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"c"];
    if (ZFIsEmptyString(str) || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}

+ (NSString *)getIsRetargeting {
    // 当前时间截
    NSString *currTimeStr = [NSStringUtils getCurrentTimestamp];
    NSInteger currTime = [currTimeStr integerValue];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSInteger saveTime = [us integerForKey:SAVE_NOTIFICATIONS_PARMATERS_TIME];
    NSDictionary *notificationsParmaters = [us objectForKey:NOTIFICATIONS_PAYMENT_PARMATERS];
    NSString *str = notificationsParmaters[@"is_retargeting"];
    if (ZFIsEmptyString(str) || currTime - saveTime > sec_per_day*3) str = @"";
    return str;
}
// ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

+ (NSString *)ZFNSStringMD5:(NSString *)string {
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

//正则匹配
+ (NSArray <NSValue *> *)matchString:(NSString *)string reg:(NSString *)regString matchOptions:(NSMatchingOptions)matchOptions
{
    if (!ZFToString(string).length) {
        return nil;
    }
    
    if (ZFIsEmptyString(regString)) {
        regString = RegularExpression;
    }
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regString options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray <NSTextCheckingResult *>*textCheck = [pattern matchesInString:string options:matchOptions range:NSMakeRange(0, string.length)];
    [textCheck enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSValue *rangeValue = [NSValue valueWithRange:obj.range];
        [values addObject:rangeValue];
    }];
    return values;
}


+ (NSInteger )mixChineseEnglishLength:(NSString *)string {
    
    if ([self isEmptyString:string]) {
        return 0;
    }
    
    int strlength = 0;
    char* p = (char*)[string cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[string lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

+ (NSString *)formatKMString:(NSString *)string {
    NSInteger count = [string integerValue];
    if (count >= 100000) {
        return [NSString stringWithFormat:@"%ldM",count / 10000];
    } else if(count >= 10000) {
        return [NSString stringWithFormat:@"%ldK",count / 1000];
    }
    return [NSString stringWithFormat:@"%ld",count];
}

+ (BOOL)matchNewPCCNum:(NSString *)pccText regex:(NSString *)regex {
    
    if (ZFIsEmptyString(pccText)) {
        return NO;
    }
    if (ZFIsEmptyString(regex)) {
        return YES;
    }
    
    BOOL result = NO;
    
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [stringTest evaluateWithObject:pccText];

    return result;
}

+ (BOOL)matchPriceMorethanZero:(NSString *)targetStr
{
    if (ZFIsEmptyString(targetStr)) {
        return NO;
    }
    BOOL result = NO;
    NSString *stringRegex = @"[1-9]";
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:stringRegex options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray <NSTextCheckingResult *>*textCheck = [pattern matchesInString:targetStr options:NSMatchingReportProgress range:NSMakeRange(0, targetStr.length)];
    [textCheck enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSValue *rangeValue = [NSValue valueWithRange:obj.range];
        [values addObject:rangeValue];
    }];
    if ([values count]) {
        result = YES;
    }
    return result;
}

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


+ (NSString *)firstCharactersCapitalized:(NSString *)string {
    if (ZFIsEmptyString(string)) {
        return @"";
    }
    
    string = [string lowercaseString];
    NSString *resultStr = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]];
    return resultStr;
}

+ (NSRange)rangeSpecailString:(NSString *)sourceString specialString:(NSString *)specialString {
    
    NSRange range = NSMakeRange(NSNotFound, 0);
    if (!ZFIsEmptyString(sourceString) && !ZFIsEmptyString(specialString)) {
        range = [sourceString rangeOfString:specialString];
//        if (range.location != NSNotFound) {
//        }
    } else {
        range = NSMakeRange(NSNotFound, 0);
    }
    return range;
}

/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */

+ (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
    int location = 0;
    NSMutableArray *locationArr = [NSMutableArray new];
    NSRange range = [content rangeOfString:tab];
    if (range.location == NSNotFound){
        return locationArr;
    }
    //声明一个临时字符串,记录截取之后的字符串
    NSString * subStr = content;
    while (range.location != NSNotFound) {
        if (location == 0) {
            location += range.location;
        } else {
            location += range.location + tab.length;
        }
        
        //记录位置
        NSNumber *number = [NSNumber numberWithUnsignedInteger:location];
        NSDictionary *dic = @{@"location":@(location),@"length":@(tab.length)};
        
        [locationArr addObject:dic];
        //每次记录之后,把找到的字串截取掉
        subStr = [subStr substringFromIndex:range.location + range.length];
        NSLog(@"subStr %@",subStr);
        range = [subStr rangeOfString:tab];
        NSLog(@"rang %@",NSStringFromRange(range));
    }
    return locationArr;
}

//获取这个字符串中的所有xxx的所在的index

+ (NSMutableArray *)getRangeStr:(NSString *)text findText:(NSString *)findText

{

    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:20];

    if (findText == nil && [findText isEqualToString:@""]) {

        return nil;

    }

    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range

    if (rang.location != NSNotFound && rang.length != 0) {

        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中

        NSRange rang1 = {0,0};

        NSInteger location = 0;

        NSInteger length = 0;

        for (int i = 0;; i++)

        {

            if (0 == i) {//去掉这个xxx

                location = rang.location + rang.length;

                length = text.length - rang.location - rang.length;

                rang1 = NSMakeRange(location, length);

            }else

            {

                location = rang1.location + rang1.length;

                length = text.length - rang1.location - rang1.length;

                rang1 = NSMakeRange(location, length);

            }

            //在一个range范围内查找另一个字符串的range

            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];

            if (rang1.location == NSNotFound && rang1.length == 0) {

                break;

            }else//添加符合条件的location进数组

                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];

        }

        return arrayRanges;

    }

    return nil;

}

+ (NSMutableAttributedString *)firstAppendStartMark:(NSString *)text markColor:(UIColor *)color isAppend:(BOOL)isAppend {
    
    NSString *starMark = @"*";
    NSString *titleName = @"";
    if (isAppend) {
        titleName = [NSString stringWithFormat:@"%@%@",starMark,ZFToString(text)];
    } else {
        titleName = ZFToString(text);
    }
    
    NSRange range = NSMakeRange(NSNotFound, 0);
    if ([titleName hasPrefix:starMark]) {
        range = NSMakeRange(0, 1);
    }
    NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:titleName];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    [attriTitle addAttribute:NSParagraphStyleAttributeName value:paragraph range:range];
    [attriTitle addAttributes:@{NSForegroundColorAttributeName : color ? color : [UIColor blackColor]} range:range];
    return attriTitle;
}
@end
