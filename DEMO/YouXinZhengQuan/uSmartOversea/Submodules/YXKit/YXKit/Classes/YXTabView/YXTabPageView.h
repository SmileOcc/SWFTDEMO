//
//  YXTabPageView.h
//  ScrollViewDemo
//
//  Created by ellison on 2018/11/1.
//  Copyright © 2018 ellison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTabView.h"
#import "YXPageView.h"
#import "YXTabMainTableView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YXTabPageScrollBlock)(UIScrollView *scrollView);

@protocol YXTabPageScrollViewProtocol <NSObject>

@required
- (UIScrollView *)pageScrollView;
- (void)pageScrollViewDidScrollCallback:(YXTabPageScrollBlock)callback;

@end

@protocol YXTabPageViewDelegate <NSObject>

@optional
- (UIView *)headerViewInTabPage;
- (CGFloat)heightForHeaderViewInTabPage;
@required
- (YXTabView *)tabViewInTabPage;
- (CGFloat)heightForTabViewInTabPage;
- (YXPageView *)pageViewInTabPage;
- (CGFloat)heightForPageViewInTabPage;

@end

@interface YXTabPageView : UIView

@property (nonatomic, weak) id<YXTabPageViewDelegate> delegate;
@property (nonatomic, strong, readonly) YXTabMainTableView *mainTableView;

@property (nonatomic, weak, readonly) UIScrollView *currentScrollingView;

- (instancetype)initWithDelegate:(id<YXTabPageViewDelegate>)delegate;

- (void)reloadData;

- (void)scrollToTop;
@end

NS_ASSUME_NONNULL_END
