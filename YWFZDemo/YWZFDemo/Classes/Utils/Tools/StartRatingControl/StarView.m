//
//  StarView.m
//  GearBest
//
//  Created by YW on 16/3/17.
//  Copyright © 2016年 gearbest. All rights reserved.
//

#import "StarView.h"
#import "StarRatingControl.h"

@implementation StarView

#pragma mark -
#pragma mark Initialization

- (id)initWithDefault:(UIImage*)star highlighted:(UIImage*)highlightedStar position:(int)index allowFractions:(BOOL)fractions {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self setTag:index];
        if (fractions) {
            highlightedStar = [self croppedImage:highlightedStar];
            star = [self croppedImage:star];
        }
        self.frame = CGRectMake((star.size.width*index), 0, star.size.width + 3, star.size.height+kEdgeInsetBottom);
        [self setStarImage:star highlightedStarImage:highlightedStar];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, kEdgeInsetBottom, 0)];
        [self setBackgroundColor:[UIColor clearColor]];
        if (index == 0) {
   	        [self setAccessibilityLabel:@"1 star"];
        } else {
   	        [self setAccessibilityLabel:[NSString stringWithFormat:@"%d stars", index+1]];
        }
    }
    return self;
}


- (UIImage *)croppedImage:(UIImage*)image {
    float partWidth = image.size.width/kNumberOfFractions * image.scale;
    int part = (self.tag+kNumberOfFractions)%kNumberOfFractions;
    float xOffset = partWidth*part;

    CGRect newFrame = CGRectMake(xOffset, (self.frame.size.height - image.size.height) / 2, partWidth , image.size.height * image.scale);
    CGImageRef resultImage = CGImageCreateWithImageInRect([image CGImage], newFrame);
    UIImage *result = [UIImage imageWithCGImage:resultImage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(resultImage);

    return result;
}



#pragma mark -
#pragma mark UIView methods

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.superview;
}

#pragma mark -
#pragma mark Layouting

- (void)centerIn:(CGRect)_frame with:(int)numberOfStars {
    CGSize size = self.frame.size;
    float widthOfStars = self.frame.size.width * numberOfStars;
    float frameWidth = _frame.size.width;
    float gapToApply = (frameWidth-widthOfStars)/2;
    self.frame = CGRectMake((size.width*self.tag) + gapToApply, 0, size.width, size.height);
}

- (void)setStarImage:(UIImage*)starImage highlightedStarImage:(UIImage*)highlightedImage {
    [self setImage:starImage forState:UIControlStateNormal];
    [self setImage:highlightedImage forState:UIControlStateSelected];
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
}

@end
