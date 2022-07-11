//
//  YXTopicVoteBtn.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTopicVoteBtn.h"
#import "uSmartOversea-Swift.h"

@interface YXTopicVoteBtn ()

@property (nonatomic, strong) CAGradientLayer *gl;

@end

@implementation YXTopicVoteBtn


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    // gradient
    CAGradientLayer *gl = [CAGradientLayer layer];
    self.gl = gl;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1.0);
    gl.locations = @[@(0), @(1.0f)];
    
    [self.layer insertSublayer:gl atIndex:0];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];


    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    
    
    UIBezierPath *path = nil;
    
    if (self.isLeft) {
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(height * 0.5, height * 0.5) radius:height * 0.5 startAngle:M_PI * 3/2 endAngle:M_PI * 1/2 clockwise:NO];
        if (self.isFull) {
            UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width - height * 0.5, height * 0.5) radius:height * 0.5 startAngle:M_PI * 1/2 endAngle:M_PI * 3/2 clockwise:NO];
            [path addLineToPoint:CGPointMake(width - height * 0.5, height)];
            [path appendPath:arcPath];
            [path addLineToPoint:CGPointMake(height * 0.5, 0)];
        } else {
            [path addLineToPoint:CGPointMake(width - 7, height)];
            [path addLineToPoint:CGPointMake(width, 0)];
        }
        [path closePath];
        self.gl.colors = @[(__bridge id)[UIColor qmui_colorWithHexString:@"#8E99F8"].CGColor, (__bridge id)[UIColor qmui_colorWithHexString:@"#555FEE"].CGColor];
    } else {
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width - height * 0.5, height * 0.5) radius:height * 0.5 startAngle:M_PI * 1/2 endAngle:M_PI * 3/2 clockwise:NO];
        
        if (self.isFull) {
            UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(height * 0.5, height * 0.5) radius:height * 0.5 startAngle:M_PI * 3/2 endAngle:M_PI * 1/2 clockwise:NO];
            [path addLineToPoint:CGPointMake(height * 0.5, 0)];
            [path appendPath:arcPath];
            [path addLineToPoint:CGPointMake(width - height * 0.5, height)];
        } else {
            [path addLineToPoint:CGPointMake(7, 0)];
            [path addLineToPoint:CGPointMake(0, height)];
        }
        [path closePath];
        self.gl.colors = @[(__bridge id)[UIColor qmui_colorWithHexString:@"#7AEDDF"].CGColor, (__bridge id)[UIColor qmui_colorWithHexString:@"#1CBE9C"].CGColor];
    }

    path.lineWidth = 1;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
        
    self.gl.frame = self.bounds;

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = path.CGPath;
    maskLayer.frame = rect;
    self.layer.mask = maskLayer;

}

@end
