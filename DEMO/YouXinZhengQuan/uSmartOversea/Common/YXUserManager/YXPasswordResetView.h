//
//  YXPasswordResetView.h
//  YXPasswordSetInputView
//
//  Created by Kelvin on 2018/8/16.
//  Copyright © 2018年 Kelvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YXTextField;
@interface YXPasswordResetView : UIView

@property (nonatomic, strong) UIColor *textColor; //文字的颜色
@property (nonatomic, strong) UIFont *textFont; //文字的大小
@property (nonatomic, strong) UIColor *seletedColor; //选中的边框的颜色
@property (nonatomic, strong) UIColor *normalColor; //未选中的边框颜色
@property (nonatomic, assign) CGFloat margin; //边距
@property (nonatomic, strong, readonly) YXTextField *textField;
@property (nonatomic, assign) BOOL textFieldEnable; //textField是否可输入

//width输入格子宽度    viewWidth YXPasswordResetView的宽
- (instancetype)initWithGridWidth:(CGFloat)width viewWidth:(float)viewWidth;

//清除输入内容
- (void)clearText;


@end
