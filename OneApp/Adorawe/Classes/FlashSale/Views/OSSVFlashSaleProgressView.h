//
//  OSSVFlashSaleProgressView.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/7.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlashSaleProgressView : UIView
@property (nonatomic, strong) UIView *progressBgV;
@property (nonatomic, strong) UIView *progressV;
@property (nonatomic, assign) float progress;
- (void)startProgressAnimation;

@end

NS_ASSUME_NONNULL_END
