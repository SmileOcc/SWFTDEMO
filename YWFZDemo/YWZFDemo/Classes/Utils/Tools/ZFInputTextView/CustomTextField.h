//
//  CustomTextField.h
//  UITextField +
//
//  Created by ZJ1620 on 16/9/26.
//  Copyright © 2016年 Globalegrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextField : UITextField

///占位文本padding 默认 10
@property (nonatomic, assign) CGFloat placeholderPadding;

//控制清除按钮的位置
//-(CGRect)clearButtonRectForBounds:(CGRect)bounds;
//控制placeHolder的位置，左右缩10
-(CGRect)placeholderRectForBounds:(CGRect)bounds;
////控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds;
////控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds;
////控制左视图位置
//- (CGRect)leftViewRectForBounds:(CGRect)bounds;
////控制placeHolder的颜色、字体
//- (void)drawPlaceholderInRect:(CGRect)rect;


@end
