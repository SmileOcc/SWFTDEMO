//
//  ZFSkinViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFSkinModel.h"
#import <YYImage/YYImage.h>

/**
 首页换肤
 */
@interface ZFSkinViewModel : NSObject

// 数据模型存储路径
+ (NSString *)skinModelPath;

/**
 请求换肤数据
 */
+ (void)requestSkinData:(void(^)(ZFSkinModel *skinModel))completeHandler;

/**
是否要显示
 */
+ (void)isNeedToShow:(void(^)(BOOL need))completeHandler;

/*****  获取的都是当前语言的换肤图 ****/
// 导航背景图
+ (UIImage *)navigationBgImage;

// 所有子页面导航栏图片
+ (UIImage *)subNavigationBgImage;

// 我的页面顶部图片
+ (UIImage *)accountHeadImage;

// 搜索图
+ (UIImage *)searchImage;

// 购物车图
+ (UIImage *)bagImage;

// 导航logo
+ (YYImage *)logoImage;

// tabbar 背景图
+ (UIImage *)tabbarBgImage;

// tabbar Home 常规图
+ (UIImage *)tabbarHomeImage;
// tabbar Home 高亮图
+ (UIImage *)tabbarHomeOnImage;

// tabbar 社区 常规图
+ (UIImage *)tabbarCommunityImage;
// tabbar 社区 高亮图
+ (UIImage *)tabbarCommunityOnImage;

// tabbar 个人中心 常规图
+ (UIImage *)tabbarPersonImage;
// tabbar 个人中心 高亮图
+ (UIImage *)tabbarPersonOnImage;

// 清除首页换肤缓存
+ (void)clearCacheFile;

@end
