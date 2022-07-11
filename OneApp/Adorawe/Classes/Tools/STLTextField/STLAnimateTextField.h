//
//  STLAnimateTextField.h
// XStarlinkProject
//
//  Created by odd on 2020/12/21.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLAnimateTextField : UITextField

// clear图标
@property (nonatomic, strong) UIImage *clearImage;
// 光标颜色
@property (nonatomic,strong) UIColor *cursorColor;

@property (nonatomic,strong) UIColor *placeholderNormalColor;

@property (nonatomic,strong) UIFont *placeholderAnimationFont;

@property (nonatomic,strong) UIFont *placeholderFont;

@property (nonatomic,assign) BOOL   isSecure;

@property (nonatomic,strong) UIButton   *rightButton;

///是否开启placeHold动画 默认为YES
@property (nonatomic,assign) BOOL enablePlaceHoldAnimation;

- (void)resetAnimation;

- (void)showPlaceholderAnimation;

@end

NS_ASSUME_NONNULL_END
