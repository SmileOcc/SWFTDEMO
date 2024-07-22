//
//  ZFTextField.h
//  ZZZZZ
//
//  Created by YW on 29/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFTextField;

@protocol ZFTextFieldDelegate <NSObject>
@optional
/**
 * 监听删除键
 */
- (void)zfTextFieldDeleteBackward:(ZFTextField *)textfield;
@end

@interface ZFTextField : UITextField

@property (nonatomic, assign) id<ZFTextFieldDelegate>   zf_delegate;

// 左边图标
@property (nonatomic, strong) UIImage *leftImage;
// clear图标
@property (nonatomic, strong) UIImage *clearImage;
// 动画最终字体
@property (nonatomic, strong) UIFont *animationFont;
// 错误提示文案
@property (nonatomic, copy) NSString   *errorTip;
// 错误提示文字颜色
@property (nonatomic, strong) UIColor   *errorTipColor;
// 错误提示文字字号
@property (nonatomic, assign) CGFloat   errorFontSize;
// 提示语 x 偏移
@property (nonatomic, assign) CGFloat  floatingLabelXPadding;
// 光标颜色
@property (nonatomic,strong) UIColor *cursorColor;
// 正常状态下线的颜色
@property (nonatomic,strong) UIColor *placeholderNormalStateColor;
// 输入状态下线的颜色
@property (nonatomic,strong) UIColor *placeholderSelectStateColor;

@property (nonatomic,strong) UIColor *placeholderColor;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) BOOL   isSecure;

@property (nonatomic, strong) UIButton   *rightButton;


- (void)resetAnimation;

- (void)showErrorTipLabel:(BOOL)isShowErrorTip;

- (void)hidenErrorTipLine;

- (void)resetMoved:(BOOL)isMoved;

- (void)showPlaceholderAnimation;

@end
