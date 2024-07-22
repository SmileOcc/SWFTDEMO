//
//  ZFCommunityAlbumCollectionView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityAlbumCollectionView.h"
#import "Constants.h"
//#import "UIScrollView+ZFUITouchEvent.h"

@implementation ZFCommunityAlbumCollectionView

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    static UIEvent *e = nil;
    
    if (e != nil && e == event) {
        e = nil;
        return [super hitTest:point withEvent:event];
    }
    
    e = event;
    

    if ([self pointInside:point withEvent:event]) {
        YWLog(@"----fffffff");
        CGPoint buttonPoint = [self convertPoint:point toView:self.superview];
        YWLog(@"----kkkk%@",NSStringFromCGPoint(buttonPoint));
        self.startOffsetY = self.contentOffset.y;
        self.startToWindowPoint = buttonPoint;
        if (self.touchesBeganPointBlock) {
            self.touchesBeganPointBlock(buttonPoint);
        }
        return self;
    }
    
    
//    if (event.type == UIEventTypeTouches) {
//        NSSet *touches = [event touchesForView:self];
//        UITouch *touch = [touches anyObject];
//        if (touch.phase == UITouchPhaseBegan) {
//            YWLog(@"Touches began");
//        }else if(touch.phase == UITouchPhaseEnded){
//            YWLog(@"Touches Ended");
//
//        }else if(touch.phase == UITouchPhaseCancelled){
//            YWLog(@"Touches Cancelled");
//
//        }else if (touch.phase == UITouchPhaseMoved){
//            YWLog(@"Touches Moved");
//
//        }
//        CGPoint tttPoint = [touch locationInView:touch.window];
//        YWLog(@"----%@",NSStringFromCGPoint(tttPoint));
//    }
    
    return [super hitTest:point withEvent:event];
}


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
////    [[self nextResponder] touchesBegan:touches withEvent:event];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
////    [[self nextResponder] touchesMoved:touches withEvent:event];
//    YWLog(@"kkkkkkkk");
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
////    [[self nextResponder] touchesEnded:touches withEvent:event];
//}

@end
