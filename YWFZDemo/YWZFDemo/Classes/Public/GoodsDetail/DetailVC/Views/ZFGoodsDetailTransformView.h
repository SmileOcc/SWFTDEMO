//
//  ZFGoodsDetailTransformView.h
//  ZZZZZ
//
//  Created by YW on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBannerViewWidth                (316.0 + 4)
#define kBannerViewHeight               (420.0)
/**
 商品详情转场过度视图
 */
@interface ZFGoodsDetailTransformView : UIView

@property (nonatomic, copy) void(^tapPopHandle)(void);
@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, assign) BOOL          showZLoadng;

- (void)setHasFinishTransition;
- (void)startLoading;
- (void)endLoading;

@end
