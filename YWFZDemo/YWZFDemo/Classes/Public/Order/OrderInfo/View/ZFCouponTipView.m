//
//  ZFCouponTipView.m
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCouponTipView.h"

@implementation ZFCouponTipView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.44);
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0);
    
    CGFloat radius     = 3.0f;
    CGRect frame       = rect;
    CGFloat arrowHeigt = 8.0f;
    CGContextMoveToPoint(ctx, 0.0, radius);
    CGContextAddArcToPoint(ctx, 0.0, 0.0, frame.size.width - arrowHeigt, 0.0, radius);
    CGContextAddArcToPoint(ctx, frame.size.width - arrowHeigt, 0.0, frame.size.width - arrowHeigt, (frame.size.height - arrowHeigt) / 2, radius);
    CGContextAddArcToPoint(ctx, frame.size.width - arrowHeigt, (frame.size.height - arrowHeigt) / 2, frame.size.width, frame.size.height / 2, radius);
    CGContextAddLineToPoint(ctx, frame.size.width, frame.size.height / 2);
    CGContextAddLineToPoint(ctx, frame.size.width - arrowHeigt, (frame.size.height - arrowHeigt) / 2 + arrowHeigt);
    CGContextAddArcToPoint(ctx, frame.size.width - arrowHeigt, (frame.size.height - arrowHeigt) / 2 + arrowHeigt, frame.size.width - arrowHeigt, frame.size.height, radius);
    CGContextAddArcToPoint(ctx, frame.size.width - arrowHeigt, frame.size.height, 0.0, frame.size.height, radius);
    CGContextAddArcToPoint(ctx, 0.0, frame.size.height, 0.0, 0.0, radius);

    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end
