//
//  UIView+ZFViewExposure.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGExposureManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GGViewExposure)

@property (nonatomic) GGViewVisibleType showing;

+ (void)doSwizzleForGGViewExposure;

@end

NS_ASSUME_NONNULL_END
