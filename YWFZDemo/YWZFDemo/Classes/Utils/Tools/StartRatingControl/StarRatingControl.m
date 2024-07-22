//
//  StarRatingControl.m
//  GearBest
//
//  Created by YW on 16/3/17.
//  Copyright © 2016年 gearbest. All rights reserved.
//

#import "StarRatingControl.h"
#import "StarView.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"

@interface StarRatingControl ()
@property (nonatomic,assign) int numberOfStars;
@property (nonatomic,assign) int currentIdx;
@end

@implementation StarRatingControl : UIControl

#pragma mark Initialization

- (void)setupView {
    self.clipsToBounds = YES;
    self.currentIdx = -1;
    if(!self.star) {
        self.star = [UIImage imageNamed:@"star_index"];
    }
    if (!self.highlightedStar) {
        self.highlightedStar = [UIImage imageNamed:@"star_s_index"];
    }
    for (int i=0; i<self.numberOfStars; i++) {
        StarView *v = [[StarView alloc] initWithDefault:self.star highlighted:self.highlightedStar position:i allowFractions:self.isFractionalRatingEnabled];
        [self addSubview:v];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.numberOfStars = kDefaultNumberOfStars;
        if (self.isFractionalRatingEnabled)
            self.numberOfStars *=kNumberOfFractions;
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfStars = kDefaultNumberOfStars;
        if (self.isFractionalRatingEnabled)
            self.numberOfStars *=kNumberOfFractions;
        [self setupView];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andStars:(int)numberOfStars isFractional:(BOOL)isFract{
    self = [super initWithFrame:frame];
    if (self) {
        self.isFractionalRatingEnabled = isFract;
        self.numberOfStars = numberOfStars;
        if (self.isFractionalRatingEnabled)
            self.numberOfStars *=kNumberOfFractions;
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andDefaultStarImage:(UIImage *)defaultStarImage highlightedStar:(UIImage *)highlightedStarImage {
    if (self = [super initWithFrame:frame]) {
        self.star = defaultStarImage;
        self.highlightedStar = highlightedStarImage;
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.star = [self image:self.star rotation:UIImageOrientationDown];
            self.highlightedStar = [self image:self.highlightedStar rotation:UIImageOrientationDown];
        }
        self.numberOfStars = kDefaultNumberOfStars;
        if (self.isFractionalRatingEnabled)
            self.numberOfStars *=kNumberOfFractions;
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews {
    for (int i=0; i < self.numberOfStars; i++) {
        [(StarView*)[self subViewWithTag:i] centerIn:self.frame with:self.numberOfStars];
    }
}

#pragma mark Customization

- (void)setStar:(UIImage*)defaultStarImage highlightedStar:(UIImage*)highlightedStarImage {
    for(int i = 0; i < self.numberOfStars; i++){
        [self setStar:defaultStarImage highlightedStar:highlightedStarImage atIndex:i];
    }
}

- (void)setStar:(UIImage*)defaultStarImage highlightedStar:(UIImage*)highlightedStarImage atIndex:(int)index {
    StarView *selectedStar = (StarView*)[self subViewWithTag:index];
    // check if star exists
    if (!selectedStar) return;
    
    // check images for nil else use default stars
    defaultStarImage = (defaultStarImage) ? defaultStarImage : self.star;
    highlightedStarImage = (highlightedStarImage) ? highlightedStarImage : self.highlightedStar;

    [selectedStar setStarImage:defaultStarImage highlightedStarImage:highlightedStarImage];
}

#pragma mark Touch Handling

- (UIButton*)starForPoint:(CGPoint)point {
    for (int i=0; i < self.numberOfStars; i++) {
        if (CGRectContainsPoint([self subViewWithTag:i].frame, point)) {
            return (UIButton*)[self subViewWithTag:i];
        }
    }
    return nil;
}

- (void)disableStarsDownToExclusive:(int)idx {
    for (int i=self.numberOfStars; i > idx; --i) {
        UIButton *b = (UIButton*)[self subViewWithTag:i];
        b.highlighted = NO;
    }
}

- (void)disableStarsDownTo:(int)idx {
    for (int i=self.numberOfStars; i >= idx; --i) {
        UIButton *b = (UIButton*)[self subViewWithTag:i];
        b.highlighted = NO;
    }
}


- (void)enableStarsUpTo:(int)idx {
    for (int i=0; i <= idx; i++) {
        UIButton *b = (UIButton*)[self subViewWithTag:i];
        b.highlighted = YES;
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    UIButton *pressedButton = [self starForPoint:point];
    if (pressedButton) {
        int idx = (int)pressedButton.tag;
        if (pressedButton.highlighted) {
            [self disableStarsDownToExclusive:idx];
        } else {
            [self enableStarsUpTo:idx];
        }
        self.currentIdx = idx;
    }
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    
    UIButton *pressedButton = [self starForPoint:point];
    if (pressedButton) {
        int idx = (int)pressedButton.tag;
        UIButton *currentButton = (UIButton*)[self subViewWithTag:self.currentIdx];
        
        if (idx < self.currentIdx) {
            currentButton.highlighted = NO;
            self.currentIdx = idx;
            [self disableStarsDownToExclusive:idx];
        } else if (idx > self.currentIdx) {
            currentButton.highlighted = YES;
            pressedButton.highlighted = YES;
            self.currentIdx = idx;
            [self enableStarsUpTo:idx];
        }
    } else if (point.x < [self subViewWithTag:0].frame.origin.x) {
        ((UIButton*)[self subViewWithTag:0]).highlighted = YES;
        self.currentIdx = 0;
        [self disableStarsDownToExclusive:0];
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self.delegate newRating:self :self.rating];
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark Rating Property

- (void)setRating:(float)_rating {
//    if (_rating<1) {
//        _rating = 1;
//    }
    if (self.isFractionalRatingEnabled) {
        _rating *=kNumberOfFractions;
    }
    [self disableStarsDownTo:0];
    self.currentIdx = (int)_rating-1;
    [self enableStarsUpTo:self.currentIdx];
}

- (float)rating {
    if (self.isFractionalRatingEnabled) {
        return (float)(self.currentIdx+1)/kNumberOfFractions;
    }
    return (float)self.currentIdx+1;
}

- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

@end


