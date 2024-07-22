//
//  ZFCommunityRemmondPageControl.h
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCommunityRemmondPageControl : UIView

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger allCounts;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat limitCorner;
@property (nonatomic, strong) UIColor *highColor;
@property (nonatomic, strong) UIColor *defaultColor;




- (void)configeMaxWidth:(CGFloat)maxWidth minWidth:(CGFloat)minWidth maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight limitCorner:(CGFloat)limitCorner;

- (void)updateDotHighColor:(UIColor *)highColor defaultColor:(UIColor *)defaultColor counts:(NSInteger)count currentIndex:(NSInteger)currentIndex;

- (void)selectIndex:(NSInteger)index;


@end

