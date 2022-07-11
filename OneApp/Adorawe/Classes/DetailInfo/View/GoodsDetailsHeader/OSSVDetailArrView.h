//
//  OSSVDetailArrView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVDetailArrView : UIView

@property (nonatomic, strong) UIImageView *storeIcon; // 店铺图标

@property (nonatomic, strong) UIImageView *sizeIcon;
@property (nonatomic, strong) YYAnimatedImageView   *rightArrow;

- (void)setTitle:(NSString *)title isArrow:(BOOL)isArrow;

- (void)setAttributeTitle:(NSAttributedString *)title isArrow:(BOOL)isArrow;

- (void)setTitle:(NSString *)title sizeContent:(NSString *)content isArrow:(BOOL)isArrow;
@end
