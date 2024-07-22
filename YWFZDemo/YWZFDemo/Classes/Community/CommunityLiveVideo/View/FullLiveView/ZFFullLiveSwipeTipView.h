//
//  ZFFullLiveSwipeTipView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"

NS_ASSUME_NONNULL_BEGIN

#define kZFFullLiveSwipeTipViewTip @"kZFFullLiveSwipeTipViewTip"

@interface ZFFullLiveSwipeTipView : UIView

@property (nonatomic, strong) UIView              *contentView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UILabel             *messageLabel;


@end

NS_ASSUME_NONNULL_END
