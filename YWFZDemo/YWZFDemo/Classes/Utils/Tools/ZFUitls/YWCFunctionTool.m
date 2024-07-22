//
//  YWCFunctionTool.m
//  IntegrationDemo
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 mao wangxin. All rights reserved.
//

#import "YWCFunctionTool.h"
#import "YWLocalHostManager.h"
#import <UIKit/UIKit.h>
#import "Constants.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation YWCFunctionTool

NSHTTPCookie *globaleZZZZZHTTPCookie(void) {
    NSHTTPCookie *ZZZZZ_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                     NSHTTPCookieName:@"staging",
                                                                     NSHTTPCookieValue:@"true",
                                                                     NSHTTPCookieDomain:@".ZZZZZ.com",
                                                                     NSHTTPCookiePath:@"/",
                                                                     }];
    return ZZZZZ_cookie;
}

NSHTTPCookie *communityZZZZZHTTPCookie(void) {
    NSHTTPCookie *community_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                            NSHTTPCookieName:@"staging",
                                                                            NSHTTPCookieValue:@"true",
                                                                            NSHTTPCookieDomain:@".gloapi.com",
                                                                            NSHTTPCookiePath:@"/",
                                                                            }];
    return community_cookie;
}

NSHTTPCookie *cmsHTTPCookie(void) {
    NSHTTPCookie *cms_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                            NSHTTPCookieName:@"staging",
                                                                            NSHTTPCookieValue:@"true",
                                                                            NSHTTPCookieDomain:@"cms.glosop.com",
                                                                            NSHTTPCookiePath:@"/",
                                                                            }];
    return cms_cookie;
}

NSHTTPCookie *geshopHTTPCookie(void) {
    NSHTTPCookie *cms_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                            NSHTTPCookieName:@"staging",
                                                                            NSHTTPCookieValue:@"true",
                                                                            NSHTTPCookieDomain:@".hqgeshop.com",
                                                                            NSHTTPCookiePath:@"/",
                                                                            }];
    return cms_cookie;
}

NSHTTPCookie *communityZZZZZLiveHTTPCookie(void) {
    NSHTTPCookie *cms_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                            NSHTTPCookieName:@"staging",
                                                                            NSHTTPCookieValue:@"true",
                                                                            NSHTTPCookieDomain:@".miyanws.com",
                                                                            NSHTTPCookiePath:@"/",
                                                                            }];
    return cms_cookie;
}


/**
 *  添加cookie
 */
void addZZZZZCookie(void) {
    // 网站的cookie
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [storage setCookie:globaleZZZZZHTTPCookie()];
    
    // CMS的cookie
    [storage setCookie:cmsHTTPCookie()];
    
    // 社区的cookie
    [storage setCookie:communityZZZZZHTTPCookie()];
    
    // 社区直播的cookie
    [storage setCookie:communityZZZZZLiveHTTPCookie()];
    
    // Geshop(新原生专题)的cookie
    [storage setCookie:geshopHTTPCookie()];
}

/**
 * 删除cookie
 */
void deleteZZZZZCookie(void) {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

/**
 * 在部分机器上发现全屏播放完视频后会出现状态栏显示的bug by: YW
 */
void showSystemStatusBar(void) {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:animated:)]) {
        [application setStatusBarHidden:NO animated:NO];
    }
}

/**
 * 隐藏状态栏显示
 */
void hideSystemStatusBar(void) {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:animated:)]) {
        [application setStatusBarHidden:YES animated:YES];
    }
}

/**
 * 仅供测试时使用:测试国家IP Cookie
 */
void addCountryIPCookie(void) {
    
    if (![YWLocalHostManager isOnlineRelease]) {
        NSString *inputCountryIP = GetUserDefault(kInputCountryIPKey);
        if (!ZFIsEmptyString(inputCountryIP)) {
            
            NSString *domainStr = @".egomsl.com";
            if ([YWLocalHostManager isPreRelease]) {
                domainStr = @".ZZZZZ.com";
            }
            
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSHTTPCookie *ZZZZZ_cookie = [[NSHTTPCookie alloc] initWithProperties:@{ NSHTTPCookieName:@"test_region_code",
                                      NSHTTPCookieValue:inputCountryIP,
                                      NSHTTPCookieDomain:domainStr,
                                      NSHTTPCookiePath:@"/",}];
            [storage setCookie:ZZZZZ_cookie];
        }
    }
}

/**
 App统一获取图片方法, 既能简化代码,又能便于以后统一处理图片 (例如:添加水印等)

 @param name 图片名
 @return 获取的图片
 */
