//
//  DropDownMenu.h
//  ListPageViewController
//
//  Created by YW on 2/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChooseCompletionHandler)(NSInteger tapIndex,BOOL isSelect);

@interface CategoryDropDownMenu : UIView

@property (nonatomic, strong) NSArray<NSString *>     *titles;

@property (nonatomic, copy) ChooseCompletionHandler   chooseCompletionHandler;

@property (nonatomic, assign) BOOL                    isDropAnimation;

@property (nonatomic, assign) BOOL                    isHideTopLine;
@property (nonatomic, assign) BOOL                    isHideBottomLine;
@property (nonatomic, assign) BOOL                    isHideSpaceLine;

/// 是否最后一个显示筛选
@property (nonatomic, assign) BOOL                    isLastFilter;


//无用
- (void)updateSelectInfoOptionWithApply:(BOOL)apply;

- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;
//无用
- (void)animateIndicatorWithIndex:(NSInteger)index;

/**
 * 重置箭头
 */
- (void)restoreIndicator:(NSInteger)index;

- (void)updateIndex:(NSInteger)index counts:(NSString *)counts;

- (void)updateIndex:(NSInteger)index title:(NSString *)title;

@end
