//
//  UIScrollView+GGViewTracker.m
//  ZZZZZ
//
//  Created by YW on 2019/2/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "UIScrollView+GGViewTracker.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
#import "GGViewTrackerManager.h"
#import "GGExposureManager.h"

static const char* kLastLayoutDate = "lastLayoutDate";

@implementation UIScrollView (GGViewTracker)
+ (void)doSwizzleForGGViewExposure
{
    //for UIView's position and rect
    [self swizzleMethod:@selector(setContentOffset:) swizzledSelector:@selector(swizzle_setContentOffset:)];
}

-(NSDate*)lastLayoutDate
{
    return objc_getAssociatedObject(self, kLastLayoutDate);
}

-(void)setLastLayoutDate:(NSDate*)date
{
    objc_setAssociatedObject(self, kLastLayoutDate, date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)swizzle_setContentOffset:(CGPoint)contentOffset
{
    [self swizzle_setContentOffset:contentOffset];
    
    //只有当应用在前台的时候才拦截setContentOffset
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if ([self lastLayoutDate] && ([[NSDate date] timeIntervalSince1970] - [[self lastLayoutDate] timeIntervalSince1970])*1000 < [GGViewTrackerManager sharedManager].exposureTimeThreshold) {
            return;
        }

        [self setLastLayoutDate:[NSDate date]];

        [GGExposureManager adjustStateForView:self forType:GGViewTrackerAdjustTypeUIScrollViewSetContentOffset];
    }
}
@end
