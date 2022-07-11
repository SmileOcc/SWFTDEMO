//
//  YXTabLayout.h
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/28.
//  Copyright © 2018 ellison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXTabLayout : NSObject

/**
 标题颜色，默认#9FB0CA
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 标题选中颜色，默认#2F79FF
 */
@property (nonatomic, strong) UIColor *titleSelectedColor;

/**
 标题字体，默认14号苹方
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 标题选中字体, 默认14号苹方Medium
 */
@property (nonatomic, strong) UIFont *titleSelectedFont;

/**
 左右起始间距，默认值为20
 若leftAlign为NO,且计算总宽度少于TabView宽度,q会自动适配间距
 规则为lrMargin = tabMargin / 2
 */
@property (nonatomic, assign) CGFloat lrMargin;

/*
 左对齐，默认为NO
 */
@property (nonatomic, assign) BOOL leftAlign;

/**
 Tab间间距，默认值为30
 若leftAlign为NO，
 且计算总宽度少于TabView宽度,会自动适配间距
 
 间距不为0,规则为lrMargin = tabMargin / 2
 间距为0,规则为中间间距自动拉伸
 */
@property (nonatomic, assign) CGFloat tabMargin;


/**
 Tab内间距，默认值为0
 */
@property (nonatomic, assign) CGFloat tabPadding;


/**
 Tab固定宽度，默认值为0
 若值为0，则宽度与当前Tab标题宽度相等
 若值为0，则宽度= 当前Tab标题宽度 + 2*tabPadding
 */
@property (nonatomic, assign) CGFloat tabWidth;
/**
 Tab选中颜色，默认为clearColor
 */
@property (nonatomic, strong) UIColor *tabSelectedColor;

/**
 Tab颜色，默认为clearColor
 */
@property (nonatomic, strong) UIColor *tabColor;

/**
 Tab圆角
 */
@property (nonatomic, assign) CGFloat tabCornerRadius;

/**
 底部线条颜色，默认#2F79FF
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 底部线条高度，默认值为2
 */
@property (nonatomic, assign) CGFloat lineHeight;

/**
 底部线条内边距，默认值为0
 */
@property (nonatomic, assign) CGFloat linePadding;

/**
 底部线条圆角，默认值为0
 */
@property (nonatomic, assign) CGFloat lineCornerRadius;

/**
 底部线条宽度，默认值为0
 若值为0，则宽度与tabWidth相等
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 底部线条是否隐藏，默认值为NO
 */
@property (nonatomic, assign) BOOL lineHidden;

/**
 点击Tab时，底部线条是滚动，默认值为NO
 */
@property (nonatomic, assign) BOOL lineScrollDisable;

/**
 在尾部添加渐隐效果，默认值为NO
 */
@property (nonatomic, assign) BOOL isGradientTail;
/**
 在尾部添加渐隐颜色，默认值为白色
 */
@property (nonatomic, strong) UIColor *gradientTailColor;
/**
 默认值为NO
 */
@property (nonatomic, assign) BOOL itemClipsToBounds;

/*
 Tab layerWidth线宽，默认0
 */
@property (nonatomic, assign) CGFloat layerWidth;
/**

/**
 Tab titleLabel选中颜色，默认为clearColor,layerWidth >0才展示
 */
@property (nonatomic, strong) UIColor *layerSelectedColor;

/**
 Tab titleLabel未选中颜色，默认为clearColor,layerWidth >0才展示
 */
@property (nonatomic, strong) UIColor *layerColor;

/**
 默认TabLayout
 
 默认示例
 YXTabView *tabView = [[YXTabView alloc] initWithFrame:frame];
 
 自定义示例
 YXTabLayout *layout = [YXTabLayout defaultLayout];
 layout.lineScrollDisable = YES;
 layout.lineHidden = YES;
 
 YXTabView *tabView = [[YXTabView alloc] initWithFrame:frame withLayout:layout];
 
 */
+ (YXTabLayout *)defaultLayout;

@end

NS_ASSUME_NONNULL_END
