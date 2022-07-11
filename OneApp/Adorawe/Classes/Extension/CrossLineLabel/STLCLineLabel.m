//
//  STLCLineLabel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLCLineLabel.h"

@implementation STLCLineLabel

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    // 上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 颜色
    [self.textColor setStroke];
    // 字体宽度
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
    // 线的起点
    CGFloat y = rect.size.height * 0.5+0.5;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        CGContextMoveToPoint(context, rect.size.width - size.width, y);
        // 线的终点
        CGContextAddLineToPoint(context, rect.size.width, y);
    } else {
        CGContextMoveToPoint(context, 0, y);
        // 线的终点
        CGContextAddLineToPoint(context, size.width, y);
    }
    // 渲染
    CGContextStrokePath(context);
    
}

@end
