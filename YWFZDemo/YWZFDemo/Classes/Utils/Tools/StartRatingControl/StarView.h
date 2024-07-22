//
//  StarView.h
//  GearBest
//
//  Created by YW on 16/3/17.
//  Copyright © 2016年 gearbest. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kEdgeInsetBottom 20

@interface StarView : UIButton
- (id)initWithDefault:(UIImage*)star highlighted:(UIImage*)highlightedStar position:(int)index allowFractions:(BOOL)fractions;
- (void)centerIn:(CGRect)_frame with:(int)numberOfStars;
- (void)setStarImage:(UIImage*)starImage highlightedStarImage:(UIImage*)highlightedImage;
- (UIImage *)croppedImage:(UIImage*)image;
@end
