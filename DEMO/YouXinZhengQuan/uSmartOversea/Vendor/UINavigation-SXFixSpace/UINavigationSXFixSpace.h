//
//  UINavigationSXFixSpace.h
//  UINavigation-SXFixSpace
//
//  Created by charles on 2019/7/26.
//  Copyright © 2018年 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationConfig : NSObject

//@property (nonatomic, assign) CGFloat sx_defaultFixSpace; //item距离两端的间距,默认为0
@property (nonatomic, assign) BOOL sx_disableFixSpace;    //是否禁止使用修正,默认为NO
@property (nonatomic, assign) CGFloat sx_defaultLeftFixSpace; //item距离左端的间距,默认为0
@property (nonatomic, assign) CGFloat sx_defaultRightFixSpace; //item距离右端的间距,默认为0


+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (CGFloat)sx_systemSpace;

@end

@interface UINavigationItem (SXFixSpace)

@end

@interface NSObject (SXFixSpace)

@end

