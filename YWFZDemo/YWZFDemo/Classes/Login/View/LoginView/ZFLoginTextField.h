//
//  YWLoginTextField.h
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWLoginTextField : UITextField

// clear图标
@property (nonatomic, strong) UIImage *clearImage;
// 光标颜色
@property (nonatomic,strong) UIColor *cursorColor;

@property (nonatomic,strong) UIColor *placeholderNormalColor;

@property (nonatomic,strong) UIFont *placeholderAnimationFont;

@property (nonatomic,strong) UIFont *placeholderFont;

@property (nonatomic,assign) BOOL   isSecure;

@property (nonatomic,strong) UIButton   *rightButton;

///是否开启placeHold动画 默认为YES
@property (nonatomic,assign) BOOL enablePlaceHoldAnimation;

- (void)resetAnimation;

- (void)showPlaceholderAnimation;

@end
