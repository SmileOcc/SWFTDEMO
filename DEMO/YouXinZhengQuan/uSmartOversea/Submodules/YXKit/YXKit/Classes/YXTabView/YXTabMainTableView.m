//
//  YXPanTableView.m
//  ScrollViewDemo
//
//  Created by ellison on 2018/10/31.
//  Copyright © 2018 ellison. All rights reserved.
//

#import "YXTabMainTableView.h"

@interface YXTabMainTableView () <UIGestureRecognizerDelegate>

@end

@implementation YXTabMainTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    
    if ( [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGFloat otherY = [(UIPanGestureRecognizer *)otherGestureRecognizer translationInView:self.superview].y;
        CGFloat otherX = [(UIPanGestureRecognizer *)otherGestureRecognizer translationInView:self.superview].x;
        
        if ((otherY == 0.0 && otherX != 0.0) || self.tableHeaderView == nil) {
            return NO;
        } else {
            // TODO: 两个滑动手势响应不同的View，且View宽度不同，说明other响应的是需要单独处理的子ScrollView，此时主Table不响应, 暂时这样处理
            if (otherGestureRecognizer.view != gestureRecognizer.view ) {
                
                UIView *targetView;
                if ([NSStringFromClass([gestureRecognizer.view class]) containsString:@"QMUITableView"]) {
                    targetView = gestureRecognizer.view;
                } else if ([NSStringFromClass([otherGestureRecognizer.view class]) containsString:@"QMUITableView"]) {
                    targetView = otherGestureRecognizer.view;
                }
                
                if (targetView) {
                    for (UIView* next = [targetView superview]; next; next = next.superview) {
                        UIResponder* nextResponder = [next nextResponder];
                        if ([NSStringFromClass([nextResponder class]) containsString:@"YXSquareAllDayInfoVC"]) {
                            return YES;
                        }
                    }
                }
                
                if (gestureRecognizer.view.bounds.size.width != otherGestureRecognizer.view.bounds.size.width) {
                    return NO;
                }
            }
            
            if (fabs(otherY)/fabs(otherX) >= 2 || otherX == 0) {
                if (gestureRecognizer.state == UIGestureRecognizerStateChanged && otherGestureRecognizer.state == UIGestureRecognizerStateBegan) {
                    return NO;
                }
                return YES;
            } else {
                return NO;
            }
        }
        
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
