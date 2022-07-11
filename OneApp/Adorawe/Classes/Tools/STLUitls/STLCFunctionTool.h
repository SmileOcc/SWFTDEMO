//
//  STLCFunctionTool.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STLCFunctionTool : NSObject

/**
 * 全局所有HTTP <.domain.com> Cookie
 */
NSHTTPCookie * globaleSTLLinkHTTPCookie(void);

/**
 *  添加cookie
 */
void addSTLLinkCookie(void);

/**
 * 删除cookie
 */
void deleteSTLLinkCookie(void);

void showSystemStatusBar(void);

/**
 App统一获取图片方法, 既能简化代码,又能便于以后统一处理图片 (例如:添加水印等)
 
 @param name 图片名
 @return 获取的图片
 */
UIImage* STLImageWithName(NSString *name);

/**
 获取bundle中的图片
 
 @param name 图片名字
 @return 图片
 */
UIImage* STLImageFromBundleWithName(NSString *name);

NSString *getLaunchImageName(void);

/**
 *  产生随机颜色
 */
UIColor* STLRandomColor(void);

/**
 *  获取应用版本号
 */
NSString* STLCurrentAppVersion(void);

/**
 *  获取应用使用语音
 */
NSString* STLUserLanguage(void);

/**
 * 设置应用使用语音
 */
void STLSetUserlanguage(NSString *language);


#pragma mark -===========字符串、对象的一些安全操作===========

/**
 * 判断是否为NSString
 */
BOOL STLJudgeNSString(id obj);

/**
 * 判断是否为NSDictionary
 */
BOOL STLJudgeNSDictionary(id obj);

/**
 * 判断是否为NSArray
 */
BOOL STLJudgeNSArray(id obj);

BOOL STLJudgeEmptyArray(id obj);
/**
 * 判断字符串是否为空
 */
BOOL STLIsEmptyString(id obj);

/**
 *  转化为NSString来返回，如果为数组或字典转为json返回, 其他对象则返回@""
 *  适用于取一个值后赋值给文本显示时用
 */
NSString * STLToString(id obj);

/**
 * 判断是否为自定义对象类
 */
BOOL STLJudgeClass(id obj, NSString *classString);

/**
 * 从数组中获取对象
 */
id STLGetObjFromArray(NSArray *array, NSInteger index);

/**
 * 从字典中获取NSString
 */
NSString * STLGetStringFromDict(NSDictionary *dictionary, NSString *key);

NSString * STLgrowingToString(id obj);

CGFloat STLFloatToLastOne(CGFloat number);

@end

