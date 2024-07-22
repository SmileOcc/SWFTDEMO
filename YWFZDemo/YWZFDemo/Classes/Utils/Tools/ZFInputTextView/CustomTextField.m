//
//  CustomTextField.m
//  UITextField +
//
//  Created by ZJ1620 on 16/9/26.
//  Copyright © 2016年 Globalegrow. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.placeholderPadding = 10;
    }
    return self;
}

//控制placeHolder的位置，左右缩10
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
//    return CGRectInset(bounds, 20, 0);
    CGRect inset = CGRectMake(bounds.origin.x+self.placeholderPadding, bounds.origin.y, bounds.size.width -self.placeholderPadding * 2, bounds.size.height);//更好理解些
    return inset;
}
//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    //return CGRectInset(bounds, 50, 0);
    CGRect inset = CGRectMake(bounds.origin.x+self.placeholderPadding, bounds.origin.y, bounds.size.width -self.placeholderPadding * 2, bounds.size.height);//更好理解些
    
    return inset;
    
}

//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    //return CGRectInset( bounds, 10 , 0 );
    
    CGRect inset = CGRectMake(bounds.origin.x +self.placeholderPadding, bounds.origin.y, bounds.size.width -self.placeholderPadding * 2,bounds.size.height);
    return inset;
}

/*
//控制清除按钮的位置
-(CGRect)clearButtonRectForBounds:(CGRect)bounds
{
//    return CGRectMake(bounds.origin.x + bounds.size.width - 50, bounds.origin.y + bounds.size.height -20, 16, 16);
}

//控制左视图位置
- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x +10, bounds.origin.y, bounds.size.width-250, bounds.size.height);
    return inset;
    //return CGRectInset(bounds,50,0);
}

////控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    [[UIColor orangeColor] setFill];
    
//    [[self placeholder] drawInRect:rectwithFont:[UIFont systemFontOfSize:20]];
}
*/

@end
