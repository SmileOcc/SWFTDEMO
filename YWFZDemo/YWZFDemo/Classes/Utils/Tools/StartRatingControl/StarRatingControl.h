//
//  StarRatingControl.h
//  GearBest
//
//  Created by YW on 16/3/17.
//  Copyright © 2016年 gearbest. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultNumberOfStars 5
#define kNumberOfFractions 10

@class StarRatingControl;

@protocol StarRatingDelegate

-(void)newRating:(StarRatingControl *)control :(float)rating;

@end

@interface StarRatingControl : UIControl 

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame andStars:(int)numberOfStars isFractional:(BOOL)isFract;
- (id)initWithFrame:(CGRect)frame andDefaultStarImage:(UIImage *)defaultStarImage highlightedStar:(UIImage *)highlightedStarImage;
- (void)setStar:(UIImage*)defaultStarImage highlightedStar:(UIImage*)highlightedStarImage;
- (void)setStar:(UIImage*)defaultStarImage highlightedStar:(UIImage*)highlightedStarImage atIndex:(int)index;

@property (strong,nonatomic) UIImage *star;
@property (strong,nonatomic) UIImage *highlightedStar;
@property (assign,nonatomic) float rating;
@property (assign,nonatomic) id<StarRatingDelegate> delegate;
@property (assign,nonatomic) BOOL isFractionalRatingEnabled;

@end
