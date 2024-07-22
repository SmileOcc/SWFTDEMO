//
//  UIView+ZFViewExposure.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "UIView+GGViewExposure.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
#import "UIView+GGViewTracker.h"
#import "GGExposureManager.h"

static const char* kShowing = "showing";

@implementation UIView (GGViewExposure)

+(void)doSwizzleForGGViewExposure
{
    [self swizzleMethod:@selector(setHidden:) swizzledSelector:@selector(swizzle_setHidden:)];
    
    //for UIView's alpha
    [self swizzleMethod:@selector(setAlpha:) swizzledSelector:@selector(swizzle_setAlpha:)];
    
    //for UIViewController's switch
    [self swizzleMethod:@selector(didMoveToWindow) swizzledSelector:@selector(swizzle_didMoveToWindow)];
}

- (GGViewVisibleType)showing
{
    if (([self respondsToSelector:@selector(controlName)] && self.controlName)) {
        return [objc_getAssociatedObject(self, kShowing) integerValue];
    }
    
    return GGViewVisibleTypeUndefined;
}

-(void)setShowing:(GGViewVisibleType)showing
{
    if (showing == self.showing) return;
    
    if (([self respondsToSelector:@selector(controlName)] && self.controlName)) {
        // end show
        if( self.showing == GGViewVisibleTypeVisible && showing == GGViewVisibleTypeInvisible)
        {
            // remove observer.
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
        //begin show
        else if(self.showing != GGViewVisibleTypeVisible && showing == GGViewVisibleTypeVisible)
        {
            // add observer.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TMVE_handlerNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
        
        objc_setAssociatedObject(self, kShowing, @(showing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)TMVE_handlerNotification:(NSNotification*)notify
{
    if ([notify.name isEqualToString:UIApplicationDidEnterBackgroundNotification] ) {
        [GGExposureManager setState:GGViewVisibleTypeInvisible forView:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(TMVE_handlerNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    else if ([notify.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [GGExposureManager setState:GGViewVisibleTypeVisible forView:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}

#pragma mark - swizzle method
-(void)swizzle_setHidden:(BOOL)hidden
{
    BOOL orig = self.hidden;
    [self swizzle_setHidden:hidden];
    
    if (orig != hidden) {
        [GGExposureManager adjustStateForView:self forType:GGViewTrackerAdjustTypeUIViewSetHidden];
    }
}

-(void)swizzle_setAlpha:(CGFloat)alpha
{
    CGFloat orig = self.alpha;
    [self swizzle_setAlpha:alpha];
    if (!(orig == alpha || (orig > 0.f && alpha >0.f))) {
        [GGExposureManager adjustStateForView:self forType:GGViewTrackerAdjustTypeUIViewSetAlpha];
    }
}

/**
 * do things in didMoveToWindow:  not willMoveToWindow:
 */
-(void)swizzle_didMoveToWindow
{
    [self swizzle_didMoveToWindow];
    
    if (!self.window) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
    [GGExposureManager adjustStateForView:self forType:GGViewTrackerAdjustTypeUIViewDidMoveToWindow];
}

@end
