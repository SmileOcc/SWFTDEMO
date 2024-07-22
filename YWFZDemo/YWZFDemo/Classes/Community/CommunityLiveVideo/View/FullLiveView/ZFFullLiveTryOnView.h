//
//  ZFFullLiveTryOnView.h
//  ZZZZZ
//
//  Created by YW on 2020/1/2.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveTryOnView : UIView

@property (nonatomic, strong) UIImageView           *liveMarkImageView;
@property (nonatomic, strong) UILabel               *liveMarkTitleLabel;
@property (nonatomic, strong) UIImageView           *liveAnimationImageView;
@property (nonatomic, assign) BOOL                  isAnimate;


- (void)startLoading;
- (void)endLoading;
@end

NS_ASSUME_NONNULL_END
