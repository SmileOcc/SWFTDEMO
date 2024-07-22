//
//  ZFShowOutfitButton.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZFShowOutfitButtonTransitionTypeCircle, // 格瓦拉转场效果
    ZFShowOutfitButtonTransitionTypeWave    // 波纹效果
} ZFShowOutfitButtonTransitionType;

@class ZFShowOutfitButton;
typedef void (^CompletionedAnimation)(ZFShowOutfitButton *_Nonnull);

@interface ZFShowOutfitButton : UIButton <CAAnimationDelegate>

@property (nonatomic, nonnull, copy) CompletionedAnimation  completionAnimation;

@property (nonatomic, assign) ZFShowOutfitButtonTransitionType transitionType;

- (instancetype)initWithBackImage:(NSString *__nonnull)backImage Image:(NSString *__nonnull)image Title:(NSString *__nonnull)title TransitionType:(ZFShowOutfitButtonTransitionType)type;

@end
