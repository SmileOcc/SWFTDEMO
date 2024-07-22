//
//  UIView+GGViewTracker.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ECommitTypeBoth,            ///合并
    ECommitTypeClick,           ///点击
    ECommitTypeExposure,        ///曝光
} ECommitType;

@interface UIView (GGViewTracker)

@property (nonatomic, strong) NSString *controlName;
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, assign) ECommitType  commitType;

@property (nonatomic, strong) NSString *minorControlName;
@end

NS_ASSUME_NONNULL_END
