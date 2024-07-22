//
//  ZFExposureManager.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//       

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GGViewVisibleType){
    GGViewVisibleTypeUndefined = 0,
    GGViewVisibleTypeVisible,   //1
    GGViewVisibleTypeInvisible  //2
};


typedef enum : NSUInteger {
    GGViewTrackerAdjustTypeCALayerSetHidden = 0,
    GGViewTrackerAdjustTypeUIViewSetHidden,
    GGViewTrackerAdjustTypeUIViewSetAlpha,
    GGViewTrackerAdjustTypeUIViewDidMoveToWindow,
    GGViewTrackerAdjustTypeUIScrollViewSetContentOffset,
    GGViewTrackerAdjustTypeForceExposure
} GGViewTrackerAdjustType;


@interface GGExposureManager : NSObject

+ (void)commitPolymerInfoForAllPage;
+ (void)commitPolymerInfoForPage:(NSString*)page;

/**
 自动更新视图的曝光状态，并使用controlName设置标记视图
 
 如果视图没有controlName， 会遍历子视图并设置状态
 
 @param view  视图
 @param type  调用类型
 */
+ (void)adjustStateForView:(UIView *)view forType:(GGViewTrackerAdjustType)type;

/**
 通过controlName设置状态
 
 @param state newState
 @param view  given View
 */
+ (void)setState:(NSUInteger)state forView:(UIView *)view;

//call this method to set the stored index of control to zero.
// the timing is ,
// 1. when the destViewController called viewDidAppear:, new appear, should reset index
// 2. when the destViewController come back from Back, viewDidAppear: may not be called, here we should do it
// 3. when the destViewController will relayout according an url's response, life cycle cant catch it, should call it.
+ (void)resetPageIndexForPage:(NSString *)pageName;

@end

NS_ASSUME_NONNULL_END
