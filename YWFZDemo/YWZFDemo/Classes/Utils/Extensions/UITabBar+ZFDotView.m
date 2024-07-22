//
//  UITabBar+ZFDotView.m
//  Zaful
//
//  Created by QianHan on 2018/1/15.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "UITabBar+ZFDotView.h"

#define kDotViewTag  10000
#define kDotViewHeight 8.0

@implementation UITabBar (ZFDotView)

- (void)showDotOnItemIndex:(NSInteger)index{
    [self removeDotOnItemIndex:index];
    UIView *dotView            = [[UIView alloc] init];
    dotView.tag                = kDotViewTag + index;
    dotView.layer.cornerRadius = kDotViewHeight / 2;
    dotView.backgroundColor    = ZFCOLOR(247, 173, 75, 1.0);
    [self addSubview:dotView];
    
    CGFloat itemWidth = KScreenWidth/self.items.count;
    CGFloat itemHeight = self.frame.size.height;
    CGFloat itemImageWidth = self.items[index].image.size.width;
    CGFloat itemImageHeight = self.items[index].image.size.height;
    dotView.frame = CGRectMake(0, 0, kDotViewHeight, kDotViewHeight);
    CGFloat centerX = itemWidth / 2.0 + itemWidth * index + itemImageWidth / 2.0;
    CGFloat centerY = (itemHeight - kiphoneXHomeBarHeight - itemImageHeight) / 2.0;
    dotView.center = CGPointMake(centerX, centerY);
}

- (void)hideDotOnItemIndex:(NSInteger)index{
    [self removeDotOnItemIndex:index];
}

- (void)removeDotOnItemIndex:(NSInteger)index{
    UIView *dotView = [self viewWithTag:(kDotViewTag + index)];
    if (dotView) {
        [dotView removeFromSuperview];
    }
}

- (void)showAnimated:(BOOL)animated {
    if (!self.isHidden) return;
    self.hidden = NO; // previous show
    if (animated) {
        CGRect frame = self.frame;
        frame.origin.y -= 50;
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                         animations:^{
                             self.frame = frame;
                         }];
    }
}

- (void)hideAnimated:(BOOL)animated {
    if (self.isHidden) return;
    if (animated) {
        CGRect frame = self.frame;
        frame.origin.y += 50;
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                         animations:^{
                             self.frame = frame;
                         } completion:^(BOOL finished) {
                             self.hidden = YES;
                         }];
    } else {
        self.hidden = YES;
    }
}


@end
