//
//  STLPageCircleControlView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/7.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLPageCircleControlView : UIView

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger allCounts;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat limitCorner;
@property (nonatomic, assign) CGFloat space;
@property (nonatomic, strong) UIColor *highColor;
@property (nonatomic, strong) UIColor *defaultColor;




- (void)configeMaxWidth:(CGFloat)maxWidth minWidth:(CGFloat)minWidth maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight limitCorner:(CGFloat)limitCorner;

- (void)configeMaxWidth:(CGFloat)maxWidth minWidth:(CGFloat)minWidth maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight limitCorner:(CGFloat)limitCorner space:(CGFloat)space;

- (void)updateDotHighColor:(UIColor *)highColor defaultColor:(UIColor *)defaultColor counts:(NSInteger)count currentIndex:(NSInteger)currentIndex;

- (void)selectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
