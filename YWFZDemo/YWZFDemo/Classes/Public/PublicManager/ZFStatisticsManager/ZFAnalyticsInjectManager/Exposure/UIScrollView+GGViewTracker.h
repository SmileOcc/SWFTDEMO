//
//  UIScrollView+GGViewTracker.h
//  ZZZZZ
//
//  Created by YW on 2019/2/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (GGViewTracker)
+ (void)doSwizzleForGGViewExposure;
@end

NS_ASSUME_NONNULL_END
