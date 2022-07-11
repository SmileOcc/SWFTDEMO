//
//  UIButton+create.m
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "UIButton+utility.h"
#import "UIView+Borders.h"

#import <YYCategories/UIImage+YYAdd.h>

@implementation UIButton (utility)


+ (instancetype)buttonWithType:(UIButtonType)type title:(NSString *)title font:(UIFont *)font{
    
    UIButton *button = [self buttonWithType:type];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = font;
    return button;
}


+ (instancetype)buttonWithType:(UIButtonType)type title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor target:(id)target action:(SEL)action{
    
    UIButton *button = [self buttonWithType:type title:title font:font];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    if (target != nil && action != nil) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

+ (instancetype)buttonWithType:(UIButtonType)type image:(UIImage *)image target:(id)target action:(SEL)action{
    UIButton *button = [self buttonWithType:type];
    if (target != nil || action != nil) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [button setImage:image forState:UIControlStateNormal];
    return button;
}


- (void)setButtonImagePostion:(YXButtonSubViewPositon)imagePosition interval:(CGFloat)interval{
    
    /*
    typedef struct UIEdgeInsets {
        CGFloat top, left, bottom, right;  // specify amount to inset (positive) for each of the edges. values can be negative to 'outset'
    } UIEdgeInsets;
    
     top : 为正数的时候,是往下偏移,为负数的时候往上偏移;
     left : 为正数的时候往右偏移,为负数的时候往左偏移;
     bottom : 为正数的时候往上偏移,为负数的时候往下偏移;
     right :为正数的时候往左偏移,为负数的时候往右偏移;
     
     */
    [self.titleLabel sizeToFit];
    
    CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    CGFloat labelHeight = self.titleLabel.intrinsicContentSize.height;
    
    CGFloat imageOffSetX = labelWidth / 2;
    CGFloat imageOffSetY = imageHeight / 2 + interval / 2;
    CGFloat labelOffSetX = imageWidth / 2;
    CGFloat labelOffSetY = labelHeight / 2 + interval / 2;
    
    CGFloat maxWidth = MAX(imageWidth, labelWidth);
    CGFloat changeWidth = imageWidth + labelWidth - maxWidth;
    CGFloat maxHeight = MAX(imageHeight,labelHeight);
    CGFloat changeHeight = imageHeight + labelHeight + interval - maxHeight;
    
    if (imagePosition == YXButtonSubViewPositonTop) {
        self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffSetY, imageOffSetX, imageOffSetY, -imageOffSetX);
        self.titleEdgeInsets = UIEdgeInsetsMake(labelOffSetY, -labelOffSetX, -labelOffSetY, labelOffSetX);
        self.contentEdgeInsets = UIEdgeInsetsMake(changeHeight - labelOffSetY, - changeWidth / 2, labelOffSetY, -changeWidth / 2);
    }
    
    if (imagePosition == YXButtonSubViewPositonBottom) {
        self.imageEdgeInsets = UIEdgeInsetsMake(imageOffSetY, imageOffSetX, -imageOffSetY, -imageOffSetX);
        self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffSetY, -labelOffSetX, labelOffSetY, labelOffSetX);
        self.contentEdgeInsets = UIEdgeInsetsMake(labelOffSetY, -changeWidth / 2, changeHeight - labelOffSetY, -changeWidth / 2);
    }
    
    if (imagePosition == YXButtonSubViewPositonRight) {
        self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + interval / 2 , 0, -labelWidth - interval / 2);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth - interval / 2, 0, imageWidth + interval / 2);
        self.contentEdgeInsets = UIEdgeInsetsMake(0, interval / 2, 0, interval / 2);
    }
    
    if (imagePosition == YXButtonSubViewPositonLeft && interval != 0) {
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -interval / 2, 0, interval / 2);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, interval / 2, 0 , - interval / 2);
        self.contentEdgeInsets = UIEdgeInsetsMake(0, interval / 2, 0, interval / 2);
    }
    
}

- (void)setButtonImagePostionRight:(CGFloat)interval {
    CGFloat labelWidth = self.titleLabel.bounds.size.width;
    CGFloat imageWidth = self.imageView.image.size.width;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + interval / 2 , 0, -labelWidth - interval / 2);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth - interval / 2, 0, imageWidth + interval / 2);
    self.contentEdgeInsets = UIEdgeInsetsMake(0, interval / 2, 0, interval / 2);
}

- (void)setLongButtonBackgroundImage {
    
    [self setBackgroundImage:[UIImage imageWithColor:QMUITheme.themeTintColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:QMUITheme.themeTintColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:QMUITheme.secondButtonDisableColor] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];//QMUITheme.textColorLevel3
    [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];//[QMUITheme textColorLevel1]
    [self makeCorners:6];
}

- (void)setLongButtonBackgroundImageWithNoCorners {
    
    [self setBackgroundImage:[UIImage imageWithColor:QMUITheme.themeTintColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:QMUITheme.themeTintColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:QMUITheme.secondButtonDisableColor] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];//QMUITheme.textColorLevel3
    [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];//[QMUITheme textColorLevel1]
}

@end