UIImage* ZFImageWithName(NSString *name){
    UIImage *getImage = nil;
    if (ZFJudgeNSString(name)) {
        getImage = [UIImage imageNamed:name];
        
        //不存在再则去.bundle取图片
//        if(!getImage) {
//            getImage = ZFImageFromBundleWithName(name);
//        }
    }
    return getImage;
}

/**
 获取bundle中的图片
 
 @param name 图片名字
 @return 图片
 */
UIImage* ZFImageFromBundleWithName(NSString *name)
{
    if (![name isKindOfClass:[NSString class]] || name.length==0) return nil;
    
    UIImage *getImage = [UIImage imageNamed:name];
    if (getImage) {
        return getImage;
    }
    
    //获取 mainBundle 所有的 bundle 文件夹
    NSArray *bundleArr = [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle" inDirectory:nil];
    
    //排除第三方的bundle目录
    NSMutableArray *allBundleArr = [NSMutableArray arrayWithArray:bundleArr];
    if (allBundleArr.count>0) {
        NSString *bundlePrefix = [allBundleArr[0] lastPathComponent];
        
        NSArray *bundleNameArr = @[@"IQKeyboardManager.bundle",
                                   @"XLForm.bundle",
                                   @"PYSearch.bundle",
                                   @"MJRefresh.bundle",
                                   @"FacebookSDKStrings.bundle",
#pragma mark - occ修改：----------3.8.0 暂时去掉，不使用地图--------
                                   //@"GoogleMaps.bundle",
                                   @"GoogleSignIn.bundle",
                                   @"TZImagePickerController.bundle"];
        for (NSString *bundleName in bundleNameArr) {
            NSString *removerPath = [NSString stringWithFormat:@"%@/%@",bundlePrefix,bundleName];
            [allBundleArr removeObject:removerPath];
        }
    }
    
    //去自己的bundle下取图片
    for (NSString *bundlePath in allBundleArr) {
        getImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",bundlePath,name] inBundle:[NSBundle bundleForClass:NSClassFromString(@"YWCFunctionTool")] compatibleWithTraitCollection:nil];
        if (getImage) {
            return getImage;
        }
        
        //遍历目录文件夹
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *folderArray = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];
        BOOL isDir = NO;
        
        for (NSString *subFolder in folderArray) {
            NSString *fullPath = [bundlePath stringByAppendingPathComponent:subFolder];
            [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
            
            //文件夹
            if (isDir) {
                getImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@/%@",bundlePath,subFolder,name] inBundle:[NSBundle bundleForClass:NSClassFromString(@"YWCFunctionTool")] compatibleWithTraitCollection:nil];
                if (getImage) {
                    return getImage;
                }
            }
        }
    }
    return getImage;
}

NSString *getLaunchImageName(void) {
    // 在V5.1.0后项目的启动图是用xib做的,因此返回一张默认的启动图
    return @"app_launch";
    
/** V5.1.0之前的方式获取启动图
    NSString *viewOrientation = @"Portrait";
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewOrientation = @"Landscape";
    }
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    
    UIWindow *currentWindow = [[UIApplication sharedApplication].windows firstObject];
    CGSize viewSize = currentWindow.bounds.size;
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
*/
}

/**
 *  产生随机颜色
 */
UIColor* ZFRandomColor(void)
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

/**
 *  获取应用使用语音
 */
NSString* ZFUserLanguage(void)
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *language = [def valueForKey:@"userLanguage"];
    return language;
}

/**
 * 设置应用使用语音
 */
void ZFSetUserlanguage(NSString *language)
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //2.持久化
    [def setValue:language forKey:@"userLanguage"];
    [def synchronize];
}

/**
 * 震动反馈1: (3DTouch中的peek)
 * (1521: peek震动, 1520:pop震动, 1521:三连震)
 * 优点:能满足大部分震动场景, (使用时倒入头文件: #import <AudioToolbox/AudioToolbox.h> )
 * 缺点:无法精准控制震动力度
 */
void ZFPlaySystemQuake(void) {
    AudioServicesPlaySystemSound(1519);
}

/**
 * 震动反馈力度:
 * 轻微:UIImpactFeedbackStyleLight,
 * 适中:UIImpactFeedbackStyleMedium,
 * 强震:UIImpactFeedbackStyleHeavy
 * 优点:能精准控制震动力度
 * 缺点:iOS10及以上系统使用
 */
void ZFPlayImpactFeedback(UIImpactFeedbackStyle Style) {
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 10.0) {
        if (Style > 2 && systemVersion < 13.0) return;
        
        UIImpactFeedbackGenerator *impactFeedBack = [[UIImpactFeedbackGenerator alloc] initWithStyle:Style];
        [impactFeedBack prepare];
        [impactFeedBack impactOccurred];
    }
}


