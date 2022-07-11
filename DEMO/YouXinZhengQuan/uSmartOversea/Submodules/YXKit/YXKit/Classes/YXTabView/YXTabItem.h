//
//  YXTabItem.h
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/30.
//  Copyright © 2018 ellison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXTabItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *titleSelectedColor;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIFont *titleSelectedFont;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) BOOL clipsToBounds;

@property (nonatomic, strong) UIColor *layerColor;
@property (nonatomic, assign) CGFloat layerWidth;
@property (nonatomic, strong) UIColor *layerSelectedColor;

@end

NS_ASSUME_NONNULL_END
