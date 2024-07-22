//
//  UIScrollView+ZFUITouchEvent.m
//  ZZZZZ
//
//  Created by YW on 2019/10/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "UIScrollView+ZFUITouchEvent.h"

@implementation UIScrollView (ZFUITouchEvent)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [[self nextResponder]touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];


}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    [[self nextResponder]touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];


}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [[self nextResponder]touchesEnded:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];


}

@end
