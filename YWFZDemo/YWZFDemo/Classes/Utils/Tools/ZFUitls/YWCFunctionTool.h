//
//  YWCFunctionTool.h
//  IntegrationDemo
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 mao wangxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YWCFunctionTool : NSObject

/**
 * 全局所有HTTP <.ZZZZZ.com> Cookie
 */
NSHTTPCookie * globaleZZZZZHTTPCookie(void);

/**
 *  添加cookie
 */
void addZZZZZCookie(void);

/**
 * 删除cookie
 */
void deleteZZZZZCookie(void);

/**
 * 在部分机器上发现全屏播放完视频后会出现状态栏显示的bug by: YW
 */
void showSystemStatusBar(void);

/**
 * 隐藏状态栏显示
 */
void hideSystemStatusBar(void);

/**
 * 仅供测试时使用:测试国家IP Cookie
 */
void addCountryIPCookie(void);

/**
 App统一获取图片方法, 既能简化代码,又能便于以后统一处理图片 (例如:添加水印等)
 
 @param name 图片名
 @return 获取的图片
 */
UIImage* ZFImageWithName(NSString *name);

/**
 获取bundle中的图片
 
 @param name 图片名字
 @return 图片
 */
UIImage* ZFImageFromBundleWithName(NSString *name);

/**
 获取启动的Launch的图片
 @return 图片
 */
NSString *getLaunchImageName(void);

/**
 *  产生随机颜色
 */
UIColor* ZFRandomColor(void);

/**
 *  获取应用使用语音
 */
NSString* ZFUserLanguage(void);

/**
 * 设置应用使用语音
 */
void ZFSetUserlanguage(NSString *language);

/**
 * 震动反馈: (3DTouch中的peek)
 * 优点:能满足大部分震动场景, (使用时倒入头文件: #import <AudioToolbox/AudioToolbox.h> )
 * 缺点:无法精准控制震动力度
 */
void ZFPlaySystemQuake(void);

/**
 * 震动反馈力度:
 * 轻微:UIImpactFeedbackStyleLight,
 * 适中:UIImpactFeedbackStyleMedium,
 * 强震:UIImpactFeedbackStyleHeavy
 * 优点:能精准控制震动力度
 * 缺点:iOS10及以上系统使用
 */
void ZFPlayImpactFeedback(UIImpactFeedbackStyle Style);


#pragma mark -===========字符串、对象的一些安全操作===========

/**
 * 判断是否为NSString
 */
BOOL ZFJudgeNSString(id obj);

/**
 * 判断是否为NSDictionary
 */
BOOL ZFJudgeNSDictionary(id obj);

/**
 * 判断是否为NSArray
 */
BOOL ZFJudgeNSArray(id obj);

/**
 * 判断字符串是否为空
 */
BOOL ZFIsEmptyString(id obj);

/**
 *  转化为NSString来返回，如果为数组或字典转为json返回, 其他对象则返回@""
 *  适用于取一个值后赋值给文本显示时用
 */
NSString * ZFToString(id obj);

/**
 * 判断是否为自定义对象类
 */
BOOL ZFJudgeClass(id obj, NSString *classString);

/**
 * 从数组中获取对象
 */
id ZFGetObjFromArray(NSArray *array, NSInteger index);

/**
 * 从字典中获取NSString
 */
NSString * ZFGetStringFromDict(NSDictionary *dictionary, NSString *key);

NSString * ZFgrowingToString(id obj);

/**
 *  字符串编码
 *  str 目标字符串
 *  是否保留 ":/?#[]@!$&'()*+,;="
 */
NSString *ZFEscapeString(NSString *str, BOOL allowReserved); 

/**
 *  字符串解码
 */
NSString *ZFUnescapeString(NSString *str);


//FIXME: 社区降级测试
BOOL ZF_COMMUNITY_RESPONSE_TEST_FLAG(void);
NSDictionary *ZF_COMMUNITY_RESPONSE_TEST(void);
@end

