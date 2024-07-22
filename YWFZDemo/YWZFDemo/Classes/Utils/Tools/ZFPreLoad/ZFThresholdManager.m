//
//  ZFThresholdManager.m
//  ZHNThresholdHelper
//
//  Created by Tsang_Fa on 2018/3/27.
//  Copyright © 2018年 zhn. All rights reserved.
//

#import "ZFThresholdManager.h"

@interface ZFThresholdManager ()<UIScrollViewDelegate>


@end

@implementation ZFThresholdManager

- (instancetype)  initWithThreshold:(CGFloat)threshold
                    everyPageSize:(NSInteger)pageSize
                           contol:(id)control
                     scrollerView:(UIScrollView*)scrollerView
                     reloadAction:(reloadAction)reloadAction
{
    if (self = [super init]) {
        self.threshold = threshold;
        self.action = reloadAction;
        self.itemPerpage = pageSize;
        
        YJNSAspectOrientProgramming *aopdelegate = [[YJNSAspectOrientProgramming alloc] init];
        [aopdelegate addTarget:control];
        [aopdelegate addTarget:self];
        self.aopDelegate = aopdelegate;
        
        if ([scrollerView isKindOfClass:[UITableView class]]) {
            scrollerView.delegate =  (id<UITableViewDelegate>)aopdelegate;

        }else if ([scrollerView isKindOfClass:[UICollectionView class]]) {
            scrollerView.delegate = (id<UICollectionViewDelegate>)aopdelegate;
        }
        
    }
    return self;
}

- (instancetype)  initWithThreshold:(CGFloat)threshold
                      everyPageSize:(NSInteger)pageSize
                             contol:(id)control
                       scrollerView:(UIScrollView*)scrollerView
                       reloadAction:(reloadAction)reloadAction
                   DelegateRollBack:(BOOL)needDelegateRollBack
{
    if (self = [super init]) {
        self.threshold = threshold;
        self.action = reloadAction;
        self.itemPerpage = pageSize;
        
        YJNSAspectOrientProgramming *aopdelegate = [[YJNSAspectOrientProgramming alloc] init];
        [aopdelegate addTarget:control];
        [aopdelegate addTarget:self];
        self.aopDelegate = aopdelegate;
    }
    return self;
}
#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    CGFloat needRead = self.itemPerpage * self.threshold + self.currentPage * self.itemPerpage;
    CGFloat totalItem = self.itemPerpage * (self.currentPage + 1);
    CGFloat newThreshold = needRead / totalItem;
    
    if (ratio >= newThreshold && !self.isloading) {
        self.loading = true;
        self.currentPage += 1;
        if (self.action) {
            self.action();
        }
    }
}

- (void)endLoadDatas{
    self.loading = false;
}


@end
