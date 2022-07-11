//
//  STLCFunctionTool.m
//  IntegrationDemo
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLCFunctionTool.h"

@implementation STLCFunctionTool

NSHTTPCookie * globaleSTLLinkHTTPCookie(void) {
    NSHTTPCookie *stlink_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                     NSHTTPCookieName:@"starlink",
                                                                     NSHTTPCookieValue:@"always",
                                                                     NSHTTPCookieDomain:@".xxxx.net",
                                                                     NSHTTPCookiePath:@"/",
                                                                     }];
    return stlink_cookie;
}

NSHTTPCookie *communitySTLLinkHTTPCookie(void) {
    NSHTTPCookie *community_cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                                            NSHTTPCookieName:@"starlink",
                                                                            NSHTTPCookieValue:@"always",
                                                                            NSHTTPCookieDomain:@".xxxxx.net",
                                                                            NSHTTPCookiePath:@"/",
                                                                            }];
    return community_cookie;
}



/**
 *  添加cookie  预发布
 */
void addSTLLinkCookie(void) {
    
    ///不用cookie
//    NSString *domaniString = [STLWebsitesGroupManager currentCountrySiteDomain];
//    if (!STLIsEmptyString(domaniString)) {
//
//        NSURL *webUrl = [NSURL URLWithString:domaniString];
//
//        NSString *domani = [NSString stringWithFormat:@".%@",webUrl.host];
//        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//
//        NSHTTPCookie *stlink_cookie1 = [[NSHTTPCookie alloc] initWithProperties:@{
//            NSHTTPCookieName:@"onesite",
//            NSHTTPCookieValue:@"true",
//            NSHTTPCookieDomain:STLToString(domani),
//            NSHTTPCookiePath:@"/",
//        }];
//
//
//        [storage setCookie:stlink_cookie1];
//    }
 
}

/**
 * 删除cookie
 */
void deleteSTLLinkCookie(void) {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
}

void showSystemStatusBar(void) {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:animated:)]) {
        [application setStatusBarHidden:NO animated:NO];
    }
}

/**
 App统一获取图片方法, 既能简化代码,又能便于以后统一处理图片 (例如:添加水印等)

 @param name 图片名
 @return 获取的图片
 */
UIImage* STLImageWithName(NSString *name){
    UIImage *getImage = nil;
    if (STLJudgeNSString(name)) {
        getImage = [UIImage imageNamed:name];
        
        //不存在再则去.bundle取图片
//        if(!getImage) {
//            getImage = STLImageFromBundleWithName(name);
//        }
    }
    return getImage;
}

/**
 获取bundle中的图片
 
 @param name 图片名字
 @return 图片
 */
UIImage* STLImageFromBundleWithName(NSString *name)
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
#pragma mark -----------暂时去掉--------
                                   //@"GoogleMaps.bundle",
                                   @"GoogleSignIn.bundle",
                                   //@"TZImagePickerController.bundle"
        ];
        for (NSString *bundleName in bundleNameArr) {
            NSString *removerPath = [NSString stringWithFormat:@"%@/%@",bundlePrefix,bundleName];
            [allBundleArr removeObject:removerPath];
        }
    }
    
    //去自己的bundle下取图片
    for (NSString *bundlePath in allBundleArr) {
        getImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",bundlePath,name] inBundle:[NSBundle bundleForClass:NSClassFromString(@"STLCFunctionTool")] compatibleWithTraitCollection:nil];
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
                getImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@/%@",bundlePath,subFolder,name] inBundle:[NSBundle bundleForClass:NSClassFromString(@"STLCFunctionTool")] compatibleWithTraitCollection:nil];
                if (getImage) {
                    return getImage;
                }
            }
        }
    }
    return getImage;
}

NSString *getLaunchImageName(void) {
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
}

/**
 *  产生随机颜色
 */
UIColor* STLRandomColor(void)
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

/**
 *  获取应用版本号
 */
NSString* STLCurrentAppVersion(void)
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    if (!version) {
        version = @"IOS_X";
    }
    return version;
}

/**
 *  获取应用使用语音
 */
NSString* STLUserLanguage(void)
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *language = [def valueForKey:@"userLanguage"];
    return language;
}

/**
 * 设置应用使用语音
 */
void STLSetUserlanguage(NSString *language)
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    //2.持久化
    [def setValue:language forKey:@"userLanguage"];
    [def synchronize];
}

#pragma mark -===========字符串、对象的一些安全操作===========

/**
 * 判断是否为NSString
 */
BOOL STLJudgeNSString(id obj) {
    if ([obj isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

/**
 * 判断是否为NSDictionary
 */
BOOL STLJudgeNSDictionary(id obj) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return NO;
}

/**
 * 判断是否为NSArray
 */
BOOL STLJudgeNSArray(id obj) {
    if ([obj isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return NO;
}

BOOL STLJudgeEmptyArray(id obj) {
    if (![obj isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return [(NSArray *)obj count] <= 0;
}

/**
 * 判断字符串是否为空
 */
BOOL STLIsEmptyString(id obj) {
    
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
    return NO;
}

/**
 *  转化为NSString来返回，如果为数组或字典转为String返回, 其他对象则返回@""
 *  适用于取一个值后赋值给文本显示时用
 */
NSString * STLToString(id obj) {
    if (!obj) return @"";
    
    if (STLJudgeNSString(obj)) {
        return obj;
    }
    
    if (STLJudgeNSDictionary(obj) || STLJudgeNSArray(obj)) {
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
BOOL STLJudgeClass(id obj, NSString *classString) {
    if (STLJudgeNSString(classString)) {
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
id STLGetObjFromArray(NSArray *array, NSInteger index) {
    if (STLJudgeNSArray(array)) {
        if (array.count > index) {
            return array[index];
        }
    }
    return nil;
}

/**
 * 从字典中获取NSString
 */
NSString * STLGetStringFromDict(NSDictionary *dictionary, NSString *key) {
    if (STLJudgeNSDictionary(dictionary) && STLJudgeNSString(key)) {
        id obj = dictionary[key];
        return STLToString(obj);
    }
    return @"";
}

NSString *STLgrowingToString(id obj){
    if (!obj) return @"nil";
    
    if (STLJudgeNSString(obj)) {
        if ([obj isEqualToString:@""]) {
            return @"nil";
        }
        return obj;
    }
    
    if (STLJudgeNSDictionary(obj) || STLJudgeNSArray(obj)) {
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

CGFloat STLFloatToLastOne(CGFloat number) {
    CGFloat resutl = [[NSString stringWithFormat:@"%.1f",number] floatValue];
    CGFloat floorFloat = floor(resutl);
    CGFloat tempF = resutl - floorFloat;
    
    resutl = floorFloat;
    if (tempF >= 0.2 && tempF < 0.5) {
        resutl = floorFloat + 0.2;
    } else if(tempF <= 0.999999) {
        resutl = floorFloat + 0.5;
    }
    return resutl;
}

@end

