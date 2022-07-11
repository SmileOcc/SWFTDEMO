//
//  OSSVTopSignInView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTopSignInView : UIView
@property (nonatomic, copy) void(^jumpIntoSignViewController)();
@end

NS_ASSUME_NONNULL_END
