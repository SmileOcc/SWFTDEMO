//
//  STLAlertMenuView.h
// XStarlinkProject
//
//  Created by odd on 2021/6/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,STLMenuArrowDirect) {
    /**上左*/
    STLMenuArrowDirectUpLeft,
    /**上右*/
    STLMenuArrowDirectUpRight,
    /**下左*/
    STLMenuArrowDirectDownLeft,
    /**下右*/
    STLMenuArrowDirectDownRight,
    
    /**左上*/
    STLMenuArrowDirectLeftUp,
    /**左下*/
    STLMenuArrowDirectLeftDown,
    /**右上*/
    STLMenuArrowDirectRightUp,
    /**右下*/
    STLMenuArrowDirectRightDown,
};

@interface STLAlertMenuView : UIView

/*
 * direct: 箭头方向
 * offset: 箭头【尖】距离设置方向的距离,
 * offset: < 0,居中
 */
- (instancetype)initTipArrowOffset:(CGFloat)offset
                            direct:(STLMenuArrowDirect)direct
                           images:(NSArray *)images
                           titles:(NSArray *)titles;

@property (nonatomic, copy) void(^selectBlock)(NSInteger index);

- (void)dismiss;

- (void)showSourceView:(UIView *)sourceView;

+ (CGRect)sourceViewFrameToWindow:(UIView *)sourceView;

+ (void)removeMenueView;
@end

NS_ASSUME_NONNULL_END
