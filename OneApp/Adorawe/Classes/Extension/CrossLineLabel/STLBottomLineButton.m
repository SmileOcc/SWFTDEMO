//
//  STLBottomLineButton.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBottomLineButton.h"

@implementation STLBottomLineButton

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    // 上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 颜色
    [self.titleLabel.textColor setStroke];
    // 线的起点
    CGFloat y = rect.size.height * 1.0;
    // 此处的 2 是为了适配在 signUp 处的修改 ===> 后期可调整
    CGContextMoveToPoint(context, 2, y);
    // 字体宽度
    CGSize size = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    // 线的终点
    CGContextAddLineToPoint(context, size.width, y);
    // 渲染
    CGContextStrokePath(context);
    
}

@end
