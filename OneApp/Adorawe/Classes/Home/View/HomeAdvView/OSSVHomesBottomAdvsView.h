//
//  STLHomeBottomBannerView.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVHomesBottomAdvsView : UIView

@property (nonatomic, copy) BaseAdvViewBlock         advDoActionBlock;
@property (nonatomic, strong) OSSVAdvsEventsModel       *advEventModel;

- (void)show;
- (void)dismiss;
- (void)disMissWithBlock:(void(^)(void))disBlock;

@end

NS_ASSUME_NONNULL_END
