//
//  YXPageView.m
//  ScrollViewDemo
//
//  Created by ellison on 2018/10/8.
//  Copyright © 2018 ellison. All rights reserved.
//

#import "YXPageView.h"
#import <Masonry/Masonry.h>

@interface YXPageView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSUInteger targetIndex;

@property (nonatomic, strong, readwrite) UIScrollView *contentView;

@property (nonatomic, strong) NSCache *cachePages;

@end

@implementation YXPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _needLayout = YES;
        [self initializeData];
        [self initializeViews];
    }
    return self;
}

- (void)initializeData {
    _viewControllers = @[];
    _currentIndex = 0;
    _targetIndex = 0;
    
    _cachePages = [[NSCache alloc] init];
}

- (void)initializeViews {
    _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _contentView.pagingEnabled = YES;
    _contentView.delegate = self;
    _contentView.bounces = NO;
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        _contentView.contentInset = UIEdgeInsetsZero;
    }
    [self addSubview:_contentView];
}

- (void)reloadDataIfNeed {
    if (_needLayout) {
        _needLayout = NO;
        [self _reloadData];
    }
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    if (_viewControllers != nil && [viewControllers count] > 0) {
        [_viewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
        [[_contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    if (_currentIndex >= [viewControllers count]) {
        _currentIndex = [viewControllers count] - 1;
    }
    
    if (_targetIndex >= [viewControllers count]) {
        _targetIndex = [viewControllers count] - 1;
    }
    _viewControllers = viewControllers;
    _contentView.contentSize = CGSizeMake(_viewControllers.count * self.bounds.size.width, _contentView.contentSize.height);
}

- (void)_reloadData {
    _contentView.frame = self.bounds;
    _contentView.contentSize = CGSizeMake(_viewControllers.count * self.bounds.size.width, _contentView.contentSize.height);
    
    if (_currentIndex < _viewControllers.count) {
        UIViewController *currentViewController = _viewControllers[_currentIndex];
        if (!currentViewController.parentViewController) {
            [_parentViewController addChildViewController:currentViewController];
            [currentViewController didMoveToParentViewController:_parentViewController];
            [_contentView addSubview:currentViewController.view];
        }
//        else {
//            [currentViewController beginAppearanceTransition:YES animated:NO];
//        }
        currentViewController.view.frame = CGRectMake(_currentIndex * _contentView.bounds.size.width, 0, _contentView.bounds.size.width, _contentView.bounds.size.height);
    }
}

- (void)reloadData {
    [self _reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self reloadDataIfNeed];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat ratio = scrollView.contentOffset.x/scrollView.bounds.size.width;
    if (ratio > _viewControllers.count - 1 || ratio < 0) {
        return;
    }
    NSInteger baseIndex = floorf(ratio);
    CGFloat remainderRatio = ratio - baseIndex;

        if (remainderRatio > -CGFLOAT_MIN && remainderRatio < CGFLOAT_MIN) {

            NSUInteger targetIndex = baseIndex;
            
            if (_useCache) {
                UIView *cachePage = (UIView *)[_cachePages objectForKey:@(targetIndex)];
                if (cachePage.superview) {
                    [cachePage removeFromSuperview];
                }
            }

            UIViewController *targetController = _viewControllers[targetIndex];
            if (!targetController.parentViewController) {
                [_parentViewController addChildViewController:targetController];
                [targetController didMoveToParentViewController:_parentViewController];
                targetController.view.frame = CGRectMake(targetIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
                [_contentView addSubview:targetController.view];
            } else {
                if (_targetIndex != targetIndex) {
                    [targetController beginAppearanceTransition:YES animated:YES];
                    [targetController endAppearanceTransition];
                }
            }
            
            if (_targetIndex != targetIndex) {
                UIViewController *oldTargetController = _viewControllers[_targetIndex];
                UIView *cachePage = [oldTargetController.view snapshotViewAfterScreenUpdates:NO];
                cachePage.frame = oldTargetController.view.frame;

                [oldTargetController beginAppearanceTransition:NO animated:YES];
                [oldTargetController.view removeFromSuperview];
                [oldTargetController removeFromParentViewController];
                [oldTargetController endAppearanceTransition];
                
                if (_useCache && cachePage != nil) {
                    [_cachePages setObject:cachePage forKey:@(_targetIndex)];
                    [_contentView addSubview:cachePage];
                }
                
                _targetIndex = targetIndex;
                _currentIndex = targetIndex;
                
            } else if (_currentIndex != targetIndex) {
                UIViewController *currentController = _viewControllers[_currentIndex];
                UIView *cachePage = [currentController.view snapshotViewAfterScreenUpdates:NO];
                cachePage.frame = currentController.view.frame;

                [currentController.view removeFromSuperview];
                [currentController removeFromParentViewController];
                [currentController endAppearanceTransition];
                
                if (_useCache && cachePage != nil) {
                    [_cachePages setObject:cachePage forKey:@(_currentIndex)];
                    [_contentView addSubview:cachePage];
                }
                
                _currentIndex = targetIndex;
            }
        }else {
            if (fabs(ratio - _currentIndex) > CGFLOAT_MIN) {
                NSUInteger targetIndex = baseIndex;
                if (ratio > _currentIndex) {
                    targetIndex = baseIndex + 1;
                }
                
                if (_targetIndex != targetIndex) {
                    if (_useCache) {
                        UIView *cachePage = (UIView *)[_cachePages objectForKey:@(targetIndex)];
                         if (!cachePage.superview) {
                             cachePage.frame = CGRectMake(targetIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
                             [_contentView addSubview:cachePage];
                         }
                    } else {
                        UIViewController *targetController = _viewControllers[targetIndex];
                        //UIViewController *currentController = _viewControllers[_currentIndex];
                        
                        if (!targetController.parentViewController) {
                            [_parentViewController addChildViewController:targetController];
                            [targetController didMoveToParentViewController:_parentViewController];
                            targetController.view.frame = CGRectMake(targetIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
                            [_contentView addSubview:targetController.view];
                        } else {
                            [targetController beginAppearanceTransition:YES animated:YES];
                            [targetController endAppearanceTransition];
                        }
                    }

                    //[currentController beginAppearanceTransition:NO animated:YES];
                    _targetIndex = targetIndex;
                }
            }
        }
    
//    if (remainderRatio > -CGFLOAT_MIN && remainderRatio < CGFLOAT_MIN) {
//        NSUInteger targetIndex = baseIndex;
//
//        UIViewController *targetController = _viewControllers[targetIndex];
//        if (!targetController.parentViewController) {
//            [targetController willMoveToParentViewController:_parentViewController];
//            [_parentViewController addChildViewController:targetController];
//            [targetController didMoveToParentViewController:_parentViewController];
//            targetController.view.frame = CGRectMake(targetIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
//            [_contentView addSubview:targetController.view];
//        } else {
//            if (_targetIndex != targetIndex) {
//                [targetController beginAppearanceTransition:YES animated:YES];
//                [targetController endAppearanceTransition];
//            }
//        }
//
//        if (_targetIndex != targetIndex) {
//            UIViewController *oldTargetController = _viewControllers[_targetIndex];
////          [oldTargetController beginAppearanceTransition:NO animated:YES];
//            [oldTargetController.view removeFromSuperview];
//            [oldTargetController removeFromParentViewController];
//            [oldTargetController endAppearanceTransition];
//            _targetIndex = targetIndex;
//            _currentIndex = targetIndex;
//        } else if (_currentIndex != targetIndex) {
//            UIViewController *currentController = _viewControllers[_currentIndex];
//            [currentController.view removeFromSuperview];
//            [currentController removeFromParentViewController];
//            [currentController endAppearanceTransition];
//            _currentIndex = targetIndex;
//        }
//    }else {
//        if (fabs(ratio - _currentIndex) > CGFLOAT_MIN) {
//            NSUInteger targetIndex = baseIndex;
//            if (ratio > _currentIndex) {
//                targetIndex = baseIndex + 1;
//            }
//
//            if (_targetIndex != targetIndex) {
//                UIViewController *targetController = _viewControllers[targetIndex];
//                //UIViewController *currentController = _viewControllers[_currentIndex];
//                if (!targetController.parentViewController) {
//                    [targetController willMoveToParentViewController:_parentViewController];
//                    [_parentViewController addChildViewController:targetController];
//                    [targetController didMoveToParentViewController:_parentViewController];
//                    targetController.view.frame = CGRectMake(targetIndex * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
//                    [_contentView addSubview:targetController.view];
//                } else {
//                    [targetController beginAppearanceTransition:YES animated:YES];
//                    [targetController endAppearanceTransition];
//                }
//                //[currentController beginAppearanceTransition:NO animated:YES];
//                _targetIndex = targetIndex;
//            }
//        }
//    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
