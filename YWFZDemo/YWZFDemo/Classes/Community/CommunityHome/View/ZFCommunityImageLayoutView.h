//
//  ZFCommunityImageLayoutView.h
//  ZZZZZ
//
//  Created by YW on 2017/2/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCommunityImageLayoutView : UIView

/** 图片容器宽度配置：默认屏幕宽*/
@property (nonatomic, assign) CGFloat contentWidth;

/** 图片距容器左边距配置：默认 10*/
@property (nonatomic, assign) CGFloat leadingSpacing;

/** 图片距容器左边距配置：默认 10*/
@property (nonatomic, assign) CGFloat trailingSpacing;

/** 图片距容器右边距配置：默认 10*/
@property (nonatomic, assign) CGFloat fixedSpacing;

/** 图片集合*/
@property (nonatomic, strong) NSArray *imagePaths;



/**
 获取图片容器的高度

 @param imagePaths 图片个数
 @param contentWidth 图片容器宽度配置：默认 屏幕宽
 @param leadSpace 图片距容器左边距
 @param trailSpace 图片距容器右边距
 @param fixedSpace 图片间距
 @return 容器高度
 */

+ (CGFloat)heightContentImagePaths:(NSArray *)imagePaths contentWidth:(CGFloat)contentWidth leadSpace:(CGFloat)leadSpace trailSpace:(CGFloat)trailSpace fixedSpace:(CGFloat)fixedSpace;

@end
