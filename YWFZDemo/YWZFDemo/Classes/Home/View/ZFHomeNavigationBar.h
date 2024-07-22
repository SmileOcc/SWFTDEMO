//
//  ZFHomeNavigationBar.h
//  ZZZZZ
//
//  Created by YW on 18/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>

typedef enum : NSUInteger {
    HomeNavBarLeftButtonAction,             //左侧按钮
    HomeNavBarSearchCategoryButtonAction,   //搜索分类按钮
    HomeNavBarSearchImageButtonAction,      //搜图按钮
    HomeNavBarRightButtonAction,            //右侧按钮
} HomeNavigationBarActionType;

//V5.0.0此类改为继承为YYAnimatedImageView支持gif图片
@interface ZFHomeNavigationBar : YYAnimatedImageView

@property (nonatomic, copy) void(^navigationBarActionBlock)(HomeNavigationBarActionType actionType);

@property (nonatomic, copy) NSString *inputPlaceHolder;

- (void)updateNavigationBar:(BOOL)needShow;

- (void)zf_setBarBackgroundColor:(UIColor *)color;

- (void)zf_setBarBackgroundImage:(UIImage *)image;

- (void)zf_setLogoImage:(YYImage *)logoImage;

- (void)zf_setLeftButtonWithImage:(UIImage *)image;

- (void)zf_setRightButtonWithImage:(UIImage *)image;

- (void)zf_setBottomLineHidden:(BOOL)hidden;

- (void)zf_setBackgroundAlpha:(CGFloat)alpha;

- (void)zf_showInputView:(BOOL)show offsetY:(CGFloat)offsetY ;

- (void)zf_setTintColor:(UIColor *)color;

- (void)setBagValues;


@end
