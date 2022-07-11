//
//  YXTabView.h
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/29.
//  Copyright © 2018 ellison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTabLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class YXTabView;
@class YXPageView;

@protocol YXTabViewDelegate <NSObject>

@optional

- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling;
- (UIImage *)tabView:(YXTabView *)tabView imageForItemAtIndex:(NSUInteger)index;

@end

@interface YXTabView : UIView

@property (nonatomic, copy) NSArray<NSString *> *titles;

@property (nonatomic, assign) NSUInteger defaultSelectedIndex;

@property (nonatomic, assign, readonly) NSUInteger selectedIndex;

@property (nonatomic, strong) YXPageView *pageView;

@property (nonatomic, weak) id<YXTabViewDelegate>delegate;

@property (nonatomic, assign) BOOL needLayout;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

- (instancetype)initWithFrame:(CGRect)frame withLayout:(YXTabLayout *)layout;

- (void)reloadData;

- (void)selectTabAtIndex:(NSUInteger)index;
- (void)selectTabAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)reloadDataKeepOffset;

//展示index的badge
- (void)showBadgeAtIndex:(NSUInteger)index;

- (void)hideBadgeAtIndex:(NSUInteger)index;

// 展示下拉小箭头
- (void)showArrowImageAtIndexs:(NSArray<NSNumber *> *)indexs;
// 获取指定索引视图
- (UIView *)getArrowViewAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
