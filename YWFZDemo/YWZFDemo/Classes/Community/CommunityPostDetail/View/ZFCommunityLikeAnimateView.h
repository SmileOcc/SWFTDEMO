//
//  ZFCommunityLikeAminateView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLikeAnimateView : UIView

+ (instancetype)shareManager;

@property (nonatomic, assign) BOOL isAnimating;

- (void)showview:(UIView*)superView completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END