#pragma mark -===========字符串、对象的一些安全操作===========

/**
 * 判断是否为NSString
 */
BOOL ZFJudgeNSString(id obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

/**
 * 判断是否为NSDictionary
 */
BOOL ZFJudgeNSDictionary(id obj) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}

/**
 * 判断是否为NSArray
 */
BOOL ZFJudgeNSArray(id obj) {
    if ([obj isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}

/**
 * 判断字符串是否为空
 */
BOOL ZFIsEmptyString(id obj) {
    
    if (![obj isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if (obj == nil || obj == NULL) {
        return YES;
    }
    if ([obj isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    
    NSString *emptyString = (NSString *)obj;
    if ([emptyString.lowercaseString isEqualToString:@"null"]) {
        return YES;
    }
    
    return NO;
}

/**
 *  转化为NSString来返回，如果为数组或字典转为String返回, 其他对象则返回@""
 *  适用于取一个值后赋值给文本显示时用
 */
NSString * ZFToString(id obj) {
    if (!obj) return @"";
    
    if (ZFJudgeNSString(obj)) {
        return obj;
    }
    
    if (ZFJudgeNSDictionary(obj) || ZFJudgeNSArray(obj)) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];        
        if (jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:(NSUTF8StringEncoding)];
        }
    }
    
    if (![obj isKindOfClass:[NSNull class]] &&
        ![obj isEqual:nil] &&
        ![obj isEqual:[NSNull null]]) {
        NSString *result = [NSString stringWithFormat:@"%@",obj];
        if (result && result.length > 0) {
            return result;
        }
    }
    return @"";
}


/**
 * 判断是否为自定义对象类
 */
BOOL ZFJudgeClass(id obj, NSString *classString) {
    if (ZFJudgeNSString(classString)) {
        Class myClass = NSClassFromString(classString);
        if (myClass) {
            return [obj isKindOfClass:myClass] ? YES : NO;
        }
    }
    return NO;
}

/**
 * 从数组中获取对象
 */
id ZFGetObjFromArray(NSArray *array, NSInteger index) {
    if (ZFJudgeNSArray(array)) {
        if (array.count > index) {
            return array[index];
        }
    }
    return nil;
}

/**
 * 从字典中获取NSString
 */
NSString * ZFGetStringFromDict(NSDictionary *dictionary, NSString *key) {
    if (ZFJudgeNSDictionary(dictionary) && ZFJudgeNSString(key)) {
        id obj = dictionary[key];
        return ZFToString(obj);
    }
    return @"";
}

NSString *ZFgrowingToString(id obj){
    if (!obj) return @"nil";
    
    if (ZFJudgeNSString(obj)) {
        if ([obj isEqualToString:@""]) {
            return @"nil";
        }
        return obj;
    }
    
    if (ZFJudgeNSDictionary(obj) || ZFJudgeNSArray(obj)) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        if (jsonData) {
            return [[NSString alloc] initWithData:jsonData encoding:(NSUTF8StringEncoding)];
        }
    }
    
    if (![obj isKindOfClass:[NSNull class]] &&
        ![obj isEqual:nil] &&
        ![obj isEqual:[NSNull null]]) {
        NSString *result = [NSString stringWithFormat:@"%@",obj];
        if (result && result.length > 0) {
            return result;
        }
    }
    return @"nil";
}

/**
 *  字符串编码
 */
NSString *ZFEscapeString(NSString *str, BOOL allowReserved)
{
    NSMutableCharacterSet *cs = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    NSString * const kReservedChars = @":/?#[]@!$&'()*+,;=";
    if (allowReserved) {
        [cs addCharactersInString:kReservedChars];
    } else {
        [cs removeCharactersInString:kReservedChars];
    }
    NSString *resultStr = [str stringByAddingPercentEncodingWithAllowedCharacters:cs];
    return resultStr;
}

/**
 *  字符串解码
 */
NSString *ZFUnescapeString(NSString *str)
{
    return [str stringByRemovingPercentEncoding];
}

BOOL ZF_COMMUNITY_RESPONSE_TEST_FLAG(void) {
    #ifdef DEBUG
        return NO;
    #endif
        return NO;
}
NSDictionary *ZF_COMMUNITY_RESPONSE_TEST(void) {
    return  @{@"code":@(0),@"statusCode":@(200),@"msg":@"Success",@"errors":@"",@"data":@[],@"staging":@(0)};
}
@end

